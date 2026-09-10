vim.opt.rtp:prepend(vim.fn.getcwd() .. "/nvim")
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/nvim-treesitter")
vim.o.loadplugins = false
vim.treesitter.language.register("tsx", "typescriptreact")
vim.treesitter.language.register("javascript", "javascriptreact")
vim.cmd("filetype plugin indent on")
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
