-- ufo setup
-- fixes the vim is undefined error
local vim = vim or {}
vim.o.foldcolumn = "0" -- 1, '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
vim.keymap.set("n", "zf", function()
  require("ufo").closeFoldsWith(1)
end)

require("ufo").setup({
  -- this is nice, but it is often too much
  -- close_fold_kinds = {'imports', 'comment'},
  provider_selector = function(bufnr, filetype, buftype)
    return { "lsp", "indent" }
  end,
  fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = (" 󰁂 %d "):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
      local chunkText = chunk[1]
      local chunkWidth = vim.fn.strdisplaywidth(chunkText)
      if targetWidth > curWidth + chunkWidth then
        table.insert(newVirtText, chunk)
      else
        chunkText = truncate(chunkText, targetWidth - curWidth)
        local hlGroup = chunk[2]
        table.insert(newVirtText, { chunkText, hlGroup })
        chunkWidth = vim.fn.strdisplaywidth(chunkText)
        -- str width returned from truncate() may less than 2nd argument, need padding
        if curWidth + chunkWidth < targetWidth then
          suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
        end
        break
      end
      curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, { suffix, "MoreMsg" })
    return newVirtText
  end,
})

require("gitsigns").setup({
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
})

require("hlslens").setup({
  nearest_only = {
    description = [[Only add lens for the nearest matched instance and ignore others]],
    default = false,
  },
  override_lens = function(render, posList, nearest, idx, relIdx)
    local sfw = vim.v.searchforward == 1
    local indicator, text, chunks
    local absRelIdx = math.abs(relIdx)
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

vim.api.nvim_set_keymap(
  "n",
  "n",
  [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
  kopts
)
vim.api.nvim_set_keymap(
  "n",
  "N",
  [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
  kopts
)
vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

vim.api.nvim_set_keymap("n", "<Leader>l", "<Cmd>noh<CR>", kopts)
-- end of hlslens setup

require("advanced_git_search.fzf").setup({
  diff_plugin = "fugitive",
})

require("Comment").setup({
  opleader = {
    block = "gB",
  },
})

require("glance").setup({
  hooks = {
    before_open = function(results, open, jump, method)
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
})

require("goto-preview").setup({
  width = 150,
  height = 20,
  references = {
    width = 250,
  },
})

require("diffview").setup({
  keymaps = {
    view = { q = "<Cmd>DiffviewClose<CR>" },
    file_panel = { q = "<Cmd>DiffviewClose<CR>" },
    file_history_panel = { q = "<Cmd>DiffviewClose<CR>" },
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
})

require("trouble").setup({})

local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua,
    -- null_ls.builtins.formatting.prettierd,
    null_ls.builtins.code_actions.refactoring,
    -- null_ls.builtins.completion.spell,
    -- require("none-ls.diagnostics.eslint"),
    require("none-ls.diagnostics.eslint_d"),
    require("none-ls.code_actions.eslint_d"),
    require("none-ls.formatting.eslint_d"),
    -- require("none-ls.diagnostics.eslint"),
    -- require("none-ls.code_actions.eslint"),
    -- require("none-ls.formatting.eslint"),
  },
})

require("colorizer").setup({
  user_default_options = {
    hsl_fn = true,
    tailwind = true,
  },
})

require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true, -- false will disable the whole extension
    -- disable = { "elixir" },  -- list of language that will be disabled
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    -- additional_vim_regex_highlighting = false,
  },
  textsubjects = {
    enable = true,
    keymaps = {
      [">"] = "textsubjects-smart",
      ["+"] = "textsubjects-container-outer",
    },
  },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = "o",
      toggle_hl_groups = "i",
      toggle_injected_languages = "t",
      toggle_anonymous_nodes = "a",
      toggle_language_display = "I",
      focus_language = "f",
      unfocus_language = "F",
      update = "R",
      goto_node = "<cr>",
      show_help = "?",
    },
  },
})

require("octo").setup({
  enable_builtin = true,
})

require('telescope').setup {
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  }
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
-- require('telescope').load_extension('fzf')

require("nvim-web-devicons").setup({
  -- your personnal icons can go here (to override)
  -- you can specify color or cterm_color instead of specifying both of them
  -- DevIcon will be appended to `name`
  override = {
    zsh = {
      icon = "",
      color = "#428850",
      cterm_color = "65",
      name = "Zsh",
    },
  },
  -- globally enable different highlight colors per icon (default to true)
  -- if set to false all icons will have the default icon's color
  color_icons = true,
  -- globally enable default icons (default to false)
  -- will get overriden by `get_icons` option
  default = true,
  -- globally enable "strict" selection of icons - icon will be looked up in
  -- different tables, first by filename, and if not found by extension; this
  -- prevents cases when file doesn't have any extension but still gets some icon
  -- because its name happened to match some extension (default to false)
  strict = true,
  -- same as `override` but specifically for overrides by filename
  -- takes effect when `strict` is true
  override_by_filename = {
    [".gitignore"] = {
      icon = "",
      color = "#f1502f",
      name = "Gitignore",
    },
  },
  -- same as `override` but specifically for overrides by extension
  -- takes effect when `strict` is true
  override_by_extension = {
    ["log"] = {
      icon = "",
      color = "#81e043",
      name = "Log",
    },
  },
})

require("mason").setup({})
require("mason-lspconfig").setup({
  ensure_installed = {
    "ts_ls",
    -- "vue_ls",
    -- "vtsls",
    "tailwindcss",
    "lua_ls",
  },
  automatic_enable = true,
})

-- local vue_ls_path = vim.fn.expand("$MASON/packages/vue-language-server")
-- local vue_plugin_path = vue_ls_path .. "/node_modules/@vue/language-server"
-- local vue_ts_plugin = {
--   name = "@vue/typescript-plugin",
--   location = vue_plugin_path,
--   languages = { "vue" },
--   configNamespace = "typescript",
-- }
-- all of above and this taken from here:
-- https://github.com/neovim/nvim-lspconfig/commit/85379d02d3bac8dc68129a4b81d7dbd00c8b0f77
-- vim.lsp.config("vtsls", {
--   settings = {
--     vtsls = {
--       tsserver = {
--         globalPlugins = {
--           vue_ts_plugin,
--         },
--       },
--     },
--   },
--   filetypes = { "vue" },
-- })


-- ALTERNATIVE FORMATTER 'CONFORM'
-- require("conform").setup({
--   formatters_by_ft = {
--     lua = { "stylua" },
--     -- Conform will run multiple formatters sequentially
--     python = { "isort", "black" },
--     -- You can customize some of the format options for the filetype (:help conform.format)
--     rust = { "rustfmt", lsp_format = "fallback" },
--     -- Conform will run the first available formatter
--     javascript = { "eslint_d", stop_after_first = true },
--     typescriptreact = { "eslint_d", stop_after_first = true },
--     typescript = { "eslint_d", stop_after_first = true },
--   },
-- })
--
-- vim.api.nvim_create_user_command("Format", function(args)
--   local range = nil
--   if args.count ~= -1 then
--     local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
--     range = {
--       start = { args.line1, 0 },
--       ["end"] = { args.line2, end_line:len() },
--     }
--   end
--   require("conform").format({ async = true, lsp_format = "fallback", range = range })
-- end, { range = true })
-- vim.keymap.set("n", "<space>f", "<Cmd>Format<CR>")

vim.keymap.set("n", "<space>f", function()
    -- Call the LSP buffer formatting function synchronously
    vim.lsp.buf.format({ async = false })
end, { noremap = true, silent = true })

-- require('formatter').setup({
--   logging = false,
--   filetype = {
--     typescript = {
--        function()
--           return {
--             exe = "eslint_d",
--             args = {vim.api.nvim_buf_get_name(0)},
--             stdin = true
--           }
--         end
--     },
--     -- other formatters ...
--   }
-- })

-- "lukas-reineke/indent-blankline.nvim",
require("ibl").setup()

-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "<space><left>", function()
  vim.diagnostic.jump({ count = -1 })
end)
vim.keymap.set("n", "<space><right>", function()
  vim.diagnostic.jump({ count = 1 })
end)

vim.o.updatetime = 300

local function hover_is_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg and cfg.relative ~= "" then
      local bufnr = vim.api.nvim_win_get_buf(win)
      local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
      -- Hover windows are opened with filetype = "lspinfo" or "markdown"
      -- You can refine this check if needed
      if ft == "markdown" then
        return true
      end
    end
  end
  return false
end

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    if not hover_is_open() then
      vim.diagnostic.open_float(nil, { focus = false })
    end
  end,
})

-- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    -- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<space>wi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<space>w<space>", vim.lsp.buf.signature_help, opts)
    -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    -- vim.keymap.set('n', '<space>wl', function()
    --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, opts)
    vim.keymap.set("n", "<space>wd", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<space>wa", vim.lsp.buf.code_action, opts)
    -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  end,
})

local stf = require("syntax-tree-surfer")
stf.setup()

-- settings for 'ziontee113/syntax-tree-surfer',
local opts = { noremap = true, silent = true }
vim.keymap.set("x", "<c-j>", "<cmd>STSSelectNextSiblingNode<cr>", opts)
vim.keymap.set("x", "<c-k>", "<cmd>STSSelectPrevSiblingNode<cr>", opts)
vim.keymap.set("x", "<c-h>", "<cmd>STSSelectParentNode<cr>", opts)
vim.keymap.set("x", "<c-l>", "<cmd>STSSelectChildNode<cr>", opts)

vim.keymap.set("n", "<c-h>", "ve<c-h>", { noremap = false, silent = true })

-- ***************
-- Bekaboo/dropbar.nvim
vim.keymap.set("n", "<space>2", require("dropbar.api").pick)

-- colorutils
require("colortils").setup()

vim.keymap.set("n", "<space>e", "<Cmd>Neotree reveal<CR>")
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
  },
  filesystem = {
    filtered_items = {
      visible = true,
    },
    window = {
      mappings = {
        -- disable fuzzy finder
        ["/"] = "noop",
      },
    },
  },
})
