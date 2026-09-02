return {
  { "junegunn/fzf", build = "./install --bin" },
  {
    "junegunn/fzf.vim",
    config = function()
      -- this whole plugin is for just that one mapping, still can't find better
      vim.keymap.set(
        "n",
        "<space>s",
        "<cmd>Rg<cr>",
        { noremap = true, silent = true, desc = "Search with FZF Ripgrep" }
      )
      -- vim.keymap.set("v", "<space>s", 'y:Rg <C-r>"<CR>', {
      --   noremap = true,
      --   silent = true,
      --   desc = "Search selection with FZF Ripgrep",
      -- })
    end,
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    config = function()
      local fzf = require("fzf-lua")
      vim.keymap.set("n", "<F1>", fzf.help_tags, { noremap = true, silent = true, desc = "FZF help tags" })
      -- vim.keymap.set("n", "<space>s", function()
      --   fzf.grep_project({ fzf_opts = { ["--nth"] = false } })
      -- end, { noremap = true, silent = true, desc = "FZF grep (path + content)" })
      vim.keymap.set("n", ",s", fzf.grep_project, { noremap = true, silent = true, desc = "FZF grep (content only)" })
      vim.keymap.set("n", ",S", fzf.resume, { noremap = true, silent = true, desc = "FZF resume" })
      vim.keymap.set("v", "<space>s", fzf.grep_visual, { noremap = true, silent = true, desc = "FZF grep selection" })
      vim.keymap.set("v", ",s", fzf.grep_visual, { noremap = true, silent = true, desc = "FZF grep selection" })
      vim.keymap.set("n", ",b", fzf.buffers, { noremap = true, silent = true, desc = "FZF buffers" })
      vim.keymap.set(
        "n",
        "<space>`",
        fzf.grep_curbuf,
        { noremap = true, silent = true, desc = "FZF grep current buffer" }
      )
    end,
  },
  "pbogut/fzf-mru.vim",
  "nvim-lua/plenary.nvim",
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      local action_state = require("telescope.actions.state")
      local telescope = require("telescope")
      telescope.setup({
        extensions = {
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
          },
          frecency = {
            hide_current_buffer = true,
          },
        },
      })
      -- Load the FZF extension
      telescope.load_extension("fzf")
      telescope.load_extension("frecency")

      local builtin = require("telescope.builtin")
      local extensions = telescope.extensions
      local frecency_module = require("frecency")
      local frecency_config = require("frecency.config")
      local function frecency_picker()
        extensions.frecency.frecency({
          attach_mappings = function(prompt_bufnr, map)
            local function refresh_frecency_results()
              local picker = action_state.get_current_picker(prompt_bufnr)
              local frecency_instance = frecency_module.frecency
              local frecency_picker_state = frecency_instance and frecency_instance.picker
              if not (picker and frecency_picker_state) then
                return
              end

              local prompt = picker:_get_prompt()
              local _, _, workspace_tag = prompt:find(frecency_picker_state.workspace_tag_regex)
              local active_workspace_tag = workspace_tag
                or frecency_picker_state.config.initial_workspace_tag
                or frecency_config.default_workspace
              local new_finder =
                frecency_picker_state:finder(picker, frecency_picker_state.workspaces, active_workspace_tag)

              picker:refresh(new_finder, { reset_prompt = false })
              new_finder:start()
            end

            map({ "i", "n" }, "<C-x>", function()
              local selection = action_state.get_selected_entry()
              local path = selection and (selection.filename or selection.name or selection.path or selection.value)
              if not path then
                return
              end
              vim.cmd("FrecencyDelete " .. vim.fn.fnameescape(path))
              refresh_frecency_results()
            end, { nowait = true })
            map({ "i", "n" }, "<F7>", function()
              vim.cmd("FrecencyValidate!")
              refresh_frecency_results()
            end, { nowait = true })
            return true
          end,
        })
      end
      -- Keymaps
      -- vim.keymap.set('n', '<F1>', builtin.help_tags, { desc = 'Telescope help tags' })
      -- vim.keymap.set('n', '<space>d', '<cmd>Telescope<cr>', { desc = 'Open Telescope' }) -- optional
      vim.keymap.set("n", ",f", builtin.find_files, { desc = "Telescope find files" })
      -- The two below use <c-r><c-w>, which can't be directly expressed in Lua — we simulate it using an expression
      vim.keymap.set("n", ",F", function()
        builtin.find_files({ default_text = vim.fn.expand("<cword>") })
      end, { desc = "Find files with word under cursor" })
      vim.keymap.set("n", "gF", function()
        builtin.find_files({ search_file = vim.fn.expand("<cword>") })
      end, { desc = "Search files matching word under cursor" })
      vim.keymap.set("n", "<space>df", builtin.oldfiles, { desc = "Telescope old files" })
      vim.keymap.set("n", ",v", frecency_picker, { desc = "Telescope frecency" })
      vim.keymap.set("n", "<space>dg", builtin.live_grep, { desc = "Telescope live grep" })
      vim.keymap.set("n", "<space>db", builtin.buffers, { desc = "Telescope buffers" })
      vim.keymap.set("n", "<space>dh", builtin.help_tags, { desc = "Telescope help tags" })
      vim.keymap.set("n", "<space>de", builtin.builtin, { desc = "Telescope builtins" })
      vim.keymap.set("n", "<space>o", builtin.lsp_document_symbols, { desc = "Telescope document symbols" })
      vim.keymap.set("n", "<space>O", builtin.lsp_dynamic_workspace_symbols, { desc = "Telescope document symbols" })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-frecency.nvim",
        version = "*",
      },
    },
  },
  {
    "dmtrKovalenko/fff",
    build = function()
      require("fff.download").download_or_build_binary()
    end,
    -- eager load so the rust backend starts indexing at startup
    lazy = false,
    opts = {},
    keys = {
      {
        ",a",
        function()
          -- auto-pairs' BufEnter init crashes on fff's lua <CR> mapping (maparg has no rhs)
          local saved = vim.o.eventignore
          vim.opt.eventignore:append("BufEnter")
          local ok, err = pcall(require("fff").find_files)
          vim.o.eventignore = saved
          if not ok then
            vim.notify(tostring(err), vim.log.levels.ERROR)
          end
        end,
        desc = "FFF find files (trial vs ,f)",
      },
    },
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = function()
      return vim.fn.executable("make") == 1
    end,
  },
  {
    "kien/ctrlp.vim",
    config = function()
      vim.g.ctrlp_max_files = 0
      vim.g.ctrlp_show_hidden = 1
      vim.g.ctrlp_working_path_mode = "rw"
      vim.g.ctrlp_by_filename = 1
      vim.g.ctrlp_mruf_max = 2500
      vim.g.ctrlp_mruf_exclude = "/tmp/.*\\|/temp/.*\\|/private/.*\\|.*/node_modules/.*\\|.*/.pyenv/.*"
      vim.g.ctrlp_user_command = 'rg %s --files --color=never --glob ""'
      -- Keymaps
      vim.keymap.set("n", ",x", ":CtrlPMRUFiles<CR>", { noremap = true, silent = true })
      -- vim.keymap.set("n", ",v", "<cmd>Telescope frecency workspace=CWD<cr>", { noremap = true, silent = true })
      vim.keymap.set("n", ",V", "<cmd>Telescope oldfiles<cr>", { noremap = true, silent = true })
    end,
  },
}
