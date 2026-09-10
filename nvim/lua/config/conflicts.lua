-- Merge-conflict helpers.
--
-- These drive real searches through the search register rather than
-- `vim.fn.search`, so that the motion also updates the search direction the
-- way the original `:normal! /<CR>` did.
--
-- Unlike the Vimscript originals, a failed search does not abort the helper:
-- feedkeys errors do not propagate. A conflict with no `|||||||` base section
-- therefore runs through the remaining steps rather than stopping part-way,
-- which yields the right result but differs from the old behaviour.

local M = {}

local function normal(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "nx", false)
end

local function searching(pattern, keys)
  local last = vim.fn.getreg("/")
  vim.fn.setreg("/", pattern)
  normal(keys)
  vim.fn.setreg("/", last)
end

function M.go_next()
  searching("<<<<<<<", "/<CR>")
end

function M.go_prev()
  searching("<<<<<<<", "?<CR>")
end

function M.keep_left()
  searching("<<<<<<<", "?<CR>dd")
  searching("|||||||", "/<CR>V")
  searching(">>>>>>>", "/<CR>d")
end

function M.keep_both()
  searching("<<<<<<<", "?<CR>dd")
  searching("|||||||", "/<CR>V")
  searching("=======", "/<CR>d")
  searching(">>>>>>>", "/<CR>dd")
end

function M.keep_right()
  searching("<<<<<<<", "?<CR>V")
  searching("=======", "/<CR>d")
  searching(">>>>>>>", "/<CR>dd")
end

function M.find_import()
  local last = vim.fn.getreg("/")
  vim.cmd("normal! gg")
  vim.fn.search("^import ", "c")
  vim.fn.setreg("/", last)
end

return M
