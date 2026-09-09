-- Run from the dotfiles root:
-- nvim --headless -u NONE -i NONE -n -l tests/navigation_spec.lua
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.o.lines = 80
vim.o.hidden = true
vim.o.swapfile = false
local links = require("config.sidekick_links")
local workspace = require("config.workspace_info")
local root = vim.fn.tempname()
vim.fn.mkdir(root .. "/packages/server/src/lib", "p")
root = vim.uv.fs_realpath(root)
local target = root .. "/packages/server/src/lib/cartesia.ts"
local content = {}
for i = 1, 180 do
  content[i] = "const line" .. i .. " = " .. i .. ";"
end
vim.fn.writefile(content, target)
local function resolve(ref, cwd)
  local result
  links.resolve(ref, cwd, function(matches)
    result = matches
  end)
  assert(
    vim.wait(4000, function()
      return result ~= nil
    end),
    "resolution timed out"
  )
  return result
end
local passed = 0
local function test(name, fn)
  local ok, err = pcall(fn)
  if not ok then
    print("FAIL: " .. name .. ": " .. tostring(err))
    vim.fn.delete(root, "rf")
    vim.cmd("cquit 1")
  end
  passed = passed + 1
  print("PASS: " .. name)
end

test("line ranges, columns, Unicode punctuation, and file URIs", function()
  for _, text in ipairs({
    "src/test.ts:105-141.",
    "src/test.ts:105–141",
    "src/test.ts:105—141",
    "src/test.ts#L105-L141",
  }) do
    assert(vim.deep_equal(links.parse(text), { path = "src/test.ts", line = 105, last = 141, col = 1 }))
  end
  assert(links.parse("src/test.ts:55:7:").col == 7)
  assert(links.parse("@src/test.ts#L55").line == 55)
  assert(links.parse("file:///tmp/my%20file.ts:3").path == "/tmp/my file.ts")
  assert(links.parse("src/данни–test.ts:3–5").path == "src/данни–test.ts")
  assert(not links.parse("https://example.com/test.ts:2"))
  assert(not links.parse("src/test.ts:0"))
  assert(not links.parse("src/test.ts:9-2"))
end)

test("resolve session-relative paths and detect ambiguous basenames", function()
  assert(vim.deep_equal(resolve(links.parse("packages/server/src/lib/cartesia.ts:105"), root), { target }))
  assert(vim.deep_equal(resolve(links.parse("cartesia.ts:105"), root), { target }))
  vim.fn.mkdir(root .. "/other", "p")
  vim.fn.writefile(content, root .. "/other/cartesia.ts")
  assert(#resolve(links.parse("cartesia.ts:105"), root) == 2)
  assert(#resolve(links.parse("missing.ts:105"), root) == 0)
  assert(vim.fn.filereadable(root .. "/missing.ts") == 0)
end)

test("missing ripgrep does not throw", function()
  local saved = vim.env.PATH
  vim.env.PATH = root
  local ok, result = pcall(resolve, links.parse("missing.ts:1"), root)
  vim.env.PATH = saved
  assert(ok, tostring(result))
end)

test("one asynchronous search resolves wrapped alternatives without blocking events", function()
  local system, calls, completed, tick = vim.system, 0, false, false
  vim.system = function(_, opts, callback)
    calls = calls + 1
    assert(opts.timeout == 3000 and callback)
    vim.defer_fn(function()
      callback({ code = 0, stdout = "packages/server/src/lib/cartesia.ts\n" })
    end, 20)
    return {}
  end
  local ref = links.parse("wrong/cartesia.ts:105")
  ref.alternative = links.parse("cartesia.ts:105")
  links.resolve(ref, root, function(matches, resolved)
    assert(matches[1] == target and resolved == ref.alternative)
    completed = true
  end)
  vim.system = system
  assert(not completed)
  vim.schedule(function()
    tick = true
  end)
  assert(vim.wait(1000, function()
    return completed
  end))
  assert(tick and calls == 1)
end)

test("a process spawn failure is reported through the resolver", function()
  local system, result, message = vim.system
  vim.system = function()
    error("spawn failed")
  end
  links.resolve(links.parse("missing.ts:1"), root, function(matches, _, err)
    result, message = matches, err
  end)
  vim.system = system
  assert(#result == 0 and message:find("spawn failed", 1, true))
end)

local source, original
test("gf reuses the code window and preserves unsaved text", function()
  vim.cmd.edit(root .. "/original.ts")
  original = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(original, 0, -1, false, { "unsaved original" })
  links.setup()
  vim.cmd.vsplit()
  vim.cmd.enew()
  source = vim.api.nvim_get_current_win()
  vim.bo.buftype = "nofile"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "See packages/server/src/lib/cartesia.ts:105–141." })
  vim.api.nvim_win_set_cursor(source, { 1, 40 }) -- on the range, not just the filename
  links.gf({ cwd = root })
  assert(vim.api.nvim_buf_get_name(0) == target)
  assert(vim.api.nvim_win_get_cursor(0)[1] == 105)
  assert(#vim.api.nvim_tabpage_list_wins(0) == 2)
  assert(vim.bo[original].modified)
  assert(vim.api.nvim_buf_get_lines(original, 0, -1, false)[1] == "unsaved original")
  local marks = vim.api.nvim_buf_get_extmarks(
    0,
    vim.api.nvim_create_namespace("sidekick_file_reference"),
    0,
    -1,
    { details = true }
  )
  assert(#marks == 1 and marks[1][2] == 104 and marks[1][4].end_row == 141)
  vim.api.nvim_win_set_cursor(0, { 106, 0 })
  vim.api.nvim_exec_autocmds("CursorMoved", { buffer = vim.api.nvim_get_current_buf() })
  assert(#vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace("sidekick_file_reference"), 0, -1, {}) == 0)
end)

test("quoted paths with spaces and Ex metacharacters are opened literally", function()
  local path = root .. "/odd | name.ts"
  vim.fn.writefile({ "first", "second", "third" }, path)
  vim.api.nvim_set_current_win(source)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'See "odd | name.ts:2-3".' })
  vim.api.nvim_win_set_cursor(source, { 1, 12 })
  links.gf({ cwd = root })
  assert(vim.api.nvim_buf_get_name(0) == path)
  assert(vim.api.nvim_win_get_cursor(0)[1] == 2)
end)

test("bare files do not pretend that line one was cited", function()
  links.open(target, links.parse("cartesia.ts"), source)
  local marks = vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace("sidekick_file_reference"), 0, -1, {})
  assert(#marks == 0)
end)

test("references align with scrolloff and create a code window when needed", function()
  vim.cmd.tabnew()
  vim.bo.buftype = "nofile"
  vim.wo.wrap = false
  local origin = vim.api.nvim_get_current_win()
  vim.o.scrolloff = 20
  links.open(target, links.parse("cartesia.ts:105-141"), origin)
  vim.cmd.redraw()
  assert(#vim.api.nvim_tabpage_list_wins(0) == 2)
  assert(vim.fn.line("w0") == 85 and vim.fn.line(".") == 105, vim.inspect(vim.fn.winsaveview()))
  links.open(target, links.parse("cartesia.ts:180-200"), origin)
  local marks = vim.api.nvim_buf_get_extmarks(
    0,
    vim.api.nvim_create_namespace("sidekick_file_reference"),
    0,
    -1,
    { details = true }
  )
  assert(marks[1][4].end_row == 180)
  vim.cmd("tabclose!")
  vim.o.scrolloff = 0
end)

test("a lost click release does not swallow the next unrelated release", function()
  vim.api.nvim_set_current_win(source)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "packages/server/src/lib/cartesia.ts:55" })
  local mouse, feed, terminal = vim.fn.getmousepos, vim.api.nvim_feedkeys, package.loaded["sidekick.cli.terminal"]
  local sent = {}
  vim.w[source].sidekick_session_id = "test"
  package.loaded["sidekick.cli.terminal"] = {
    get = function()
      return { cwd = root }
    end,
  }
  vim.fn.getmousepos = function()
    return { winid = source, line = 1, column = 10 }
  end
  vim.api.nvim_feedkeys = function(key)
    sent[#sent + 1] = key
  end
  links.mouse()
  vim.fn.getmousepos = function()
    return { winid = 0 }
  end
  links.mouse()
  for _, mapping in ipairs(vim.api.nvim_get_keymap("n")) do
    if mapping.lhs == "<C-LeftRelease>" then
      mapping.callback()
    end
  end
  vim.fn.getmousepos, vim.api.nvim_feedkeys = mouse, feed
  package.loaded["sidekick.cli.terminal"] = terminal
  vim.w[source].sidekick_session_id = nil
  assert(sent[#sent] == vim.keycode("<C-LeftRelease>"))
  vim.wait(20)
end)

test("references split across actual terminal rows", function()
  vim.api.nvim_set_current_win(source)
  vim.cmd.enew()
  vim.api.nvim_win_set_width(source, 35)
  vim.wo.number = false
  vim.wo.signcolumn = "no"
  local buf = vim.api.nvim_get_current_buf()
  local channel = vim.api.nvim_open_term(buf, {})
  vim.api.nvim_chan_send(channel, "See packages/server/src/lib/cartesia.ts:105–141.\r\n")
  vim.wait(50)
  local first = links.at(source, 1, 12)
  local second = links.at(source, 2, 4)
  assert(first.path == "packages/server/src/lib/cartesia.ts" and first.last == 141, vim.inspect(first))
  assert(second.path == first.path and second.last == 141, vim.inspect(second))
end)

test("directory abbreviations preserve recognizable names and filenames", function()
  assert(workspace.shorten_path("packages/server/src/lib/cartesia.ts") == "pckg/srvr/src/lib/cartesia.ts")
  assert(workspace.shorten_path("components/config/audio/file.ts") == "cmpn/cnfg/audi/file.ts")
  assert(workspace.shorten_path(".config/nvim/file.lua") == ".cnfg/nvim/file.lua")
  assert(vim.fn.strdisplaywidth(workspace.fit("дълго-име.ts", 8)) <= 8)
end)

test("server labels share work within a redraw and details expose the actual command", function()
  vim.wait(10)
  local get_clients, calls = vim.lsp.get_clients, 0
  local cmd = { "/tmp/project/node_modules/.bin/tsgo", "--lsp", "--stdio" }
  vim.lsp.get_clients = function()
    calls = calls + 1
    return {
      {
        id = 1,
        name = "tsc",
        initialized = true,
        root_dir = root,
        config = { cmd = function() end, _resolved_cmd = cmd },
      },
    }
  end
  workspace.servers()
  workspace.servers()
  assert(calls == 1)
  local details = table.concat(workspace.details(), "\n")
  vim.lsp.get_clients = get_clients
  assert(details:find(table.concat(cmd, " "), 1, true))
end)

vim.fn.delete(root, "rf")
print(string.format("%d navigation checks passed", passed))
vim.cmd("qa!")
