local M = {}
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- Helper: collect top-level symbols and only keep exported ones
---@param bufnr integer
---@param symbols table
---@return table
local function collect_exported_symbols(bufnr, symbols)
  local exported = {}
  for _, s in ipairs(symbols or {}) do
    local line_num = s.range["start"].line -- 0-based
    local ok, line = pcall(vim.api.nvim_buf_get_lines, bufnr, line_num, line_num + 1, false)
    line = ok and (line[1] or "") or ""

    if line:match("^%s*export%s+") then
      table.insert(exported, s)
    end

    -- Recurse into children
    if s.children then
      for _, c in ipairs(collect_exported_symbols(bufnr, s.children)) do
        table.insert(exported, c)
      end
    end
  end
  return exported
end

---Get line text from buffer or file
---@param uri string
---@param lnum integer 0-based
---@return string
local function get_line_from_uri(uri, lnum)
  local bufnr = vim.uri_to_bufnr(uri)
  if vim.api.nvim_buf_is_loaded(bufnr) then
    local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, lnum, lnum + 1, false)
    if ok and lines and lines[1] then
      return lines[1]
    end
  end
  -- fallback: read directly from file
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

---Find references to exported symbols from the current file
function M.find_file_references()
  local bufnr = vim.api.nvim_get_current_buf()
  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

  vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", params, function(err, symbols)
    if err or not symbols then
      return
    end

    local top_symbols = collect_exported_symbols(bufnr, symbols)
    if #top_symbols == 0 then
      return
    end

    local results = {}
    local pending = #top_symbols
    local abs_current = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p")

    for _, sym in ipairs(top_symbols) do
      vim.schedule(function()
        local ref_params = {
          textDocument = { uri = vim.uri_from_bufnr(bufnr) },
          position = { line = sym.range["start"].line, character = sym.range["start"].character },
          context = { includeDeclaration = true },
        }

        vim.lsp.buf_request(bufnr, "textDocument/references", ref_params, function(err2, refs)
          if refs then
            for _, r in ipairs(refs) do
              local abs_uri = vim.fn.fnamemodify(vim.uri_to_fname(r.uri), ":p")
              if abs_uri ~= abs_current then
                local rel = vim.fn.fnamemodify(abs_uri, ":.")
                local line_num = r.range["start"].line + 1
                local line = get_line_from_uri(r.uri, r.range["start"].line)
                table.insert(results, {
                  filename = rel,
                  lnum = line_num,
                  text = line,
                })
              end
            end
          end

          pending = pending - 1
          if pending == 0 and #results > 0 then
            table.sort(results, function(a, b)
              return a.filename > b.filename or (a.filename == b.filename and a.lnum > b.lnum)
            end)

            pickers
              .new({}, {
                prompt_title = "File References",
                finder = finders.new_table({
                  results = results,
                  entry_maker = function(item)
                    return {
                      value = item,
                      display = string.format("%s:%d %s", item.filename, item.lnum, item.text),
                      ordinal = item.filename .. " " .. item.text,
                      filename = item.filename,
                      lnum = item.lnum,
                      text = item.text,
                    }
                  end,
                }),
                sorter = conf.generic_sorter({}),
                previewer = conf.grep_previewer({}),
                attach_mappings = function(prompt_bufnr, _)
                  actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    if selection then
                      vim.cmd(string.format("edit %s | %d", selection.filename, selection.lnum))
                    end
                  end)
                  return true
                end,
              })
              :find()
          end
        end)
      end)
    end
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("FindFileReferences", M.find_file_references, {})
  vim.keymap.set("n", "<Space>9", M.find_file_references, { noremap = true, silent = true })
end

return M
