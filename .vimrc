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

"hi LineNr guifg=#AAAAAA guibg=#111111
"set guifont=Roboto\ Mono\ for\ Powerline:h14

" Load vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif
call plug#begin('~/.vim/plugged')
" Plugins {

    " themes
    "Plug 'Railscasts-Theme-GUIand256color'
    Plug 'flazz/vim-colorschemes'
    "Plug 'felixhummel/setcolors.vim'
    Plug 'sheerun/vim-polyglot'
    "let g:polyglot_disabled = ['typescript', 'javascript']

    Plug 'jelera/vim-javascript-syntax'
    Plug 'herringtondarkholme/yats.vim'
    Plug 'othree/javascript-libraries-syntax.vim'
    Plug 'ianks/vim-tsx'

    Plug 'sbdchd/neoformat'

    "Plug 'bigfish/vim-js-context-coloring'
    "Plug 'elzr/vim-json'

    ""match tags and navigate through %
    Plug 'tmhedberg/matchit'
    Plug 'groenewege/vim-less'

    "Plug 'kchmck/vim-coffee-script'
    Plug 'scrooloose/nerdcommenter'
    Plug 'scrooloose/nerdtree'
    Plug 'Xuyuanp/nerdtree-git-plugin'
    let g:NERDTreeQuitOnOpen = 1
    let g:NERDTreeChDirMode  = 2
    noremap <space>p :NERDTreeFind<CR>zz
    let NERDTreeShowHidden=1
    noremap <silent> <F4> :NERDTreeToggle<CR>

    "Plug 'kien/rainbow_parentheses.vim'
    "au VimEnter * RainbowParenthesesActivate
    "au BufEnter * RainbowParenthesesLoadRound
    "au BufEnter * RainbowParenthesesLoadBraces
    "au BufEnter * RainbowParenthesesLoadSquare

    Plug 'mhinz/vim-startify'
    let g:startify_change_to_dir = 0
    let g:startify_change_to_vcs_root = 1
    let g:startify_session_persistence = 1

    Plug 'airblade/vim-gitgutter'
    highlight GitGutterAdd  ctermfg=2 ctermbg=180
    highlight GitGutterChange  ctermfg=3 ctermbg=180
    highlight GitGutterDelete  ctermfg=1 ctermbg=180

    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    let g:coc_global_extensions = [ 'coc-tslint', 'coc-tslint-plugin', 'coc-emmet', 'coc-git', 'coc-vimlsp',
      \ 'coc-tabnine', 'coc-lists', 'coc-snippets', 'coc-highlight', 'coc-vetur', 'coc-html', 'coc-tsserver',
      \ 'coc-css', 'coc-json', 'coc-java', 'coc-python', 'coc-yank' ]

    " You will have bad experience for diagnostic messages when it's default 4000.
    set updatetime=300

    " always show signcolumns
    "set signcolumn=yes

    " Use tab for trigger completion with characters ahead and navigate.
    " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
    "Make <tab> used for trigger completion, completion confirm, snippet expand and jump like VSCode.
    inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

    function! s:check_back_space() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    " Use <c-space> to trigger completion.
    inoremap <silent><expr> <C-Space> coc#refresh()

    " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
    " Coc only does snippet and additional edit on confirm.
    inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

    " Use `[c` and `]c` to navigate diagnostics
    nmap <silent> <space><left> <Plug>(coc-diagnostic-prev)
    nmap <silent> <space><right> <Plug>(coc-diagnostic-next)

    " Use space-t to use list plugin
    nmap <silent> <space>t :CocList<cr>

    " Remap keys for gotos
    nmap <silent> ,d <Plug>(coc-definition)
    nmap <silent> gd <Plug>(coc-type-definition)
    nmap <silent> ,i <Plug>(coc-implementation)
    nmap <silent> ,6 <Plug>(coc-references)

    " Use K to show documentation in preview window
    nnoremap <silent> <space><space> :call <SID>show_documentation()<CR>

    function! s:show_documentation()
      if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
      else
        call CocAction('doHover')
      endif
    endfunction

    " Highlight symbol under cursor on CursorHold
    "autocmd CursorHold * silent call CocActionAsync('highlight')

    " Remap for rename current word
    nmap ,r <Plug>(coc-rename)

    " Remap for format selected region
    xmap <space>f  <Plug>(coc-format-selected)
    nmap <space>f  <Plug>(coc-format-selected)

    augroup mygroup
      autocmd!
      " Setup formatexpr specified filetype(s).
      autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
      " Update signature help on jump placeholder
      autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    augroup end

    " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
    xmap <space>l  <Plug>(coc-codeaction-selected)
    " Remap for do codeAction of current line
    nmap <space>l  <Plug>(coc-codeaction)
    " Fix autofix problem of current line
    nmap <space>qf  <Plug>(coc-fix-current)

    " Use <tab> for select selections ranges, needs server support, like: coc-tsserver, coc-python
    nmap <silent> <TAB> <Plug>(coc-range-select)
    xmap <silent> <TAB> <Plug>(coc-range-select)
    xmap <silent> <S-TAB> <Plug>(coc-range-select-backword)

    " Use `:Format` to format current buffer
    command! -nargs=0 Format :call CocAction('format')

    " Use `:Fold` to fold current buffer
    command! -nargs=? Fold :call     CocAction('fold', <f-args>)

    " use `:OR` for organize import of current buffer
    command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

    " Using CocList
    " Show all diagnostics
    nnoremap <silent> <space>ca  :<C-u>CocList diagnostics<cr>
    " Manage extensions
    nnoremap <silent> <space>ce  :<C-u>CocList extensions<cr>
    " Show commands
    nnoremap <silent> <space>cc  :<C-u>CocList commands<cr>
    " Find symbol of current document
    nnoremap <silent> <space>co  :<C-u>CocList outline<cr>
    " Search workspace symbols
    nnoremap <silent> <space>cs  :<C-u>CocList -I symbols<cr>
    " Do default action for next item.
    nnoremap <silent> <space>cj  :<C-u>CocNext<CR>
    " Do default action for previous item.
    nnoremap <silent> <space>ck  :<C-u>CocPrev<CR>
    " Resume latest coc list
    nnoremap <silent> <space>cp  :<C-u>CocListResume<CR>

    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-unimpaired'
    Plug 'duganchen/vim-soy'
    Plug 'mg979/vim-visual-multi'
    let g:VM_mouse_mappings = 1
    map <F2> \\A

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
    let g:AutoPairsShortcutBackInsert = '<C-b>'
    let g:AutoPairsShortcutFastWrap = '<C-e>'

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

    " search with sublime-alternative
    noremap <leader>r :CtrlSF 
    noremap <Space>r :CtrlSFOpen<CR> 
    vnoremap <leader>r y:CtrlSF \b<C-R>"\b -R
    " bind R to search and replace word under the cursor or visual selection
    nnoremap R :CtrlSF <C-R><C-W> -R -W<CR>
    vnoremap R y:CtrlSF "<C-R>""<CR>


    "git tools blame, log, view files in other branches
    Plug 'tpope/vim-fugitive'
    Plug 'junegunn/gv.vim'
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
    "BufExplorer show relative paths by default
    let g:bufExplorerShowRelativePath=1  " Show relative paths.

    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'
    nmap <F1> :Helptags<cr>
    nmap <leader>f :FZF<cr>
    command! -bang -nargs=* Rg
      \ call fzf#vim#grep(
      \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
      \   <bang>0 ? fzf#vim#with_preview('up:60%')
      \           : fzf#vim#with_preview('right:50%:hidden', '?'),
      \   <bang>0)

    Plug 'junegunn/vim-easy-align'

    Plug 'rust-lang/rust.vim'
    Plug 'racer-rust/vim-racer'
    au FileType rust nmap ,d <Plug>(rust-def)
    let g:racer_cmd = "~/.cargo/bin/racer"

    " Haskell omni complete, TODO use COC
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

    Plug 'chrisbra/csv.vim'
    au FileType csv nnoremap <buffer> <Space><Space> :WhatColumn!<CR>

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

    set shortmess=caoOtI

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
    nnoremap <PageUp> <C-u>
    nnoremap <PageDown> <C-d>

    noremap <S-CR> <Esc>
    nnoremap U <C-R>
    vnoremap U gU

    "provide alternative to use COUNT
    nnoremap 2 :w<CR>
    nnoremap 3 #
    vnoremap 3 #
    nnoremap 4 $
    vnoremap 4 $
    nnoremap 5 %
    vnoremap 5 %
    nnoremap 6 ^
    vnoremap 6 ^
    nnoremap 8 *
    vnoremap 8 *
    nnoremap 9 <C-o>
    nnoremap 0 <C-i>

    nnoremap <up> 8<C-y>
    vnoremap <up> 8<C-y>
    nnoremap <down> 8<C-e>
    vnoremap <down> 8<C-e>
    nnoremap <left> <C-w>h
    nnoremap <right> <C-w>l

    " disable the highlight search
    nnoremap <CR> :noh<CR><CR>
    nnoremap <f5> :e!<CR>
    nnoremap <f6> :q<CR>

    "sudo overwrite protect file
    cmap w!! w !sudo tee > /dev/null %

    set backspace=indent,eol,start " make backspace behave consistently with other apps

    " delete trailing whitespace
    nnoremap <silent> <leader>q :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

    " search with ag via the Ack frontend plugin
    noremap <leader>s :Ack! 

    " quick-paste last yanked text
    noremap <C-p> "0p
    noremap <C-P> "0P

    "search with YankRing (Ditto like plugin)
    "nnoremap <leader><Space> :YRShow<CR>
    "inoremap <leader><Space> :YRShow<CR>
    nnoremap <C-b> :CtrlPMRU<CR>
    nnoremap ,v :CtrlPMRU<CR>

    " bind K to search grep word under the cursor
    nnoremap K :Ack! <cword><CR>
    vnoremap K y:Ack! "<C-R>""<CR>
    vnoremap <leader>s y:Ack! "<C-R>"" 
    "search for the visually selected text
    vnoremap // y/<C-R>"<CR>

    vmap ( S(
    vmap ) S)
    vmap [ S[
    vmap ] S]
    vmap { S{
    vmap } S}
    vmap " S"
    vmap ' S'

    ""replace word under cursor
    "nnoremap ,r :%s/\<<C-r><C-w>\>//g<Left><Left>
    "close window
    noremap ,w <C-w>c
    noremap Q q
    noremap q <C-w>c
    "create new vertical split
    noremap ,n :vnew<CR>

    "use incsearch plugin
    map /  <Plug>(incsearch-forward)
    map ?  <Plug>(incsearch-backward)

    nnoremap ,o :only<CR>

    " center screen
    "noremap <Space><Space> zz
    " add space after
    noremap <Space>a a<Space><ESC>h
    " add space before
    noremap <Space>i i<Space><ESC>l

    "jump to the closest opening bracket of type {
    nnoremap { [{

    " indent!

    nnoremap <Tab> >>
    nnoremap <S-Tab> <<
    vnoremap <Tab> >gv
    vnoremap <S-Tab> <gv

    noremap <C-e> 8<C-e>
    noremap <C-y> 8<C-y>

    nnoremap ; 8<C-e>
    nnoremap ' 8<C-y>

    noremap <D-j> 8<C-e>
    noremap <D-k> 8<C-y>
    noremap <M-j> 8<C-e>
    noremap <M-k> 8<C-y>

    nnoremap vv <C-w>

    command! -nargs=0 -range SortWords call SortWords()
    " Add a mapping, go to your string, then press vi",s
    " vi" selects everything inside the quotation
    " ,s calls the sorting algorithm
    vmap ,s :SortWords<CR>
    " Normal mode one: ,s to select inside the {} and sort the words
    nmap ,s vi{,s

    " close buffer
    nnoremap <C-W>! <Plug>Kwbd

    noremap <leader>ve :e $MYVIMRC<CR>
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
    if has("patch-8.1.0360")
      set diffopt+=internal,algorithm:patience
    endif
" }

" Coding {

    set iskeyword+=_,$,@,%,#
    set scrolloff=20
    " hide the toolbar and the menu of GVIM
    set guioptions-=m
    set guioptions-=T

    " show line numbers
    set number
    " highlight lineNr ctermfg=grey
    "syntax on

    "set cursorline
    "hi CursorLine guibg=NONE

    "set completeopt=longest,menuone
    inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

    " show trailing whitespace
    set list listchars=tab:>-,trail:.

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
    set pastetoggle=<F10>

    set autoindent
    set smartindent
    set smarttab

    filetype plugin indent on

    au FileType gitcommit           setlocal spell
    "disable continuous comments vim
    au FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
    au BufEnter *.bg* setlocal keymap=bulgarian-phonetic
" }

" workspace specific options

function! WorkSpaceSettings()
  let l:path = expand('%:p')
  if l:path =~ '/Leanplum/'
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
