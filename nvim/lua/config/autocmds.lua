-- Filetype-scoped mappings and options.
--
-- `vim.opt_local` is the direct equivalent of `setlocal`: FileType fires with
-- the buffer current, and the window-local options here (foldmethod, spell,
-- number) cannot be set through `vim.wo[bufnr]`, which takes a window id.
--
-- The original mixed `nnoremap` with recursive `nmap` and `imap`. For the
-- recursive ones use `remap = true`: `vim.keymap.set` ignores `noremap = false`,
-- so that spelling silently produces a non-recursive mapping instead.

local group = vim.api.nvim_create_augroup("autocommands", { clear = true })

local function on_filetype(filetypes, callback)
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = filetypes,
    callback = callback,
  })
end

on_filetype("ctrlsf", function(ev)
  local o = { buffer = ev.buf, silent = true }
  vim.keymap.set("n", "<space>`", ":BLines<cr>", o)
  vim.keymap.set("v", "<space>`", [[y:BLines <c-r>"<cr>]], o)
  vim.keymap.set("n", "gn", "n", o)
end)

on_filetype("fugitive", function(ev)
  local b = { buffer = ev.buf }
  local r = { buffer = ev.buf, remap = true }
  vim.keymap.set("n", "2", "2", b)
  vim.keymap.set("n", "3", "3", b)
  -- use 'ours' when merge conflict
  vim.keymap.set("n", "g1", "2X", r)
  -- use 'theirs' when merge conflict
  vim.keymap.set("n", "g3", "3X", r)
  vim.keymap.set("n", "o", "gO<right>q<left>", r)
  vim.keymap.set("n", "f<space>", ":G fetch<cr>", r)
  vim.keymap.set("n", "g<space>", ":G<space>", r)
  vim.keymap.set("n", "sm<space>", ":G switch master<cr>", r)
end)

on_filetype("fzf", function(ev)
  vim.keymap.set("i", "<esc>", "<c-c>", { buffer = ev.buf, remap = true })
end)

on_filetype("csv", function(ev)
  vim.keymap.set("n", "<Space><Space>", ":WhatColumn!<CR>", { buffer = ev.buf })
end)

on_filetype("gitcommit", function()
  vim.opt_local.spell = true
end)

-- Vim's continuous comment leader, off everywhere.
on_filetype("*", function()
  vim.opt_local.formatoptions:remove({ "c", "r", "o" })
end)

-- Vim motions while writing in Bulgarian.
vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  pattern = "*.bg.*",
  callback = function()
    vim.opt_local.keymap = "bulgarian-phonetic"
  end,
})

on_filetype("help", function()
  vim.opt_local.number = true
end)

on_filetype("vim", function(ev)
  vim.opt_local.shiftwidth = 2
  vim.keymap.set("v", "<Space>=", ":<C-u>@*<CR>", { buffer = ev.buf })
  vim.opt_local.foldmethod = "marker"
end)

-- Run the current buffer (or selection) through node.
on_filetype("typescript,javascript,vue", function(ev)
  vim.keymap.set("v", "<space>=", ":lua visual_selection_to_node()<CR>", { buffer = ev.buf })
  vim.keymap.set("n", "<space>=", "ggVG:lua visual_selection_to_node()<CR>", { buffer = ev.buf })
end)

on_filetype("git", function(ev)
  vim.keymap.set("n", "o", "gO", { buffer = ev.buf, remap = true })
  vim.opt_local.foldmethod = "expr"
  -- Fully qualified so the expression carries its own dependency: a bare
  -- `DiffFoldLevel()` is a Vimscript call and cannot see a Lua function.
  vim.opt_local.foldexpr = [[v:lua.require'config.util'.diff_fold_level(v:lnum)]]
  vim.opt_local.foldlevel = 0
  vim.opt_local.foldenable = true
  vim.keymap.set("n", "-", function()
    return vim.fn.foldclosed(vim.fn.line(".")) == -1 and "za" or "zA"
  end, { buffer = ev.buf, expr = true, remap = true })
end)

-- Offer the test-watch mapping in projects that have a vitest config.
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  group = group,
  callback = function()
    require("config.util").update_mapping_for_vitest("vitest.config.ts")
  end,
})
