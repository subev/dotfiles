-- Emit comparable metrics for whatever config Neovim just loaded.
--
-- Run against a config with:
--   nvim --headless -c 'luafile /path/to/config_metrics.lua' -c 'qa!'
-- and it writes key=value lines to $CONFIG_METRICS_OUT.
--
-- Everything is sorted before hashing so plugin load order cannot make two
-- identical configs look different. Path-bearing options are excluded for the
-- same reason: the two refs under comparison live in different directories and
-- would otherwise never match.
local out_file = assert(vim.env.CONFIG_METRICS_OUT, "CONFIG_METRICS_OUT must be set")

local function sha(list)
  return vim.fn.sha256(table.concat(list, "\n"))
end

local function emit(lines)
  local f = assert(io.open(out_file, "w"))
  f:write(table.concat(lines, "\n") .. "\n")
  f:close()
end

local out = {}

-- Load every spec before sampling. Without this, which lazily-loaded plugins
-- have registered their mappings by the time we look varies from process to
-- process, so the same config hashes differently run to run.
local ok_lazy, lazy = pcall(require, "lazy")
if ok_lazy then
  local names = {}
  for name in pairs(require("lazy.core.config").plugins) do
    names[#names + 1] = name
  end
  pcall(lazy.load, { plugins = names })
end

-- Global mappings, in both senses: which keys are bound, and what they do.
-- Lua-defined mappings have no rhs, so they collapse to a placeholder; that is
-- fine for a count and still catches a key that stopped being bound.
local maps, lhs_only = {}, {}
for _, mode in ipairs({ "n", "x", "s", "o", "i", "l", "c", "t" }) do
  for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
    local rhs = m.rhs ~= "" and m.rhs or (m.callback and "<Lua>" or "")
    -- Script-local ids are assigned at load time and differ between processes.
    -- Some plugins (auto-pairs, easy-align) generate mappings whose *lhs* is
    -- itself a script-local name, so both sides need normalising.
    maps[#maps + 1] = mode .. "\t" .. m.lhs:gsub("<SNR>%d+_", "<SNR>_") .. "\t" .. rhs:gsub("<SNR>%d+_", "<SNR>_")
    lhs_only[#lhs_only + 1] = mode .. "\t" .. m.lhs:gsub("<SNR>%d+_", "<SNR>_")
  end
end
table.sort(maps)
table.sort(lhs_only)
out[#out + 1] = "keymaps.count=" .. #maps
out[#out + 1] = "keymaps.lhs_hash=" .. sha(lhs_only)
out[#out + 1] = "keymaps.full_hash=" .. sha(maps)

-- User commands.
local cmds = {}
for name in pairs(vim.api.nvim_get_commands({})) do
  cmds[#cmds + 1] = name
end
table.sort(cmds)
out[#out + 1] = "commands.count=" .. #cmds
out[#out + 1] = "commands.hash=" .. sha(cmds)

-- Autocommands, keyed by event and pattern so a reordering is not a diff.
local aucmds = {}
for _, a in ipairs(vim.api.nvim_get_autocmds({})) do
  aucmds[#aucmds + 1] = a.event .. "\t" .. (a.pattern or "") .. "\t" .. tostring(a.group_name or "")
end
table.sort(aucmds)
out[#out + 1] = "autocmds.count=" .. #aucmds
out[#out + 1] = "autocmds.hash=" .. sha(aucmds)

-- Option values. Path-bearing ones differ by construction between two
-- checkouts, and 'runtimepath' additionally differs in length.
local SKIP = {
  runtimepath = true,
  packpath = true,
  undodir = true,
  directory = true,
  backupdir = true,
  viewdir = true,
  spellfile = true,
  cdpath = true,
  path = true,
  tags = true,
}
local opts = {}
for name in pairs(vim.api.nvim_get_all_options_info()) do
  if not SKIP[name] then
    local ok, v = pcall(function()
      return vim.o[name]
    end)
    if ok then
      opts[#opts + 1] = name .. "=" .. tostring(v)
    end
  end
end
table.sort(opts)
out[#out + 1] = "options.count=" .. #opts
out[#out + 1] = "options.hash=" .. sha(opts)

-- Highlight groups, minus the ones a colorscheme is free to reorder.
local hls = vim.fn.getcompletion("", "highlight")
table.sort(hls)
out[#out + 1] = "highlights.count=" .. #hls

-- Loaded plugins, by name, so a spec that stopped loading shows up.
local ok_cfg, lazy_cfg = pcall(require, "lazy.core.config")
if ok_cfg and lazy_cfg.plugins then
  local names = {}
  for name in pairs(lazy_cfg.plugins) do
    names[#names + 1] = name
  end
  table.sort(names)
  out[#out + 1] = "plugins.count=" .. #names
  out[#out + 1] = "plugins.hash=" .. sha(names)
else
  out[#out + 1] = "plugins.count=0"
end

emit(out)
