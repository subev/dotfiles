-- Speaks Claude Code's last end-of-turn summary through tts.nvim.
--
-- The text does not come from the pane or from the transcript. A Stop hook
-- (bin/claude-speak-hook) writes the message the CLI hands it to a JSON record,
-- keyed by project directory and by the pane's slot name. Reading that back
-- avoids both the documented lag in the transcript file at Stop time and any
-- dependency on the transcript's internal format.
--
-- The directory layout here has to match the hook's byte for byte.
local M = {}

local function root()
  return vim.env.CLAUDE_SPEAK_DIR
    or vim.fs.joinpath(vim.fn.expand("~"), ".cache", "claude-speak")
end

-- Mirrors the hook's slug, after canonicalising the path. Without the realpath
-- both sides disagree about /tmp vs /private/tmp, which macOS uses
-- interchangeably and which shows up in real project paths here.
--
-- The 80-char prefix is legibility in `ls` and bounds the name so a deep path
-- cannot exceed NAME_MAX; the hash carries the uniqueness. Slash-substitution
-- alone is not injective -- /a/b and /a-b sanitise alike -- and two projects
-- sharing a directory would read each other's summary aloud, which is the one
-- thing the per-project keying exists to prevent.
local function slug(path)
  local real = vim.uv.fs_realpath(path) or path
  local prefix = (real:gsub("/", "-")):sub(1, 80)
  return ("%s-%s"):format(prefix, vim.fn.sha256(real):sub(1, 16))
end

--- Exposed so the spec can lay its fixtures out where `pick` will look for them.
--- @param path string
M.slug = slug

local function read_record(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok or type(lines) ~= "table" or #lines == 0 then
    return nil
  end
  local decoded, record = pcall(vim.json.decode, table.concat(lines, "\n"))
  -- `text` is the one field every record carries, and the one that tells a real
  -- record from JSON that merely decoded: [1,2,3] is a Lua table too, and a
  -- bare {}/null/number would otherwise pass a type() check and be spoken from.
  if not decoded or type(record) ~= "table" or type(record.text) ~= "string" then
    return nil
  end
  return record
end

local function age(ts)
  if type(ts) ~= "number" then
    return "age unknown"
  end
  local secs = os.time() - ts
  if secs < 90 then
    return "just now"
  elseif secs < 3600 then
    return ("%d min ago"):format(secs / 60)
  elseif secs < 86400 then
    return ("%d h ago"):format(secs / 3600)
  end
  return ("%d d ago"):format(secs / 86400)
end

--- Which recorded message to speak, and what to call its source.
---
--- Pure but for `read`, so tests drive it with a table of records.
--- @param slot string|nil  the pane's tool name, when we know it
--- @param cwd string|nil   the project directory to look under
--- @param read fun(path: string): table|nil  defaults to the filesystem
--- @return table|nil record, string|nil source
function M.pick(slot, cwd, read)
  read = read or read_record
  local base = root() .. "/" .. slug(cwd or vim.fn.getcwd())

  if slot and slot ~= "" then
    -- This pane's own record, or nothing. The project's latest is deliberately
    -- not tried here: several agents run side by side, so that file is some
    -- other pane's reply -- telling them apart is the entire reason the record
    -- carries a slot at all. An empty answer means this pane has not finished
    -- a turn since it started.
    return read(base .. "/" .. slot .. ".json"), slot
  end

  -- No pane to scope to -- a code buffer, or claude started outside sidekick --
  -- where the project's most recent turn is the best answer there is.
  local record = read(base .. "/latest.json")
  if record then
    return record, "latest in this project"
  end
end

--- Somewhere that proves the server is both up *and* the right build, or nil
--- when the active backend does not talk to it at all.
---
--- Not /health: it answers 200 without touching the model, so it proves the port
--- is held and nothing more. An older Spotter build's bundled copy answers
--- /health while having neither /v1/audio/speech nor /voices, so a liveness probe
--- passes and the synthesis then fails somewhere much less obvious.
---
--- The gate matters for `:TTSBackend macos`, which misc.lua's comment offers as
--- the fallback when the server is down: probing from the openai config anyway
--- would refuse to speak for the very reason macos was selected.
local function probe_url()
  if require("tts.backends").get_backend_name() ~= "openai" then
    return nil
  end

  local openai = require("tts.config").get().openai or {}
  local base = (openai.api_url or ""):match("^(.*)/v1/audio/speech$")
  return base and (base .. "/voices") or nil
end

--- Speak `record.text`, but check the server first.
---
--- tts.nvim's openai backend has no probe of its own, so a dead or wrong server
--- would otherwise surface as one curl error per sentence, or worse, as afplay
--- being handed an error page.
local function play(record)
  local url = probe_url()
  if not url then
    require("tts").play(record.text)
    return
  end

  vim.system({ "curl", "-s", "-m", "2", "-o", "/dev/null", "-w", "%{http_code}", url },
    { text = true }, function(result)
      vim.schedule(function()
        local code = vim.trim(result.stdout or "")
        if result.code ~= 0 or code == "" or code == "000" then
          vim.notify(
            "Speak out: no Kokoro server is answering.\n"
              .. "Start it with: launchctl kickstart -k gui/$UID/com.petur.kokoro-tts",
            vim.log.levels.ERROR
          )
        elseif code ~= "200" then
          vim.notify(
            ("Speak out: the server on that port has no %s (HTTP %s).\n"
              .. "That is normally an older Spotter build holding 8741; quitting "
              .. "Spotter lets the LaunchAgent bind."):format(url, code),
            vim.log.levels.ERROR
          )
        else
          require("tts").play(record.text)
        end
      end)
    end)
end

--- @param terminal table|nil the sidekick terminal the cursor is in, if any
function M.speak(terminal)
  local slot = terminal and terminal.tool and terminal.tool.name or nil
  local cwd = terminal and terminal.cwd or vim.fn.getcwd()
  local record, source = M.pick(slot, cwd, read_record)

  if not record then
    -- Name the pane, because with several agents running the usual cause is
    -- that this one has nothing yet while a sibling does -- and reaching for
    -- the sibling's reply is exactly what we no longer do.
    local where = slot and ("the %s pane"):format(slot) or "this project"
    vim.notify(("Speak out: nothing recorded for %s yet"):format(where), vim.log.levels.WARN)
    return
  end

  -- A turn that ended in a tool call has no message. The record says so rather
  -- than being skipped, so this is a real answer and not a replay.
  if record.text == "" then
    vim.notify("Speak out: Claude's last turn had nothing to say", vim.log.levels.INFO)
    return
  end

  -- Quiet when it is the pane you were just looking at -- the audio is the
  -- feedback. The fallback can be an older turn, where the age is the only
  -- honest signal, and speaking it silently would be worse.
  if source ~= slot then
    vim.notify(("Speak out: %s, %s"):format(source, age(record.ts)), vim.log.levels.INFO)
  end

  play(record)
end

function M.setup()
  -- Terminal-Normal mode is Normal mode as far as mappings are concerned, so
  -- this one key covers a code buffer and a pane you have left with <C-q>.
  vim.keymap.set({ "n", "v" }, "<leader>tS", function()
    M.speak(require("config.sidekick_term").from_win(vim.api.nvim_get_current_win()))
  end, { desc = "TTS: Speak Claude's last summary" })
end

return M
