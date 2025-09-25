local M = {}
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- Helper: collect top-level symbols and only keep exported ones
local function collect_exported_symbols(bufnr, symbols)
  local exported = {}
  vim.notify(string.format("Collecting exported symbols from %d symbols", #symbols))
  for _, s in ipairs(symbols or {}) do
    local line_num = s.range.start.line -- 0-based
    local ok, line = pcall(vim.api.nvim_buf_get_lines, bufnr, line_num, line_num + 1, false)
    line = ok and (line[1] or "") or ""

    vim.notify(string.format(
      "Symbol candidate: name=%s kind=%s line=%d text='%s'",
      s.name,
      tostring(s.kind),
      line_num + 1, -- for humans
      line
    ))

    if line:match("^%s*export%s+") then
      vim.notify("  ✅ accepted (export): " .. s.name)
      table.insert(exported, s)
    else
      vim.notify("  ❌ rejected (no export keyword): " .. s.name)
    end

    -- Recurse into children
    if s.children then
      for _, c in ipairs(collect_exported_symbols(bufnr, s.children)) do
        table.insert(exported, c)
      end
    end
  end

  vim.notify(string.format("Collected %d exported symbols", #exported))
  return exported
end

function M.find_file_references()
  local bufnr = vim.api.nvim_get_current_buf()
  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

  vim.notify("Requesting document symbols for current buffer...")

  vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", params, function(err, symbols)
    if err or not symbols then
      vim.notify("Error or no symbols found: " .. tostring(err))
      return
    end

    local top_symbols = collect_exported_symbols(bufnr, symbols)

    if #top_symbols == 0 then
      vim.notify("No exported symbols to process")
      return
    end

    local results = {}
    local pending = #top_symbols
    local abs_current = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p")

    for _, sym in ipairs(top_symbols) do
      vim.schedule(function()
        local ref_params = {
          textDocument = { uri = vim.uri_from_bufnr(bufnr) },
          position = { line = sym.range.start.line, character = sym.range.start.character },
          context = { includeDeclaration = true },
        }

        vim.notify("Requesting references for symbol: " .. sym.name)

        vim.lsp.buf_request(bufnr, "textDocument/references", ref_params, function(err2, refs)
          if err2 then
            vim.notify("Error getting references for symbol " .. sym.name .. ": " .. tostring(err2))
          end

          vim.notify(string.format("Found %d references for symbol %s", refs and #refs or 0, sym.name))

          if refs then
            for _, r in ipairs(refs) do
              local abs_uri = vim.fn.fnamemodify(vim.uri_to_fname(r.uri), ":p")
              -- exclude current file
              if abs_uri ~= abs_current then
                local rel = vim.fn.fnamemodify(abs_uri, ":.")
                local line_num = r.range.start.line + 1
                local ok, line = pcall(
                  vim.api.nvim_buf_get_lines,
                  vim.uri_to_bufnr(r.uri),
                  r.range.start.line,
                  r.range.start.line + 1,
                  false
                )
                line = ok and (line[1] or "") or ""
                table.insert(results, {
                  filename = rel,
                  lnum = line_num,
                  text = line,
                })
              end
            end
          end

          pending = pending - 1
          if pending == 0 then
            vim.notify("All references collected, total: " .. #results)
            if #results == 0 then
              vim.notify("No references found")
              return
            end

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
