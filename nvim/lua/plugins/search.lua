return {
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
}
