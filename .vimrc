" disable the highlight search
nnoremap <CR> :noh<CR><CR>

" increase the window size, usually used for windows terminals
" set lines=60 columns=220

hi LineNr guifg=#AAAAAA guibg=#111111

filetype off
set rtp=~/.vim/bundle/vundle/,~/.vim,$VIMRUNTIME
let g:snippets_dir='~/dotfiles/snippets/'
call vundle#rc()

" Plugins {
    Bundle 'gmarik/vundle'

    " themes
    Bundle 'Railscasts-Theme-GUIand256color'
    Bundle 'flazz/vim-colorschemes'

    "match tags and navigate through %
    Bundle 'tmhedberg/matchit'
    Bundle 'groenewege/vim-less'
    Bundle 'msanders/snipmate.vim'
    Bundle 'kchmck/vim-coffee-script'
    Bundle 'scrooloose/nerdcommenter'
    Bundle 'scrooloose/nerdtree'
    "use leader-r to navigate to current file in nerdtree
    map <leader>r :NERDTreeFind<cr>zz


    " handlebars and mustache support
    Bundle 'mustache/vim-mustache-handlebars'
    " Bundle 'vim-scripts/JavaScript-Indent'
    Bundle 'vim-scripts/Javascript-Indentation'
    Bundle 'vim-scripts/jsbeautify'
    "respect gitignore files
    "Bundle 'vim-scripts/gitignore'

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
    Bundle 'digitaltoad/vim-jade'
    Bundle 'duganchen/vim-soy'

    Bundle 'mileszs/ack.vim'
    Bundle 'rking/ag.vim'

    Bundle 'tpope/vim-fugitive'
    Bundle 'tpope/vim-unimpaired'
    Bundle 'tpope/vim-surround'
    Bundle 'tpope/vim-ragtag'
    let g:ragtag_global_maps = 1

    Bundle 'kien/ctrlp.vim'

    " let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
    "let g:ctrlp_regexp = 1
    "let g:ctrlp_working_path_mode = 1 " Smart path mode
    "let g:ctrlp_mru_files = 2 " Enable Most Recently Used files feature
    "let g:ctrlp_jump_to_buffer = 3 " Jump to tab AND buffer if already open

    set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]
    set laststatus=2
    Bundle 'Lokaltog/vim-powerline'
    let g:Powerline_symbols = 'fancy'
    Bundle 'Lokaltog/vim-easymotion'
" }

  " The Silver Searcher
 if executable('ag')
     " Use ag over grep
     set grepprg=ag\ --nogroup\ --nocolor

     " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
     let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

    " ag is fast enough that CtrlP doesn't need to cache
    let g:ctrlp_use_caching = 0

  endif

" General {
    set hidden

    set clipboard+=unnamed
    set encoding=utf-8

    " do not show folded
    set foldlevel=20

    " searching
    set ignorecase
    set smartcase
    set incsearch
    set showmatch
    set hlsearch

    "disable hit enter to contine spam msg when redrawing
    "

    set shortmess=aoOtI

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

    " bind K to grep word under the cursor
    nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR><CR>

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

    silent! colorscheme railscasts " vividchalk theme is good high contrast too


    autocmd BufEnter * :syntax sync fromstart

    " show trailing whitespace
    set list listchars=tab:>-,trail:.

    " ignore binaries and artifacts
    set wildignore=*.o,*.obj,*.bin,*.dll,*.zip
    " exclude version control directories
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*
    set wildignore+=*\\.git\\*,*\\.hg\\*,*\\.svn\\*

    set completeopt=menuone

    set tabstop=2
    set shiftwidth=2
    set softtabstop=2
    set expandtab

    "switch paste behavior to avoid added tabs
    set pastetoggle=<F10>

    set autoindent
    set smartindent
    set smarttab

    filetype plugin indent on

    au FileType gitcommit           setlocal spell
    au BufRead,BufNewFile *.html    setlocal filetype=html.javascript
    autocmd BufReadPost *cshtml set filetype=html
    autocmd BufReadPost Jakefile set filetype=javascript
" }
