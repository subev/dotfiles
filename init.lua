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

require("lazy").setup({
  {
    'rmagatti/goto-preview',
    config = function()
      require("goto-preview").setup({
        width = 150,
        height = 20,
        references = {
          width = 250,
        },
      })
    end
  },
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = {
          enable = true, -- false will disable the whole extension
          -- disable = { "elixir" },  -- list of language that will be disabled
          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          -- additional_vim_regex_highlighting = false,
        },
        textobjects = {
          select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              -- You can optionally set descriptions to the mappings (used in the desc parameter of
              -- nvim_buf_set_keymap) which plugins like which-key display
              ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
              -- You can also use captures from other query groups like `locals.scm`
              ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
              -- selects the return statement without the return keyword
              ["ir"] = { query = "@return.inner", desc = "Select inner part of a return statement" },
              ["ar"] = { query = "@return.outer", desc = "Select outer part of a return statement" },
            },
            -- You can choose the select mode (default is charwise 'v')
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * method: eg 'v' or 'o'
            -- and should return the mode ('v', 'V', or '<c-v>') or a table
            -- mapping query_strings to modes.
            selection_modes = {
              ["@parameter.outer"] = "v", -- charwise
              ["@function.outer"] = "V", -- linewise
              ["@class.outer"] = "<c-v>", -- blockwise
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            -- `ap`.
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * selection_mode: eg 'v'
            -- and should return true or false
            include_surrounding_whitespace = false,
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              ["]m"] = "@function.outer",
              -- ["]]"] = { query = "@class.outer", desc = "Next class start" },
              --
              -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queries.
              -- ["]o"] = "@loop.*",
              -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
              --
              -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
              -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
              ["]s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
              -- uses shift down arrow to go to next statement (more granular than function)
              ["J"] = "@statement.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              -- ["[["] = "@class.outer",
              ["K"] = "@statement.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
            -- Below will go to either the start or the end, whichever is closer.
            -- Use if you want more granular movements
            -- Make it even more gradual by adding multiple queries and regex.
            goto_next = {
              ["]d"] = "@conditional.outer",
            },
            goto_previous = {
              ["[d"] = "@conditional.outer",
            },
          },
        },
        textsubjects = {
          enable = true,
          keymaps = {
            [">"] = "textsubjects-smart",
            ["+"] = "textsubjects-container-outer",
          },
        },
        playground = {
          enable = true,
          disable = {},
          updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
          persist_queries = false, -- Whether the query persists across vim sessions
          keybindings = {
            toggle_query_editor = "o",
            toggle_hl_groups = "i",
            toggle_injected_languages = "t",
            toggle_anonymous_nodes = "a",
            toggle_language_display = "I",
            focus_language = "f",
            unfocus_language = "F",
            update = "R",
            goto_node = "<cr>",
            show_help = "?",
          },
        },
      })
    end
    },
  'nvim-treesitter/playground',
  -- shows wrapping function signature if it is outside of the view
  'nvim-treesitter/nvim-treesitter-context',
  'nvim-treesitter/nvim-treesitter-textobjects',
  {
    'ziontee113/syntax-tree-surfer',
    config = function()
      require("syntax-tree-surfer").setup()

      local opts = { noremap = true, silent = true }
      vim.keymap.set("x", "<c-j>", "<cmd>STSSelectNextSiblingNode<cr>", opts)
      vim.keymap.set("x", "<c-k>", "<cmd>STSSelectPrevSiblingNode<cr>", opts)
      vim.keymap.set("x", "<c-h>", "<cmd>STSSelectParentNode<cr>", opts)
      vim.keymap.set("x", "<c-l>", "<cmd>STSSelectChildNode<cr>", opts)

      vim.keymap.set("n", "<c-h>", "ve<c-h>", { noremap = false, silent = true })
    end
  },
  'RRethy/nvim-treesitter-textsubjects',

  'sainnhe/sonokai',
  'sainnhe/everforest',

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
  },

  {
    'aaronhallaert/advanced-git-search.nvim', dependencies = "ibhagwan/fzf-lua",
    config = function()
      require("advanced_git_search.fzf").setup({
        diff_plugin = "fugitive",
      })
    end
  },

  { "junegunn/fzf", build = "./install --bin" },
  'github/copilot.vim',

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" }
  },

  {
    'numToStr/Comment.nvim',
    config = function()
      require("Comment").setup({
        opleader = {
          block = "gB",
        },
      })
    end
  },

  'scrooloose/nerdtree',
  'Xuyuanp/nerdtree-git-plugin',
  'mhinz/vim-startify',
  'skanehira/gh.vim',

  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require("gitsigns").setup({
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
      })
    end
  },

  {
    'dnlhc/glance.nvim',
    config = function()
      require("glance").setup({
        hooks = {
          before_open = function(results, open, jump, method)
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
      })
    end
  },

  'tpope/vim-repeat',
  'tpope/vim-unimpaired',
  'tpope/vim-fireplace',
  'clojure-vim/vim-cider',
  'kana/vim-smartword',
  'bkad/camelcasemotion',
  'mg979/vim-visual-multi',
  'easymotion/vim-easymotion',
  'AndrewRadev/switch.vim',
  'AndrewRadev/splitjoin.vim',
  'AndrewRadev/sideways.vim',
  'jiangmiao/auto-pairs',

  {
    'NvChad/nvim-colorizer.lua',
    config = function()
      require("colorizer").setup({
        user_default_options = {
          hsl_fn = true,
          tailwind = true,
        },
      })
    end
  },
  'HiPhish/rainbow-delimiters.nvim',
  'mbbill/undotree',
  'matze/vim-move',
  'dyng/ctrlsf.vim',
  'tpope/vim-fugitive',
  {
    'sindrets/diffview.nvim',
    config = function()
      require("diffview").setup({
        keymaps = {
          view = { q = "<Cmd>DiffviewClose<CR>" },
          file_panel = { q = "<Cmd>DiffviewClose<CR>" },
          file_history_panel = { q = "<Cmd>DiffviewClose<CR>" },
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
      })
    end
  },
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<F6>",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      -- {
      --   "<leader>xX",
      --   "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      --   desc = "Buffer Diagnostics (Trouble)",
      -- },
      {
        "<space>O",
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
  'junegunn/gv.vim',
  'tpope/vim-rhubarb',
  'tpope/vim-surround',
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
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
          lualine_x = { "filetype" },
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
    end
  },
  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = { -- Example mapping to toggle outline
      { "<space>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
      -- Your setup opts here
      outline_window = {
        position = 'left',
        auto_close = true,
      }
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "marilari88/neotest-vitest",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-vitest"),
        }
      })
      vim.keymap.set("n", "<space>tt", function()
        require("neotest").run.run()
        require("neotest").summary.open()
      end, { desc = "Run nearest test" })

      vim.keymap.set("n", "<space>ts", function()
        require("neotest").run.stop()
        require("neotest").summary.close()
      end, { desc = "Stop nearest test" })

      vim.keymap.set("n", "<space>ta", function()
        require("neotest").run.run(vim.fn.expand("%"))
        require("neotest").summary.open()
      end, { desc = "Run current file tests" })

      vim.keymap.set("n", "<space>to", function()
        require("neotest").output.open({ enter = true })
      end, { desc = "See the output from the tests" })

      vim.keymap.set("n", "<space>tww", function()
        require('neotest').run.run({ vitestCommand = 'vitest --watch' })
      end, { desc = "Run & Watch Nearest Test" })

      vim.keymap.set("n", "<space>twa", function()
        require('neotest').run.run({ vim.fn.expand('%'), vitestCommand = 'vitest --watch' })
      end, { desc = "Run and Watch File" })
    end,
  },

  'mfussenegger/nvim-dap',
  {
    'rcarriga/nvim-dap-ui',
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
        }
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
            "--pool", "threads", -- disable worker threads (important for debugging)
            "--poolOptions.threads.singleThread"
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
      end ,{ desc = "DAP: Terminate" })

      -- maps F10 to step over
      vim.keymap.set("n", "<F10>",
        function() dap.step_over() end
      ,{ desc = "DAP: Step Over" })

      -- maps F11 to step into
      vim.keymap.set("n", "<F11>",
        function() dap.step_into() end
      ,{ desc = "DAP: Step Into" })

      -- maps F12 to step out
      vim.keymap.set("n", "<F12>",
        function() dap.step_out() end
      ,{ desc = "DAP: Step Out" })

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
  {
    "rcarriga/nvim-dap-ui",
    dependencies =
    {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio"
    }
  },
  {
    "j-hui/fidget.nvim",
    opts = {
      -- options
    },
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
      require('tiny-inline-diagnostic').setup({

      })

      vim.diagnostic.config({ virtual_text = false }) -- Disable default virtual text
    end
  },
  'jlanzarotta/bufexplorer',
  'junegunn/fzf.vim',
  'pbogut/fzf-mru.vim',
  'kien/ctrlp.vim',
  'nvim-lua/plenary.nvim',

  {
    'nvim-telescope/telescope.nvim',
    config= function()
      require("telescope").setup({
        extensions = {
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
          },
        },
      })

      -- CANT COMPILE THE FOLLOWING CAUSE CMAKE FAILS ON MACOS
      -- To get fzf loaded and working with telescope, you need to call
      -- load_extension, somewhere after setup function:
      -- require('telescope').load_extension('fzf')
    end
  },
  -- { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' },
  { 'nvim-tree/nvim-web-devicons',
    config = function()
      require("nvim-web-devicons").setup({
        -- your personnal icons can go here (to override)
        -- you can specify color or cterm_color instead of specifying both of them
        -- DevIcon will be appended to `name`
        override = {
          zsh = {
            icon = "",
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
            icon = "",
            color = "#f1502f",
            name = "Gitignore",
          },
        },
        -- same as `override` but specifically for overrides by extension
        -- takes effect when `strict` is true
        override_by_extension = {
          ["log"] = {
            icon = "",
            color = "#81e043",
            name = "Log",
          },
        },
      })
    end
  },

  {
    'pwntester/octo.nvim',
    config = function()
      require("octo").setup({
        enable_builtin = true,
      })
    end
  },

  'junegunn/vim-easy-align',

  {
    "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {},
    config = function()
      require("ibl").setup()
    end
  },

  'bronson/vim-visual-star-search',
  'terryma/vim-expand-region',
  'wellle/targets.vim',
  'michaeljsmith/vim-indent-object',
  'haya14busa/vim-textobj-function-syntax',
  'chrisbra/csv.vim',

  { 'stevearc/conform.nvim', opts = {}, },
  -- 'mhartington/formatter.nvim',

  'editorconfig/editorconfig-vim',
  'jeetsukumaran/vim-indentwise',

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
        copy = "<C-y>"  -- Normal mode keymap to copy the CSS values between {}
      }
    }
  },

  {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    config = function(_, opts)
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ts_ls",
          -- "vue_ls",
          -- "vtsls",
          "tailwindcss",
          "lua_ls",
        },
        automatic_enable = true,
      })
    end
  },

  {
    'mason-org/mason.nvim',
    config = function()
      require("mason").setup()
    end
  },

  'neovim/nvim-lspconfig',

  {
    'kevinhwang91/nvim-hlslens',
    config = function()
      require("hlslens").setup({
        nearest_only = {
          description = [[Only add lens for the nearest matched instance and ignore others]],
          default = false,
        },
        override_lens = function(render, posList, nearest, idx, relIdx)
          local sfw = vim.v.searchforward == 1
          local indicator, text, chunks
          local absRelIdx = math.abs(relIdx)
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
      vim.api.nvim_set_keymap( "n", "n",
        [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
        kopts
      )
      vim.api.nvim_set_keymap( "n", "N",
        [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
        kopts
      )
      vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

      vim.api.nvim_set_keymap("n", "<Leader>l", "<Cmd>noh<CR>", kopts)
    end
  },

  {
    'kevinhwang91/nvim-ufo', dependencies = "kevinhwang91/promise-async",
    config = function()
      vim.o.foldcolumn = "0" -- 1, '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
      vim.keymap.set("n", "zR", require("ufo").openAllFolds)
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
      vim.keymap.set("n", "zf", function()
        require("ufo").closeFoldsWith(1)
      end)

      require("ufo").setup({
        -- this is nice, but it is often too much
        -- close_fold_kinds = {'imports', 'comment'},
        provider_selector = function(bufnr, filetype, buftype)
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
    end
  },

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
    'Bekaboo/dropbar.nvim',
    -- optional, but required for fuzzy finder support
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim'
    },
    opts = {
      bar = {
        sources = function()
          local sources = require('dropbar.sources')
          return {
            sources.path
          }
        end
      }
    },
    config = function()
      vim.keymap.set("n", "<space>2", require("dropbar.api").pick)
    end
  },

  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
  },

  {
    "max397574/colortils.nvim",
    setup = function()
      require("colortils").setup()
    end
  },

  {
    "mhanberg/output-panel.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("output_panel").setup({
        max_buffer_size = 5000 -- default
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
    }
  },

  {'meznaric/key-analyzer.nvim', opts = {} },

  {
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
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
        },
        filesystem = {
          filtered_items = {
            visible = true,
          },
          window = {
            mappings = {
              -- disable fuzzy finder
              ["/"] = "noop",
            },
          },
        },
      })

      vim.keymap.set("n", "<space>e", "<Cmd>Neotree reveal<CR>")
    end
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
          null_ls.builtins.formatting.stylua,
          -- null_ls.builtins.formatting.prettierd,
          null_ls.builtins.code_actions.refactoring,
          -- null_ls.builtins.completion.spell,
          -- require("none-ls.diagnostics.eslint"),
          require("none-ls.diagnostics.eslint_d"),
          require("none-ls.code_actions.eslint_d"),
          require("none-ls.formatting.eslint_d"),
          -- require("none-ls.diagnostics.eslint"),
          -- require("none-ls.code_actions.eslint"),
          -- require("none-ls.formatting.eslint"),
        },
      })
    end
  },

  {
    "zeioth/none-ls-autoload.nvim",
    event = "BufEnter",
    dependencies = { "williamboman/mason.nvim", "nvimtools/none-ls.nvim" },
    opts = {},
  },

  {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = {
      'rafamadriz/friendly-snippets',
      {
        "mikavilpas/blink-ripgrep.nvim",
        version = "*", -- use the latest stable version
      }
    },

    -- use a release tag to download pre-built binaries
    version = '1.*',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = 'default' },
      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono'
      },
      -- (Default) Only show the documentation popup when manually triggered
      completion = { documentation = { auto_show = true } },
      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = {
          'lsp',
          'path',
          'snippets',
          'buffer',
          'ripgrep'  -- 👈🏻 add "ripgrep" here
        },
        providers = {
          -- 👇🏻👇🏻 add the ripgrep provider config below
          ripgrep = {
            module = "blink-ripgrep",
            name = "Ripgrep",
            -- see the full configuration below for all available options
            ---@module "blink-ripgrep"
            ---@type blink-ripgrep.Options
            opts = {},
          },
        },
      },
      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = "prefer_rust_with_warning" },
      signature = { enabled = true }
    },
    opts_extend = { "sources.default" }
  },

  'RRethy/vim-illuminate',

  {
    'nvimdev/lspsaga.nvim',
    config = function()
      require('lspsaga').setup({
        lightbulb = {
          enable = false,
        },
        symbol_in_winbar = {
          enable = false,
        },
      })
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter', -- optional
      'nvim-tree/nvim-web-devicons',     -- optional
    }
  }
})


vim.keymap.set("n", "<space>f", function()
  -- Call the LSP buffer formatting function synchronously
  vim.lsp.buf.format({ async = false })
end, { noremap = true, silent = true })

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

-- not migrated yet
vim.cmd("source " .. vim.fn.expand("~/dotfiles/vimrc/plugins-configs.vim"))
vim.cmd("source " .. vim.fn.expand("~/dotfiles/vimrc/keybindings.vim"))
vim.cmd("source " .. vim.fn.expand("~/dotfiles/vimrc/functions.vim"))
vim.cmd("source " .. vim.fn.expand("~/dotfiles/vimrc/general-variables.vim"))
vim.cmd("source " .. vim.fn.expand("~/dotfiles/vimrc/autocommands.vim"))

require('lsp_file_refs_treesitter').setup()
require('custom_functions')

vim.cmd([[
  highlight link HlSearchLensNear Substitute
]])
