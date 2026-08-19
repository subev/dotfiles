local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
vim.opt.termguicolors = true

local function find_textclub_root(startpath)
  local path = startpath or vim.fn.expand("%:p:h")
  if path == "" then
    path = vim.fn.getcwd()
  end

  local root_marker = vim.fs.find({ "pnpm-workspace.yaml", ".git" }, {
    path = path,
    upward = true,
    stop = vim.loop.os_homedir(),
    limit = 1,
  })[1]

  if not root_marker then
    return nil
  end

  local root = vim.fs.dirname(root_marker)
  if vim.fs.basename(root) ~= "textclub" then
    return nil
  end

  return root
end

local function run_textclub_overseer_task(script_name)
  local root = find_textclub_root()
  if not root then
    vim.notify("Not inside the textclub workspace", vim.log.levels.WARN)
    return
  end

  local overseer = require("overseer")
  local task = overseer.new_task({
    name = "pnpm run " .. script_name,
    cmd = { "pnpm", "run", script_name },
    cwd = root,
    components = {
      { "unique", replace = false },
      "default",
    },
  })

  task:start()
  task:open_output("vertical")
end

local function open_recent_overseer_output()
  local overseer = require("overseer")
  local tasks = overseer.list_tasks({})
  if vim.tbl_isempty(tasks) then
    vim.notify("No Overseer tasks found", vim.log.levels.WARN)
    return
  end

  table.sort(tasks, function(a, b)
    local a_time = a.time_start or a.time_end or 0
    local b_time = b.time_start or b.time_end or 0
    return a_time > b_time
  end)

  tasks[1]:open_output("float")
end

require("lazy").setup({
  -- ============================================================================
  -- COLORSCHEMES
  -- ============================================================================
  "sainnhe/sonokai",
  "sainnhe/everforest",

  -- ============================================================================
  -- TREESITTER & SYNTAX
  -- ============================================================================
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      -- shows wrapping function signature if it is outside of the view
      "nvim-treesitter/nvim-treesitter-context",
    },
    config = function()
      require("nvim-treesitter").setup({})
      -- Install all parsers (lazy-loaded, no perf impact)
      require("nvim-treesitter").install("all")
      -- Enable treesitter highlighting for all filetypes
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    lazy = false,
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          selection_modes = {
            ["@parameter.outer"] = "v",
            ["@function.outer"] = "V",
            ["@class.outer"] = "<c-v>",
          },
          include_surrounding_whitespace = false,
        },
        move = {
          set_jumps = true,
        },
      })

      local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject
      local move = require("nvim-treesitter-textobjects.move")

      -- Select textobjects
      vim.keymap.set({ "x", "o" }, "af", function()
        select_textobject("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "if", function()
        select_textobject("@function.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ac", function()
        select_textobject("@class.outer", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ic", function()
        select_textobject("@class.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "as", function()
        select_textobject("@local.scope", "locals")
      end)
      vim.keymap.set({ "x", "o" }, "ir", function()
        select_textobject("@return.inner", "textobjects")
      end)
      vim.keymap.set({ "x", "o" }, "ar", function()
        select_textobject("@return.outer", "textobjects")
      end)

      -- Move textobjects
      vim.keymap.set({ "n", "x", "o" }, "]m", function()
        move.goto_next_start("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "n", "x", "o" }, "]s", function()
        move.goto_next_start("@local.scope", "locals")
      end)
      vim.keymap.set({ "n", "x", "o" }, "]M", function()
        move.goto_next_end("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "n", "x", "o" }, "][", function()
        move.goto_next_end("@class.outer", "textobjects")
      end)
      vim.keymap.set({ "n", "x", "o" }, "[m", function()
        move.goto_previous_start("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "n", "x", "o" }, "[M", function()
        move.goto_previous_end("@function.outer", "textobjects")
      end)
      vim.keymap.set({ "n", "x", "o" }, "[]", function()
        move.goto_previous_end("@class.outer", "textobjects")
      end)
      vim.keymap.set({ "n", "x", "o" }, "]d", function()
        move.goto_next("@conditional.outer", "textobjects")
      end)
      vim.keymap.set({ "n", "x", "o" }, "[d", function()
        move.goto_previous("@conditional.outer", "textobjects")
      end)
    end,
  },
  "HiPhish/rainbow-delimiters.nvim",

  -- ============================================================================
  -- LSP & LANGUAGE SERVERS
  -- ============================================================================
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

      vim.lsp.enable("pyright")
      vim.lsp.enable("ruff")
      vim.lsp.enable("eslint")
      vim.lsp.enable("oxlint")

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

  -- ============================================================================
  -- COMPLETION
  -- ============================================================================
  {
    "saghen/blink.cmp",
    -- optional: provides snippets for the snippet source
    dependencies = {
      "rafamadriz/friendly-snippets",
      {
        "mikavilpas/blink-ripgrep.nvim",
        version = "*", -- use the latest stable version
      },
      -- this adds blink suggestion items that are same as copilot, search below 'copilot'
      -- { "fang2hou/blink-copilot" },
    },

    -- use a release tag to download pre-built binaries
    version = "1.*",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "default",
        ["<C-k>"] = false, -- or {}
      },
      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = "mono",
      },
      -- (Default) Only show the documentation popup when manually triggered
      completion = { documentation = { auto_show = true } },
      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = {
          "lsp",
          -- needs fang2hou/blink-copilot
          -- "copilot", -- for now using grayed out suggestions by copilot.lua
          "path",
          "snippets",
          "buffer",
          "lazydev",
          "ripgrep", -- 👈🏻 add "ripgrep" here
        },
        providers = {
          -- 👇🏻👇🏻 add the ripgrep provider config below
          ripgrep = {
            module = "blink-ripgrep",
            name = "Ripgrep",
            score_offset = -50,
            -- see the full configuration below for all available options
            ---@module "blink-ripgrep"
            ---@type blink-ripgrep.Options
            opts = {
              min_length = 4, -- only trigger after 4+ chars typed
            },
          },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 90,
          },
        },
      },
      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = "prefer_rust_with_warning" },
      signature = { enabled = true },
    },
    opts_extend = { "sources.default" },
  },

  -- ============================================================================
  -- FORMATTING & LINTING
  -- ============================================================================
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
      },
      formatters_by_ft = {
        lua = { "stylua" },
        -- Conform will run multiple formatters sequentially
        python = { "ruff_format" },
        -- You can customize some of the format options for the filetype (:help conform.format)
        rust = { "rustfmt", lsp_format = "fallback" },
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

  -- ============================================================================
  -- DIAGNOSTICS & ERRORS
  -- ============================================================================
  {
    "folke/trouble.nvim",
    lazy = false,
    opts = {
      modes = {
        diagnostics = {
          -- auto_open = true,
          -- auto_close = true,
          warn_no_results = false,
        },
      },
    }, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    config = function(_, opts)
      require("trouble").setup(opts)

      local trouble = require("trouble")

      local function update_trouble_for_cur_buf_errors()
        -- Don't trigger in insert or replace modes
        local mode = vim.fn.mode()
        if mode:match("^[iIrR]") then
          return
        end

        -- Don't trigger if we're in a Trouble window
        local current_buf = vim.api.nvim_get_current_buf()
        local buf_filetype = vim.bo[current_buf].filetype
        if buf_filetype == "trouble" then
          return
        end

        local bufnr = 0 -- current buffer
        local diagnostics = vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })

        if #diagnostics > 0 then
          trouble.open({
            mode = "diagnostics",
            focus = false,
            filter = {
              buf = bufnr,
              severity = vim.diagnostic.severity.ERROR,
            },
          })
        else
          trouble.close("diagnostics")
        end
      end

      local group = vim.api.nvim_create_augroup("TroubleAutoUpdate", { clear = true })

      vim.api.nvim_create_autocmd({ "DiagnosticChanged", "WinEnter", "InsertLeave", "BufEnter" }, {
        group = group,
        callback = function()
          vim.schedule(update_trouble_for_cur_buf_errors)
        end,
      })

      -- Cleanup autocmds on exit
      vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group,
        callback = function()
          vim.api.nvim_del_augroup_by_id(group)
        end,
      })

      -- Initial check
      vim.schedule(update_trouble_for_cur_buf_errors)
    end,
    keys = {
      {
        "<F6>",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "All Diagnostics (Trouble)",
      },
      {
        "<leader><F6>",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>vO",
        "<cmd>Trouble symbols toggle focus=true win.position=bottom auto_close=true<cr>",
        desc = "Symbols (Trouble)",
      },
      -- {
      --   "<leader>cl",
      --   "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      --   desc = "LSP Definitions / references / ... (Trouble)",
      -- },
      -- {
      --   "<leader>xL",
      --   "<cmd>Trouble loclist toggle<cr>",
      --   desc = "Location List (Trouble)",
      -- },
      -- {
      --   "<leader>xQ",
      --   "<cmd>Trouble qflist toggle<cr>",
      --   desc = "Quickfix List (Trouble)",
      -- },
    },
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup({})

      vim.diagnostic.config({ virtual_text = false }) -- Disable default virtual text
    end,
  },

  -- ============================================================================
  -- CODE NAVIGATION
  -- ============================================================================
  {
    dir = "~/repos/sibling-jump", -- Use local development version
    opts = {
      next_key = "<C-j>",
      prev_key = "<C-k>",
      center_on_jump = true,
      filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "lua", "python" },
      block_loop_key = "Z", -- Cycle through block boundaries (if/else, functions, objects, arrays)
      block_loop_key_visual = "z", -- Visual mode keybinding for block-loop
      block_loop_center_on_jump = false, -- Don't center screen for block-loop (only for sibling-jump)
    },
  },
  {
    "aaronik/treewalker.nvim",
    opts = {
      scope_confined = true,
    },
    keys = {
      -- movement; in normal mode tidy up by closing the fold we leave and
      -- opening the one we land in. Surgical, no full-buffer redraw.
      {
        "<C-S-k>",
        function()
          vim.cmd("silent! normal! zc")
          vim.cmd("Treewalker Up")
          vim.cmd("silent! normal! zo")
        end,
        mode = "n",
        silent = true,
      },
      {
        "<C-S-j>",
        function()
          vim.cmd("silent! normal! zc")
          vim.cmd("Treewalker Down")
          vim.cmd("silent! normal! zo")
        end,
        mode = "n",
        silent = true,
      },
      { "<C-S-k>", "<cmd>Treewalker Up<cr>", mode = "v", silent = true },
      { "<C-S-j>", "<cmd>Treewalker Down<cr>", mode = "v", silent = true },
      { "<C-h>", "<cmd>Treewalker Left<cr>", mode = { "n", "v" }, silent = true },
      { "<C-l>", "<cmd>Treewalker Right<cr>", mode = { "n", "v" }, silent = true },
    },
  },
  {
    "rmagatti/goto-preview",
    opts = {
      width = 100,
      height = 40,
      references = {
        width = 250,
      },
    },
    keys = {
      { "gpp", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", desc = "Preview definition" },
      {
        "gpt",
        "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>",
        desc = "Preview type definition",
      },
      { "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", desc = "Preview implementation" },
      { "gp", "<cmd>lua require('goto-preview').close_all_win()<CR>", desc = "Close all preview windows" },
      { "gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>", desc = "Preview references" },
      { "gpd", "<cmd>lua require('goto-preview').goto_preview_declaration()<CR>", desc = "Preview declaration" },
    },
  },
  {
    "subev/refjump.nvim",
    -- branch = "all-feat",
    branch = "main",
    event = "LspAttach", -- Uncomment to lazy load
    opts = {
      keymaps = {
        enable = true,
        next = "J", -- Keymap to jump to next LSP reference
        prev = "K", -- Keymap to jump to previous LSP reference
      },
      highlights = {
        enable = true, -- Highlight the LSP references on jump
        auto_clear = true, -- Automatically clear highlights when cursor moves
        clear_on_escape = true, -- Listen for escape/ctrl-c to clear highlights (non-intrusive)
      },
      counter = {
        enable = true, -- Enable virtual text counter at end of line
      },
      loop = false, -- Don't loop back to first/last reference when reaching the end
    },
  },
  {
    "dnlhc/glance.nvim",
    opts = {
      hooks = {
        before_open = function(results, open, jump)
          local uri = vim.uri_from_bufnr(0)
          if #results == 1 then
            local target_uri = results[1].uri or results[1].targetUri
            if target_uri == uri then
              jump(results[1])
            else
              open(results)
            end
          else
            open(results)
          end
        end,
      },
      detached = function(winid)
        return vim.api.nvim_win_get_width(winid) < 150
      end,
    },
    keys = {
      { ",d", "<cmd>Glance definitions<cr>", desc = "Glance definitions" },
      { "gti", "<cmd>Glance implementations<cr>", desc = "Glance implementations" },
      { "gr", "<cmd>Glance references<cr>", desc = "Glance references" },
      { "gT", "<cmd>Glance type_definitions<cr>", desc = "Glance type_definitions" },
      { "<space><backspace>", "<cmd>Glance references<cr>", desc = "Glance references" },
    },
  },
  {
    "subev/vim-illuminate",
    branch = "feat/cursor-highlight-groups",
    lazy = false,
    config = function()
      require("illuminate").configure({})
    end,
  },

  -- ============================================================================
  -- AI & COPILOT
  -- ============================================================================
  {
    "copilotlsp-nvim/copilot-lsp",
    enabled = true,
    opts = {},
    init = function()
      -- vim.g.copilot_nes_debounce = 300
      -- this thing works but it relies on mason's copilot-lsp installation which conflicts with copilot.lua
      -- vim.lsp.enable("copilot_ls")
      -- vim.keymap.set("n", "7", function()
      --     local bufnr = vim.api.nvim_get_current_buf()
      --     local state = vim.b[bufnr].nes_state
      --     if state then
      --       -- Try to jump to the start of the suggestion edit.
      --       -- If already at the start, then apply the pending suggestion and jump to the end of the edit.
      --       local _ = require("copilot-lsp.nes").walk_cursor_start_edit()
      --         or (
      --           require("copilot-lsp.nes").apply_pending_nes()
      --           and require("copilot-lsp.nes").walk_cursor_end_edit()
      --         )
      --       return nil
      --     else
      --       -- Resolving the terminal's inability to distinguish between `TAB` and `<C-i>` in normal mode
      --       return "7"
      --     end
      --   end, { desc = "Accept Copilot NES suggestion", expr = true })
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      panel = {
        enabled = false,
        auto_refresh = true,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<c-cr>",
          next = "<c-j>",
          prev = "<c-k>",
          accept_line = "<c-l>",
        },
      },
      -- can' seem to make this work neither with copilot.lua nor copilot-lsp
      nes = {
        enabled = false, -- requires copilot-lsp as a dependency
        auto_trigger = true,
        keymap = {
          accept_and_goto = "<c-i>",
          accept = false,
          dismiss = false,
        },
      },
    },
  },
  {
    "folke/sidekick.nvim",
    lazy = false,
    opts = {
      nes = { enabled = false },
      cli = {
        layout = "right",
        win = {
          split = {
            width = 0.5,
          },
        },
        mux = {
          backend = "zellij",
          enabled = true,
        },
      },
    },
    keys = {
      {
        "1",
        function()
          -- if there is a next edit, jump to it, otherwise apply it if any
          if not require("sidekick").nes_jump_or_apply() then
            return "1" -- fallback to normal
          end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<c-.>",
        function()
          require("sidekick.cli").toggle()
        end,
        desc = "Sidekick Toggle",
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>aa",
        function()
          require("sidekick.cli").send({ msg = "{this}" })
        end,
        mode = { "x", "n" },
        desc = "Send This (at cursor)",
      },
      {
        "<leader>as",
        function()
          require("sidekick.cli").select()
        end,
        -- Or to select only installed tools:
        -- require("sidekick.cli").select({ filter = { installed = true } })
        desc = "Select CLI",
      },
      {
        "<leader>ad",
        function()
          require("sidekick.cli").close()
        end,
        desc = "Detach a CLI Session",
      },
      {
        "<leader>af",
        function()
          require("sidekick.cli").send({ msg = "{file}" })
        end,
        desc = "Send File",
      },
      {
        "<leader>av",
        function()
          require("sidekick.cli").send({ msg = "{selection}" })
        end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    opts = {
      strategies = {
        chat = {
          adapter = "anthropic",
          keymaps = {
            send = {
              modes = { n = "2" },
              opts = {},
            },
            -- Add further custom keymaps here
          },
        },
        inline = {
          adapter = "anthropic",
        },
      },
      adapters = {
        http = {
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              schema = {
                model = {
                  default = "claude-sonnet-4-5",
                },
              },
            })
          end,
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    lazy = false,
    init = function()
      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd([[cab cc CodeCompanion]])
    end,
    keys = {
      {
        "<leader>cc",
        ":CodeCompanion #{buffer} ",
        desc = "Prepare `Code Companion` with current buffer and visual selection",
        mode = { "n", "v" },
      },
      {
        "<leader>ca",
        "<cmd>CodeCompanionActions<cr>",
        desc = "Toggle Code Companion Actions",
        mode = { "n", "v" },
      },
      {
        "<leader>cv",
        "<cmd>CodeCompanionChat Add<cr>",
        desc = "Add visual selection to Code Companion Chat",
        mode = "v",
      },
      {
        "<leader>co",
        "<cmd>CodeCompanionChat<cr>",
        desc = "Open Code Companion Chat",
        mode = "n",
      },
      {
        "<leader>ce",
        ":CodeCompanionChat /explain #{buffer} ",
        desc = "Explain current visual selection with Code Companion",
        mode = { "n", "v" },
      },
      {
        "<leader>ct",
        ":CodeCompanion #{buffer} /tests ",
        desc = "Add tests for visual selection",
        mode = { "n", "v" },
      },
    },
  },

  -- ============================================================================
  -- GIT INTEGRATION
  -- ============================================================================
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed.
      "nvim-telescope/telescope.nvim", -- optional
      "ibhagwan/fzf-lua", -- optional
      "nvim-mini/mini.pick", -- optional
      "folke/snacks.nvim", -- optional
    },
    opts = {},
    keys = {
      { "<leader>g", "<cmd>Neogit<cr>", desc = "Open Neogit" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, { expr = true })

        map("n", "[c", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, { expr = true })

        -- Actions
        map("n", "<space>x", gs.reset_hunk)
        map("n", "<space>h", gs.preview_hunk)

        map("n", "<leader>hs", gs.stage_hunk)
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end)
        map("v", "<space>x", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end)
        map("n", "<leader>hS", gs.stage_buffer)
        map("n", "<leader>hu", gs.undo_stage_hunk)
        map("n", "<leader>hR", gs.reset_buffer)
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end)
        map("n", "<leader>tb", gs.toggle_current_line_blame)
        map("n", "<leader>hd", gs.diffthis)
        map("n", "<leader>hD", function()
          gs.diffthis("~")
        end)
        map("n", "<leader>td", gs.toggle_deleted)

        -- Text object
        map({ "o", "x" }, "ah", ":<C-U>Gitsigns select_hunk<CR>")
      end,
    },
  },
  {
    "tpope/vim-fugitive",
    init = function()
      vim.keymap.set("n", "gD", ":Gvdiffsplit<cr>", { noremap = true, silent = true, desc = "Git vertical diff split" })
      vim.keymap.set("n", "gb", ":G blame --date=relative<cr>", { noremap = true, silent = true, desc = "Git blame" })
      vim.keymap.set("v", "gb", ":GBrowse<cr>", { noremap = true, silent = true, desc = "Git browse" })
      vim.keymap.set("n", ",g", ":G<CR>", { noremap = true, silent = true, desc = "Git status" })
      vim.keymap.set("n", ",gg", ":G<CR><c-w>H", { noremap = true, silent = true, desc = "Git status in left pane" })
      vim.keymap.set(
        "n",
        ",gc",
        ":GV?<cr><c-w>H",
        { noremap = true, silent = true, desc = "Git commit log in new tab" }
      )
      vim.keymap.set(
        "n",
        ",gH",
        ":G log --stat -p -U0 --abbrev-commit --date=relative -- %<cr><c-w>H",
        { noremap = true, silent = true, desc = "Git file history in left pane" }
      )
      vim.keymap.set("n", ",gp", ":G pull", { noremap = true, silent = true, desc = "Git pull (waiting for confirm)" })
      vim.keymap.set("n", ",gs", ":G push", { noremap = true, silent = true, desc = "Git push (waiting for confirm)" })
      vim.keymap.set("n", ",gf", ":G fetch<cr>", { noremap = true, silent = true, desc = "Git fetch" })
      vim.keymap.set(
        "n",
        ",gx",
        ":G merge origin/master<cr>",
        { noremap = true, silent = true, desc = "Git merge origin/master" }
      )
      vim.keymap.set(
        "n",
        ",gz",
        ":G merge --continue<cr>",
        { noremap = true, silent = true, desc = "Git merge continue" }
      )
      vim.keymap.set(
        "n",
        "gM",
        ":Gvsplit origin/<C-r>=GetMasterBranchName()<CR>:%<cr>",
        { noremap = true, silent = true, desc = "Git vertical diff split with master" }
      )
      vim.keymap.set(
        "n",
        "gm",
        ":Gvdiffsplit origin/<C-r>=GetMasterBranchName()<CR>:%<cr>",
        { noremap = true, silent = true, desc = "Git see same file but in master" }
      )
      vim.keymap.set(
        "n",
        ",gM",
        ":G diff origin/<C-r>=GetMasterBranchName()<CR>... --no-ext-diff <cr><c-w>H",
        { noremap = true, silent = true, desc = "Git diff with master in left pane" }
      )
    end,
  },
  {
    "sindrets/diffview.nvim",
    opts = {
      keymaps = {
        view = {
          q = "<Cmd>DiffviewClose<CR>",
        },
        file_panel = {
          q = "<Cmd>DiffviewClose<CR>",
          -- {
          --   "n",
          --   "<up>",
          --   function()
          --     print("scrolling up, fix me")
          --     require("diffview.actions").scroll_view(-10)
          --   end,
          --   { desc = "Scroll the view up" },
          -- },
          -- {
          --   "n",
          --   "<down>",
          --   function()
          --     print("scrolling down, fix me")
          --     require("diffview.actions").scroll_view(10)
          --   end,
          --   { desc = "Scroll the view down" },
          -- },
        },
        file_history_panel = {
          q = "<Cmd>DiffviewClose<CR>",
        },
      },
      file_panel = {
        win_config = {
          width = 50,
        },
      },
      view = {
        merge_tool = {
          layout = "diff4_mixed",
          disable_diagnostics = true,
        },
      },
      hooks = {
        -- When a diff buffer is shown in a window: expand all folds and
        -- center the first change. Fires for each file (incl. <Tab> navigation).
        diff_buf_win_enter = function(_, winid, _)
          vim.api.nvim_win_call(winid, function()
            vim.opt_local.foldenable = false -- expand the collapsed unchanged regions
          end)
          -- Defer the cursor jump: when this hook fires the diff hasn't been
          -- computed yet, so ]c finds nothing. Schedule it for the next tick.
          vim.defer_fn(function()
            if vim.api.nvim_win_is_valid(winid) then
              vim.api.nvim_win_call(winid, function()
                vim.cmd("normal! gg]czz") -- jump to first change, center on screen
              end)
            end
          end, 50)
        end,
      },
    },
    lazy = false,
    keys = {
      { ",gd", ":DiffviewOpen<cr>", desc = "Git Diffview Open" },
      { ",gh", ":DiffviewFileHistory %<cr>", desc = "Git Diffview File History" },
      {
        ",gm",
        ":DiffviewOpen origin/<C-r>=GetMasterBranchName()<CR>...HEAD<cr>",
        desc = "Git Diffview Open with master",
      },
    },
  },
  {
    "barrettruth/diffs.nvim",
    -- must not be lazy-loaded (no keys/event/config); it lazy-loads itself
    lazy = false,
    init = function()
      vim.g.diffs = {
        integrations = {
          fugitive = true,
          neogit = true,
          gitsigns = true,
          telescope = true,
          difftastic = true,
        },
      }
      vim.keymap.set("n", ",gr", "<cmd>Diff review HEAD<cr>", { desc = "Diffs Review Uncommitted" })
    end,
  },
  {
    dir = "~/repos/difftastic.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    config = function()
      require("difftastic-nvim").setup({
        vcs = "git",
        hunk_wrap_file = true,
        scroll_to_first_hunk = true,
        keymaps = {
          next_hunk = "<Tab>",
          prev_hunk = "<S-Tab>",
          focus_tree = false,
          focus_diff = false,
        },
      })
    end,
    keys = {
      { ",gD", "<cmd>:Difft<cr>", desc = "Difftastic Open" },
      { ",GM", "<cmd>:Difft origin/main..HEAD<cr>", desc = "Difftastic Open" },
      { ",gC", "<cmd>:DifftFileHistory <cr>", desc = "Difftastic File History" },
    },
    cmd = { "Difft" },
  },
  -- Enables :GBrowse from fugitive.vim to open GitHub URLs
  "tpope/vim-rhubarb",
  {
    "junegunn/gv.vim",
    config = function() end,
  },
  "skanehira/gh.vim",
  {
    "pwntester/octo.nvim",
    opts = {
      enable_builtin = true,
    },
    keys = {
      { "<space>v", "<cmd>Octo<cr>", desc = "Open Octo" },
      { "<space>vv", "<cmd>Octo<cr>", desc = "Open Octo" },
      { "<leader>pro", "<cmd>Octo pr checkout<cr>", desc = "Checkout PR" },
      { "<leader>prr", "<cmd>Octo review start<cr>", desc = "Start PR Review" },
    },
    cmd = { "Octo" },
  },
  {
    "ldelossa/gh.nvim",
    dependencies = {
      {
        "ldelossa/litee.nvim",
        config = function()
          require("litee.lib").setup()
        end,
      },
    },
    config = function()
      require("litee.gh").setup()
    end,
  },

  -- ============================================================================
  -- FILE EXPLORER & NAVIGATION
  -- ============================================================================
  {
    "preservim/nerdtree",
    dependencies = { "Xuyuanp/nerdtree-git-plugin" },
    init = function()
      vim.g.NERDTreeQuitOnOpen = 1
      vim.g.NERDTreeChDirMode = 1
      vim.g.NERDTreeShowHidden = 1
      vim.g.NERDTreeWinSize = 70
    end,
    keys = {
      { "<space>p", ":NERDTreeFind<CR>zz", desc = "Find file in NERDTree" },
    },
    cmd = { "NERDTreeFind" },
    lazy = true,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false, -- neo-tree will lazily load itself
    config = function()
      local neo_tree_width = 40

      require("neo-tree").setup({
        event_handlers = {
          {
            event = "file_open_requested",
            handler = function()
              -- auto close
              -- vim.cmd("Neotree close")
              -- OR
              require("neo-tree.command").execute({ action = "close" })
            end,
          },
          {
            event = "neo_tree_window_before_close",
            handler = function(args)
              local winid = args.winid
              if winid and vim.api.nvim_win_is_valid(winid) then
                neo_tree_width = vim.api.nvim_win_get_width(winid)
              end
            end,
          },
          {
            event = "neo_tree_window_after_open",
            handler = function(args)
              local winid = args.winid
              if winid and vim.api.nvim_win_is_valid(winid) then
                vim.api.nvim_win_set_width(winid, neo_tree_width)
              end
            end,
          },
        },
        filesystem = {
          filtered_items = {
            visible = true,
          },
          window = {
            mappings = {
              -- disable fuzzy finder
              ["/"] = "noop",
              ["o"] = "system_open",
            },
          },
        },
        commands = {
          system_open = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            -- macOs: open file in default application in the background.
            vim.fn.jobstart({ "open", path }, { detach = true })
            -- Linux: open file in default application
            vim.fn.jobstart({ "xdg-open", path }, { detach = true })

            -- Windows: Without removing the file from the path, it opens in code.exe instead of explorer.exe
            local p
            local lastSlashIndex = path:match("^.+()\\[^\\]*$") -- Match the last slash and everything before it
            if lastSlashIndex then
              p = path:sub(1, lastSlashIndex - 1) -- Extract substring before the last slash
            else
              p = path -- If no slash found, return original path
            end
            vim.cmd("silent !start explorer " .. p)
          end,
        },
      })

      vim.keymap.set("n", "<space>e", "<Cmd>Neotree reveal<CR>")
    end,
  },
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      image = {
        -- your image configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
      picker = {
        enabled = true,
      },
    },
  },
  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = { -- Example mapping to toggle outline
      { "<leader>vo", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
      -- Your setup opts here
      outline_window = {
        position = "left",
        auto_close = false,
      },
    },
  },
  {
    "Bekaboo/dropbar.nvim",
    -- optional, but required for fuzzy finder support
    opts = {
      bar = {
        sources = function()
          local sources = require("dropbar.sources")
          return {
            sources.path,
          }
        end,
      },
    },
    config = function()
      vim.keymap.set("n", "<space>2", require("dropbar.api").pick)
    end,
  },

  -- ============================================================================
  -- FUZZY FINDING & SEARCH
  -- ============================================================================
  { "junegunn/fzf", build = "./install --bin" },
  {
    "junegunn/fzf.vim",
    config = function()
      -- this whole plugin is for just that one mapping, still can't find better
      vim.keymap.set(
        "n",
        "<space>s",
        "<cmd>Rg<cr>",
        { noremap = true, silent = true, desc = "Search with FZF Ripgrep" }
      )
      -- vim.keymap.set("v", "<space>s", 'y:Rg <C-r>"<CR>', {
      --   noremap = true,
      --   silent = true,
      --   desc = "Search selection with FZF Ripgrep",
      -- })
    end,
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    config = function()
      local fzf = require("fzf-lua")
      vim.keymap.set("n", "<F1>", fzf.help_tags, { noremap = true, silent = true, desc = "FZF help tags" })
      -- vim.keymap.set("n", "<space>s", function()
      --   fzf.grep_project({ fzf_opts = { ["--nth"] = false } })
      -- end, { noremap = true, silent = true, desc = "FZF grep (path + content)" })
      vim.keymap.set("n", ",s", fzf.grep_project, { noremap = true, silent = true, desc = "FZF grep (content only)" })
      vim.keymap.set("n", ",S", fzf.resume, { noremap = true, silent = true, desc = "FZF resume" })
      vim.keymap.set("v", "<space>s", fzf.grep_visual, { noremap = true, silent = true, desc = "FZF grep selection" })
      vim.keymap.set("v", ",s", fzf.grep_visual, { noremap = true, silent = true, desc = "FZF grep selection" })
      vim.keymap.set("n", ",b", fzf.buffers, { noremap = true, silent = true, desc = "FZF buffers" })
      vim.keymap.set(
        "n",
        "<space>`",
        fzf.grep_curbuf,
        { noremap = true, silent = true, desc = "FZF grep current buffer" }
      )
    end,
  },
  "pbogut/fzf-mru.vim",
  "nvim-lua/plenary.nvim",
	  {
	    "nvim-telescope/telescope.nvim",
	    config = function()
	      local action_state = require("telescope.actions.state")
	      local telescope = require("telescope")
	      telescope.setup({
	        extensions = {
	          fzf = {
	            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
	            override_file_sorter = true, -- override the file sorter
	            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
	            -- the default case_mode is "smart_case"
	          },
	          frecency = {
	            hide_current_buffer = true,
	          },
	        },
	      })
	      -- Load the FZF extension
	      telescope.load_extension("fzf")
	      telescope.load_extension("frecency")

	      local builtin = require("telescope.builtin")
	      local extensions = telescope.extensions
	      local frecency_module = require("frecency")
	      local frecency_config = require("frecency.config")
	      local function frecency_picker()
	        extensions.frecency.frecency({
	          attach_mappings = function(prompt_bufnr, map)
	            local function refresh_frecency_results()
	              local picker = action_state.get_current_picker(prompt_bufnr)
	              local frecency_instance = frecency_module.frecency
	              local frecency_picker_state = frecency_instance and frecency_instance.picker
	              if not (picker and frecency_picker_state) then
	                return
	              end

	              local prompt = picker:_get_prompt()
	              local _, _, workspace_tag = prompt:find(frecency_picker_state.workspace_tag_regex)
	              local active_workspace_tag = workspace_tag
	                or frecency_picker_state.config.initial_workspace_tag
	                or frecency_config.default_workspace
	              local new_finder =
	                frecency_picker_state:finder(picker, frecency_picker_state.workspaces, active_workspace_tag)

	              picker:refresh(new_finder, { reset_prompt = false })
	              new_finder:start()
	            end

	            map({ "i", "n" }, "<C-x>", function()
	              local selection = action_state.get_selected_entry()
	              local path = selection and (selection.filename or selection.name or selection.path or selection.value)
	              if not path then
	                return
	              end
	              vim.cmd("FrecencyDelete " .. vim.fn.fnameescape(path))
	              refresh_frecency_results()
	            end, { nowait = true })
	            map({ "i", "n" }, "<F7>", function()
	              vim.cmd("FrecencyValidate!")
	              refresh_frecency_results()
	            end, { nowait = true })
	            return true
	          end,
	        })
	      end
	      -- Keymaps
	      -- vim.keymap.set('n', '<F1>', builtin.help_tags, { desc = 'Telescope help tags' })
	      -- vim.keymap.set('n', '<space>d', '<cmd>Telescope<cr>', { desc = 'Open Telescope' }) -- optional
	      vim.keymap.set("n", ",f", builtin.find_files, { desc = "Telescope find files" })
      -- The two below use <c-r><c-w>, which can't be directly expressed in Lua — we simulate it using an expression
      vim.keymap.set("n", ",F", function()
        builtin.find_files({ default_text = vim.fn.expand("<cword>") })
      end, { desc = "Find files with word under cursor" })
      vim.keymap.set("n", "gF", function()
        builtin.find_files({ search_file = vim.fn.expand("<cword>") })
	      end, { desc = "Search files matching word under cursor" })
	      vim.keymap.set("n", "<space>df", builtin.oldfiles, { desc = "Telescope old files" })
	      vim.keymap.set("n", ",v", frecency_picker, { desc = "Telescope frecency" })
	      vim.keymap.set("n", "<space>dg", builtin.live_grep, { desc = "Telescope live grep" })
	      vim.keymap.set("n", "<space>db", builtin.buffers, { desc = "Telescope buffers" })
	      vim.keymap.set("n", "<space>dh", builtin.help_tags, { desc = "Telescope help tags" })
	      vim.keymap.set("n", "<space>de", builtin.builtin, { desc = "Telescope builtins" })
	      vim.keymap.set("n", "<space>o", builtin.lsp_document_symbols, { desc = "Telescope document symbols" })
	      vim.keymap.set("n", "<space>O", builtin.lsp_dynamic_workspace_symbols, { desc = "Telescope document symbols" })
	    end,
	    dependencies = {
	      "nvim-lua/plenary.nvim",
	      {
	        "nvim-telescope/telescope-frecency.nvim",
        version = "*",
      },
    },
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = function()
      return vim.fn.executable("make") == 1
    end,
  },
  {
    "kien/ctrlp.vim",
    config = function()
      vim.g.ctrlp_max_files = 0
      vim.g.ctrlp_show_hidden = 1
      vim.g.ctrlp_working_path_mode = "rw"
      vim.g.ctrlp_by_filename = 1
      vim.g.ctrlp_mruf_max = 2500
      vim.g.ctrlp_mruf_exclude = "/tmp/.*\\|/temp/.*\\|/private/.*\\|.*/node_modules/.*\\|.*/.pyenv/.*"
      vim.g.ctrlp_user_command = 'rg %s --files --color=never --glob ""'
      -- Keymaps
      vim.keymap.set("n", ",x", ":CtrlPMRUFiles<CR>", { noremap = true, silent = true })
      -- vim.keymap.set("n", ",v", "<cmd>Telescope frecency workspace=CWD<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", ",V", "<cmd>Telescope oldfiles<cr>", { noremap = true, silent = true })
    end,
  },

  -- ============================================================================
  -- SEARCH & REPLACE
  -- ============================================================================
  {
    "dyng/ctrlsf.vim",
    init = function()
      vim.g.ctrlsf_ackprg = "rg"
      vim.g.ctrlsf_mapping = {
        next = "n",
        prev = "N",
        vsplit = "s",
        open = "<cr>",
      }
      vim.g.ctrlsf_auto_focus = {
        at = "start",
      }
      vim.g.ctrlsf_confirm_save = 0
    end,

    keys = {
      { "<leader>r", ":CtrlSF<space>", noremap = true, silent = true, desc = "CtrlSF" },
      { "<space>r", ":CtrlSFOpen<CR>", noremap = true, silent = true, desc = "CtrlSF Open" },
      {
        "<leader>r",
        'y:CtrlSF \\b<C-R>"\\b -R -G !*.test.ts<CR>',
        mode = "v",
        noremap = true,
        silent = true,
        desc = "CtrlSF with visual selection (ignore .test.ts files)",
      },
      {
        "<space>r",
        'y:CtrlSF <C-R>" <C-R>=expand("%:p")<cr><cr>',
        mode = "v",
        noremap = true,
        silent = true,
        desc = "CtrlSF in current file with visual selection",
      },
      { "R", ":CtrlSF <C-R><C-W> -W<CR>", noremap = true, silent = true, desc = "CtrlSF word under cursor" },
      {
        "R",
        'y:CtrlSF "<C-R>""<CR>',
        mode = "v",
        noremap = true,
        silent = true,
        desc = "CtrlSF with visual selection",
      },
      {
        "T",
        'y:CtrlSF "<C-R>"" -G !*.test.ts<CR>',
        mode = "v",
        noremap = true,
        silent = true,
        desc = "CtrlSF with visual selection (ignore .test.ts files)",
      },
    },
  },
  {
    "kevinhwang91/nvim-hlslens",
    config = function()
      require("hlslens").setup({
        nearest_only = {
          description = [[Only add lens for the nearest matched instance and ignore others]],
          default = false,
        },
        build_position_cb = function(plist, _, _, _)
          require("scrollbar.handlers.search").handler.show(plist.start_pos)
        end,
        override_lens = function(render, posList, nearest, idx)
          local sfw = vim.v.searchforward == 1
          local indicator, text, chunks
          indicator = sfw and "▼" or "▲"

          local lnum, col = unpack(posList[idx])
          if nearest then
            local cnt = #posList
            text = ("[%s %d/%d]"):format(indicator, idx, cnt)
            chunks = { { " ", "Ignore" }, { text, "HlSearchLensNear" } }
          else
            text = ("[%s %d]"):format(indicator, idx)
            chunks = { { " ", "Ignore" }, { text, "HlSearchLens" } }
          end
          render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
        end,
      })

      local kopts = { noremap = true, silent = true }

      -- Keep traditional n/N with hlslens, zv opens folds at search result
      vim.api.nvim_set_keymap(
        "n",
        "n",
        [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>zv]],
        kopts
      )
      vim.api.nvim_set_keymap(
        "n",
        "N",
        [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>zv]],
        kopts
      )

      -- Keep traditional search operators with hlslens
      vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

      vim.api.nvim_set_keymap("n", "<Leader>l", "<Cmd>noh<CR>", kopts)

      -- CR to toggle refjump highlights (without jumping)
      vim.keymap.set("n", "<CR>", function()
        local refjump = require("refjump")
        if vim.v.hlsearch == 1 then
          -- Clear traditional search highlights
          vim.cmd("nohlsearch")
        elseif refjump.is_highlight_active() then
          -- Clear refjump highlights
          refjump.clear_highlights()
        else
          -- Trigger refjump highlight (no jump)
          smart_search_under_cursor()
        end
      end, { noremap = true, silent = true, desc = "Toggle refjump highlights or clear hlsearch" })
    end,
  },

  -- ============================================================================
  -- BUFFER MANAGEMENT
  -- ============================================================================
  {
    "jlanzarotta/bufexplorer",
    config = function()
      vim.keymap.set("n", ",B", ":BufExplorerVerticalSplit<CR>", { noremap = true, silent = true })
      vim.g.bufExplorerShowNoName = 1
      vim.g.bufExplorerShowRelativePath = 1
    end,
  },

  -- ============================================================================
  -- TEXT MANIPULATION & EDITING
  -- ============================================================================
  {
    "numToStr/Comment.nvim",
    opts = {
      opleader = {
        block = "gB",
      },
    },
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
        -- "settings for 'tpope/vim-surround'
        -- vmap s S
      })
    end,
  },
  {
    "AndrewRadev/splitjoin.vim",
    config = function()
      vim.keymap.set("n", "gs", ":SplitjoinSplit<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "gj", ":SplitjoinJoin<cr>", { noremap = true, silent = true })
    end,
  },
  {
    "AndrewRadev/sideways.vim",
    config = function()
      vim.keymap.set("n", "gh", ":SidewaysLeft<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", "gl", ":SidewaysRight<cr>", { noremap = true, silent = true })
    end,
  },
  {
    "AndrewRadev/switch.vim",
    init = function()
      -- Define custom switch pairs
      vim.g.switch_custom_definitions = {
        { "!==", "===" },
        { "!=", "==" },
      }
    end,
    lazy = true,
    keys = {
      {
        "!",
        "<Plug>(Switch)",
        mode = "n",
        noremap = false,
        silent = true,
        desc = "Toggle operator with switch.vim",
      },
    },
  },
  {
    "jiangmiao/auto-pairs",
    config = function()
      vim.g.AutoPairsShortcutBackInsert = "<C-b>"
      vim.g.AutoPairsShortcutFastWrap = "<C-e>"

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "snacks_input",
          "snacks_layout_box",
          "snacks_picker_input",
          "snacks_picker_list",
          "snacks_picker_preview",
          "TelescopePrompt",
          "fzf",
        },
        callback = function()
          vim.b.autopairs_loaded = 1
          vim.b.autopairs_enabled = 0
        end,
      })
    end,
  },
  {
    "matze/vim-move",
    init = function()
      vim.g.move_map_keys = 0
      vim.keymap.set("v", "H", "<Plug>MoveBlockUp", {
        noremap = false,
        silent = true,
        desc = "Move block up",
      })
      vim.keymap.set("v", "L", "<Plug>MoveBlockDown", {
        noremap = false,
        silent = true,
        desc = "Move block down",
      })
      vim.keymap.set("n", "H", "<Plug>MoveLineUp", {
        noremap = false,
        silent = true,
        desc = "Move line up",
      })
      vim.keymap.set("n", "L", "<Plug>MoveLineDown", {
        noremap = false,
        silent = true,
        desc = "Move line down",
      })
    end,
  },
  {
    "mg979/vim-visual-multi",
    init = function()
      vim.g.VM_mouse_mappings = 1
    end,
  },
  {
    "easymotion/vim-easymotion",
    init = function()
      vim.g.EasyMotion_smartcase = 1
      vim.g.EasyMotion_keys = "asdghklqwertyuiopzxcvbnmfj"
    end,
    lazy = true,
    keys = {
      {
        "f",
        "<Plug>(easymotion-overwin-f2)",
        mode = "n",
        noremap = false,
        silent = true,
        desc = "Easymotion over window f2",
      },
    },
  },
  "tpope/vim-repeat",
  "tpope/vim-unimpaired",
  "kana/vim-smartword",
  "bkad/camelcasemotion",

  -- ============================================================================
  -- TEXT OBJECTS & MOTIONS
  -- ============================================================================
  "wellle/targets.vim",
  "michaeljsmith/vim-indent-object",
  "haya14busa/vim-textobj-function-syntax",
  "bronson/vim-visual-star-search",
  "terryma/vim-expand-region",
  "jeetsukumaran/vim-indentwise",

  -- ============================================================================
  -- TESTING & DEBUGGING
  -- ============================================================================
  {
    "nvim-neotest/neotest",
    lazy = false,
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "marilari88/neotest-vitest",
      "subev/neotest-playwright-e2e",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-vitest")({
            is_test_file = function(file_path)
              if not file_path then
                return false
              end
              if file_path:find("/e2e/") then
                return false
              end
              return file_path:match("%.test%.[tj]sx?$") ~= nil or file_path:match("%.spec%.[tj]sx?$") ~= nil
            end,
            vitestCommand = function(path)
              local root = vim.fs.root(path, "package.json")
              if not root then
                return "npx vitest"
              end
              local rel = path:sub(#root + 2)

              -- server/vitest.config.browser.ts → app/**/*.test.tsx
              if rel:match("^app/") then
                return "npx vitest --browser.headless"
              end
              -- management-console-client/vitest.config.browser.ts → src/**/*.test.tsx
              if rel:match("^src/.*%.test%.tsx$") then
                return "npx vitest --browser.headless"
              end

              return "npx vitest"
            end,
            vitestConfigFile = function(path)
              local root = vim.fs.root(path, "package.json")
              if not root then
                return nil
              end
              local rel = path:sub(#root + 2)

              -- server/vitest.config.client.ts → test/client/**/*.test.ts
              if rel:match("^test/client/") then
                return root .. "/vitest.config.client.ts"
              end
              -- server/vitest.config.llm.ts → test/llm/**/*.test.ts
              if rel:match("^test/llm/") then
                return root .. "/vitest.config.llm.ts"
              end
              -- server/vitest.config.browser.ts → app/**/*.test.tsx
              if rel:match("^app/") then
                return root .. "/vitest.config.browser.ts"
              end
              -- management-console-client/vitest.config.browser.ts → src/**/*.test.tsx
              if rel:match("^src/.*%.test%.tsx$") then
                return root .. "/vitest.config.browser.ts"
              end

              -- packages/common/vitest.config.ts, server/vitest.config.ts → default
              return nil
            end,
          }),
          require("neotest-playwright-e2e")(),
        },
      })

      local function run_and_open_summary(run_arg)
        if run_arg then
          require("neotest").run.run(run_arg)
        else
          require("neotest").run.run()
        end
        vim.cmd("doautocmd BufEnter")
        vim.schedule(function()
          require("neotest").summary.open()
        end)
      end

      vim.keymap.set("n", "<space>tt", function()
        run_and_open_summary()
      end, { desc = "Run nearest test" })

      vim.keymap.set("n", "<space>ta", function()
        run_and_open_summary(vim.fn.expand("%"))
      end, { desc = "Run current file tests" })

      vim.keymap.set("n", "<space>ts", function()
        require("neotest").run.stop()
        require("neotest").summary.close()
      end, { desc = "Stop nearest test" })

      vim.keymap.set("n", "<space>to", function()
        require("neotest").output.open({ enter = true })
      end, { desc = "See the output from the tests" })

      vim.keymap.set("n", "<space>tww", function()
        require("neotest").run.run({ vitestCommand = "vitest --watch", suite = false })
      end, { desc = "Run & Watch Nearest Test" })

      vim.keymap.set("n", "<space>twa", function()
        require("neotest").run.run({ vim.fn.expand("%"), vitestCommand = "vitest --watch", suite = false })
      end, { desc = "Run and Watch File" })
    end,
  },
  "mfussenegger/nvim-dap",
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/bin/js-debug-adapter",
          args = { "${port}" },
        },
      }

      dap.configurations.typescript = {
        -- your normal node config for running files
        -- {
        --   type = "pwa-node",
        --   request = "launch",
        --   name = "Launch file",
        --   program = "${file}",
        --   cwd = "${workspaceFolder}",
        -- },

        -- Vitest debug config
        {
          type = "pwa-node",
          request = "launch",
          name = "Debug Vitest current file",
          cwd = "${workspaceFolder}",
          runtimeExecutable = "node",
          runtimeArgs = {
            "${workspaceFolder}/node_modules/vitest/vitest.mjs", -- Vitest entry
            "run",
            "${file}", -- run only the current test file
            "--inspect-brk", -- ensure it waits for debugger
            "--pool",
            "threads", -- disable worker threads (important for debugging)
            "--poolOptions.threads.singleThread",
          },
          console = "integratedTerminal",
          internalConsoleOptions = "neverOpen",
        },
      }

      dapui.setup()
      dap.listeners.after.event_initialized.dapui_config = dapui.open
      dap.listeners.before.event_terminated.dapui_config = dapui.close
      dap.listeners.before.event_exited.dapui_config = dapui.close

      --  maps F8 to set a breakpoint and start a new debugging session
      -- or toggle a breakpoint if a session is already running
      vim.keymap.set("n", "<F8>", function()
        if dap.session() then
          dap.toggle_breakpoint()
        else
          dap.set_breakpoint()
          dap.continue()
        end
      end, { desc = "DAP: Toggle Breakpoint / Start" })

      -- maps F9 to stop the debugging
      vim.keymap.set("n", "<F9>", function()
        dap.clear_breakpoints()
        dap.disconnect()
        dap.close()
      end, { desc = "DAP: Terminate" })

      -- maps F10 to step over
      vim.keymap.set("n", "<F10>", function()
        dap.step_over()
      end, { desc = "DAP: Step Over" })

      -- maps F11 to step into
      vim.keymap.set("n", "<F11>", function()
        dap.step_into()
      end, { desc = "DAP: Step Into" })

      -- maps F12 to step out
      vim.keymap.set("n", "<F12>", function()
        dap.step_out()
      end, { desc = "DAP: Step Out" })

      -- add to watch expression elements the selected text in visual mode
      vim.keymap.set("v", "<space>tE", function()
        -- yank selected text to register v
        vim.cmd('normal! "vy')
        local expr = vim.fn.getreg("v")
        dapui.elements.watches.add(expr)
      end, { noremap = true, silent = true, desc = "Add selection as watch expression" })

      vim.keymap.set(
        { "n", "v" }, -- works in both normal and visual mode
        "<space>te",
        function()
          dapui.eval()
        end,
        { noremap = true, silent = true, desc = "Evaluate expression in a floating window (dapui)" }
      )
    end,
  },

  -- ============================================================================
  -- UI ENHANCEMENTS
  -- ============================================================================
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          always_show_tabline = true,
          globalstatus = false,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
            refresh_time = 16, -- ~60fps
            events = {
              "WinEnter",
              "BufEnter",
              "BufWritePost",
              "SessionLoadPost",
              "FileChangedShellPost",
              "VimResized",
              "Filetype",
              "CursorMoved",
              "CursorMovedI",
              "ModeChanged",
            },
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "diff", "diagnostics" },
          lualine_c = {
            {
              "filename",
              path = 1,
            },
          },
          lualine_x = {
            {
              function()
                local ok, refjump = pcall(require, "refjump")
                if not ok then
                  return ""
                end
                local info = refjump.get_reference_info()
                if info.index then
                  return string.format("[%d/%d]", info.index, info.total)
                end
                return ""
              end,
            },
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {
          "fugitive",
          "fzf",
          "lazy",
          "mason",
          "neo-tree",
          "nerdtree",
          "trouble",
          "nvim-dap-ui",
        },
      })
    end,
  },
  {
    "petertriho/nvim-scrollbar",
    opts = {
      show_in_active_only = false,
      handlers = {
        cursor = true,
        diagnostic = true,
        search = true, -- Requires hlslens
        gitsigns = true, -- Requires gitsigns
      },
      handle = {
        text = " ",
        blend = 80, -- Integer between 0 and 100. 0 for fully opaque and 100 to full transparent. Defaults to 30.
        color = nil,
        color_nr = nil, -- cterm
        highlight = "ScrollbarHandle",
        hide_if_all_visible = true, -- Hides handle if all lines are visible
      },
      marks = {
        Cursor = {
          text = "•",
          priority = 0,
          gui = nil,
          color = "#569CD6",
          cterm = nil,
          color_nr = nil, -- cterm
          highlight = "Normal",
        },
        Search = {
          text = { "─", "═" },
          priority = 1,
          gui = nil,
          color = "#FFA500",
          cterm = nil,
          color_nr = nil, -- cterm
          highlight = "Search",
        },
        Error = {
          text = { "-", "=" },
          priority = 2,
          gui = nil,
          color = nil,
          cterm = nil,
          color_nr = nil, -- cterm
          highlight = "DiagnosticSignError",
        },
      },
    },
  },
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        user_default_options = {
          hsl_fn = true,
          tailwind = true,
        },
      })
    end,
  },
  {
    "max397574/colortils.nvim",
    setup = function()
      require("colortils").setup()
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup({
        -- your personnal icons can go here (to override)
        -- you can specify color or cterm_color instead of specifying both of them
        -- DevIcon will be appended to `name`
        override = {
          zsh = {
            icon = "",
            color = "#428850",
            cterm_color = "65",
            name = "Zsh",
          },
        },
        -- globally enable different highlight colors per icon (default to true)
        -- if set to false all icons will have the default icon's color
        color_icons = true,
        -- globally enable default icons (default to false)
        -- will get overriden by `get_icons` option
        default = true,
        -- globally enable "strict" selection of icons - icon will be looked up in
        -- different tables, first by filename, and if not found by extension; this
        -- prevents cases when file doesn't have any extension but still gets some icon
        -- because its name happened to match some extension (default to false)
        strict = true,
        -- same as `override` but specifically for overrides by filename
        -- takes effect when `strict` is true
        override_by_filename = {
          [".gitignore"] = {
            icon = "",
            color = "#f1502f",
            name = "Gitignore",
          },
        },
        -- same as `override` but specifically for overrides by extension
        -- takes effect when `strict` is true
        override_by_extension = {
          ["log"] = {
            icon = "",
            color = "#81e043",
            name = "Log",
          },
        },
      })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
    config = function()
      require("ibl").setup()
    end,
  },

  -- ============================================================================
  -- FOLDING
  -- ============================================================================
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

  -- ============================================================================
  -- SESSIONS & STARTUP
  -- ============================================================================
  {
    "rmagatti/auto-session",
    lazy = false,

    keys = {
      -- Will use Telescope if installed or a vim.ui.select picker otherwise
      { "<leader>s", "<cmd>AutoSession search<CR>", desc = "Session search" },
      -- { "<leader>ws", "<cmd>SessionSave<CR>", desc = "Save session" },
      -- { "<leader>wa", "<cmd>SessionToggleAutoSave<CR>", desc = "Toggle autosave" },
    },

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      show_auto_restore_notif = false,
    },
  },
  {
    "mhinz/vim-startify",
    init = function()
      vim.g.startify_change_to_dir = 0
      vim.g.startify_change_to_vcs_root = 0
      vim.g.startify_session_persistence = 0
    end,
  },

  -- ============================================================================
  -- UTILITIES
  -- ============================================================================
  {
    "mbbill/undotree",
    lazy = true,
    keys = {
      { "<leader>u", ":UndotreeToggle<cr>", noremap = true, silent = true, desc = "Toggle Undotree" },
    },
    cmd = { "UndotreeToggle" },
  },
  {
    "mhanberg/output-panel.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("output_panel").setup({
        max_buffer_size = 5000, -- default
      })
    end,
    cmd = { "OutputPanel" },
    keys = {
      {
        "<leader>o",
        vim.cmd.OutputPanel,
        mode = "n",
        desc = "Toggle the output panel",
      },
    },
  },
  { "meznaric/key-analyzer.nvim", opts = {} },
  {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
    dependencies = {
      -- include a picker of your choice, see picker section for more details
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      arg = "leet",
      lang = "typescript",
    },
    lazy = true,
    cmd = { "Leet" },
  },
  {
    -- does not seem to work
    "MaximilianLloyd/tw-values.nvim",
    keys = {
      { "<leader><space><space>", "<cmd>TWValues<cr>", desc = "Show tailwind CSS values" },
    },
    opts = {
      border = "rounded", -- Valid window border style,
      show_unknown_classes = true, -- Shows the unknown classes popup
      focus_preview = true, -- Sets the preview as the current window
      copy_register = "", -- The register to copy values to,
      keymaps = {
        copy = "<C-y>", -- Normal mode keymap to copy the CSS values between {}
      },
    },
  },
  "chrisbra/csv.vim",
  "junegunn/vim-easy-align",
  -- nice markdown preview
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    opts = {
      preview = {
        filetypes = { "markdown", "codecompanion" },
        ignore_buftypes = { "nofile" },
      },
    },
  },
  -- Overseer is for non-persistent project tasks you want to inspect inside Neovim.
  --
  -- Usage:
  --   ,cc  toggle the task list dock on the left
  --   ,cr  open OverseerRun through the current `vim.ui.select` backend (Snacks picker)
  --   ,ck  run textclub's root-level `pnpm run checks` and open its output
  --   ,ct  run textclub's root-level `pnpm run typecheck:watch` and open its output
  --   ,co  reopen the most recent Overseer task output in a float
  --
  -- `,ck` and `,ct` are just opinionated shortcuts for the root textclub scripts you are likely
  -- to want often. These tasks are not persistent: quitting Neovim stops them. For persistent
  -- shells or dev servers, use the zellij-backed terminal flow on `,t` instead.
  {
    "stevearc/overseer.nvim",
    keys = {
      {
        ",cc",
        function()
          require("overseer").toggle({ enter = false, direction = "left" })
        end,
        desc = "Overseer: toggle task list",
      },
      {
        ",cr",
        "<cmd>OverseerRun<CR>",
        desc = "Overseer: run task",
      },
      {
        ",ck",
        function()
          run_textclub_overseer_task("checks")
        end,
        desc = "Overseer: textclub checks",
      },
      {
        ",ct",
        function()
          run_textclub_overseer_task("typecheck:watch")
        end,
        desc = "Overseer: textclub typecheck watch",
      },
      {
        ",co",
        function()
          open_recent_overseer_output()
        end,
        desc = "Overseer: open recent output",
      },
    },
    opts = {
      task_list = {
        direction = "left",
        min_width = { 40, 0.2 },
        max_width = 0.5,
      },
    },
  },
  -- Read text aloud (visual selection, paragraph, or motion).
  --
  -- Usage:
  --   <leader>tp  play visual selection (or current section in normal mode)
  --   <leader>ts  stop playback
  --   <leader>tq / <leader>tc / <leader>tn / <leader>tN  queue add/clear/next/prev
  --
  -- Currently on the native macOS `say` backend. To upgrade voice quality later,
  -- run a local Kokoro server (ghcr.io/remsky/kokoro-fastapi-cpu, port 8880) and
  -- switch with :TTSBackend openai after filling in the openai table below.
  {
    "chriswritescode-dev/tts.nvim",
    opts = {
      backend = "macos",
      macos = {
        -- pre-quoted: the plugin concatenates this unescaped into `sh -c "say -v ..."`
        voice = "'Evan (Enhanced)'",
        rate = 260,
      },
    },
  },
})

-- ============================================================================
-- LSP CONFIGURATION
-- ============================================================================

-- vim.keymap.set("n", "<space>f", function()
--   -- Call the LSP buffer formatting function synchronously
--   vim.lsp.buf.format({ async = false })
-- end, { noremap = true, silent = true })

-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "<space><left>", function()
  vim.diagnostic.jump({ count = -1 })
end)
vim.keymap.set("n", "<space><right>", function()
  vim.diagnostic.jump({ count = 1 })
end)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    -- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    -- vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<space>wi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<space>w<space>", vim.lsp.buf.signature_help, opts)
    -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    -- vim.keymap.set('n', '<space>wl', function()
    --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, opts)
    vim.keymap.set("n", "<space>wd", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<space>wa", vim.lsp.buf.code_action, opts)
    -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  end,
})

vim.o.undofile = true
vim.o.updatetime = 300

-- ============================================================================
-- EXTERNAL VIM CONFIGURATION FILES
-- ============================================================================
-- not migrated yet
vim.cmd("source " .. vim.fn.expand("~/dotfiles/vimrc/plugins-configs.vim"))
vim.cmd("source " .. vim.fn.expand("~/dotfiles/vimrc/keybindings.vim"))
vim.cmd("source " .. vim.fn.expand("~/dotfiles/vimrc/functions.vim"))
vim.cmd("source " .. vim.fn.expand("~/dotfiles/vimrc/general-variables.vim"))
vim.cmd("source " .. vim.fn.expand("~/dotfiles/vimrc/autocommands.vim"))

-- ============================================================================
-- FINAL SETUP
-- ============================================================================
require("lsp_file_refs_treesitter").setup()
-- NOTE: statement_jump is now installed as sibling-jump.nvim plugin (see CODE NAVIGATION section)
-- require("statement_jump").setup({
--   center_on_jump = true,
-- })
require("custom_functions")
require("search_context").setup({ context_lines = 3 })

vim.api.nvim_set_hl(0, "HlSearchLensNear", { link = "Substitute" })

vim.api.nvim_set_hl(0, "RefjumpReference", { link = "Substitute" })

vim.api.nvim_set_hl(0, "IlluminatedWordText", { fg = "#a0d995", bg = "#444045", underline = true })
vim.api.nvim_set_hl(0, "IlluminatedWordRead", { fg = "#a0d995", bg = "#444045", underline = true })
vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { fg = "#a0d995", bg = "#444045", underline = true })
vim.api.nvim_set_hl(0, "IlluminatedWordCursor", { fg = "#a0d995", bg = "#444045" })
vim.api.nvim_set_hl(0, "IlluminatedWordCursorRead", { fg = "#a0d995", bg = "#444045" })
vim.api.nvim_set_hl(0, "IlluminatedWordCursorWrite", { fg = "#a0d995", bg = "#444045" })
