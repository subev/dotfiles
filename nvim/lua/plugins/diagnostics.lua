return {
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
}
