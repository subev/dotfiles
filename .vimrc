
" installs lazy.nvim if not exist
lua <<EOF
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
  'rmagatti/goto-preview',
  'nvim-treesitter/nvim-treesitter',
  'nvim-treesitter/playground',
  'nvim-treesitter/nvim-treesitter-context',
  'nvim-treesitter/nvim-treesitter-textobjects',
  'ziontee113/syntax-tree-surfer',
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
  { 'aaronhallaert/advanced-git-search.nvim', dependencies = "ibhagwan/fzf-lua" },
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
  'numToStr/Comment.nvim',
  'scrooloose/nerdtree',
  'Xuyuanp/nerdtree-git-plugin',
  'mhinz/vim-startify',
  'skanehira/gh.vim',
  'lewis6991/gitsigns.nvim',
  'dnlhc/glance.nvim',
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
  'NvChad/nvim-colorizer.lua',
  'HiPhish/rainbow-delimiters.nvim',
  'mbbill/undotree',
  'matze/vim-move',
  'dyng/ctrlsf.vim',
  'tpope/vim-fugitive',
  'sindrets/diffview.nvim',
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
  'itchyny/lightline.vim',
  'jlanzarotta/bufexplorer',
  'junegunn/fzf.vim',
  'pbogut/fzf-mru.vim',
  'kien/ctrlp.vim',
  'nvim-lua/plenary.nvim',
  'nvim-telescope/telescope.nvim',
  'nvim-tree/nvim-web-devicons',
  'pwntester/octo.nvim',
  'junegunn/vim-easy-align',
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
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
  },
  'mason-org/mason.nvim',
  'neovim/nvim-lspconfig',

  'kevinhwang91/nvim-hlslens',
  { 'kevinhwang91/nvim-ufo', dependencies = "kevinhwang91/promise-async" },
  {
    "rmagatti/auto-session",
    lazy = false,

    keys = {
      -- Will use Telescope if installed or a vim.ui.select picker otherwise
      { "<leader>s", "<cmd>SessionSearch<CR>", desc = "Session search" },
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
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
  },
  "max397574/colortils.nvim",
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
  },

  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvimtools/none-ls-extras.nvim",
    },
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
EOF

"let g:python3_host_prog = '/usr/local/bin/python3'

" order is important here
source ~/dotfiles/vimrc/custom-functions.lua
source ~/dotfiles/vimrc/plugins-configs.vim
source ~/dotfiles/vimrc/plugins-setup.lua
source ~/dotfiles/vimrc/keybindings.vim
source ~/dotfiles/vimrc/functions.vim
source ~/dotfiles/vimrc/general-variables.vim
source ~/dotfiles/vimrc/autocommands.vim
source ~/dotfiles/neovide.lua

lua require('lsp_file_refs').setup()

highlight link HlSearchLensNear Substitute
highlight link ScrollViewSearch Question
