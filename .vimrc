"to make sure every verson of vim/nvim/mvim works install both python and python3
if has('nvim')
  let g:python2_host_prog = '/usr/local/bin/python'
  let g:python3_host_prog = '/usr/local/bin/python3'
else
  command! -nargs=1 Py py3 <args>
  set pythonthreedll=/usr/local/Frameworks/Python.framework/Versions/3.7/Python
  set pythonthreehome=/usr/local/Frameworks/Python.framework/Versions/3.7
endif

" increase the window size, usually used for windows terminals
" set lines=60 columns=220

hi LineNr guifg=#AAAAAA guibg=#111111
"set guifont=Roboto\ Mono\ for\ Powerline:h14
let g:snippets_dir='~/dotfiles/snippets/'
filetype off

" Load vim-plug
if empty(glob("~/.vim/autoload/plug.vim"))
  execute '!curl -fLo ~/.vim/autoload/plug.vim https://raw.github.com/junegunn/vim-plug/master/plug.vim'
endif
call plug#begin('~/.vim/plugged')
" Plugins {

    " themes
    "Plug 'Railscasts-Theme-GUIand256color'
    Plug 'flazz/vim-colorschemes'
    Plug 'felixhummel/setcolors.vim'
    "although vim polyglot is loaded after this I love the syntax of jelera more than pangloss coming from polyglot
    Plug 'jelera/vim-javascript-syntax'
    " typescript highlighting
    Plug 'herringtondarkholme/yats.vim'
    Plug 'sheerun/vim-polyglot'
    Plug 'othree/javascript-libraries-syntax.vim'
    Plug 'ianks/vim-tsx'

    " post install (yarn install | npm install) then load plugin only for editing supported files
    "Plug 'prettier/vim-prettier', {
      "\ 'do': 'yarn install',
      "\ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql'] }
    "let g:prettier#exec_cmd_async = 1

    Plug 'sbdchd/neoformat'

    "Plug 'bigfish/vim-js-context-coloring'
    Plug 'elzr/vim-json'

    ""match tags and navigate through %
    Plug 'tmhedberg/matchit'
    Plug 'groenewege/vim-less'

    "This plugin is supposed to use tab instead of ctrl-n
    Plug 'ervandew/supertab'
    let g:SuperTabDefaultCompletionType = "<c-n>"

    "Plug 'msanders/snipmate.vim'

    Plug 'SirVer/ultisnips'
    let g:UltiSnipsEditSplit = "vertical"

    "the repo of snippets for ultisnips
    Plug 'honza/vim-snippets'

    Plug 'kchmck/vim-coffee-script'
    Plug 'scrooloose/nerdcommenter'
    Plug 'scrooloose/nerdtree'
    Plug 'Xuyuanp/nerdtree-git-plugin'
    let g:NERDTreeQuitOnOpen = 1
    let g:NERDTreeChDirMode  = 2

    Plug 'scrooloose/syntastic'
    nnoremap ,c :SyntasticCheck<CR>
    nnoremap ,C :SyntasticToggleMode<CR>

    Plug 'mhinz/vim-startify'
    let g:startify_change_to_dir = 0
    let g:startify_change_to_vcs_root = 1

    Plug 'airblade/vim-gitgutter'
    highlight GitGutterAdd  ctermfg=2 ctermbg=180
    highlight GitGutterChange  ctermfg=3 ctermbg=180
    highlight GitGutterDelete  ctermfg=1 ctermbg=180

    "typescript plugins for intellisense
    Plug 'shougo/vimproc.vim'
    Plug 'quramy/tsuquyomi'
    let g:tsuquyomi_use_vimproc = 1

    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-unimpaired'
    Plug 'mattn/emmet-vim'
    Plug 'duganchen/vim-soy'
    Plug 'mg979/vim-visual-multi'

    Plug 'haya14busa/incsearch.vim'
    Plug 'easymotion/vim-easymotion'
    let g:EasyMotion_smartcase = 1
    let g:EasyMotion_keys = 'asdghklqwertyuiopzxcvbnmfj'

    " move to single character
    nmap f <Plug>(easymotion-overwin-f2)
    nmap F <Plug>(easymotion-overwin-line)

    "Plug 'majutsushi/tagbar'
    "This addon does not work well with easymotion when jumping over win
    "nmap <F3> :TagbarToggle<CR>
    "let g:tagbar_compact = 1
    "let g:tagbar_autofocus = 1
    "let g:tagbar_foldlevel = 1

    "Plug 'rking/ag.vim'
    " This addon does the oposite of 'J' in vim
    Plug 'AndrewRadev/splitjoin.vim'
    "gS and gJ are the two shortcuts to Split and Join
    let g:splitjoin_split_mapping = 'gS'
    let g:splitjoin_join_mapping = 'gj'

    Plug 'AndrewRadev/sideways.vim'
    nnoremap gh :SidewaysLeft<cr>
    nnoremap gl :SidewaysRight<cr>

    "addon for auto closing brackets
    Plug 'jiangmiao/auto-pairs'
    let g:AutoPairsFlyMode = 0

    Plug 'mbbill/undotree'
    nnoremap <leader>u :UndotreeToggle<cr>

    "this one should be used instead of the keybindings near the end of the file'
    Plug 'matze/vim-move'
    let g:move_map_keys = 0
    vmap H <Plug>MoveBlockUp
    vmap L <Plug>MoveBlockDown
    nmap H <Plug>MoveLineUp
    nmap L <Plug>MoveLineDown

    " this one should be depricated soon
    Plug 'mileszs/ack.vim'
    Plug 'dyng/ctrlsf.vim'
    let g:ctrlsf_ackprg = 'rg'
    "let g:ctrlsf_debug_mode = 1
    let g:ctrlsf_mapping = {
      \ "next": "n",
      \ "prev": "N",
      \ "vsplit": "s",
      \ }
    let g:ctrlsf_auto_focus = {
        \ "at" : "start"
        \ }
    let g:ctrlsf_confirm_save = 0

    "git tools blame, log, view files in other branches
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-rhubarb'
    " change surrounding brancjes
    Plug 'tpope/vim-surround'

    let g:ragtag_global_maps = 1

    Plug 'kien/ctrlp.vim'
    let g:ctrlp_max_files=0
    let g:ctrlp_show_hidden = 1
    let g:ctrlp_working_path_mode = 'rw'
    let g:ctrlp_by_filename = 1

    set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]
    set laststatus=2

    Plug 'vim-airline/vim-airline'
    let g:airline_powerline_fonts = 1
    let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'

    Plug 'jlanzarotta/bufexplorer'
    nnoremap ,b :BufExplorer<CR>
    Plug 'junegunn/vim-easy-align'

    Plug 'davidhalter/jedi-vim'
    let g:jedi#goto_command = ",d"
    let g:jedi#documentation_command = ",h"
    let g:jedi#usages_command = ",6"
    let g:jedi#completions_command = "<C-Space>"
    let g:jedi#rename_command = ",r"

    if has('nvim')
      Plug 'Shougo/deoplete.nvim'
    else
      Plug 'Shougo/deoplete.nvim'
      Plug 'roxma/nvim-yarp'
      Plug 'roxma/vim-hug-neovim-rpc'
    endif
    let g:deoplete#enable_at_startup = 1

    "Plug 'neoclide/coc.nvim', {'tag': '*', 'do': { -> coc#util#install()}}

    Plug 'rust-lang/rust.vim'
    Plug 'racer-rust/vim-racer'
    au FileType rust nmap ,d <Plug>(rust-def)
    set hidden
    let g:racer_cmd = "~/.cargo/bin/racer"

    " Haskell omni complete
    Plug 'eagletmt/neco-ghc'
    Plug 'eagletmt/ghcmod-vim'
    au FileType haskell nnoremap <buffer> <Space><Space> :GhcModType!<CR>
    au FileType haskell nnoremap <buffer> <Space>i :GhcModInfo!<CR>
    au FileType haskell nnoremap <buffer> <Space>t :GhcModType!<CR>
    au FileType haskell noremap <buffer> <CR> :GhcModTypeClear<CR>:noh<CR><CR>
    au FileType haskell nnoremap <buffer> ,tt :GhcModTypeInsert!<CR>
    au FileType haskell nnoremap <buffer> ,s :GhcModSplitFunCase!<CR>
    au FileType haskell nnoremap <buffer> <Space>c :GhcModCheckAsync!<CR>
    au FileType haskell nnoremap <buffer> <Space>l :GhcModLintAsync!<CR>

    Plug 'fsharp/vim-fsharp', {
      \ 'for': 'fsharp',
      \ 'do':  'make fsautocomplete',
      \}
    let g:fsharp_only_check_errors_on_write = 1

    "Plug 'nathanaelkane/vim-indent-guides'
    Plug 'Yggdroot/indentLine'
    let g:indent_guides_enable_on_vim_startup = 1

    Plug 'bronson/vim-visual-star-search'
    Plug 'terryma/vim-expand-region'
    Plug 'wellle/targets.vim'
    Plug 'ap/vim-css-color'
    Plug 'google/vim-searchindex'

    Plug 'pseewald/vim-anyfold'
    nmap zf :AnyFoldActivate<CR>:set foldlevel=1<CR>:set foldenable<CR>
    "use - to toggle
    nnoremap <expr> - (foldclosed(line(".")) == -1) ? 'za':'zA'

    "folding cheat sheet:
        "zr - expand more levels
        "zm - collapse more levels
        "zi - toggle fold mode
        "-  - toggle fold (expand as much as possible and collapse only 1 level back)
    set foldlevel=1

    " Purescript
    Plug 'frigoeu/psc-ide-vim'

    Plug 'editorconfig/editorconfig-vim'

    Plug 'MattesGroeger/vim-bookmarks'
    let g:bookmark_save_per_working_dir = 1

    nmap <Leader>m <Plug>BookmarkToggle
    nmap <Leader>mi <Plug>BookmarkAnnotate
    nmap <Leader>ma <Plug>BookmarkShowAll
    nmap <Leader>mj <Plug>BookmarkNext
    nmap <Leader>mk <Plug>BookmarkPrev
    nmap <Leader>mc <Plug>BookmarkClear
    nmap <Leader>mx <Plug>BookmarkClearAll
    nmap <Leader>mg <Plug>BookmarkMoveToLine

" }
call plug#end()

silent! colorscheme desertEx " SlateDark, vividchalk themes is good high contrast too

  " The Silver Searcher
  if executable('ag')
    " Use ag over grep
    set grepprg=ag\ --nogroup\ --nocolor
    let g:ackprg = 'ag --vimgrep'

     " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

    " ag is fast enough that CtrlP doesn't need to cache
    let g:ctrlp_use_caching = 0
  endif

  if executable ('rg')
    set grepprg=rg\ --color=never
    "set grepformat=%f:%l:%c:%m,%f:%l:%m
    let g:ackprg = 'rg --vimgrep --no-heading'
    let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
  endif

  " Syntastic checkers
  let g:syntastic_error_symbol = "✗"
  let g:syntastic_warning_symbol = "⚠"
  " make sure  you have eslint/jshint installed globally from npm
  let g:syntastic_javascript_checkers = ["eslint"]
  let g:syntastic_scss_checkers=["scss_lint", "stylelint"]
  let g:syntastic_vue_checkers=["eslint"]
  let g:syntastic_rust_checkers=["cargo"]
  let g:syntastic_haskell_checkers=["hdevtools"]

  let g:tsuquyomi_disable_quickfix = 1
  let g:tsuquyomi_disable_default_mappings = 1
  let g:syntastic_typescript_checkers = ['tsuquyomi']
  let g:syntastic_typescript_tsuquyomi_args="--strictNullChecks false"

  " make use of local eslint !! wohoo
  let local_eslint = finddir('node_modules', '.;') . '/.bin/eslint'
  if matchstr(local_eslint, "^\/\\w") == ''
      let local_eslint = getcwd() . "/" . local_eslint
  endif
  if executable(local_eslint)
      let g:syntastic_javascript_eslint_exec = local_eslint
      let g:syntastic_vue_eslint_exec = local_eslint
  endif


  let g:syntastic_always_populate_loc_list = 1
  let g:syntastic_auto_loc_list = 1
  "BufExplorer show relative paths by default
  let g:bufExplorerShowRelativePath=1  " Show relative paths.

" General {
    set hidden

    if $TMUX == ''
      set clipboard+=unnamed
    endif
    set encoding=utf-8

    set colorcolumn=100

    " searching
    set ignorecase
    set smartcase
    set incsearch
    set showmatch
    set hlsearch

    "au FileType qf noremap q :q<CR><CR>

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
    "set t_Co=256
    set mouse=a
    if !has('nvim')
      set ttymouse=xterm2
    endif
" }

" Keybindings {
    noremap <C-S> :w<CR>
    inoremap <C-S> <C-O>:w<CR><Esc>

    noremap <S-CR> <Esc>
    nnoremap U <C-R>
    vnoremap U gU

    "provide alternative to use COUNT
    nnoremap 1 :w<CR>
    nnoremap <Space>1 1
    nnoremap 3 #
    nnoremap <Space>3 3
    nnoremap 4 $
    nnoremap <Space>4 4
    nnoremap 6 ^
    nnoremap <Space>6 6
    nnoremap 8 *
    nnoremap <Space>8 8

    nnoremap 5 %
    nnoremap <Space>5 5

    "enable back the go forward and backward in jump history
    nnoremap <Space>9 9
    nnoremap 9 <C-o>
    nnoremap <Space>0 0
    nnoremap 0 <C-i>

    " disable the highlight search
    nnoremap <CR> :noh<CR><CR>

    "sudo overwrite protect file
    cmap w!! w !sudo tee > /dev/null %

    set backspace=indent,eol,start " make backspace behave consistently with other apps

    " delete trailing whitespace
    nnoremap <silent> <leader>q :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

    " toggle NerdTree
    noremap <silent> <leader>] :NERDTreeToggle<CR>

    " search with ag via the Ack frontend plugin
    noremap <leader>s :Ack! 
    " search with sublime-alternative
    noremap <leader>R :CtrlSF 
    vnoremap <leader>R y:CtrlSF \b<C-R>"\b -R
    "use leader-r to navigate to current file in nerdtree
    noremap <leader>r :NERDTreeFind<CR>zz

    " quick-paste last yanked text
    noremap <C-p> "0p
    noremap <C-P> "0P

    "search with YankRing (Ditto like plugin)
    "nnoremap <leader><Space> :YRShow<CR>
    "inoremap <leader><Space> :YRShow<CR>
    nnoremap <C-b> :CtrlPMRU<CR>
    nnoremap ,v :CtrlPMRU<CR>

    " bind R to search and replace word under the cursor or visual selection
    nnoremap R :CtrlSF <C-R><C-W> -R -W<CR>
    vnoremap R y:CtrlSF "<C-R>""<CR>

    " bind K to search grep word under the cursor
    nnoremap K :Ack! <cword><CR>
    vnoremap K y:Ack! "<C-R>""<CR>
    vnoremap <leader>s y:Ack! "<C-R>"" 
    "search for the visually selected text
    vnoremap // y/<C-R>"<CR>

    vmap ( S(
    vmap ) S)
    vmap [ S(
    vmap { S)
    vmap " S"
    vmap ' S'

    "replace word under cursor
    nnoremap ,r :%s/\<<C-r><C-w>\>//g<Left><Left>
    "close window
    noremap ,w <C-w>c
    "create new vertical split
    noremap ,n :vnew<CR>

    "typescript tools by tsuquyomi, just for typescript
    au FileType typescript,typescript.tsx nnoremap ,f :TsuQuickFix<CR>
    au FileType typescript,typescript.tsx nnoremap ,i :TsuImport<CR>
    au FileType typescript,typescript.tsx nnoremap ,d :TsuDefinition<CR>
    au FileType typescript,typescript.tsx nnoremap ,D :TsuImplementation<CR>
    au FileType typescript,typescript.tsx nnoremap ,` :TsuGoBack<CR>
    au FileType typescript,typescript.tsx nnoremap ,6 :TsuReferences<CR>
    au FileType typescript,typescript.tsx nnoremap ,r :TsuRenameSymbol<CR>
    au FileType typescript,typescript.tsx nmap <buffer> <Space><Space> : <C-u>echo tsuquyomi#hint()<CR>

    "use incsearch plugin
    map /  <Plug>(incsearch-forward)
    map ?  <Plug>(incsearch-backward)

    nnoremap ,o :only<CR>

    " center screen
    noremap <Space><Space> zz
    " add space after
    noremap <Space>a a<Space><ESC>h
    " add space before
    noremap <Space>i i<Space><ESC>l

    "jump to the closest opening bracket of type {
    nnoremap { [{

    " indent!

    nnoremap <Tab> >>
    nnoremap <S-Tab> <<

    "this is a workaround to remap after plugins
    "in this case supertab was imitating default behavior
    au VimEnter * vnoremap <Tab> >gv
    au VimEnter * vnoremap <S-Tab> <gv

    noremap <C-e> 5<C-e>
    noremap <C-y> 5<C-y>
    noremap <D-j> 5<C-e>
    noremap <D-k> 5<C-y>
    noremap <M-j> 5<C-e>
    noremap <M-k> 5<C-y>

    nnoremap <C-h> <C-w>h
    nnoremap <C-j> <C-w>j
    nnoremap <C-k> <C-w>k
    nnoremap <C-l> <C-w>l

    nnoremap vv <C-w>

    command! -nargs=0 -range SortWords call SortWords()
    " Add a mapping, go to your string, then press vi",s
    " vi" selects everything inside the quotation
    " ,s calls the sorting algorithm
    vmap ,s :SortWords<CR>
    " Normal mode one: ,s to select inside the {} and sort the words
    nmap ,s vi{,s

    " tag auto-close with c-space
    imap <C-Space> <C-X><C-O>

    " close buffer
    nnoremap <C-W>! <Plug>Kwbd

    noremap <leader>ve :vsplit $MYVIMRC<CR>
    noremap <leader>vu :source %<CR>

    "free the mapping <C-i> taken by snipmate
    "unmap <C-i>

    " Settings for VimDiff as MergeTool
    if &diff
      noremap <leader>1 :diffget LOCAL<CR>
      noremap <leader>2 :diffget BASE<CR>
      noremap <leader>3 :diffget REMOTE<CR>
      colorscheme darkBlue
    endif
" }

" Coding {
    set iskeyword+=_,$,@,%,#
    " hide the toolbar and the menu of GVIM
    set guioptions-=m
    set guioptions-=T

    " show line numbers
    set number
    " highlight lineNr ctermfg=grey
    syntax on

    set cursorline
    hi CursorLine guibg=NONE


    set completeopt=longest,menuone
    inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

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
    "au BufRead,BufNewFile *.vue    setlocal syntax=javascript
    "au BufReadPost *.json set filetype=javascript
    "au BufReadPost *.es6 set filetype=typescript.tsx
    "disable continuous comments vim
    au FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
" }

" auto reload the vimrc when it is saved

augroup reload_vimrc " {
    au!
    au BufWritePost $MYVIMRC source $MYVIMRC
    au BufWritePost $MYVIMRC source $MYGVIMRC
augroup END " }


" workspace specific options

function! WorkSpaceSettings()
  let l:path = expand('%:p')
  if l:path =~ '/Leanplum/'
    "let b:syntastic_checkers = ["jshint"]

    iabbrev @@@ // All rights reserved. Leanplum. 2016.
          \<CR>// Author: Petur Subev (petur@leanplum.com)
          \<CR>// 

    if l:path =~ '.*\.py$'
      setlocal tabstop=2
      setlocal shiftwidth=2
      setlocal softtabstop=2
    endif

  endif
endfunction

" Insert a newline after each specified string (or before if use '!').
" If no arguments, use previous search.
command! -bang -nargs=* -range LineBreakAt <line1>,<line2>call LineBreakAt('<bang>', <f-args>)
function! LineBreakAt(bang, ...) range
  let save_search = @/
  if empty(a:bang)
    let before = ''
    let after = '\ze.'
    let repl = '&\r'
  else
    let before = '.\zs'
    let after = ''
    let repl = '\r&'
  endif
  let pat_list = map(deepcopy(a:000), "escape(v:val, '/\\.*$^~[')")
  let find = empty(pat_list) ? @/ : join(pat_list, '\|')
  let find = before . '\%(' . find . '\)' . after
  " Example: 10,20s/\%(arg1\|arg2\|arg3\)\ze./&\r/ge
  execute a:firstline . ',' . a:lastline . 's/'. find . '/' . repl . '/ge'
  let @/ = save_search
endfunction

function! SortWords()
  " Get the visual mark points
  let StartPosition = getpos("'<")
  let EndPosition = getpos("'>")

  if StartPosition[0] != EndPosition[0]
      echoerr "Range spans multiple buffers"
  elseif StartPosition[1] != EndPosition[1]
      " This is a multiple line range, probably easiest to work line wise

      " This could be made a lot more complicated and sort the whole
      " lot, but that would require thoughts on how many
      " words/characters on each line, so that can be an exercise for
      " the reader!
      for LineNum in range(StartPosition[1], EndPosition[1])
          call setline(LineNum, join(sort(split(getline('.'), ' ')), " "))
      endfor
  else
      " Single line range, sort words
      let CurrentLine = getline(StartPosition[1])

      " Split the line into the prefix, the selected bit and the suffix

      " The start bit
      if StartPosition[2] > 1
          let StartOfLine = CurrentLine[:StartPosition[2]-2]
      else
          let StartOfLine = ""
      endif
      " The end bit
      if EndPosition[2] < len(CurrentLine)
          let EndOfLine = CurrentLine[EndPosition[2]:]
      else
          let EndOfLine = ""
      endif
      " The middle bit
      let BitToSort = CurrentLine[StartPosition[2]-1:EndPosition[2]-1]

      " Move spaces at the start of the section to variable StartOfLine
      while BitToSort[0] == ' '
          let BitToSort = BitToSort[1:]
          let StartOfLine .= ' '
      endwhile
      " Move spaces at the end of the section to variable EndOfLine
      while BitToSort[len(BitToSort)-1] == ' '
          let BitToSort = BitToSort[:len(BitToSort)-2]
          let EndOfLine = ' ' . EndOfLine
      endwhile

      " Sort the middle bit
      let Sorted = join(sort(split(BitToSort, ' ')), ' ')
      " Reform the line
      let NewLine = StartOfLine . Sorted . EndOfLine
      " Write it out
      call setline(StartPosition[1], NewLine)
  endif
endfunction

au! BufReadPost,BufNewFile * call WorkSpaceSettings()
