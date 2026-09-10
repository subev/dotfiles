-- Small editor commands and helpers.

local M = {}

-- :Redir {cmd} — put the output of a command (or `:!cmd`) into a scratch buffer,
-- with the command that produced it and a separator above the output.
function M.redir(cmd)
  local output
  if cmd:sub(1, 1) == "!" then
    output = vim.fn.system(cmd:sub(2))
  else
    output = vim.api.nvim_exec2(cmd, { output = true }).output
  end

  vim.cmd("vnew")
  vim.bo.buflisted = false
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  -- trimempty matches Vim's split(), which drops trailing empty fields.
  vim.fn.setline(1, vim.split(output, "\n", { trimempty = true }))
  vim.fn.append(0, cmd)
  vim.fn.append(1, "----")
end

-- :MoveFile {path} — save the buffer somewhere new and remove the old file.
function M.move_file(newfile)
  local oldfile = vim.fn.expand("%")
  vim.cmd("saveas " .. vim.fn.fnameescape(newfile))
  if vim.fn.filereadable(oldfile) == 1 then
    vim.fn.delete(oldfile)
    vim.notify("Moved " .. oldfile .. " to " .. newfile, vim.log.levels.INFO)
  else
    -- WARN, not ERROR: an ERROR notification raises out of a user command.
    vim.notify("Error moving file!", vim.log.levels.WARN)
  end
end

-- Fold level for `git log -p` output, consumed by the git FileType autocmd's
-- foldexpr. A module field rather than a global so the expression can reach it
-- through v:lua.require, with no dependency on load order.
function M.diff_fold_level(lnum)
  local line = vim.fn.getline(lnum)
  if line:match("^diff %-%-git") then
    return ">1"
  elseif line:match("^commit") then
    return "<1"
  end
  return "="
end

-- Registers the test-watch mapping in projects that have a vitest config.
-- Called from the BufEnter/BufWinEnter autocmd in config/autocmds.lua.
function M.update_mapping_for_vitest(filename)
  if vim.fn.filereadable(filename) ~= 1 then
    return
  end
  vim.keymap.set("n", "<Space>tc", function()
    vim.cmd("vsplit")
    vim.cmd("terminal npm run test " .. vim.fn.expand("%:p") .. " -- --watch")
  end, { buffer = true, desc = "Run this file's tests on watch" })
end

vim.api.nvim_create_user_command("Redir", function(args)
  M.redir(args.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command("MoveFile", function(args)
  M.move_file(args.args)
end, { nargs = 1 })

return M
