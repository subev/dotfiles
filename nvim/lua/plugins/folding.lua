return {
  {
    -- ultra folding plugin
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    config = function()
      vim.o.foldcolumn = "0" -- 1, '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      -- Track fold level for incremental zm/zr (ufo ignores vim's native foldlevel)
      local ufo_fold_level = 99

      -- Re-enable foldenable if it was toggled off with zi
      local function ensure_folds()
        if not vim.wo.foldenable then
          vim.wo.foldenable = true
        end
      end

      -- Re-close LSP-reported "imports" folds. ufo has no public close-by-kind
      -- API, so read the cached ranges from its internal fold module.
      local function refold_imports()
        local ok, fold = pcall(require, "ufo.fold")
        if not ok then
          return
        end
        local fb = fold.get(vim.api.nvim_get_current_buf())
        if not fb or not fb.foldRanges then
          return
        end
        local cmds = {}
        for _, range in ipairs(fb.foldRanges) do
          if range.kind == "imports" then
            table.insert(cmds, (range.startLine + 1) .. "foldclose")
          end
        end
        if #cmds > 0 then
          pcall(vim.cmd, table.concat(cmds, "|"))
        end
      end

      -- zR: open all folds
      vim.keymap.set("n", "zR", function()
        ensure_folds()
        ufo_fold_level = 99
        require("ufo").openAllFolds()
      end)

      -- zM: close all folds
      vim.keymap.set("n", "zM", function()
        ensure_folds()
        ufo_fold_level = 0
        require("ufo").closeAllFolds()
      end)

      -- zm: close one fold level
      vim.keymap.set("n", "zm", function()
        ensure_folds()
        ufo_fold_level = math.max(0, ufo_fold_level - 1)
        require("ufo").closeFoldsWith(ufo_fold_level)
        refold_imports()
      end)

      -- zr: open one fold level
      vim.keymap.set("n", "zr", function()
        ensure_folds()
        ufo_fold_level = ufo_fold_level + 1
        require("ufo").closeFoldsWith(ufo_fold_level)
        refold_imports()
      end)

      -- Fold level presets — jump to a specific fold depth, then zv to reveal cursor
      -- zf/z0: close everything (same as zM but consistent with z1-z4)
      -- z1: top-level only (modules, classes) — maximum overview
      -- z2: + methods/functions inside top-level items
      -- z3: + nested blocks (if/for/try inside methods)
      -- z4: + deeply nested logic (callbacks, inner functions)
      local function close_and_reveal(level)
        ensure_folds()
        ufo_fold_level = level
        if level == 0 then
          require("ufo").closeAllFolds()
        else
          require("ufo").closeFoldsWith(level)
        end
        vim.schedule(function()
          vim.cmd("normal! zv")
          refold_imports()
        end)
      end

      vim.keymap.set("n", "zf", function()
        close_and_reveal(0)
      end)
      vim.keymap.set("n", "z0", function()
        close_and_reveal(0)
      end)
      vim.keymap.set("n", "z1", function()
        close_and_reveal(1)
      end)
      vim.keymap.set("n", "z2", function()
        close_and_reveal(2)
      end)
      vim.keymap.set("n", "z3", function()
        close_and_reveal(3)
      end)
      vim.keymap.set("n", "z4", function()
        close_and_reveal(4)
      end)

      require("ufo").setup({
        close_fold_kinds_for_ft = {
          javascript = { "imports" },
          javascriptreact = { "imports" },
          typescript = { "imports" },
          typescriptreact = { "imports" },
          python = { "imports" },
          go = { "imports" },
          rust = { "imports" },
          swift = { "imports" },
        },
        provider_selector = function()
          return { "lsp", "indent" }
        end,
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
          local newVirtText = {}
          local suffix = (" 󰁂 %d "):format(endLnum - lnum)
          local sufWidth = vim.fn.strdisplaywidth(suffix)
          local targetWidth = width - sufWidth
          local curWidth = 0
          for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
              table.insert(newVirtText, chunk)
            else
              chunkText = truncate(chunkText, targetWidth - curWidth)
              local hlGroup = chunk[2]
              table.insert(newVirtText, { chunkText, hlGroup })
              chunkWidth = vim.fn.strdisplaywidth(chunkText)
              -- str width returned from truncate() may less than 2nd argument, need padding
              if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
              end
              break
            end
            curWidth = curWidth + chunkWidth
          end
          table.insert(newVirtText, { suffix, "MoreMsg" })
          return newVirtText
        end,
      })
    end,
  },
}
