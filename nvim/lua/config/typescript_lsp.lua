local M = {}
local probes, pending, selected = {}, {}, {}

local function probe(bin, done)
  local stat = vim.uv.fs_stat(bin)
  if not stat then
    return done(false)
  end
  local key = table.concat({
    bin,
    vim.uv.fs_realpath(bin) or bin,
    stat.ino,
    stat.size,
    stat.mtime.sec,
    stat.mtime.nsec,
    stat.ctime.sec,
    stat.ctime.nsec,
  }, ":")
  if probes[bin] and probes[bin].key == key then
    return done(probes[bin].native)
  end
  if pending[key] then
    pending[key][#pending[key] + 1] = done
    return
  end
  pending[key] = { done }
  local function finish(result)
    local version = vim.version.parse(result.stdout or "")
    local native = result.code == 0 and version ~= nil and version.major >= 7
    if result.code == 0 and version then
      probes[bin] = { key = key, native = native }
    end
    local callbacks = pending[key]
    pending[key] = nil
    for _, callback in ipairs(callbacks) do
      callback(native)
    end
  end
  local ok = pcall(vim.system, { bin, "--version" }, { text = true, timeout = 5000 }, vim.schedule_wrap(finish))
  if not ok then
    finish({ code = -1 })
  end
end

function M.select(start, root, done)
  local dir = vim.fs.normalize(start)
  root = vim.fs.normalize(root)
  while dir do
    local bins = {}
    for _, name in ipairs({ "tsc", "tsgo" }) do
      local bin = vim.fs.joinpath(dir, "node_modules/.bin", name)
      if vim.fn.executable(bin) == 1 then
        bins[#bins + 1] = bin
      end
    end
    if #bins > 0 then
      local scope = dir
      local function try(index)
        if not bins[index] then
          selected[scope] = nil
          return done(nil, scope)
        end
        probe(bins[index], function(native)
          if native then
            selected[scope] = bins[index]
            done(bins[index], scope)
          else
            try(index + 1)
          end
        end)
      end
      return try(1)
    end
    if dir == root or (root ~= "/" and dir:sub(1, #root + 1) ~= root .. "/") then
      break
    end
    dir = vim.fs.dirname(dir)
  end
  selected[root] = nil
  done(nil, root)
end

function M.setup()
  local project_root = vim.lsp.config.ts_ls.root_dir
  for _, name in ipairs({ "tsc", "ts_ls" }) do
    local native = name == "tsc"
    vim.lsp.config(name, {
      root_dir = function(buf, on_dir)
        local path = vim.api.nvim_buf_get_name(buf)
        project_root(buf, function(root)
          M.select(vim.fs.dirname(path) or root, root, function(bin, scope)
            if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf) == path and (bin ~= nil) == native then
              on_dir(scope)
            end
          end)
        end)
      end,
      cmd = function(dispatchers, config)
        local bin
        if native then
          bin = selected[config.root_dir]
          if not bin or vim.fn.executable(bin) ~= 1 then
            error("No verified native TypeScript for this root; open a TypeScript buffer to select its server")
          end
        else
          local dir = config.root_dir
          while dir do
            local candidate = vim.fs.joinpath(dir, "node_modules/.bin/typescript-language-server")
            if vim.fn.executable(candidate) == 1 then
              bin = candidate
              break
            end
            local parent = vim.fs.dirname(dir)
            if parent == dir then
              break
            end
            dir = parent
          end
          bin = bin or vim.fn.exepath("typescript-language-server")
          if bin == "" then
            error("typescript-language-server is missing; install ts_ls with Mason")
          end
        end
        local cmd = native and { bin, "--lsp", "--stdio" } or { bin, "--stdio" }
        config._resolved_cmd = cmd
        return vim.lsp.rpc.start(cmd, dispatchers, { cwd = config.cmd_cwd, env = config.cmd_env })
      end,
    })
  end
end

return M
