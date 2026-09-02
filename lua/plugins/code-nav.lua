return {
  {
    dir = "~/repos/sibling-jump", -- Use local development version
    opts = {
      next_key = "<C-j>",
      prev_key = "<C-k>",
      center_on_jump = true,
      filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "lua", "python", "swift" },
      block_loop_key = "Z", -- Cycle through block boundaries (if/else, functions, objects, arrays)
      block_loop_key_visual = "z", -- Visual mode keybinding for block-loop
      block_loop_center_on_jump = false, -- Don't center screen for block-loop (only for sibling-jump)
    },
  },
  {
    "aaronik/treewalker.nvim",
    opts = {
      scope_confined = true,
    },
    keys = {
      -- movement; in normal mode tidy up by closing the fold we leave and
      -- opening the one we land in. Surgical, no full-buffer redraw.
      {
        "<C-S-k>",
        function()
          vim.cmd("silent! normal! zc")
          vim.cmd("Treewalker Up")
          vim.cmd("silent! normal! zo")
        end,
        mode = "n",
        silent = true,
      },
      {
        "<C-S-j>",
        function()
          vim.cmd("silent! normal! zc")
          vim.cmd("Treewalker Down")
          vim.cmd("silent! normal! zo")
        end,
        mode = "n",
        silent = true,
      },
      { "<C-S-k>", "<cmd>Treewalker Up<cr>", mode = "v", silent = true },
      { "<C-S-j>", "<cmd>Treewalker Down<cr>", mode = "v", silent = true },
      { "<C-h>", "<cmd>Treewalker Left<cr>", mode = { "n", "v" }, silent = true },
      { "<C-l>", "<cmd>Treewalker Right<cr>", mode = { "n", "v" }, silent = true },
    },
  },
  {
    "rmagatti/goto-preview",
    opts = {
      width = 100,
      height = 40,
      references = {
        width = 250,
      },
    },
    keys = {
      { "gpp", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", desc = "Preview definition" },
      {
        "gpt",
        "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>",
        desc = "Preview type definition",
      },
      { "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", desc = "Preview implementation" },
      { "gp", "<cmd>lua require('goto-preview').close_all_win()<CR>", desc = "Close all preview windows" },
      { "gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>", desc = "Preview references" },
      { "gpd", "<cmd>lua require('goto-preview').goto_preview_declaration()<CR>", desc = "Preview declaration" },
    },
  },
  {
    "subev/refjump.nvim",
    -- branch = "all-feat",
    branch = "main",
    event = "LspAttach", -- Uncomment to lazy load
    opts = {
      keymaps = {
        enable = true,
        next = "J", -- Keymap to jump to next LSP reference
        prev = "K", -- Keymap to jump to previous LSP reference
      },
      highlights = {
        enable = true, -- Highlight the LSP references on jump
        auto_clear = true, -- Automatically clear highlights when cursor moves
        clear_on_escape = true, -- Listen for escape/ctrl-c to clear highlights (non-intrusive)
      },
      counter = {
        enable = true, -- Enable virtual text counter at end of line
      },
      loop = false, -- Don't loop back to first/last reference when reaching the end
    },
  },
  {
    "dnlhc/glance.nvim",
    opts = {
      hooks = {
        before_open = function(results, open, jump)
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
    },
    keys = {
      { ",d", "<cmd>Glance definitions<cr>", desc = "Glance definitions" },
      { "gti", "<cmd>Glance implementations<cr>", desc = "Glance implementations" },
      { "gr", "<cmd>Glance references<cr>", desc = "Glance references" },
      { "gT", "<cmd>Glance type_definitions<cr>", desc = "Glance type_definitions" },
      { "<space><backspace>", "<cmd>Glance references<cr>", desc = "Glance references" },
    },
  },
  {
    "subev/vim-illuminate",
    branch = "feat/cursor-highlight-groups",
    lazy = false,
    config = function()
      require("illuminate").configure({})
    end,
  },
}
