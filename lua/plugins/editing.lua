return {
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
          "fff_input",
          "fff_list",
          "fff_preview",
          "fff_file_info",
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
}
