local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("config.options")
-- The explicit `spec` key matters: called with a single table, setup() treats it
-- as the plugin spec and silently ignores top-level options like `dev`.
require("lazy").setup({
  spec = { import = "plugins" },
  dev = {
    -- Prefer a local checkout under ~/repos when one exists, so unpushed work
    -- is what loads; otherwise install from GitHub. Local dirs drop the .nvim
    -- suffix, so both spellings are tried.
    path = function(plugin)
      local name = plugin.name
      for _, candidate in ipairs({ name, (name:gsub("%.nvim$", "")) }) do
        local dir = vim.fn.expand("~/repos/" .. candidate)
        if vim.fn.isdirectory(dir) == 1 then
          return dir
        end
      end
      return vim.fn.expand("~/repos/" .. name)
    end,
    -- Matched with plain substring search against the plugin url, not a Lua
    -- pattern, so these are literal fragments.
    patterns = { "sibling-jump", "difftastic" },
    fallback = true,
  },
})

-- Required explicitly rather than as a side effect of requiring keymaps: these
-- register user commands (config.util, config.fzf) and the _G.DiffFoldLevel
-- foldexpr global (config.util), so init.lua should show that they run.
require("config.util")
require("config.conflicts")
require("config.fzf")

require("config.autocmds")
require("config.keymaps")

require("lsp_file_refs_treesitter").setup()
require("custom_functions")
require("search_context").setup({ context_lines = 3 })

require("config.highlights")
