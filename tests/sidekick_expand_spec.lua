vim.opt.rtp:prepend(vim.fn.getcwd() .. "/nvim")
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/sidekick.nvim")

local expand = require("config.sidekick_expand")

local failed = false
local function check(ok, msg)
  if not ok then
    failed = true
    io.stderr:write("FAIL: " .. msg .. "\n")
  end
end

local system, captured, opts_seen = vim.system, {}, {}
vim.system = function(cmd, opts, on_exit)
  captured[#captured + 1] = cmd
  opts_seen[#opts_seen + 1] = opts
  if on_exit then
    on_exit({ code = 0, stdout = "", stderr = "" })
  end
  return { wait = function() return { code = 0 } end }
end

local terminal = require("sidekick.cli.terminal")
local fake = setmetatable({ sid = "claude 0123456789abcdef", mux_backend = "zellij" }, { __index = terminal })
terminal.get = function()
  return fake
end

local win = vim.api.nvim_get_current_win()
local buf = vim.api.nvim_get_current_buf()
vim.w[win].sidekick_session_id = "test"
vim.keymap.set({ "n", "t" }, "<C-LeftMouse>", function() end, { buffer = buf })

local mouse = vim.fn.getmousepos
---@param row integer 1-based buffer row under the pointer
---@param col integer 1-based column
local function click_at(row, col)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "  Thought for 6s (ctrl+o to expand)" })
  vim.fn.getmousepos = function()
    return { winid = win, line = row, column = col }
  end
  return expand.click(buf, win)
end

local RELAY = { "zellij", "-s", "claude 0123456789abcdef", "action", "write", "15" }

-- A click on the hint relays Ctrl+O (byte 15) to the Zellij session.
captured, opts_seen = {}, {}
check(click_at(1, 20) == true, "hint click is handled")
check(#captured == 1, "one relay for the hint click")
check(captured[1] and vim.deep_equal(captured[1], RELAY), "relay command")
check(opts_seen[1] and opts_seen[1].timeout, "the relay must time out, or a wedged client leaks a child")

-- A pane on another mux backend cannot be relayed into at all: the chord is not
-- ours to send, so the click has to fall through rather than be swallowed by a
-- handler that could never have acted.
captured = {}
fake.mux_backend = "tmux"
check(click_at(1, 20) == false, "a non-Zellij pane is not handled")
check(#captured == 0, "no relay outside Zellij")
fake.mux_backend = "zellij"

-- The trailing "+N lines" form carries the same hint text.
captured = {}
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "  ... +28 lines (ctrl+o to expand)" })
vim.fn.getmousepos = function()
  return { winid = win, line = 1, column = 18 }
end
check(expand.click(buf, win) == true, "ellipsis hint is handled")
check(#captured == 1, "ellipsis relay count")

-- Clicks off the hint must fall through to Neovim's own mouse handling.
captured = {}
check(click_at(1, 3) == false, "click before the hint is not handled")
check(#captured == 0, "no relay before the hint")

captured = {}
check(click_at(1, 36) == false, "click after the hint is not handled")
check(#captured == 0, "no relay after the hint")

captured = {}
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "  Read the file and reported back" })
vim.fn.getmousepos = function()
  return { winid = win, line = 1, column = 10 }
end
check(expand.click(buf, win) == false, "plain output is not handled")
check(#captured == 0, "no relay for plain output")

-- The pointer's `line` is a buffer line, so a hint further down the buffer is
-- found, while a click on a row without one is not.
captured = {}
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "line one", "line two", "  Thought for 6s (ctrl+o to expand)" })
vim.fn.getmousepos = function()
  return { winid = win, line = 3, column = 20 }
end
check(expand.click(buf, win) == true, "hint is found on its own buffer row")

captured = {}
vim.fn.getmousepos = function()
  return { winid = win, line = 1, column = 20 }
end
check(expand.click(buf, win) == false, "click on an earlier row is not handled")
check(#captured == 0, "no relay from an earlier row")

-- getmousepos() does not always carry every field; a mapping that throws makes
-- every click in the pane an error, so a short table must never raise.
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "  Thought for 6s (ctrl+o to expand)" })
for _, pos in ipairs({
  { winid = win, line = 1, column = 20, screenrow = 5 },
  { winid = win, line = 1, column = 20 },
  { winid = win },
  {},
}) do
  vim.fn.getmousepos = function()
    return pos
  end
  local ok = pcall(expand.click, buf, win)
  check(ok, ("short getmousepos result does not raise: %s"):format(vim.inspect(pos)))
end

-- Claude renders the chord into several different sentences; matching the
-- trailing words instead of the chord is what broke clicking in a narrow pane.
captured = {}
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "  Showing detailed transcript · ctrl+o to toggle" })
vim.fn.getmousepos = function()
  return { winid = win, line = 1, column = 37 }
end
check(expand.click(buf, win) == true, "transcript footer hint is handled")
check(#captured == 1, "relay for the footer hint")

-- Rows that follow a full-width row are ordinary wrapped output, not the hint.
-- Rebuilding wrapped lines was tried and removed: it reported a hit on plain
-- prose, which is worse than missing a token that a wrap split in two.
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { string.rep("x", 24), "wrapped prose here" })
check(not expand.hint_at(buf, 2, 1), "plain wrapped prose is not the hint")

-- The hint is matched only on the clicked row, whatever the pane width.
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { string.rep("x", 24), "o to expand)" })
check(not expand.hint_at(buf, 2, 1), "a continuation row alone is not the hint")
-- A wrapped continuation of the token is not matched; only the row that carries
-- the full token is. This is a deliberate limit, see M.hint_at.
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "short line", "o to expand" })
check(not expand.hint_at(buf, 2, 1), "a bare continuation row is not the hint")

-- Non-sidekick windows are left alone even on a hint-looking line.
captured = {}
vim.w[win].sidekick_session_id = nil
check(click_at(1, 20) == false, "non-sidekick window is not handled")
check(#captured == 0, "no relay outside a sidekick window")
vim.w[win].sidekick_session_id = "test"

-- The mapping is buffer-local and covers normal and terminal mode.
expand.setup()
vim.bo[buf].filetype = "sidekick_terminal"
vim.api.nvim_exec_autocmds("FileType", { buffer = buf })
for _, mode in ipairs({ "n", "t" }) do
  check(vim.fn.maparg("<LeftMouse>", mode, false, true).lhs ~= nil, ("map in mode %s"):format(mode))
end

vim.fn.getmousepos = mouse
vim.system = system

if failed then
  os.exit(1)
end
print("sidekick_expand: ok")
