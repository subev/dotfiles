" disable the highlight search
nnoremap <CR> :noh<CR><CR>

" increase the window size
set lines=60 columns=220

filetype off
set rtp=~/.vim/bundle/vundle/,~/.vim,$VIMRUNTIME
let g:snippets_dir='~/dotfiles/snippets/'
call vundle#rc()

" Plugins {
    Bundle 'gmarik/vundle'

    " themes
    Bundle 'Railscasts-Theme-GUIand256color'
    Bundle 'flazz/vim-colorschemes'

    Bundle 'groenewege/vim-less'
    Bundle 'msanders/snipmate.vim'
    Bundle 'scrooloose/nerdcommenter'
    Bundle 'scrooloose/nerdtree'
    " Bundle 'vim-scripts/JavaScript-Indent'
    Bundle 'vim-scripts/Javascript-Indentation'
    Bundle 'vim-scripts/jsbeautify'
    Bundle 'flazz/vim-colorschemes'
    " improvement instead of ctrlp
    " Bundle 'sjbach/lusty'
    Bundle 'underlog/vim-PairTools'
    Bundle 'mattn/emmet-vim'
    " Bundle 'cespare/vim-bclose'
    " Vim diff plugin
    "Bundle 'airblade/vim-gitgutter'
    " Ditto like registry tool
    " Bundle 'vim-scripts/YankRing.vim'
    " Mark down highlight and other niceties
    "Bundle 'tpope/vim-markdown'

    Bundle 'mileszs/ack.vim'
    Bundle 'rking/ag.vim'

    Bundle 'tpope/vim-fugitive'
    Bundle 'tpope/vim-unimpaired'
    Bundle 'tpope/vim-surround'
    Bundle 'tpope/vim-ragtag'
    let g:ragtag_global_maps = 1

    Bundle 'kien/ctrlp.vim'
    let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v[\/]\dist$',
      \ }

    let g:ctrlp_working_path_mode = 2 " Smart path mode
    let g:ctrlp_mru_files = 1 " Enable Most Recently Used files feature
    let g:ctrlp_jump_to_buffer = 2 " Jump to tab AND buffer if already open

    set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]
    set laststatus=2
    Bundle 'Lokaltog/vim-powerline'
    let g:Powerline_symbols = 'fancy'
    Bundle 'Lokaltog/vim-easymotion'
" }

" General {
    set hidden

    set clipboard+=unnamed
    set encoding=utf-8

    " searching
    set ignorecase
    set smartcase
    set incsearch
    set showmatch
    set hlsearch

    " avoid swap, temp and backup files
    set nobackup
    set nowritebackup
    set noswapfile

    " show the cursor position all the time
    set ruler

    " display incomplete commands
    set showcmd
    set wildmenu

    " terminal settings
    set t_Co=256
    set mouse=a
    set ttymouse=xterm2
" }

" Keyboard {
    noremap <C-S> :w<CR>
    inoremap <C-S> <C-O>:w<CR><Esc>

    noremap <S-CR> <Esc>

    set backspace=indent,eol,start " make backspace behave consistently with other apps

    " delete trailing whitespace with F5
    nnoremap <silent> <leader>q :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

    " toggle NerdTree
    noremap <leader>] :NERDTreeToggle<CR>

    " search smart with ag
    noremap <leader>s :Ag -S 

    " quick-paste last yanked text
    noremap <C-p> "0p
    noremap <C-P> "0P

    "search with YankRing (Ditto like plugin)
    "nnoremap <leader><Space> :YRShow<CR>
    "inoremap <leader><Space> :YRShow<CR>

    " center screen
    noremap <Space> zz

    " indent!
    nnoremap <Tab> >>
    nnoremap <S-Tab> <<
    vnoremap <Tab> >gv
    vnoremap <S-Tab> <gv

    nnoremap <C-e> 3<C-e>
    nnoremap <C-y> 3<C-y>

    " tag auto-close with c-space
    imap <C-Space> <C-X><C-O>

    " close buffer
    nmap <C-W>! <Plug>Kwbd
" }

" Coding {
    set iskeyword+=_,$,@,%,# 
    set guifont=Consolas:h10
    " hide the toolbar and the menu of GVIM
    set guioptions-=m
    set guioptions-=T

    " show line numbers
    set number
    " highlight lineNr ctermfg=grey
    syntax on

    silent! colorscheme vividchalk
    autocmd BufEnter * :syntax sync fromstart

    " show trailing whitespace
    set list listchars=tab:>-,trail:.

    " ignore binaries and artifacts
    set wildignore=*.o,*.obj,*.bin,*.dll,*.zip
    " exclude version control directories
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*
    set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*

    set completeopt=menuone

    set tabstop=4
    set shiftwidth=4
    set softtabstop=4
    set expandtab

    set autoindent
    set smartindent
    set smarttab

    filetype plugin indent on

    au FileType gitcommit           setlocal spell
    au BufRead,BufNewFile *.html    setlocal filetype=html.javascript
    autocmd BufReadPost *cshtml set filetype=html
    autocmd BufReadPost Jakefile set filetype=javascript
" }
