return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        oxfmt = {
          command = "oxfmt",
          args = { "$FILENAME" },
          stdin = false,
          -- When stdin=false, use this template to generate the temporary file that gets formatted
          tmpfile_format = ".conform.$RANDOM.$FILENAME",
        },
        swift_format = {
          inherit = false,
          command = "swift",
          -- swift-format only auto-discovers .swift-format next to the input, and conform
          -- feeds it a temp file, so the project config has to be passed explicitly
          args = function(_, ctx)
            local args = { "format", "--in-place" }
            local config = vim.fs.find(".swift-format", { path = ctx.dirname, upward = true })[1]
            if config then
              vim.list_extend(args, { "--configuration", config })
            end
            table.insert(args, "$FILENAME")
            return args
          end,
          stdin = false,
        },
      },
      formatters_by_ft = {
        lua = { "stylua" },
        -- Conform will run multiple formatters sequentially
        python = { "ruff_format" },
        -- You can customize some of the format options for the filetype (:help conform.format)
        rust = { "rustfmt", lsp_format = "fallback" },
        swift = { "swift_format" },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        -- Conform will run the first available formatter
        javascript = {
          "oxfmt",
          "prettierd",
          "prettier",
          stop_after_first = true,
        },
        typescript = {
          "oxfmt",
          "prettierd",
          "prettier",
          stop_after_first = true,
        },
        javascriptreact = {
          "oxfmt",
          "prettierd",
          "prettier",
          stop_after_first = true,
        },
        typescriptreact = {
          "oxfmt",
          "prettierd",
          "prettier",
          stop_after_first = true,
        },
        css = { "prettierd", "prettier", stop_after_first = true },
      },
      format_after_save = function(bufnr)
        local name = vim.api.nvim_buf_get_name(bufnr)
        -- If a large file, don't format on save
        local max_filesize = 512 * 1024 -- 512 KB
        local ok, stats = pcall(vim.loop.fs_stat, name)
        if ok and stats and stats.size > max_filesize then
          return
        end
        return { lsp_fallback = false }
      end,
    },
    init = function()
      vim.api.nvim_create_user_command("Format", function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
          }
        end
        require("conform").format({ async = true, lsp_format = "fallback", range = range })
      end, { range = true })

      -- maps it to <space>f
      vim.keymap.set("n", "<space>f", ":Format<CR>", { noremap = true, silent = true, desc = "Format buffer" })
      vim.keymap.set("v", "<space>f", ":Format<CR>", { noremap = true, silent = true, desc = "Format selection" })

      -- set up formatexpr for gq formatting
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvimtools/none-ls-extras.nvim",
    },
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          -- formatting is handled by conform.nvim, so we don't need these
          -- null_ls.builtins.formatting.stylua,
          -- null_ls.builtins.formatting.prettierd,

          -- COMMENTED OUT: These code actions cause 3-4s delay in lspsaga
          -- Refactoring actions - uncomment if you find you need them
          -- null_ls.builtins.code_actions.refactoring,

          -- ESLint code actions - now handled by native eslint LSP (fast!)
          -- Use <space>1 for ESLint auto-fix instead
          -- require("none-ls.code_actions.eslint"),

          -- KEEP: ESLint formatting (this is fast and works on save)
          -- require("none-ls.formatting.eslint"),

          -- null_ls.builtins.completion.spell,
          -- require("none-ls.diagnostics.eslint"),
          -- require("none-ls.diagnostics.eslint"),
          -- require("none-ls.code_actions.eslint"),
          -- require("none-ls.formatting.eslint"),
        },
      })
    end,
  },
  "editorconfig/editorconfig-vim",
}
