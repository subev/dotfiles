-- :colorscheme clears all groups, so re-apply on every switch rather than
-- relying on this running after the colorscheme is set
local function apply()
  vim.api.nvim_set_hl(0, "HlSearchLensNear", { link = "Substitute" })

  vim.api.nvim_set_hl(0, "RefjumpReference", { link = "Substitute" })

  vim.api.nvim_set_hl(0, "IlluminatedWordText", { fg = "#a0d995", bg = "#444045", underline = true })
  vim.api.nvim_set_hl(0, "IlluminatedWordRead", { fg = "#a0d995", bg = "#444045", underline = true })
  vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { fg = "#a0d995", bg = "#444045", underline = true })
  vim.api.nvim_set_hl(0, "IlluminatedWordCursor", { fg = "#a0d995", bg = "#444045" })
  vim.api.nvim_set_hl(0, "IlluminatedWordCursorRead", { fg = "#a0d995", bg = "#444045" })
  vim.api.nvim_set_hl(0, "IlluminatedWordCursorWrite", { fg = "#a0d995", bg = "#444045" })
end

vim.api.nvim_create_autocmd("ColorScheme", { callback = apply })
apply()
