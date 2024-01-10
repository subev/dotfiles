-- ufo setup
vim.o.foldcolumn = '0' -- 1, '0' is not bad
vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
vim.keymap.set('n', 'zf', function() require('ufo').closeFoldsWith(1) end)

require('ufo').setup({
  -- this is nice, but it is often too much
  -- close_fold_kinds = {'imports', 'comment'},
  provider_selector = function(bufnr, filetype, buftype)
    return { 'lsp', 'indent' }
  end,
  fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = (' 󰁂 %d '):format(endLnum - lnum)
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
          suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
        end
        break
      end
      curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, { suffix, 'MoreMsg' })
    return newVirtText
  end
})

require('gitsigns').setup {
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    -- Actions
    map('n', '<space>x', gs.reset_hunk)
    map('n', '<space>h', gs.preview_hunk)

    map('n', '<leader>hs', gs.stage_hunk)
    map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
    map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
    map('n', '<leader>hS', gs.stage_buffer)
    map('n', '<leader>hu', gs.undo_stage_hunk)
    map('n', '<leader>hR', gs.reset_buffer)
    map('n', '<leader>hb', function() gs.blame_line { full = true } end)
    map('n', '<leader>tb', gs.toggle_current_line_blame)
    map('n', '<leader>hd', gs.diffthis)
    map('n', '<leader>hD', function() gs.diffthis('~') end)
    map('n', '<leader>td', gs.toggle_deleted)

    -- Text object
    map({ 'o', 'x' }, 'ah', ':<C-U>Gitsigns select_hunk<CR>')
  end
}
-- require('scrollview.contrib.gitsigns').setup()

require('hlslens').setup({
  nearest_only = {
    description = [[Only add lens for the nearest matched instance and ignore others]],
    default = false
  },
  override_lens = function(render, posList, nearest, idx, relIdx)
    local sfw = vim.v.searchforward == 1
    local indicator, text, chunks
    local absRelIdx = math.abs(relIdx)
    indicator = sfw and '▼' or '▲'

    local lnum, col = unpack(posList[idx])
    if nearest then
      local cnt = #posList
      text = ('[%s %d/%d]'):format(indicator, idx, cnt)
      chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLensNear' } }
    else
      text = ('[%s %d]'):format(indicator, idx)
      chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLens' } }
    end
    render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
  end
})

local kopts = { noremap = true, silent = true }

vim.api.nvim_set_keymap('n', 'n',
  [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
  kopts)
vim.api.nvim_set_keymap('n', 'N',
  [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
  kopts)
vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

vim.api.nvim_set_keymap('n', '<Leader>l', '<Cmd>noh<CR>', kopts)
-- end of hlslens setup

require 'advanced_git_search.fzf'.setup {
  diff_plugin = "fugitive",
}

require('Comment').setup {
  opleader = {
    block = 'gB',
  }
}

require 'glance'.setup {
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
}

require('goto-preview').setup {
  width = 150,
  height = 20,
  references = {
    width = 250,
  }
}

require('diffview').setup {
  keymaps = {
    view = { q = "<Cmd>CocEnable<CR><Cmd>DiffviewClose<CR>" },
    file_panel = { q = "<Cmd>CocEnable<CR><Cmd>DiffviewClose<CR>" },
    file_history_panel = { q = "<Cmd>CocEnable<CR><Cmd>DiffviewClose<CR>" },
  },
  file_panel = {
    win_config = {
      width = 50,
    }
  },
  view = {
    merge_tool = {
      layout = "diff4_mixed",
      disable_diagnostics = true,
    }
  }
}

require('trouble').setup {
}

require 'colorizer'.setup({
  user_default_options = {
    hsl_fn = true,
    tailwind = true,
  }
})

require 'nvim-treesitter.configs'.setup {
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
      ['>'] = 'textsubjects-smart',
      ['+'] = 'textsubjects-container-outer',
    }
  },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25,         -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = 'o',
      toggle_hl_groups = 'i',
      toggle_injected_languages = 't',
      toggle_anonymous_nodes = 'a',
      toggle_language_display = 'I',
      focus_language = 'f',
      unfocus_language = 'F',
      update = 'R',
      goto_node = '<cr>',
      show_help = '?',
    },
  },
}

require "octo".setup {
  enable_builtin = true
}

require 'nvim-web-devicons'.setup {
  -- your personnal icons can go here (to override)
  -- you can specify color or cterm_color instead of specifying both of them
  -- DevIcon will be appended to `name`
  override = {
    zsh = {
      icon = "",
      color = "#428850",
      cterm_color = "65",
      name = "Zsh"
    }
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
      name = "Gitignore"
    }
  },
  -- same as `override` but specifically for overrides by extension
  -- takes effect when `strict` is true
  override_by_extension = {
    ["log"] = {
      icon = "",
      color = "#81e043",
      name = "Log"
    }
  },
}

require('auto-dark-mode').setup({
  update_interval = 3000,
  set_dark_mode = function()
    vim.api.nvim_set_option('background', 'dark')
    vim.cmd('colorscheme sonokai')
  end,
  set_light_mode = function()
    vim.api.nvim_set_option('background', 'light')
    vim.cmd('colorscheme everforest')
  end,
})

require 'lspconfig'.elixirls.setup {
  -- sadly the below path cannot be expanded
  cmd = { "/Users/petur/nvim-lsp/elixir/elixir-ls-v0.16.0/language_server.sh" },
}
require 'mason'.setup {}
require 'formatter'.setup {}
require 'lspconfig'.tsserver.setup {}
require 'lspconfig'.volar.setup {}
require 'lspconfig'.vimls.setup {}
require 'lspconfig'.tailwindcss.setup {}
require 'lspconfig'.lua_ls.setup {}

-- require'lspconfig'.pyright.setup{}
-- require'lspconfig'.eslint.setup{}
