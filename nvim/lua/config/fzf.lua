-- fzf.vim-driven commands.

local M = {}

-- :RgX — ripgrep for the current file's basename, excluding the file itself.
function M.rg_x(bang)
  local abs = vim.fn.expand("%:p")
  if abs == "" then
    vim.notify("RgX: current buffer has no file", vim.log.levels.ERROR)
    return
  end

  local pattern = vim.fn.expand("%:t"):gsub("%..*$", "")
  if pattern == "" then
    vim.notify("RgX: cannot determine file basename", vim.log.levels.ERROR)
    return
  end

  -- Path relative to the git root when there is one, else to :pwd.
  local rel = ""
  local git_top = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")
  if #git_top > 0 and vim.v.shell_error == 0 then
    local top = git_top[1]:gsub("/+$", "")
    if abs:sub(1, #top) == top then
      -- Vimscript slicing is 0-based, so `abs[len(top)+1:]` drops the slash;
      -- Lua's 1-based sub needs +2 to land on the same character.
      rel = abs:sub(#top + 2)
    end
  end
  if rel == "" then
    rel = vim.fn.fnamemodify(abs, ":.")
  end
  rel = rel:gsub("\\\\", "/")

  -- Anchor the exclusion to the search root so exactly this file is skipped.
  local rg_cmd = "rg --column --line-number --no-heading --color=always -s -F "
    .. "--glob "
    .. vim.fn.shellescape("!/" .. rel)
    .. " -- "
    .. pattern
  -- echom equivalent: to the message history, not a popup on every invocation.
  vim.api.nvim_echo({ { rg_cmd } }, true, {})

  vim.fn["fzf#vim#grep"](rg_cmd, vim.fn["fzf#vim#with_preview"](), bang)
end

-- Search the project for the current file's basename.
function M.rg_file_references()
  local ext = vim.fn.expand("%:e")
  local name = vim.fn.expand("%:t:r")
  if ext == "vue" or ext == "jsx" or ext == "tsx" then
    vim.cmd("Rg <" .. name .. "\\b")
  else
    vim.cmd("Rg " .. name .. "\\(")
  end
end

vim.api.nvim_create_user_command("RgX", function(args)
  M.rg_x(args.bang and 1 or 0)
end, { bang = true, nargs = 0 })

vim.api.nvim_create_user_command("CustomBLines", function(args)
  local cmd = "rg --with-filename --column --line-number --no-heading --smart-case . "
    .. vim.fn.fnameescape(vim.fn.expand("%:p"))
  vim.fn["fzf#vim#grep"](
    cmd,
    1,
    vim.fn["fzf#vim#with_preview"]({
      options = "--no-sort --layout reverse --query "
        .. vim.fn.shellescape(args.args)
        .. [[ --with-nth=4.. --delimiter=":"]],
    }, "right:50%")
  )
end, { bang = true, nargs = "*" })

vim.keymap.set("i", "<c-x><c-f>", function()
  return vim.fn["fzf#vim#complete#path"]("rg --files")
end, { expr = true })

return M
