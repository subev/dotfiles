-- A sidekick session id is the tool name plus a hash of the cwd, so a tool name
-- only ever has one session per directory. Registering the same CLI under
-- several names is what allows parallel sessions; these are those names, in
-- preference order.
local SLOTS = 5

local function slots(name)
  local ret = { name }
  for i = 2, SLOTS do
    ret[i] = ("%s_%d"):format(name, i)
  end
  return ret
end

local claude_slots = slots("claude")
-- Same CLI, DeepSeek backend; see bin/claude-deepseek.
local ds_slots = slots("claude_ds")

local function free_slot(names)
  local State = require("sidekick.cli.state")
  for _, name in ipairs(names) do
    if #State.get({ name = name, started = true, cwd = true }) == 0 then
      return name
    end
  end
end

-- Cycling visits the running agents in this directory in slot order. The ring
-- is rebuilt on every press, so an agent that exits drops out on its own.
local function next_agent(terminal)
  local State = require("sidekick.cli.state")
  local agents = State.get({ cwd = true, started = true })
  if #agents < 2 then
    vim.notify("No other agent in this directory", vim.log.levels.WARN)
    return
  end
  -- State.get orders by attached terminal before name, which would reshuffle
  -- the ring as we visit panes; sort by slot name so the order stays put.
  table.sort(agents, function(a, b)
    return a.tool.name < b.tool.name
  end)
  local current = 0
  for i, agent in ipairs(agents) do
    if agent.tool.name == terminal.tool.name then
      current = i
      break
    end
  end
  -- One agent on screen at a time, the way Ctrl-Tab works in a browser: cycling
  -- swaps panes rather than stacking them. Hiding closes the window and leaves
  -- the job running, so nothing is interrupted.
  local Terminal = require("sidekick.cli.terminal")
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local id = vim.w[win].sidekick_session_id
    local pane = id and Terminal.get(id)
    if pane then
      pane:hide()
    end
  end
  -- Attach the state itself rather than going through `cli.show({ name = ... })`:
  -- that filter matches the tool name alone, which also matches sessions in other
  -- directories and opens the picker as soon as more than one matches.
  local state = State.attach(agents[current % #agents + 1], { show = true, focus = true })
  -- Arriving ready to type: clear the mode Sidekick would restore, then insert
  -- after the main loop, because hiding the pane we came from leaves a
  -- `:stopinsert` that Neovim applies once this mapping returns and would
  -- otherwise undo the `startinsert`.
  local target = state and state.terminal
  if target then
    target.normal_mode = false
    vim.schedule(function()
      if target:is_running() and target.win and vim.api.nvim_win_is_valid(target.win) then
        vim.api.nvim_set_current_win(target.win)
        vim.cmd.startinsert()
      end
    end)
  end
end

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
        tools = {
          codex = {
            -- Zellij >= 0.44.1 preserves Codex's formatted scrollback in the main screen.
            cmd = { "codex", "--no-alt-screen" },
            keys = {
              buffers = false, -- Ctrl+B belongs to Codex's editor.
              files = false, -- Ctrl+F belongs to Codex's editor.
              prompt = false, -- Ctrl+P belongs to Codex's history navigation.
            },
          },
        },
        win = {
          keys = {
            goto_reference = {
              "gf",
              function(terminal)
                require("config.sidekick_links").gf(terminal)
              end,
              mode = "n",
              desc = "Open referenced file in the code pane",
            },
            next_agent = {
              "<c-n>",
              function(terminal)
                next_agent(terminal)
              end,
              mode = "tn",
              desc = "Next agent in this directory",
            },
          },
          config = function(terminal)
            if terminal.mux_backend ~= "zellij" then
              return
            end
            -- Sidekick generates this layout before starting the terminal.
            local layout = require("sidekick.config").state("zellij-layout-" .. terminal.parent.sid .. ".kdl")
            local lines = vim.fn.readfile(layout)
            if terminal.tool.name == "codex" then
              terminal.opts.wo.wrap = true
              terminal.opts.wo.scrolloff = 0
              require("config.sidekick_scrollback").setup(terminal)
              -- Zellij 0.44.1 can export ANSI history; Sidekick still disables its dump reader.
              terminal.parent.dump = function(session)
                local _, output = require("sidekick.util").exec({
                  "zellij",
                  "-s",
                  session.mux_session or session.sid,
                  "action",
                  "dump-screen",
                  "--full",
                  "--ansi",
                }, { timeout = 3000 })
                return output
              end
              -- With close_on_exit=true, let Zellij hold Codex's final output until
              -- Ctrl+C closes it or Enter runs it again.
              for i, line in ipairs(lines) do
                lines[i] = line:gsub("close_on_exit true", "close_on_exit false")
              end
            end
            -- The pane is embedded in Neovim, which owns navigation and the
            -- Ctrl keys it maps; the rest belong to the agent. Zellij's
            -- defaults would swallow them instead -- Ctrl+G locks the session
            -- with every key dead until Ctrl+G again.
            if not vim.tbl_contains(lines, "keybinds clear-defaults=true {}") then
              lines[#lines + 1] = "keybinds clear-defaults=true {}"
            end
            vim.fn.writefile(lines, layout)
          end,
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
      local claude = dofile(vim.api.nvim_get_runtime_file("sk/cli/claude.lua", false)[1])
      opts.cli.tools = opts.cli.tools or {}
      -- slot 1 is sidekick's built-in claude tool
      for i = 2, #claude_slots do
        opts.cli.tools[claude_slots[i]] = vim.tbl_extend("force", claude, { is_proc = false })
      end
      for _, name in ipairs(ds_slots) do
        opts.cli.tools[name] = vim.tbl_extend("force", claude, {
          cmd = { "claude-deepseek" },
          is_proc = false,
        })
      end
      require("sidekick").setup(opts)
      require("config.sidekick_links").setup()
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
          local name = free_slot(claude_slots)
          if name then
            require("sidekick.cli").show({ name = name, focus = true })
          else
            vim.notify("No free Claude slot", vim.log.levels.WARN)
          end
        end,
        desc = "New Claude Session",
      },
      {
        "<leader>aN",
        function()
          local name = free_slot(ds_slots)
          if name then
            require("sidekick.cli").show({ name = name, focus = true })
          else
            vim.notify("No free DeepSeek slot", vim.log.levels.WARN)
          end
        end,
        desc = "New DeepSeek Session",
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
