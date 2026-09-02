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
require("lazy").setup({ import = "plugins" })
require("config.vimscript")

require("lsp_file_refs_treesitter").setup()
require("custom_functions")
require("search_context").setup({ context_lines = 3 })

require("config.highlights")
