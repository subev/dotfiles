-- Run through tests/test_runner.sh, or nvim --headless -u NONE -i NONE -n -l tests/typescript_spec.lua.
vim.opt.rtp:prepend(vim.fn.getcwd() .. "/nvim")
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/nvim-lspconfig")
local typescript = require("config.typescript_lsp")
local root = vim.fn.tempname()
vim.fn.mkdir(root, "p")
root = vim.uv.fs_realpath(root)
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
local function binary(dir, name, version)
  local bin = dir .. "/node_modules/.bin/" .. name
  vim.fn.mkdir(vim.fs.dirname(bin), "p")
  vim.fn.writefile({ "#!/bin/sh", "echo 'Version " .. version .. "'" }, bin .. ".new")
  vim.fn.setfperm(bin .. ".new", "rwxr-xr-x")
  assert(vim.uv.fs_rename(bin .. ".new", bin))
  return bin
end
local function select(start, workspace)
  local result
  typescript.select(start, workspace, function(bin, scope)
    result = { bin = bin, scope = scope }
  end)
  assert(
    vim.wait(6000, function()
      return result ~= nil
    end),
    "TypeScript probe timed out"
  )
  return result
end

test("projects with no installed TypeScript retain the legacy fallback", function()
  local result = select(root, root)
  assert(result.bin == nil and result.scope == root)
end)

test("TS6 falls back, then a newly installed tsgo is detected without restarting", function()
  local dir = root .. "/preview"
  binary(dir, "tsc", "6.0.3")
  assert(select(dir, root).bin == nil)
  local bin = binary(dir, "tsgo", "7.0.0-dev.20260801")
  assert(select(dir, root).bin == bin)
end)

test("replacing an installed compiler invalidates its cached version", function()
  local dir = root .. "/upgrade"
  binary(dir, "tsc", "6.0.3")
  assert(select(dir, root).bin == nil)
  local bin = binary(dir, "tsc", "7.0.2")
  assert(select(dir, root).bin == bin)
  binary(dir, "tsc", "6.0.3")
  assert(select(dir, root).bin == nil)
end)

test("package-local compilers override a different workspace version", function()
  binary(root, "tsc", "7.0.2")
  local legacy = root .. "/packages/legacy"
  binary(legacy, "tsc", "6.0.3")
  local result = select(legacy .. "/src", root)
  assert(result.bin == nil and result.scope == legacy)
  local native = root .. "/packages/native"
  local bin = binary(native, "tsgo", "7.0.0-dev.20260801")
  result = select(native .. "/src", root)
  assert(result.bin == bin and result.scope == native)
end)

test("concurrent root checks share a nonblocking version probe", function()
  local dir = root .. "/slow"
  binary(dir, "tsc", "7.0.2")
  local system, calls, finished, tick = vim.system, 0, 0, false
  vim.system = function(_, opts, callback)
    calls = calls + 1
    assert(opts.timeout == 5000 and callback)
    vim.defer_fn(function()
      callback({ code = 0, stdout = "Version 7.0.2" })
    end, 20)
    return {}
  end
  for _ = 1, 2 do
    typescript.select(dir, root, function(bin)
      assert(bin)
      finished = finished + 1
    end)
  end
  vim.system = system
  assert(finished == 0 and calls == 1)
  vim.schedule(function()
    tick = true
  end)
  assert(vim.wait(1000, function()
    return finished == 2
  end))
  assert(tick)
end)

test("spawn failures fall back and are not cached permanently", function()
  local dir = root .. "/spawn"
  local bin = binary(dir, "tsc", "7.0.2")
  local system = vim.system
  vim.system = function()
    error("spawn failed")
  end
  local result = select(dir, root)
  vim.system = system
  assert(result.bin == nil)
  assert(select(dir, root).bin == bin)
end)

typescript.setup()
test("upstream Deno exclusion and mutually exclusive roots are preserved", function()
  vim.fn.writefile({ "{}" }, root .. "/package-lock.json")
  local dir = root .. "/packages/native"
  local path = dir .. "/index.ts"
  vim.fn.writefile({ "const answer = 42;" }, path)
  local buf = vim.fn.bufadd(path)
  local roots = {}
  for _, name in ipairs({ "tsc", "ts_ls" }) do
    vim.lsp.config[name].root_dir(buf, function(scope)
      roots[name] = scope
    end)
  end
  assert(vim.wait(1000, function()
    return roots.tsc ~= nil
  end))
  assert(roots.tsc == dir and roots.ts_ls == nil)
  vim.fn.writefile({ "{}" }, dir .. "/deno.json")
  roots = {}
  for _, name in ipairs({ "tsc", "ts_ls" }) do
    vim.lsp.config[name].root_dir(buf, function(scope)
      roots[name] = scope
    end)
  end
  vim.wait(20)
  assert(next(roots) == nil)
end)

test("launchers expose the actual command and reject an ungated native root", function()
  local start, launched = vim.lsp.rpc.start
  vim.lsp.rpc.start = function(cmd)
    launched = cmd
    return {}
  end
  local config = { root_dir = root .. "/packages/native" }
  vim.lsp.config.tsc.cmd({}, config)
  assert(launched[1] == config.root_dir .. "/node_modules/.bin/tsgo")
  assert(vim.deep_equal(config._resolved_cmd, launched))
  local ok, err = pcall(vim.lsp.config.tsc.cmd, {}, { root_dir = root .. "/unknown" })
  assert(not ok and tostring(err):find("No verified native TypeScript", 1, true))
  local legacy = root .. "/packages/legacy"
  local launcher = binary(root, "typescript-language-server", "5.0.0")
  config = { root_dir = legacy }
  vim.lsp.config.ts_ls.cmd({}, config)
  assert(launched[1] == launcher and launched[2] == "--stdio")
  assert(vim.deep_equal(config._resolved_cmd, launched))
  local exepath = vim.fn.exepath
  vim.fn.exepath = function()
    return "/test/mason/typescript-language-server"
  end
  config = { root_dir = "/" }
  vim.lsp.config.ts_ls.cmd({}, config)
  vim.fn.exepath = exepath
  assert(launched[1] == "/test/mason/typescript-language-server")
  vim.lsp.rpc.start = start
end)

vim.fn.delete(root, "rf")
print(string.format("%d TypeScript checks passed", passed))
vim.cmd("qa!")
