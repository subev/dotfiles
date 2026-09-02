return {
  {
    "nvim-neotest/neotest",
    lazy = false,
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "marilari88/neotest-vitest",
      { url = "https://codeberg.org/mmllr/neotest-swift-testing" },
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
          }),
          require("neotest-swift-testing"),
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
}
