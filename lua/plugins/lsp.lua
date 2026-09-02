return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ts_ls",
          -- "vue_ls",
          -- "vtsls",
          "tailwindcss",
          "lua_ls",
          "ruff",
          "pyright",
          "oxlint",
        },
        automatic_enable = true,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local function find_workspace_root(startpath)
        if not startpath or startpath == "" then
          return nil
        end

        local markers = { "pnpm-workspace.yaml", ".git" }
        local found = vim.fs.find(markers, {
          path = startpath,
          upward = true,
          stop = vim.loop.os_homedir(),
          limit = 1,
        })[1]

        if not found then
          return nil
        end

        return vim.fs.dirname(found)
      end

      vim.lsp.config("oxlint", {
        cmd = function(dispatchers, config)
          local candidates = {}
          local root_dir = (config or {}).root_dir

          if root_dir then
            table.insert(candidates, vim.fs.joinpath(root_dir, "node_modules", ".bin", "oxlint"))

            local workspace_root = find_workspace_root(root_dir)
            if workspace_root and workspace_root ~= root_dir then
              table.insert(candidates, vim.fs.joinpath(workspace_root, "node_modules", ".bin", "oxlint"))
            end
          end

          local cmd = "oxlint"
          for _, candidate in ipairs(candidates) do
            if vim.fn.executable(candidate) == 1 then
              cmd = candidate
              break
            end
          end

          return vim.lsp.rpc.start({ cmd, "--lsp" }, dispatchers)
        end,
      })

      vim.lsp.config("pyright", {
        settings = {
          pyright = {
            disableOrganizeImports = true,
          },
          python = {
            analysis = {
              ignore = { "*" },
            },
          },
        },
      })

      vim.lsp.config("ruff", {
        init_options = {
          settings = {
            lint = {
              enable = true,
            },
          },
        },
      })

      -- lspconfig ranks .stylua.toml above .git, so a stray ~/.stylua.toml makes any
      -- repo without its own .luarc.json resolve to $HOME, which lua_ls refuses to load
      vim.lsp.config("lua_ls", {
        root_markers = {
          { ".emmyrc.json", ".luarc.json", ".luarc.jsonc" },
          { ".git" },
          { ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml" },
        },
      })

      -- ships inside the Xcode toolchain, so Mason never installs it
      vim.lsp.config("sourcekit", {
        filetypes = { "swift", "objc", "objcpp" },
      })

      vim.lsp.enable("pyright")
      vim.lsp.enable("ruff")
      vim.lsp.enable("eslint")
      vim.lsp.enable("oxlint")
      vim.lsp.enable("sourcekit")

      vim.keymap.set("n", "<space>1", function()
        local bufnr = vim.api.nvim_get_current_buf()

        if #vim.lsp.get_clients({ bufnr = bufnr, name = "oxlint" }) > 0 then
          vim.cmd("LspOxlintFixAll")
          return
        end

        if #vim.lsp.get_clients({ bufnr = bufnr, name = "eslint" }) > 0 then
          vim.cmd("LspEslintFixAll")
          return
        end

        vim.lsp.buf.code_action({
          apply = true,
          context = {
            only = { "source.fixAll" },
            diagnostics = vim.diagnostic.get(bufnr),
          },
        })
      end, {
        noremap = true,
        silent = true,
        desc = "Fix all auto-fixable issues",
      })

      vim.keymap.set("n", "<space><left>", function()
        vim.diagnostic.jump({ count = -1 })
      end)
      vim.keymap.set("n", "<space><right>", function()
        vim.diagnostic.jump({ count = 1 })
      end)

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "<space>wi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<space>w<space>", vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", "<space>wd", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "<space>wr", vim.lsp.buf.rename, opts)
          vim.keymap.set({ "n", "v" }, "<space>wa", vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    config = function()
      -- Primary Source of Truth is null-ls's setup
      require("mason-null-ls").setup({
        -- handlers = {},
        automatic_installation = true,
      })
    end,
  },
  {
    "nvimdev/lspsaga.nvim",
    config = function()
      require("lspsaga").setup({
        lightbulb = {
          enable = false,
        },
        symbol_in_winbar = {
          enable = false,
        },
      })

      vim.keymap.set({ "n", "v" }, "<space>l", "<cmd>Lspsaga code_action<CR>")
      vim.keymap.set("n", "<space>u", "<cmd>Lspsaga outgoing_calls<CR>")
      vim.keymap.set("n", "<space>U", "<cmd>Lspsaga incoming_calls<CR>")
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter", -- optional
      "nvim-tree/nvim-web-devicons", -- optional
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "j-hui/fidget.nvim",
    opts = {
      -- options
    },
  },
}
