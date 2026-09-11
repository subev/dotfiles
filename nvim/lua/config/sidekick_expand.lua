-- Claude's TUI expands collapsed tool output and thinking on Ctrl+O, which is a
-- global toggle: nothing is expandable by clicking, and the collapsed text is
-- not in the buffer. Relay the chord into the pane that owns it instead.
local M = {}

-- The chord itself: Claude renders the hint from its own bindings, and the
-- trailing words differ per entry ("to expand", "to toggle", "for history").
-- A narrow pane can wrap the hint, so only this short token is safe to match.
local HINT = "ctrl+o"
-- Zellij's `action write` takes bytes as decimal numbers.
local CTRL_O = 15

--- Is the token present at this 0-based column?
---@param text string
---@param col integer
---@return boolean
local function token_at(text, col)
  local from = 1
  while true do
    local start = text:find(HINT, from, true)
    if not start then
      return false
    end
    if col >= start - 1 and col < start - 1 + #HINT then
      return true
    end
    from = start + #HINT
  end
end

--- The hint is rendered at the end of a line. It is only matched on the row the
--- click landed on: rebuilding a wrapped line from its neighbours costs far more
--- in false positives than it buys, since the token is short enough to survive
--- any realistic pane width on one row.
---@param buf integer
---@param row integer 1-based buffer row
---@param col integer 1-based clicked column
---@return boolean
function M.hint_at(buf, row, col)
  local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ""
  return token_at(line, col - 1)
end

local terminal = require("config.sidekick_term").from_win

---@param term sidekick.cli.Terminal
---@return boolean handled
function M.expand(term)
  -- Only Zellij can be written into this way. On any other mux backend the chord
  -- is not ours to relay, and reporting a failure on every click is noise the
  -- user cannot act on -- so decline, and let the click fall through.
  if term.mux_backend ~= "zellij" then
    return false
  end
  local session = term.mux_session or term.sid
  if not session then
    return false
  end
  vim.system(
    { "zellij", "-s", session, "action", "write", tostring(CTRL_O) },
    -- Without a timeout a wedged client keeps the child alive for the session and
    -- the exit callback never fires, so nothing ever reports the failure.
    { text = true, timeout = 3000 },
    function(result)
      if result.code ~= 0 then
        vim.schedule(function()
          vim.notify(("Could not expand: %s"):format(result.stderr or "zellij write failed"), vim.log.levels.WARN)
        end)
      end
    end
  )
  return true
end

--- Handle a click in the terminal buffer.
---@param buf integer
---@param win integer
---@return boolean handled
function M.click(buf, win)
  local term = terminal(win)
  if not term then
    return false
  end
  -- A mapping that raises breaks every click in the buffer, so any failure
  -- below just means "not ours".
  local ok, handled = pcall(function()
    local pos = vim.fn.getmousepos()
    -- `line` is the buffer line under the pointer; it is only zeroed when the
    -- mouse is outside the editor, and there is no topline field to combine
    -- it with. Neovim has already moved the cursor onto the click by now.
    local row = pos.line and pos.line > 0 and pos.line or vim.fn.line(".")
    local col = pos.column or vim.api.nvim_win_get_cursor(win)[2] + 1
    if not M.hint_at(buf, row, col) then
      return false
    end
    return M.expand(term)
  end)
  return ok and handled == true
end

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("SidekickExpand", { clear = true }),
    pattern = "sidekick_terminal",
    callback = function(ev)
      for _, mode in ipairs({ "n", "t" }) do
        vim.keymap.set(mode, "<LeftMouse>", function()
          -- Resolve win and buf before the click finishes moving the cursor.
          local win = vim.api.nvim_get_current_win()
          if not M.click(vim.api.nvim_get_current_buf(), win) then
            vim.api.nvim_feedkeys(vim.keycode("<LeftMouse>"), "n", false)
            return
          end
          -- Keeping the pane focused is the point: the expansion is what you
          -- want to read next.
          if vim.fn.mode() ~= "t" then
            vim.cmd.startinsert()
          end
        end, { buffer = ev.buf, desc = "Expand Sidekick transcript" })
      end
    end,
  })
end

return M
