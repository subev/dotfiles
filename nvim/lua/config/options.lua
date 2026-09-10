-- The TUI sets 'background' itself if it detects a light terminal; pin it.
vim.o.background = "dark"

vim.o.termguicolors = true
vim.o.undofile = true
vim.o.updatetime = 300

-- Treat - and $ as keyword characters.
vim.opt.iskeyword:append({ "-", "$" })

vim.o.scrolloff = 20
vim.o.number = true
vim.o.mouse = "a"
vim.o.list = true
vim.opt.listchars = { tab = "->", trail = "." }

vim.opt.wildignore = {
  "*.o",
  "*.obj",
  "*.bin",
  "*.dll",
  "*.zip",
  "*/.git/*",
  "*/.hg/*",
  "*/.svn/*",
  "*\\.git\\*",
  "*\\.hg\\*",
  "*\\.svn\\*",
}

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.colorcolumn = "100"

-- Outside tmux the system clipboard is the only one available; inside tmux, tmux owns it.
if vim.env.TMUX == nil or vim.env.TMUX == "" then
  vim.opt.clipboard:append("unnamed")
end

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.writebackup = false
vim.o.swapfile = false
