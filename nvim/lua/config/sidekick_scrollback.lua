local M = {}

function M.clamp(terminal)
  if not (terminal.scrollback and terminal.scrollback:is_open()) then
    return
  end
  vim.api.nvim_win_call(terminal.win, function()
    local view = vim.fn.winsaveview()
    local height = vim.api.nvim_win_get_height(terminal.win)
    local remaining = vim.api.nvim_win_text_height(terminal.win, {
      start_row = view.topline - 1,
      start_vcol = view.skipcol,
      max_height = height,
    }).all
    if remaining >= height or (view.topline == 1 and view.skipcol == 0) then
      return
    end
    -- Let Neovim align the last screen row, including wrapped lines.
    vim.cmd("keepjumps normal! Gzb")
    vim.fn.winrestview({ lnum = view.lnum, col = view.col, coladd = view.coladd, curswant = view.curswant })
  end)
end

function M.setup(terminal)
  vim.api.nvim_create_autocmd("WinScrolled", {
    group = terminal.group,
    callback = function()
      M.clamp(terminal)
    end,
  })
end

return M
