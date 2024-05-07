if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0.02
  vim.keymap.set('n', '<D-s>', ':w<CR>') -- Save
  vim.keymap.set('v', '<D-c>', '"+y') -- Copy

  -- pasting
  vim.keymap.set('n', '<D-v>', '"+P')
  vim.keymap.set('c', '<D-v>', '<C-R>+') -- Paste command mode
  vim.keymap.set('i', '<D-v>', '<C-R>+') -- Paste insert mode
  vim.keymap.set('!', '<D-v>', '<C-R>+') -- Paste insert mode

  vim.o.guifont = "Hack Nerd Font Mono:h15"
  -- vim.g.neovide_cursor_vfx_mode = "railgun"
end
