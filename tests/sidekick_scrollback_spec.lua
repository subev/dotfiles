vim.opt.rtp:prepend(vim.fn.getcwd() .. "/nvim")
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/sidekick.nvim")

local configure
for _, plugin in ipairs(dofile("nvim/lua/plugins/ai.lua")) do
  if plugin[1] == "folke/sidekick.nvim" then
    configure = plugin.opts.cli.win.config
  end
end

local config = require("sidekick.config")
local scrollback = require("sidekick.cli.scrollback")
local layout = vim.fn.tempname()
local state, system = config.state, vim.system
config.state = function()
  return layout
end
vim.fn.writefile({ "layout { pane { close_on_exit true; } }" }, layout)

local output = "\27[31mold output\27[0m\n\ncurrent output\n"
local failed = false
vim.system = function(cmd, opts)
  assert(vim.deep_equal(cmd, {
    "zellij",
    "-s",
    "codex test session",
    "action",
    "dump-screen",
    "--full",
    "--ansi",
  }))
  assert(opts.timeout == 3000)
  return {
    wait = function()
      return { code = failed and 1 or 0, stdout = output, stderr = "" }
    end,
  }
end

local ok, err = pcall(function()
  local terminal = {
    tool = { name = "codex" },
    mux_backend = "zellij",
    parent = { sid = "codex test session" },
    opts = { wo = { wrap = false } },
    group = vim.api.nvim_create_augroup("SidekickScrollbackTest", { clear = true }),
  }
  assert(not scrollback.is_enabled(terminal))
  configure(terminal)
  assert(scrollback.is_enabled(terminal), "Codex must enable Sidekick history")
  assert(terminal.parent:dump() == output, "ANSI styling and blank lines must survive")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { string.rep("history ", 40) })
  vim.wo.wrap = terminal.opts.wo.wrap
  vim.cmd("normal! 20zl")
  assert(vim.fn.winsaveview().leftcol == 0, "history must not scroll past the start of lines")
  vim.api.nvim_buf_delete(buf, { force = true })
  buf = vim.api.nvim_create_buf(false, true)
  vim.cmd("botright 10split")
  terminal.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(terminal.win, buf)
  terminal.scrollback = {
    is_open = function()
      return vim.api.nvim_win_get_buf(terminal.win) == buf
    end,
  }
  vim.wo.wrap = terminal.opts.wo.wrap
  vim.wo.scrolloff = 0
  local lines = {}
  for i = 1, 100 do
    lines[i] = "history " .. i
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.cmd("normal! Gzt")
  vim.api.nvim_exec_autocmds("WinScrolled", {})
  assert(vim.fn.winsaveview().topline == 91, "scrolling must stop with the final line at the bottom")
  assert(vim.fn.line(".") == 100, "clamping must preserve the cursor")
  vim.fn.winrestview({ topline = 40, lnum = 45 })
  vim.api.nvim_exec_autocmds("WinScrolled", {})
  assert(vim.fn.winsaveview().topline == 40, "older history must remain freely scrollable")
  for i = 96, 100 do
    lines[i] = string.rep("x", vim.api.nvim_win_get_width(terminal.win) + 3)
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.cmd("normal! Gzt")
  vim.api.nvim_exec_autocmds("WinScrolled", {})
  assert(vim.fn.winsaveview().topline == 96, "bottom limit must count wrapped screen rows")
  vim.api.nvim_win_set_height(terminal.win, 12)
  vim.api.nvim_exec_autocmds("WinScrolled", {})
  assert(vim.fn.winsaveview().topline == 94, "resizing must keep the bottom filled")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "short", "history" })
  vim.cmd("normal! Gzt")
  vim.api.nvim_exec_autocmds("WinScrolled", {})
  assert(vim.fn.winsaveview().topline == 1, "short history must stay at the top")
  local live = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(terminal.win, live)
  vim.api.nvim_buf_set_lines(live, 0, -1, false, lines)
  vim.cmd("normal! Gzt")
  local live_view = vim.fn.winsaveview()
  vim.api.nvim_exec_autocmds("WinScrolled", {})
  assert(vim.deep_equal(vim.fn.winsaveview(), live_view), "the live terminal view must be untouched")
  vim.api.nvim_win_close(terminal.win, true)
  vim.api.nvim_buf_delete(live, { force = true })
  vim.api.nvim_buf_delete(buf, { force = true })
  vim.api.nvim_del_augroup_by_id(terminal.group)
  terminal.parent.mux_session = terminal.parent.sid
  terminal.parent.sid = "different derived id"
  assert(terminal.parent:dump() == output, "reattached sessions must use their actual name")
  failed = true
  local notify = vim.notify
  local notified = false
  vim.notify = function()
    notified = true
  end
  local result = terminal.parent:dump()
  assert(vim.wait(1000, function()
    return notified
  end))
  vim.notify = notify
  assert(result == nil, "failed exports must not replace the live buffer")
  for _, other in ipairs({
    { tool = { name = "claude" }, mux_backend = "zellij", parent = {} },
    { tool = { name = "codex" }, mux_backend = "tmux", parent = {} },
  }) do
    configure(other)
    assert(other.parent.dump == nil)
  end
end)

config.state, vim.system = state, system
vim.fn.delete(layout)
assert(ok, err)
print("PASS: Codex history export, scroll boundaries, session targeting, and failure fallback")
