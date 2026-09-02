return {
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
    config = function(_, opts)
      -- session id is derived from tool name + cwd, so extra names = extra parallel claudes
      local claude = dofile(vim.api.nvim_get_runtime_file("sk/cli/claude.lua", false)[1])
      opts.cli.tools = opts.cli.tools or {}
      for i = 2, 5 do
        opts.cli.tools["claude_" .. i] = vim.tbl_extend("force", claude, { is_proc = false })
      end
      require("sidekick").setup(opts)
    end,
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
        "<leader>an",
        function()
          local State = require("sidekick.cli.state")
          for i = 1, 5 do
            local name = i == 1 and "claude" or ("claude_" .. i)
            if #State.get({ name = name, started = true, cwd = true }) == 0 then
              return require("sidekick.cli").show({ name = name, focus = true })
            end
          end
          vim.notify("No free Claude slot", vim.log.levels.WARN)
        end,
        desc = "New Claude Session",
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
}
