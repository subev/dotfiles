-- Covers the <C-n> cycle over the agents in the current directory: the ring, the
-- swap that keeps one pane on screen, landing ready to type, and the Zellij
-- keybind clearing that stops agent panes swallowing Ctrl keys.
vim.opt.rtp:prepend(vim.fn.getcwd() .. "/nvim")
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/sidekick.nvim")

local spec
for _, plugin in ipairs(dofile("nvim/lua/plugins/ai.lua")) do
  if plugin[1] == "folke/sidekick.nvim" then
    spec = plugin
  end
end

local keys = spec.opts.cli.win.keys
local configure = spec.opts.cli.win.config

assert(keys.next_agent, "<C-n> must cycle to the next agent")
assert(keys.next_agent[1] == "<c-n>", "<C-n> is the key that reaches Sidekick unclaimed")
assert(keys.next_agent.mode == "tn", "cycling must work from terminal and normal mode")
assert(keys.prompt == nil, "the prompt picker must keep <C-p>")
assert(keys.nav_left == nil and keys.nav_right == nil, "window navigation must keep <C-h> and <C-l>")

local config = require("sidekick.config")
local real_state = config.state
local layout = vim.fn.tempname()
config.state = function()
  return layout
end

local function write_layout()
  vim.fn.writefile({
    "layout {",
    '    pane command="claude" {',
    "      close_on_exit true",
    "   }",
    "}",
    "session_serialization false",
  }, layout)
end

local function count(lines, needle)
  return #vim.tbl_filter(function(line)
    return line:find(needle, 1, true) ~= nil
  end, lines)
end

local ok, err = pcall(function()
  write_layout()
  local claude = {
    tool = { name = "claude" },
    mux_backend = "zellij",
    parent = { sid = "claude test session" },
    opts = { wo = {} },
  }
  configure(claude)
  local lines = vim.fn.readfile(layout)
  assert(lines[#lines] == "keybinds clear-defaults=true {}", "agent panes must clear Zellij keybinds")
  assert(count(lines, "close_on_exit true") == 1, "claude must keep close_on_exit")
  configure(claude)
  assert(count(vim.fn.readfile(layout), "keybinds clear-defaults=true {}") == 1, "the clearing must not stack")

  write_layout()
  local codex = {
    tool = { name = "codex" },
    mux_backend = "zellij",
    parent = { sid = "codex test session" },
    opts = { wo = { wrap = false } },
    group = vim.api.nvim_create_augroup("SidekickAgentsTest", { clear = true }),
  }
  configure(codex)
  lines = vim.fn.readfile(layout)
  assert(lines[#lines] == "keybinds clear-defaults=true {}", "codex must clear Zellij keybinds too")
  assert(count(lines, "close_on_exit false") == 1, "codex must let Zellij hold its final output")
  assert(require("sidekick.cli.scrollback").is_enabled(codex), "codex must keep its history export")
  vim.api.nvim_del_augroup_by_id(codex.group)

  write_layout()
  local untouched = vim.fn.readfile(layout)
  for _, other in ipairs({
    { tool = { name = "claude" }, mux_backend = "tmux", parent = {}, opts = { wo = {} } },
    { tool = { name = "claude" }, parent = {}, opts = { wo = {} } },
  }) do
    configure(other)
    assert(vim.deep_equal(vim.fn.readfile(layout), untouched), "only Zellij sessions rewrite the layout")
  end

  local State = require("sidekick.cli.state")
  local get, attach = State.get, State.attach
  local select = require("sidekick.cli.ui.select")
  local picker = select.select
  local agents = {
    { tool = { name = "claude_ds" } },
    { tool = { name = "claude_2" } },
    { tool = { name = "claude" } },
  }
  State.get = function()
    return vim.deepcopy(agents)
  end
  local cycled, opts, landed
  State.attach = function(state, o)
    cycled, opts = state.tool.name, o
    return { terminal = landed }
  end
  -- Cycling is Ctrl-Tab, not Ctrl-P: reaching for the picker means the target
  -- was filtered by tool name, which also matches other directories.
  select.select = function()
    error("cycling must attach its target, never open the picker")
  end

  local cycle = keys.next_agent[2]
  cycle({ tool = { name = "claude" } })
  assert(cycled == "claude_2", "cycling must follow slot order, not the order the filter returned")
  cycle({ tool = { name = "claude_2" } })
  assert(cycled == "claude_ds", "claude_ds must follow claude_2")
  cycle({ tool = { name = "claude_ds" } })
  assert(cycled == "claude", "the ring must wrap")
  assert(opts.show and opts.focus, "the cycled agent must be shown and focused")

  -- Arriving ready to type: a pane that was last left in normal mode must not
  -- restore it, and the cursor must land in it once the main loop settles.
  -- Hiding the pane we came from leaves a pending `:stopinsert` that Neovim only
  -- applies then, so the focus has to happen after it -- a real terminal mode is
  -- not observable from a headless script, which is why this asserts the cursor.
  vim.cmd("belowright split")
  landed = {
    normal_mode = true,
    win = vim.api.nvim_get_current_win(),
    is_running = function()
      return true
    end,
  }
  vim.cmd("wincmd p")
  cycled = nil
  cycle({ tool = { name = "claude" } })
  assert(landed.normal_mode == false, "the cycled pane must not restore normal mode")
  vim.wait(1000, function()
    return vim.api.nvim_get_current_win() == landed.win
  end)
  assert(vim.api.nvim_get_current_win() == landed.win, "the cycled pane must take the cursor")
  landed = nil

  -- Cycling swaps rather than stacks: whatever agent panes are open make way
  -- for the one being cycled to, so the screen never accumulates panes.
  local Terminal = require("sidekick.cli.terminal")
  local get_terminal = Terminal.get
  local hidden = {}
  Terminal.get = function(id)
    return {
      hide = function()
        hidden[#hidden + 1] = id
      end,
    }
  end
  for i = 1, 2 do
    vim.cmd("belowright split")
    vim.w[vim.api.nvim_get_current_win()].sidekick_session_id = "terminal: agent" .. i
  end
  cycled = nil
  cycle({ tool = { name = "claude" } })
  assert(#hidden == 2, "every open agent pane must be hidden so the next one takes its place")
  assert(cycled == "claude_2", "hiding panes must not disturb which agent is cycled to")
  Terminal.get = get_terminal

  State.get = function()
    return { { tool = { name = "claude" } } }
  end
  cycled = nil
  local notify, notified = vim.notify, false
  vim.notify = function()
    notified = true
  end
  cycle({ tool = { name = "claude" } })
  vim.notify = notify
  assert(notified, "a lone agent must say there is nowhere to go")
  assert(cycled == nil, "a lone agent must not be re-attached")

  State.get, State.attach, select.select = get, attach, picker
end)

config.state = real_state
vim.fn.delete(layout)
assert(ok, err)
print("PASS: <C-n> agent ring, slot ordering, and Zellij keybind clearing")
