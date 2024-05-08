
" installs lazy.nvim if not exist
lua <<EOF
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  'rmagatti/goto-preview',
  'nvim-treesitter/nvim-treesitter',
  'nvim-treesitter/playground',
  'nvim-treesitter/nvim-treesitter-context',
  'nvim-treesitter/nvim-treesitter-textobjects',
  'RRethy/nvim-treesitter-textsubjects',
  'sainnhe/sonokai',
  'f-person/auto-dark-mode.nvim',
  'sainnhe/everforest',
  'posva/vim-vue',
  'ianding1/leetcode.vim',
  { 'aaronhallaert/advanced-git-search.nvim', dependencies = "ibhagwan/fzf-lua" },
  { "junegunn/fzf", build = "./install --bin" },
  'github/copilot.vim',
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" }
  },
  'numToStr/Comment.nvim',
  'scrooloose/nerdtree',
  'Xuyuanp/nerdtree-git-plugin',
  'mhinz/vim-startify',
  'skanehira/gh.vim',
  'lewis6991/gitsigns.nvim',
  'elixir-editors/vim-elixir',
  { 'neoclide/coc.nvim', build = "npm ci" },
  'dnlhc/glance.nvim',
  'm-pilia/vim-ccls',
  'tpope/vim-repeat',
  'tpope/vim-unimpaired',
  'kana/vim-smartword',
  'bkad/camelcasemotion',
  'mg979/vim-visual-multi',
  'easymotion/vim-easymotion',
  'AndrewRadev/switch.vim',
  'AndrewRadev/splitjoin.vim',
  'AndrewRadev/sideways.vim',
  'jiangmiao/auto-pairs',
  'NvChad/nvim-colorizer.lua',
  'HiPhish/rainbow-delimiters.nvim',
  'mbbill/undotree',
  'matze/vim-move',
  'dyng/ctrlsf.vim',
  'tpope/vim-fugitive',
  'sindrets/diffview.nvim',
  'folke/trouble.nvim',
  'junegunn/gv.vim',
  'tpope/vim-rhubarb',
  'tpope/vim-surround',
  'itchyny/lightline.vim',
  'jlanzarotta/bufexplorer',
  'junegunn/fzf.vim',
  'pbogut/fzf-mru.vim',
  'kien/ctrlp.vim',
  'nvim-lua/plenary.nvim',
  'nvim-telescope/telescope.nvim',
  'nvim-tree/nvim-web-devicons',
  'pwntester/octo.nvim',
  'junegunn/vim-easy-align',
  'Yggdroot/indentLine',
  'bronson/vim-visual-star-search',
  'terryma/vim-expand-region',
  'wellle/targets.vim',
  'michaeljsmith/vim-indent-object',
  'haya14busa/vim-textobj-function-syntax',
  'chrisbra/csv.vim',
  'mhartington/formatter.nvim',
  'editorconfig/editorconfig-vim',
  'jeetsukumaran/vim-indentwise',
  {
    -- does not seem to work
    "MaximilianLloyd/tw-values.nvim",
    keys = {
      { "<leader><space><space>", "<cmd>TWValues<cr>", desc = "Show tailwind CSS values" },
    },
    opts = {
        border = "rounded", -- Valid window border style,
        show_unknown_classes = true, -- Shows the unknown classes popup
        focus_preview = true, -- Sets the preview as the current window
        copy_register = "", -- The register to copy values to,
        keymaps = {
            copy = "<C-y>"  -- Normal mode keymap to copy the CSS values between {}
        }
    }
  },
  -- order of the next 3 is important
  'williamboman/mason.nvim',
  "williamboman/mason-lspconfig.nvim",
  'neovim/nvim-lspconfig',

  'mfussenegger/nvim-dap',
  -- requird by nvim-dap-ui
  'nvim-neotest/nvim-nio',
  'rcarriga/nvim-dap-ui',
  -- 'dstein64/nvim-scrollview',
  'kevinhwang91/nvim-hlslens',
  { 'kevinhwang91/nvim-ufo', dependencies = "kevinhwang91/promise-async" },
  'honza/vim-snippets',

  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/nvim-cmp',
  'SirVer/ultisnips',
  'quangnguyen30192/cmp-nvim-ultisnips'
})

EOF

"let g:python3_host_prog = '/usr/local/bin/python3'

" order is important here
source ~/dotfiles/vimrc/custom-functions.lua
source ~/dotfiles/vimrc/plugins-configs.vim
source ~/dotfiles/vimrc/plugins-setup.lua
source ~/dotfiles/vimrc/keybindings.vim
source ~/dotfiles/vimrc/functions.vim
source ~/dotfiles/vimrc/general-variables.vim
source ~/dotfiles/vimrc/autocommands.vim
source ~/dotfiles/neovide.lua

highlight link HlSearchLensNear Substitute
highlight link ScrollViewSearch Question
