return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed.
      "nvim-telescope/telescope.nvim", -- optional
      "ibhagwan/fzf-lua", -- optional
      "nvim-mini/mini.pick", -- optional
      "folke/snacks.nvim", -- optional
    },
    opts = {},
    keys = {
      { "<leader>g", "<cmd>Neogit<cr>", desc = "Open Neogit" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, { expr = true })

        map("n", "[c", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, { expr = true })

        -- Actions
        map("n", "<space>x", gs.reset_hunk)
        map("n", "<space>h", gs.preview_hunk)

        map("n", "<leader>hs", gs.stage_hunk)
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end)
        map("v", "<space>x", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end)
        map("n", "<leader>hS", gs.stage_buffer)
        map("n", "<leader>hu", gs.undo_stage_hunk)
        map("n", "<leader>hR", gs.reset_buffer)
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end)
        map("n", "<leader>tb", gs.toggle_current_line_blame)
        map("n", "<leader>hd", gs.diffthis)
        map("n", "<leader>hD", function()
          gs.diffthis("~")
        end)
        map("n", "<leader>td", gs.toggle_deleted)

        -- Text object
        map({ "o", "x" }, "ah", ":<C-U>Gitsigns select_hunk<CR>")
      end,
    },
  },
  {
    "tpope/vim-fugitive",
    init = function()
      vim.keymap.set("n", "gD", ":Gvdiffsplit<cr>", { noremap = true, silent = true, desc = "Git vertical diff split" })
      vim.keymap.set("n", "gb", ":G blame --date=relative<cr>", { noremap = true, silent = true, desc = "Git blame" })
      vim.keymap.set("v", "gb", ":GBrowse<cr>", { noremap = true, silent = true, desc = "Git browse" })
      vim.keymap.set("n", ",g", ":G<CR>", { noremap = true, silent = true, desc = "Git status" })
      vim.keymap.set("n", ",gg", ":G<CR><c-w>H", { noremap = true, silent = true, desc = "Git status in left pane" })
      vim.keymap.set(
        "n",
        ",gc",
        ":GV?<cr><c-w>H",
        { noremap = true, silent = true, desc = "Git commit log in new tab" }
      )
      vim.keymap.set(
        "n",
        ",gH",
        ":G log --stat -p -U0 --abbrev-commit --date=relative -- %<cr><c-w>H",
        { noremap = true, silent = true, desc = "Git file history in left pane" }
      )
      vim.keymap.set("n", ",gp", ":G pull", { noremap = true, silent = true, desc = "Git pull (waiting for confirm)" })
      vim.keymap.set("n", ",gs", ":G push", { noremap = true, silent = true, desc = "Git push (waiting for confirm)" })
      vim.keymap.set("n", ",gf", ":G fetch<cr>", { noremap = true, silent = true, desc = "Git fetch" })
      vim.keymap.set(
        "n",
        ",gx",
        ":G merge origin/master<cr>",
        { noremap = true, silent = true, desc = "Git merge origin/master" }
      )
      vim.keymap.set(
        "n",
        ",gz",
        ":G merge --continue<cr>",
        { noremap = true, silent = true, desc = "Git merge continue" }
      )
      vim.keymap.set(
        "n",
        "gM",
        ":Gvsplit origin/<C-r>=GetMasterBranchName()<CR>:%<cr>",
        { noremap = true, silent = true, desc = "Git vertical diff split with master" }
      )
      vim.keymap.set(
        "n",
        "gm",
        ":Gvdiffsplit origin/<C-r>=GetMasterBranchName()<CR>:%<cr>",
        { noremap = true, silent = true, desc = "Git see same file but in master" }
      )
      vim.keymap.set(
        "n",
        ",gM",
        ":G diff origin/<C-r>=GetMasterBranchName()<CR>... --no-ext-diff <cr><c-w>H",
        { noremap = true, silent = true, desc = "Git diff with master in left pane" }
      )
    end,
  },
  {
    "sindrets/diffview.nvim",
    opts = {
      keymaps = {
        view = {
          q = "<Cmd>DiffviewClose<CR>",
        },
        file_panel = {
          q = "<Cmd>DiffviewClose<CR>",
          -- {
          --   "n",
          --   "<up>",
          --   function()
          --     print("scrolling up, fix me")
          --     require("diffview.actions").scroll_view(-10)
          --   end,
          --   { desc = "Scroll the view up" },
          -- },
          -- {
          --   "n",
          --   "<down>",
          --   function()
          --     print("scrolling down, fix me")
          --     require("diffview.actions").scroll_view(10)
          --   end,
          --   { desc = "Scroll the view down" },
          -- },
        },
        file_history_panel = {
          q = "<Cmd>DiffviewClose<CR>",
        },
      },
      file_panel = {
        win_config = {
          width = 50,
        },
      },
      view = {
        merge_tool = {
          layout = "diff4_mixed",
          disable_diagnostics = true,
        },
      },
      hooks = {
        -- When a diff buffer is shown in a window: expand all folds and
        -- center the first change. Fires for each file (incl. <Tab> navigation).
        diff_buf_win_enter = function(_, winid, _)
          vim.api.nvim_win_call(winid, function()
            vim.opt_local.foldenable = false -- expand the collapsed unchanged regions
          end)
          -- Defer the cursor jump: when this hook fires the diff hasn't been
          -- computed yet, so ]c finds nothing. Schedule it for the next tick.
          vim.defer_fn(function()
            if vim.api.nvim_win_is_valid(winid) then
              vim.wo[winid].winhighlight = "" -- undo diffs.nvim's &diff recoloring in diffview
              vim.api.nvim_win_call(winid, function()
                vim.cmd("normal! gg]czz") -- jump to first change, center on screen
              end)
            end
          end, 50)
        end,
      },
    },
    lazy = false,
    keys = {
      { ",gd", ":DiffviewOpen<cr>", desc = "Git Diffview Open" },
      { ",gh", ":DiffviewFileHistory %<cr>", desc = "Git Diffview File History" },
      {
        ",gm",
        ":DiffviewOpen origin/<C-r>=GetMasterBranchName()<CR>...HEAD<cr>",
        desc = "Git Diffview Open with master",
      },
    },
  },
  {
    "barrettruth/diffs.nvim",
    -- must not be lazy-loaded (no keys/event/config); it lazy-loads itself
    lazy = false,
    init = function()
      vim.g.diffs = {
        integrations = {
          fugitive = true,
          neogit = true,
          gitsigns = true,
          -- built-in telescope integration replaced by the guarded autocmd below:
          -- it attaches to every preview, and binary previews (NUL bytes) crash
          -- its diff parser with E974 (blob passed to vim.fn.bufnr)
          telescope = false,
          difftastic = true,
        },
        highlights = {
          overrides = {
            -- neutralize the native &diff window recoloring so diffview looks stock
            DiffsDiffAdd = { link = "DiffAdd" },
            DiffsDiffDelete = { link = "DiffDelete" },
            DiffsDiffChange = { link = "DiffChange" },
            DiffsDiffText = { link = "DiffText" },
            -- sonokai's DiffAdd/DiffDelete bgs are too muted for the intra-line
            -- word spans; use its accent green/red blended onto Normal bg instead
            DiffsAddText = { bg = "#587847", bold = true },
            DiffsDeleteText = { bg = "#743c4c", bold = true },
          },
        },
      }
      vim.keymap.set("n", ",gr", "<cmd>Diff review HEAD<cr>", { desc = "Diffs Review Uncommitted" })
      vim.api.nvim_create_autocmd("User", {
        pattern = "TelescopePreviewerLoaded",
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, 50, false)) do
            if line:find("\0", 1, true) then
              return
            end
          end
          require("diffs.runtime").attach(buf)
        end,
      })
    end,
  },
  {
    dir = "~/repos/difftastic.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    config = function()
      require("difftastic-nvim").setup({
        vcs = "git",
        hunk_wrap_file = true,
        scroll_to_first_hunk = true,
        snacks_picker = { enabled = true },
        keymaps = {
          next_hunk = "<Tab>",
          prev_hunk = "<S-Tab>",
          focus_tree = false,
          focus_diff = false,
        },
      })
    end,
    keys = {
      { ",gD", "<cmd>:Difft<cr>", desc = "Difftastic Open" },
      { ",GM", "<cmd>:Difft origin/main..HEAD<cr>", desc = "Difftastic Open" },
      { ",gC", "<cmd>:DifftFileHistory <cr>", desc = "Difftastic File History" },
      { ",gk", "<cmd>DifftPick<cr>", desc = "Difftastic Pick Commit" },
    },
    cmd = { "Difft", "DifftPick", "DifftPickRange" },
  },
  -- Enables :GBrowse from fugitive.vim to open GitHub URLs
  "tpope/vim-rhubarb",
  {
    "junegunn/gv.vim",
    config = function() end,
  },
  "skanehira/gh.vim",
  {
    "pwntester/octo.nvim",
    opts = {
      enable_builtin = true,
    },
    keys = {
      { "<space>v", "<cmd>Octo<cr>", desc = "Open Octo" },
      { "<space>vv", "<cmd>Octo<cr>", desc = "Open Octo" },
      { "<leader>pro", "<cmd>Octo pr checkout<cr>", desc = "Checkout PR" },
      { "<leader>prr", "<cmd>Octo review start<cr>", desc = "Start PR Review" },
    },
    cmd = { "Octo" },
  },
  {
    "ldelossa/gh.nvim",
    dependencies = {
      {
        "ldelossa/litee.nvim",
        config = function()
          require("litee.lib").setup()
        end,
      },
    },
    config = function()
      require("litee.gh").setup()
    end,
  },
}
