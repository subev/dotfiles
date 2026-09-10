return {
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
        default_component_configs = {
          container = { right_padding = 1 },
          name = {
            use_filtered_colors = false,
            use_git_status_colors = true,
          },
          modified = { symbol = "● " },
          diagnostics = {
            symbols = {
              error = "",
              warn = "",
              info = "",
              hint = "",
            },
          },
          git_status = {
            symbols = {
              added = "",
              deleted = "",
              modified = "",
              renamed = "➜",
              untracked = "",
              ignored = "",
              unstaged = "",
              staged = "",
              conflict = "",
            },
          },
        },
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
              ["O"] = "system_reveal",
            },
          },
        },
        commands = {
          system_open = function(state)
            local path = state.tree:get_node():get_id()
            if vim.fn.has("mac") == 1 then
              vim.fn.jobstart({ "open", path }, { detach = true })
            elseif vim.fn.has("win32") == 1 then
              vim.fn.jobstart({ "cmd.exe", "/c", "start", "", path }, { detach = true })
            else
              vim.fn.jobstart({ "xdg-open", path }, { detach = true })
            end
          end,
          system_reveal = function(state)
            local path = state.tree:get_node():get_id()
            if vim.fn.has("mac") == 1 then
              vim.fn.jobstart({ "open", "-R", path }, { detach = true })
            elseif vim.fn.has("win32") == 1 then
              vim.fn.jobstart({ "explorer.exe", "/select," .. path }, { detach = true })
            else
              vim.fn.jobstart({ "xdg-open", vim.fs.dirname(path) }, { detach = true })
            end
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
}
