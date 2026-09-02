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
}
