-- find_exports_telescope.lua (query-free, robust)
-- Walks the treesitter AST to find export_statement nodes, extracts shallow
-- identifier/type_identifier children as exported names, then asks LSP for
-- references and presents external references in a Telescope picker (or quickfix
-- fallback).

local M = {}

local pickers_ok, pickers = pcall(require, "telescope.pickers")
local finders_ok, finders = pcall(require, "telescope.finders")
local actions_ok, actions = pcall(require, "telescope.actions")
local action_state_ok, action_state = pcall(require, "telescope.actions.state")
local conf_ok, conf = pcall(require, "telescope.config")
local telescope_conf_values = conf_ok and conf.values or nil

local function ts_lang_for_buf(bufnr)
  local ft = vim.bo[bufnr].filetype or ""
  if ft == "typescriptreact" then
    return "tsx"
  end
  if ft == "javascriptreact" then
    return "javascript"
  end
  return ft
end

local function get_line_from_uri(uri, lnum)
  local bufnr = vim.uri_to_bufnr(uri)
  if vim.api.nvim_buf_is_loaded(bufnr) then
    local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, lnum, lnum + 1, false)
    if ok and lines and lines[1] then
      return lines[1]
    end
  end
  local fname = vim.uri_to_fname(uri)
  local f = io.open(fname, "r")
  if not f then
    return ""
  end
  local i = 0
  for line in f:lines() do
    if i == lnum then
      f:close()
      return line
    end
    i = i + 1
  end
  f:close()
  return ""
end

-- Walk the tree to collect export_statement nodes (no queries used)
local function collect_export_statement_nodes(bufnr)
  local lang = ts_lang_for_buf(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok or not parser then
    return nil, "no treesitter parser for " .. tostring(lang)
  end
  local tree = parser:parse()[1]
  if not tree then
    return nil, "failed to parse buffer"
  end
  local root = tree:root()

  local nodes = {}
  local function walk(node)
    if not node then
      return
    end
    if node:type() == "export_statement" then
      table.insert(nodes, node)
      return -- don't walk inside this node deeper than we need (we'll shallow-scan it later)
    end
    for child in node:iter_children() do
      walk(child)
    end
  end
  walk(root)
  return nodes
end

-- Collect only the first/direct exported name from each top-level export_statement.
local function collect_exports_from_nodes(bufnr, nodes, opts)
  opts = opts or {}
  local exports = {}
  local MAX_DEPTH = 3

  local function shallow_find(node, depth)
    if depth > MAX_DEPTH then
      return nil
    end
    for child in node:iter_children() do
      local t = child:type()
      if t == "identifier" or t == "type_identifier" then
        return child
      end
      local found = shallow_find(child, depth + 1)
      if found then
        return found
      end
    end
    return nil
  end

  for _, stmt in ipairs(nodes) do
    -- skip re-exports like `export { x } from "..."` (they reference other files)
    local is_reexport = false
    for ch in stmt:iter_children() do
      if ch:type() == "string" or ch:type() == "source" then
        is_reexport = true
        break
      end
    end
    if is_reexport then
      goto continue
    end

    local name_node = shallow_find(stmt, 0)
    if name_node then
      local name = vim.treesitter.get_node_text(name_node, bufnr)
      if name and name ~= "" and not exports[name] then
        local r, c = name_node:start()
        exports[name] = { line = r, col = c, node = name_node }
        if opts.verbose then
          vim.notify(string.format("export found: %s @%d:%d", name, r + 1, c + 1))
        end
      end
    end

    ::continue::
  end

  return exports
end

-- Ask LSP for references for each candidate and collect external references
local function find_references_for_candidates(bufnr, candidates, opts, cb)
  opts = opts or {}
  local results = {}
  local pending = #candidates
  if pending == 0 then
    cb(results)
    return
  end

  local abs_current = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p")

  for _, cand in ipairs(candidates) do
    vim.schedule(function()
      if opts.verbose then
        vim.notify(string.format("requesting refs for %s @ %d:%d", cand.name, cand.pos.line + 1, cand.pos.col + 1))
      end
      local params = {
        textDocument = { uri = vim.uri_from_bufnr(bufnr) },
        position = { line = cand.pos.line, character = cand.pos.col },
        context = { includeDeclaration = true },
      }

      vim.lsp.buf_request(bufnr, "textDocument/references", params, function(err, refs)
        if err then
          if opts.verbose then
            vim.notify("LSP refs error for " .. cand.name .. ": " .. vim.inspect(err), vim.log.levels.WARN)
          end
        end

        if refs then
          for _, r in ipairs(refs) do
            -- support both Location and LocationLink shapes
            local uri = r.uri or r.targetUri
            local range = r.range or r.targetSelectionRange
            if uri and range then
              local abs_uri = vim.fn.fnamemodify(vim.uri_to_fname(uri), ":p")
              if abs_uri ~= abs_current then -- drop current buffer refs
                local rel = vim.fn.fnamemodify(abs_uri, ":.")
                local lnum = range.start.line + 1
                local text = get_line_from_uri(uri, range.start.line)
                table.insert(results, { filename = rel, lnum = lnum, text = text, symbol = cand.name })
              end
            end
          end
        else
          if opts.verbose then
            vim.notify(string.format("no refs returned for %s", cand.name))
          end
        end

        pending = pending - 1
        if pending == 0 then
          cb(results)
        end
      end)
    end)
  end
end

local function show_results(results)
  if not results or vim.tbl_isempty(results) then
    vim.notify("No external references found.")
    return
  end

  table.sort(results, function(a, b)
    if a.filename == b.filename then
      return a.lnum > b.lnum
    end
    return a.filename > b.filename
  end)

  if pickers_ok and finders_ok and conf_ok and actions_ok and action_state_ok then
    pickers
      .new({}, {
        prompt_title = "Export References",
        finder = finders.new_table({
          results = results,
          entry_maker = function(item)
            return {
              value = item,
              display = string.format(
                "%s:%d [%s] %s",
                item.filename,
                item.lnum,
                item.symbol or "",
                vim.trim(item.text or "")
              ),
              ordinal = item.filename .. " " .. tostring(item.lnum) .. " " .. (item.text or ""),
              filename = item.filename,
              lnum = item.lnum,
              text = item.text,
              symbol = item.symbol,
            }
          end,
        }),
        sorter = telescope_conf_values and telescope_conf_values.generic_sorter({}) or nil,
        previewer = telescope_conf_values and telescope_conf_values.grep_previewer({}) or nil,
        attach_mappings = function(prompt_bufnr, _)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              local fname = vim.fn.fnameescape(selection.filename)
              vim.cmd("edit " .. fname)
              pcall(function()
                vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
              end)
            end
          end)
          return true
        end,
      })
      :find()
  else
    -- simple quickfix fallback
    local qf = {}
    for _, r in ipairs(results) do
      table.insert(
        qf,
        { filename = r.filename, lnum = r.lnum, col = 1, text = string.format("[%s] %s", r.symbol, r.text) }
      )
    end
    vim.fn.setqflist({}, " ", { title = "Export references", items = qf })
    vim.cmd("copen")
  end
end

-- Public entry
function M.find_exports_and_refs(user_opts)
  user_opts = user_opts or {}
  local verbose = user_opts.verbose
  local bufnr = vim.api.nvim_get_current_buf()

  local nodes, err = collect_export_statement_nodes(bufnr)
  if not nodes then
    vim.notify("collect_export_statement_nodes failed: " .. tostring(err), vim.log.levels.WARN)
    return
  end

  local exports = collect_exports_from_nodes(bufnr, nodes, { verbose = verbose })
  local candidates = {}
  for name, meta in pairs(exports) do
    table.insert(candidates, { name = name, pos = { line = meta.line, col = meta.col } })
  end

  if #candidates == 0 then
    vim.notify("No export candidates found (treesitter).", vim.log.levels.INFO)
    return
  end

  find_references_for_candidates(bufnr, candidates, user_opts, function(results)
    show_results(results)
  end)
end

function M.setup(user_opts)
  user_opts = user_opts or {}
  vim.api.nvim_create_user_command("FindExportsRefsTelescope", function()
    M.find_exports_and_refs(user_opts)
  end, {})
  vim.keymap.set("n", "<Space>0", function()
    M.find_exports_and_refs(user_opts)
  end, { noremap = true, silent = true })
end

return M
