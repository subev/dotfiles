if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0.02
  vim.keymap.set('n', '<D-s>', ':w<CR>') -- Save
  vim.keymap.set('v', '<D-c>', '"+y') -- Copy
  vim.keymap.set('c', '<D-v>', '<C-R>+') -- Paste command mode, add a hack to force render it
  vim.o.guifont = "Hack Nerd Font Mono:h15"
end
