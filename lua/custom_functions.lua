function Unique_Buffers()
  local seen_buffers = {}
  local windows_to_close = {}

  -- Iterate through all windows
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)

    -- If we've seen this buffer already, mark the window for closing
    if seen_buffers[buf_name] then
      table.insert(windows_to_close, win)
    else
      seen_buffers[buf_name] = true
    end
  end

  -- Close marked windows
  for _, win in ipairs(windows_to_close) do
    -- Make sure the window is still valid (hasn't been closed since we checked)
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, false)
    end
  end
end

function GetMasterBranchName()
  local main_exists = vim.fn.system('git branch --list main')
  if string.find(main_exists, 'main') then
    return 'main'
  else
    return 'master'
  end
end

-- noremap ,gl :lua GiT_Log_CurrentFile_With_External_Diff_Inside_New_Terminal()<cr>

function GiT_Log_CurrentFile_With_External_Diff_Inside_New_Terminal()
  local current_file = vim.fn.expand('%:p')
  local git_command = "GIT_EXTERNAL_DIFF=difft git log --ext-diff -p -- " .. current_file
  vim.cmd('tabnew')
  vim.cmd('terminal ' .. git_command)
  vim.cmd('startinsert')

  -- Close the tab if the command exits
  vim.cmd([[
    autocmd TermClose <buffer> q
  ]])
end

-- noremap ,gp :lua Git_Show_Log_Patches()<cr>
function Git_Show_Log_Patches()
  local git_command = "GIT_EXTERNAL_DIFF=difft git ls -p"
  vim.cmd('tabnew')
  vim.cmd('terminal ' .. git_command)
  vim.cmd('startinsert')

  -- Close the tab if the command exits
  vim.cmd([[
    autocmd TermClose <buffer> q
  ]])
end

-- noremap ,gm :CocDisable<cr>:DiffviewOpen origin/<C-r>=GetMasterBranchName()<CR>...HEAD<cr>
function Git_Show_Diff_Against_Main_Or_Master()
  local main_branch = GetMasterBranchName()
  local git_command = "GIT_EXTERNAL_DIFF=difft git diff --ext-diff origin/" .. main_branch .. "...HEAD"
  vim.cmd('tabnew')
  vim.cmd('terminal ' .. git_command)
  vim.cmd('startinsert')

  -- Close the tab if the command exits
  vim.cmd([[
    autocmd TermClose <buffer> q
  ]])
end

function VisualSelectionToNode()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line, start_col = start_pos[2], start_pos[3]
  local end_line, end_col = end_pos[2], end_pos[3]

  -- Retrieve lines in the visual selection
  local lines = vim.fn.getline(start_line, end_line)

  -- Adjust the first and last lines to respect column boundaries
  if #lines > 0 then
    lines[1] = lines[1]:sub(start_col)
    lines[#lines] = lines[#lines]:sub(1, end_col)
  end

  -- Combine the lines into a single string
  local selection = table.concat(lines, "\n")

  -- Pass the selection to node with eval mode and discard stderr
  local command = 'node --experimental-strip-types -e "' .. selection:gsub('"', '\\"') .. '"' .. ' 2>/dev/null'
  -- same without discarding stderr
  local command = 'node --experimental-strip-types -e "' .. selection:gsub('"', '\\"') .. '"'
  local output = vim.fn.system(command)
  print(output)
end

-- Add the function to the global namespace if you want to call it from command mode or a keybinding
_G.unique_buffers = Unique_Buffers
_G.git_log_file = GiT_Log_CurrentFile_With_External_Diff_Inside_New_Terminal
_G.git_diff_main = Git_Show_Diff_Against_Main_Or_Master
_G.git_log_patches = Git_Show_Log_Patches
_G.visual_selection_to_node = VisualSelectionToNode
