local M = { MODE_WIDTH = 20, ICON_WIDTH = 40, DIAGNOSTICS_WIDTH = 100 }
local server_cache = {}

local function status_win()
  local win = tonumber(vim.g.statusline_winid)
  return win and vim.api.nvim_win_is_valid(win) and win or vim.api.nvim_get_current_win()
end

local function short_path(path)
  return path and path ~= "" and vim.fn.fnamemodify(path, ":~") or "(none)"
end

local function sorted_clients(filter)
  local clients = vim.lsp.get_clients(filter)
  table.sort(clients, function(a, b)
    return a.name == b.name and a.id < b.id or a.name < b.name
  end)
  return clients
end

function M.cwd()
  if M.width() < 80 then
    return ""
  end
  local path = vim.fn.getcwd(status_win())
  return " " .. M.fit(vim.fs.basename(path) or path, M.width() < 140 and 12 or 18):gsub("%%", "%%%%")
end

function M.width()
  return vim.api.nvim_win_get_width(status_win())
end

-- Measure screen cells rather than bytes: filenames can contain Unicode.
function M.fit(text, cells)
  if vim.fn.strdisplaywidth(text) <= cells then
    return text
  end
  while text ~= "" and vim.fn.strdisplaywidth(text) > cells - 1 do
    text = vim.fn.strcharpart(text, 1)
  end
  return "…" .. text
end

function M.shorten_path(path)
  return path:gsub("([^/]+)/", function(folder)
    if vim.fn.strchars(folder) <= 4 or folder == ".." then
      return folder .. "/"
    end
    local prefix = folder:sub(1, 1) == "." and "." or ""
    local letters = folder:gsub("^%.", "")
    local consonants = letters:gsub("[aeiouAEIOU%-%_ ]", "")
    -- Vowel-heavy names such as audio need more than a single letter.
    local short = vim.fn.strchars(consonants) >= 3 and consonants or letters
    return prefix .. vim.fn.strcharpart(short, 0, 4) .. "/"
  end)
end

function M.filename()
  local win = status_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local name = vim.api.nvim_buf_get_name(buf)
  local width = M.width()
  if width < 3 then
    return ""
  end
  if vim.bo[buf].buftype == "terminal" then
    local tool = vim.w[win].sidekick_cli
    name = tool and tool.name or "terminal"
  elseif name == "" then
    name = "[No Name]"
  elseif width < 100 then
    name = vim.fs.basename(name)
  else
    local cwd = vim.fn.getcwd(win) .. "/"
    name = name:sub(1, #cwd) == cwd and name:sub(#cwd + 1) or short_path(name)
    name = M.shorten_path(name)
  end
  local reserved = 1 -- filename padding
  for _, component in ipairs({ M.cwd(), M.servers(), M.location() }) do
    if component ~= "" then
      reserved = reserved + vim.fn.strdisplaywidth(component:gsub("%%%%", "%%")) + 2
    end
  end
  if width >= M.MODE_WIDTH then
    reserved = reserved + 3
  end -- mode and padding
  if width >= M.ICON_WIDTH then
    reserved = reserved + 2
  end -- file devicon
  if width >= M.DIAGNOSTICS_WIDTH then
    local counts = vim.diagnostic.count(buf)
    for _, severity in ipairs({ vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN }) do
      if (counts[severity] or 0) > 0 then
        reserved = reserved + 4 + #tostring(counts[severity])
      end
    end
  end
  local references = M.references()
  if references ~= "" then
    reserved = reserved + vim.fn.strdisplaywidth(references) + 2
  end
  local modified = vim.bo[buf].modified and " +" or ""
  return ((M.fit(name, math.max(1, width - reserved - #modified)) .. modified):gsub("%%", "%%%%"))
end

local function servers()
  local width = M.width()
  if width < 20 then
    return ""
  end
  local buf = vim.api.nvim_win_get_buf(status_win())
  local clients = vim.lsp.get_clients({ bufnr = buf })
  -- Keep the language engine visible before supplemental linters.
  table.sort(clients, function(a, b)
    local priorities = { tsc = 1, ts_ls = 1, lua_ls = 1, pyright = 1 }
    local ap, bp = priorities[a.name] or 2, priorities[b.name] or 2
    return ap == bp and (a.name == b.name and a.id < b.id or a.name < b.name) or ap < bp
  end)
  local names = {}
  for _, client in ipairs(clients) do
    local name = client.name
    if width < 80 then
      name = ({ tsc = "TS7", ts_ls = "TS" })[name] or name
    elseif width >= 180 and name == "tsc" and client.server_info and client.server_info.version then
      name = name .. " " .. client.server_info.version
    end
    names[#names + 1] = name .. (client.initialized and "" or "…")
  end
  if #names == 0 and vim.bo[buf].buftype ~= "" then
    return ""
  end
  if #names == 0 then
    return " 0"
  elseif width < 40 then
    return " " .. #names
  end
  local budget = width < 60 and 9 or width < 80 and 16 or width < 140 and 20 or width < 180 and 28 or 40
  local shown = names[1]
  for i = 2, #names do
    local candidate = shown .. ", " .. names[i]
    local remaining = i < #names and (" +" .. (#names - i)) or ""
    if vim.fn.strdisplaywidth(candidate .. remaining) > budget - 2 then
      shown = M.fit(shown, budget - 2 - #(" +" .. (#names - i + 1))) .. " +" .. (#names - i + 1)
      return ((" " .. shown):gsub("%%", "%%%%"))
    end
    shown = candidate
  end
  return ((" " .. M.fit(shown, budget - 2)):gsub("%%", "%%%%"))
end

function M.servers()
  local win = status_win()
  local key = win .. ":" .. vim.api.nvim_win_get_buf(win) .. ":" .. M.width()
  if server_cache[key] == nil then
    server_cache[key] = servers()
    vim.schedule(function()
      server_cache = {}
    end)
  end
  return server_cache[key]
end

function M.location()
  local pos = vim.api.nvim_win_get_cursor(status_win())
  return M.width() < 30 and "" or M.width() < 80 and tostring(pos[1]) or (pos[1] .. ":" .. (pos[2] + 1))
end

function M.references()
  local refjump = package.loaded.refjump
  if M.width() < 140 or not refjump then
    return ""
  end
  local info = refjump.get_reference_info()
  return info.index and M.fit(string.format("[%d/%d]", info.index, info.total), 10) or ""
end

function M.details(win)
  win = win or vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local tab = vim.api.nvim_tabpage_get_number(vim.api.nvim_win_get_tabpage(win))
  local scope = vim.fn.haslocaldir(win, tab) == 1 and "window" or vim.fn.haslocaldir(-1, tab) == 1 and "tab" or "global"
  local lines = {
    "Working directory (" .. scope .. "): " .. short_path(vim.fn.getcwd(win, tab)),
    "Global directory: " .. short_path(vim.fn.getcwd(-1, -1)),
    "Tab directory: " .. short_path(vim.fn.getcwd(-1, tab)),
    "Buffer: " .. short_path(vim.api.nvim_buf_get_name(buf)),
    "Filetype: " .. (vim.bo[buf].filetype ~= "" and vim.bo[buf].filetype or "(none)"),
    "",
    "Attached to this buffer",
  }
  local attached = {}
  for _, client in ipairs(sorted_clients({ bufnr = buf })) do
    attached[client.id] = true
    local info = client.server_info or {}
    lines[#lines + 1] =
      string.format("  %s #%d — %s", client.name, client.id, client.initialized and "ready" or "starting")
    lines[#lines + 1] = "    Server version: " .. (info.version or "not reported")
    lines[#lines + 1] = "    Root: " .. short_path(client.root_dir)
    local cmd = client.config._resolved_cmd or client.config.cmd
    lines[#lines + 1] = "    Command: " .. (type(cmd) == "table" and table.concat(cmd, " ") or "custom launcher")
    for _, folder in ipairs(client.workspace_folders or {}) do
      lines[#lines + 1] = "    Workspace: " .. short_path(vim.uri_to_fname(folder.uri))
    end
  end
  if not next(attached) then
    lines[#lines + 1] = "  None"
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "Other running servers"
  local others = false
  for _, client in ipairs(sorted_clients()) do
    if not attached[client.id] then
      others = true
      lines[#lines + 1] = string.format("  %s #%d — %s", client.name, client.id, short_path(client.root_dir))
    end
  end
  if not others then
    lines[#lines + 1] = "  None"
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "q / Esc: close    H: full LSP health report"
  return lines
end

function M.show(win)
  local lines = M.details(win)
  local buf, float = vim.lsp.util.open_floating_preview(lines, "text", {
    border = "rounded",
    max_width = math.max(20, math.min(110, vim.o.columns - 4)),
    max_height = math.max(5, vim.o.lines - 6),
    focus_id = "workspace_info",
  })
  vim.api.nvim_set_current_win(float)
  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, function()
      vim.api.nvim_win_close(float, true)
    end, { buffer = buf, silent = true })
  end
  vim.keymap.set("n", "H", function()
    vim.api.nvim_win_close(float, true)
    vim.cmd("checkhealth vim.lsp")
  end, { buffer = buf, silent = true })
end

function M.click()
  local win = vim.fn.getmousepos().winid
  M.show(win ~= 0 and win or nil)
end

function M.setup()
  vim.api.nvim_create_user_command("WorkspaceInfo", function()
    M.show()
  end, { desc = "Show working directories and running language servers" })
  vim.keymap.set("n", "<space>wI", M.show, { desc = "Workspace and LSP info" })
  -- New nvim-lspconfig skips its legacy commands when Neovim provides :lsp.
  if vim.fn.exists(":LspInfo") == 0 then
    vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", { desc = "LSP health report" })
  end
end

return M
