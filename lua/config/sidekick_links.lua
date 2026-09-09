local M = {}
local ns = vim.api.nvim_create_namespace("sidekick_file_reference")
local last_code_win = {}
local highlighted
local consumed_click = false

function M.parse(text)
  text = vim.trim(text):gsub("[.,;!?:]+$", ""):gsub("^@", "")
  local normalized = text:gsub("(%d)–(%d+)$", "%1-%2"):gsub("(%d)—(%d+)$", "%1-%2")
  local path, first, last = normalized:match("^(.-)#L(%d+)%-L?(%d+)$")
  if not path then
    path, first, last = normalized:match("^(.-):(%d+)%-(%d+)$")
  end
  local col
  if not path then
    path, first, col = normalized:match("^(.-):(%d+):(%d+)$")
  end
  if not path then
    path, first = normalized:match("^(.-)#L(%d+)$")
  end
  if not path then
    path, first = normalized:match("^(.-):(%d+)$")
  end
  path = path or normalized
  if path:match("^file://") then
    path = vim.uri_to_fname(path)
  elseif path:match("^[%a][%w+.-]*://") then
    return nil
  end
  if path == "" or not path:find("[/%.]") or path:find("[\r\n]") then
    return nil
  end
  first, last, col = tonumber(first), tonumber(last), tonumber(col)
  if (first and first < 1) or (col and col < 1) or (last and last < first) then
    return nil
  end
  return { path = path, line = first, last = last or first, col = col or 1 }
end

local function in_text(text, column)
  -- Quoted paths and Markdown destinations can contain spaces.
  for _, pattern in ipairs({
    "`()([^`]+)()`",
    '"()([^"]+)()"',
    "'()([^']+)()'",
    "%(()([^%)]+)()%)",
    "()([^%s`\"'<>%[%]%(%)]+)()",
  }) do
    for first, candidate, finish in text:gmatch(pattern) do
      if column >= first and column < finish then
        local ref = M.parse(candidate)
        if ref then
          return ref
        end
      end
    end
  end
end

function M.at(win, row, column)
  local buf = vim.api.nvim_win_get_buf(win)
  local count = vim.api.nvim_buf_line_count(buf)
  if row < 1 or row > count or column < 1 then
    return nil
  end
  local lines = vim.api.nvim_buf_get_lines(buf, math.max(0, row - 3), math.min(count, row + 2), false)
  local index = math.min(row, 3)
  local text, offset = lines[index], column
  local width = vim.api.nvim_win_get_width(win) - vim.fn.getwininfo(win)[1].textoff
  -- Terminal wrapping can split a path anywhere. Join only full-width rows,
  -- allowing the small right margin used by AI terminal renderers.
  if vim.bo[buf].buftype == "terminal" then
    local first, last = index, index
    while first > 1 and vim.fn.strdisplaywidth(lines[first - 1]) >= width - 3 do
      first = first - 1
      local previous = lines[first]:gsub("%s+$", "")
      local indent = #(text:match("^%s*") or "")
      text = previous .. text:sub(indent + 1)
      offset = #previous + offset - indent
    end
    while last < #lines and vim.fn.strdisplaywidth(lines[last]) >= width - 3 do
      last = last + 1
      text = text:gsub("%s+$", "") .. lines[last]:gsub("^%s+", "")
    end
  end
  local ref = in_text(text, offset)
  local plain = in_text(lines[index], column)
  if ref and plain and not vim.deep_equal(ref, plain) then
    ref.alternative = plain
  end
  return ref or plain
end

function M.resolve(ref, cwd, done)
  local refs = { ref }
  if ref.alternative then
    refs[#refs + 1] = ref.alternative
  end
  local function direct(candidate)
    local path = candidate.path
    if path:sub(1, 2) == "~/" then
      path = vim.uv.os_homedir() .. path:sub(2)
    end
    local absolute = path:sub(1, 1) == "/"
    local target = vim.fs.normalize(absolute and path or vim.fs.joinpath(cwd, path))
    local stat = vim.uv.fs_stat(target)
    return stat and stat.type == "file" and target or nil, absolute
  end
  local function finish(files, err)
    for _, candidate in ipairs(refs) do
      local target, absolute = direct(candidate)
      if target then
        return done({ target }, candidate)
      end
      local matches = {}
      if not absolute then
        local path = candidate.path:gsub("^%./", "")
        for _, file in ipairs(files) do
          if file == path or file:sub(-#path - 1) == "/" .. path then
            matches[#matches + 1] = vim.fs.joinpath(cwd, file)
          end
        end
      end
      if #matches > 0 then
        table.sort(matches)
        return done(matches, candidate)
      end
    end
    done({}, ref, err)
  end
  local target, absolute = direct(ref)
  if target or (absolute and not ref.alternative) then
    return finish({})
  end
  if vim.fn.executable("rg") ~= 1 then
    return finish({}, "Install ripgrep to resolve abbreviated file references")
  end
  local ok, err = pcall(vim.system, { "rg", "--files", "--hidden", "-g", "!.git", "-g", "!node_modules" }, {
    cwd = cwd,
    text = true,
    timeout = 3000,
  }, function(result)
    vim.schedule(function()
      finish(
        result.code == 0 and vim.split(result.stdout or "", "\n", { trimempty = true }) or {},
        result.code ~= 0 and "File reference search failed or timed out" or nil
      )
    end)
  end)
  if not ok then
    finish({}, "Could not search file references: " .. tostring(err))
  end
end

local function code_window(win)
  return win
    and vim.api.nvim_win_is_valid(win)
    and vim.api.nvim_win_get_config(win).relative == ""
    and vim.bo[vim.api.nvim_win_get_buf(win)].buftype == ""
    and not vim.w[win].sidekick_session_id
end

local function clear_highlight()
  if highlighted and vim.api.nvim_buf_is_valid(highlighted) then
    vim.api.nvim_buf_clear_namespace(highlighted, ns, 0, -1)
  end
  highlighted = nil
  vim.api.nvim_clear_autocmds({ group = "SidekickReferenceHighlight" })
end

function M.open(path, ref, source_win)
  if not vim.api.nvim_win_is_valid(source_win) then
    return
  end
  local tab = vim.api.nvim_win_get_tabpage(source_win)
  local target = last_code_win[tab]
  if not code_window(target) or vim.api.nvim_win_get_tabpage(target) ~= tab then
    target = nil
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if code_window(win) then
      target = target or win
      if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)) == path then
        target = win
        break
      end
    end
  end
  vim.cmd.stopinsert()
  if not target then
    vim.api.nvim_set_current_win(source_win)
    vim.cmd("leftabove vsplit")
    target = vim.api.nvim_get_current_win()
    vim.w[target].sidekick_session_id = nil
    vim.w[target].sidekick_cli = nil
  end
  vim.api.nvim_set_current_win(target)
  vim.cmd("normal! m'")
  -- :edit respects unsaved-buffer protections; never force or execute a path.
  local ok, err = pcall(vim.cmd.edit, { args = { path } })
  if not ok then
    vim.notify(tostring(err), vim.log.levels.WARN)
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  local count = vim.api.nvim_buf_line_count(buf)
  local first, last = math.min(ref.line or 1, count), math.min(ref.last or ref.line or 1, count)
  local line = vim.api.nvim_buf_get_lines(buf, first - 1, first, false)[1] or ""
  local col = math.min(ref.col - 1, math.max(0, #line - 1))
  vim.api.nvim_win_set_cursor(target, { first, col })
  -- Keep scrolloff context above the reference and maximize the range below it.
  vim.cmd("normal! zvzt")
  clear_highlight()
  if not ref.line then
    return
  end
  vim.api.nvim_buf_set_extmark(buf, ns, first - 1, 0, {
    end_row = last,
    end_col = 0,
    hl_group = "Visual",
    hl_eol = true,
    priority = 180,
  })
  highlighted = buf
  vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "TextChanged", "BufWipeout" }, {
    group = "SidekickReferenceHighlight",
    buffer = buf,
    callback = function(ev)
      local pos = vim.api.nvim_win_get_cursor(0)
      if ev.event ~= "CursorMoved" or pos[1] ~= first or pos[2] ~= col then
        clear_highlight()
      end
    end,
  })
end

local function terminal(win)
  local id = vim.w[win].sidekick_session_id
  local mod = package.loaded["sidekick.cli.terminal"]
  return id and mod and mod.get(id)
end

local request_id = 0
local function follow(ref, win, term)
  request_id = request_id + 1
  local request = request_id
  local buf = vim.api.nvim_win_get_buf(win)
  M.resolve(ref, term.cwd or vim.fn.getcwd(win), function(matches, resolved, err)
    if request ~= request_id or not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
      return
    end
    if #matches == 0 then
      vim.notify(err or ("File reference not found: " .. resolved.path), vim.log.levels.WARN)
    elseif #matches == 1 then
      M.open(matches[1], resolved, win)
    else
      vim.ui.select(matches, {
        prompt = "Open file reference:",
        format_item = function(path)
          return vim.fn.fnamemodify(path, ":~")
        end,
      }, function(path)
        if path and request == request_id then
          M.open(path, resolved, win)
        end
      end)
    end
  end)
end

function M.gf(term)
  local win = vim.api.nvim_get_current_win()
  local pos = vim.api.nvim_win_get_cursor(win)
  local ref = M.at(win, pos[1], pos[2] + 1)
  if not ref then
    vim.notify("No file reference under cursor", vim.log.levels.INFO)
    return
  end
  follow(ref, win, term)
end

function M.mouse()
  consumed_click = false
  local pos = vim.fn.getmousepos()
  local term = pos.winid ~= 0 and terminal(pos.winid)
  local ref = term and M.at(pos.winid, pos.line, pos.column)
  if not ref then
    if term then
      consumed_click = true
    elseif
      vim.fn.mode() == "n"
      and pos.winid ~= 0
      and code_window(pos.winid)
      and vim.fn.maparg("<Plug>(VM-Mouse-Cursor)", "n") ~= ""
    then
      vim.api.nvim_feedkeys(vim.keycode("<Plug>(VM-Mouse-Cursor)"), "m", false)
    else
      vim.api.nvim_feedkeys(vim.keycode("<C-LeftMouse>"), "n", false)
    end
    return
  end
  consumed_click = true
  -- Capture everything before TermLeave can replace the live terminal with
  -- Sidekick's scrollback dump. Handle the click entirely inside Neovim.
  vim.cmd.stopinsert()
  vim.schedule(function()
    follow(ref, pos.winid, term)
  end)
end

function M.setup()
  vim.api.nvim_create_augroup("SidekickReferenceHighlight", { clear = true })
  local group = vim.api.nvim_create_augroup("SidekickReferenceWindows", { clear = true })
  local function remember()
    local win = vim.api.nvim_get_current_win()
    if code_window(win) then
      last_code_win[vim.api.nvim_get_current_tabpage()] = win
    end
  end
  remember()
  vim.api.nvim_create_autocmd("TabClosed", {
    group = group,
    callback = function()
      for tab in pairs(last_code_win) do
        if not vim.api.nvim_tabpage_is_valid(tab) then
          last_code_win[tab] = nil
        end
      end
    end,
  })
  vim.api.nvim_create_autocmd("WinEnter", { group = group, callback = remember })
  -- Global dispatch is necessary when clicking the AI pane from a code window.
  vim.keymap.set({ "n", "t" }, "<C-LeftMouse>", M.mouse, { desc = "Open Sidekick file reference" })
  vim.keymap.set({ "n", "t" }, "<C-LeftRelease>", function()
    if consumed_click then
      consumed_click = false
      return
    end
    vim.api.nvim_feedkeys(vim.keycode("<C-LeftRelease>"), "n", false)
  end, { desc = "Finish Sidekick file-reference click" })
end

return M
