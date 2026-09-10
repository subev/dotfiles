local M = {}

M.config = {
  context_lines = 3,
  width = 80,
}

local path_ok, fzf_path = pcall(require, "fzf-lua.path")

local function get_context_lines()
  return vim.g.search_context_lines or M.config.context_lines
end

local function read_file_lines(filepath, start_line, end_line)
  local lines = {}
  local f = io.open(filepath, "r")
  if not f then
    return lines
  end
  local i = 1
  for line in f:lines() do
    if i >= start_line and i <= end_line then
      table.insert(lines, { lnum = i, text = line })
    end
    if i > end_line then
      break
    end
    i = i + 1
  end
  f:close()
  return lines
end

local function parse_entry(entry, opts)
  if path_ok then
    return fzf_path.entry_to_file(entry, opts)
  end
  local file, lnum, col, text = entry:match("^(.-):(%-?%d+):(%-?%d+):(.*)$")
  if file and lnum then
    return {
      path = file,
      line = tonumber(lnum),
      col = tonumber(col),
      stripped = entry,
    }
  end
  return nil
end

local function group_matches_by_file(matches)
  local by_file = {}
  local file_order = {}
  for _, m in ipairs(matches) do
    if m.path then
      if not by_file[m.path] then
        by_file[m.path] = {}
        table.insert(file_order, m.path)
      end
      table.insert(by_file[m.path], m)
    end
  end
  for _, file in ipairs(file_order) do
    table.sort(by_file[file], function(a, b)
      return a.line < b.line
    end)
  end
  return by_file, file_order
end

local function merge_ranges(matches, context)
  local ranges = {}
  for _, m in ipairs(matches) do
    local range_start = math.max(1, m.line - context)
    local range_end = m.line + context
    if #ranges > 0 and ranges[#ranges].end_line >= range_start - 1 then
      ranges[#ranges].end_line = math.max(ranges[#ranges].end_line, range_end)
      table.insert(ranges[#ranges].match_lines, m.line)
    else
      table.insert(ranges, {
        start_line = range_start,
        end_line = range_end,
        match_lines = { m.line },
      })
    end
  end
  return ranges
end

function M.open_context_buffer(selected, opts)
  opts = opts or {}
  if not selected or #selected == 0 then
    vim.notify("No results to display", vim.log.levels.WARN)
    return
  end

  local matches = {}
  for _, entry in ipairs(selected) do
    local parsed = parse_entry(entry, opts)
    if parsed and parsed.path and parsed.line and parsed.line > 0 then
      table.insert(matches, parsed)
    end
  end

  if #matches == 0 then
    vim.notify("No valid matches to display", vim.log.levels.WARN)
    return
  end

  local by_file, file_order = group_matches_by_file(matches)
  local context = get_context_lines()
  local buffer_lines = {}
  local line_map = {}
  local match_line_numbers = {}

  table.insert(buffer_lines, string.format("%d matches across %d files", #matches, #file_order))
  table.insert(line_map, false)

  for _, filepath in ipairs(file_order) do
    local file_matches = by_file[filepath]
    local ranges = merge_ranges(file_matches, context)
    local match_set = {}
    for _, m in ipairs(file_matches) do
      match_set[m.line] = true
    end

    table.insert(buffer_lines, "")
    table.insert(line_map, false)
    table.insert(buffer_lines, filepath .. ":")
    table.insert(line_map, { file = filepath, type = "header" })

    for ri, range in ipairs(ranges) do
      if ri > 1 then
        table.insert(buffer_lines, "....")
        table.insert(line_map, false)
      end

      local lines_data = read_file_lines(filepath, range.start_line, range.end_line)
      for _, ld in ipairs(lines_data) do
        local is_match = match_set[ld.lnum]
        local prefix = string.format("%5d%s ", ld.lnum, is_match and ":" or "-")
        table.insert(buffer_lines, prefix .. ld.text)
        table.insert(line_map, {
          file = filepath,
          lnum = ld.lnum,
          is_match = is_match,
          type = "content",
        })
        if is_match then
          table.insert(match_line_numbers, #buffer_lines)
        end
      end
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, buffer_lines)
  vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  vim.api.nvim_buf_set_name(buf, string.format("SearchContext://results/%d", buf))
  vim.api.nvim_set_option_value("filetype", "searchcontext", { buf = buf })

  vim.b[buf].search_context_line_map = line_map
  vim.b[buf].search_context_match_lines = match_line_numbers
  vim.b[buf].search_context_line_count = #buffer_lines
  vim.api.nvim_set_option_value("modified", false, { buf = buf })

  vim.cmd("topleft vsplit")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.api.nvim_win_set_width(win, M.config.width)

  M.setup_buffer_keymaps(buf)
  M.setup_buffer_autocmds(buf)
  M.setup_buffer_syntax(buf)

  if #match_line_numbers > 0 then
    vim.api.nvim_win_set_cursor(win, { match_line_numbers[1], 0 })
  end
end

function M.setup_buffer_keymaps(buf)
  local opts = { buffer = buf, noremap = true, silent = true }

  vim.keymap.set("n", "<CR>", function()
    M.jump_to_location(buf)
  end, opts)

  vim.keymap.set("n", "o", function()
    M.jump_to_location(buf)
  end, opts)

  vim.keymap.set("n", "s", function()
    M.jump_to_location(buf, "vsplit")
  end, opts)

  vim.keymap.set("n", "n", function()
    M.goto_next_match(buf, 1)
  end, opts)

  vim.keymap.set("n", "N", function()
    M.goto_next_match(buf, -1)
  end, opts)

  vim.keymap.set("n", "q", function()
    vim.api.nvim_buf_delete(buf, { force = true })
  end, opts)
end

function M.setup_buffer_autocmds(buf)
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      M.save_changes(buf)
    end,
  })
end

function M.setup_buffer_syntax(buf)
  vim.api.nvim_buf_call(buf, function()
    vim.cmd([[
      syntax match SearchContextFile /^[^ ].*:$/
      syntax match SearchContextMatch /^\s*\d\+:.*$/
      syntax match SearchContextContext /^\s*\d\+-.*$/
      syntax match SearchContextLineNum /^\s*\d\+[:-]/ contained containedin=SearchContextMatch,SearchContextContext
      syntax match SearchContextEllipsis /^\.\.\.\.$/
      syntax match SearchContextSummary /^\d\+ matches across \d\+ files$/

      highlight default link SearchContextFile Directory
      highlight default link SearchContextMatch None
      highlight default link SearchContextContext Comment
      highlight default link SearchContextLineNum LineNr
      highlight default link SearchContextEllipsis Comment
      highlight default link SearchContextSummary Title
    ]])
  end)
end

function M.jump_to_location(buf, split_cmd)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line_map = vim.b[buf].search_context_line_map
  if not line_map then
    return
  end

  local info = line_map[cursor[1]]
  if not info or not info.file then
    return
  end

  local target_file = info.file
  local target_line = info.lnum or 1

  local context_win = vim.api.nvim_get_current_win()
  vim.cmd("wincmd l")

  if split_cmd then
    vim.cmd(split_cmd)
  end
  vim.cmd("edit " .. vim.fn.fnameescape(target_file))
  vim.api.nvim_win_set_cursor(0, { target_line, 0 })
  vim.cmd("normal! zz")

  vim.api.nvim_set_current_win(context_win)
end

function M.goto_next_match(buf, direction)
  local match_lines = vim.b[buf].search_context_match_lines
  if not match_lines or #match_lines == 0 then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor[1]

  if direction > 0 then
    for _, ml in ipairs(match_lines) do
      if ml > current_line then
        vim.api.nvim_win_set_cursor(0, { ml, 0 })
        return
      end
    end
    vim.api.nvim_win_set_cursor(0, { match_lines[1], 0 })
  else
    for i = #match_lines, 1, -1 do
      if match_lines[i] < current_line then
        vim.api.nvim_win_set_cursor(0, { match_lines[i], 0 })
        return
      end
    end
    vim.api.nvim_win_set_cursor(0, { match_lines[#match_lines], 0 })
  end
end

function M.save_changes(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local line_map = vim.b[buf].search_context_line_map
  if not line_map then
    vim.notify("No line map found", vim.log.levels.ERROR)
    return
  end

  -- line_map is positional, so adding or removing a row silently retargets every
  -- edit below it; refuse rather than write to the wrong lines
  if #lines ~= vim.b[buf].search_context_line_count then
    vim.notify("Lines were added or removed - refusing to save", vim.log.levels.ERROR)
    return
  end

  local changes_by_file = {}
  for i, line in ipairs(lines) do
    local info = line_map[i]
    if info and info.type == "content" and info.file and info.lnum then
      local content = line:match("^%s*%d+[:-]%s?(.*)$")
      if content then
        if not changes_by_file[info.file] then
          changes_by_file[info.file] = {}
        end
        changes_by_file[info.file][info.lnum] = content
      end
    end
  end

  local files_changed = 0
  for filepath, line_changes in pairs(changes_by_file) do
    local file_lines = {}
    local f = io.open(filepath, "r")
    if f then
      for file_line in f:lines() do
        table.insert(file_lines, file_line)
      end
      f:close()

      local changed = false
      for lnum, new_content in pairs(line_changes) do
        if file_lines[lnum] ~= new_content then
          file_lines[lnum] = new_content
          changed = true
        end
      end

      if changed then
        f = io.open(filepath, "w")
        if f then
          f:write(table.concat(file_lines, "\n"))
          if #file_lines > 0 then
            f:write("\n")
          end
          f:close()
          files_changed = files_changed + 1
        end
      end
    end
  end

  vim.api.nvim_set_option_value("modified", false, { buf = buf })
  vim.notify(string.format("Saved changes to %d file(s)", files_changed), vim.log.levels.INFO)
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  local fzf_lua_ok, fzf_lua = pcall(require, "fzf-lua")
  if fzf_lua_ok then
    fzf_lua.setup({
      grep = {
        actions = {
          ["alt-enter"] = {
            fn = M.open_context_buffer,
            prefix = "select-all+",
          },
        },
      },
    })
  end

  vim.api.nvim_create_user_command("SearchContextOpen", function()
    local qf = vim.fn.getqflist()
    if #qf == 0 then
      vim.notify("Quickfix list is empty", vim.log.levels.WARN)
      return
    end
    local entries = {}
    for _, item in ipairs(qf) do
      -- bufname(0) resolves to the *current* buffer, which would show and then
      -- write to whatever file you happen to be editing
      if item.valid == 1 and item.bufnr and item.bufnr > 0 and item.lnum > 0 then
        local fname = vim.fn.bufname(item.bufnr)
        if fname ~= "" then
          table.insert(entries, string.format("%s:%d:%d:%s", fname, item.lnum, item.col, item.text))
        end
      end
    end
    if #entries == 0 then
      vim.notify("No quickfix entries with a resolvable file and line", vim.log.levels.WARN)
      return
    end
    M.open_context_buffer(entries, {})
  end, { desc = "Open quickfix list in context buffer" })

  -- normal-mode S only; visual S belongs to nvim-surround
  vim.keymap.set("n", "S", "<cmd>SearchContextOpen<cr>", { desc = "Search context buffer (from quickfix)" })
end

return M
