" General variables set {{{

  set background=dark    " Setting dark mode
  set termguicolors

  " hides formatting symbols, might be overriden
  set conceallevel=0

  " this is the default one, but there is also a plugin called auto-dark-mode
  " that automatically changes it based on the system config
  let g:sonokai_style = 'shusia'
  " let g:everforest_background = 'soft'
  colorscheme sonokai

  " this way you can use gf to open a file at a specific line
  set isfname-=:
  set iskeyword+=-,\$

  set scrolloff=20
  " hide the toolbar and the menu of GVIM
  set guioptions-=m
  set guioptions-=T

  " show line numbers
  set number
  set mouse=a
  " highlight lineNr ctermfg=grey
  "syntax on

  "set cursorline
  "hi CursorLine guibg=NONE

  " show trailing whitespace
  set list listchars=tab:->,trail:.

  " ignore binaries and artifacts
  set wildignore=*.o,*.obj,*.bin,*.dll,*.zip
  " exclude version control directories
  set wildignore+=*/.git/*,*/.hg/*,*/.svn/*
  set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*

  "set completeopt=menuone

  set tabstop=2
  set shiftwidth=2
  set softtabstop=2
  set expandtab

  "switch paste behavior to avoid added tabs
  " set pastetoggle=<F10>

  set smartindent

  filetype plugin indent on

  set hidden

  set shortmess-=S

  if $TMUX == ''
    set clipboard+=unnamed
  endif
  set encoding=utf-8

  set colorcolumn=100

  " searching
  set ignorecase
  set smartcase
  set incsearch
  set hlsearch

  " avoid swap, temp and backup files
  set nobackup
  set nowritebackup
  set noswapfile

  if !has('nvim')
    set ttymouse=xterm2
  endif

  hi CocHighlightText ctermbg=241 guibg=#665c54
" }}}
