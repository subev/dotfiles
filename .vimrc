let g:python3_host_prog = '/usr/local/bin/python3'

" Load vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif
call plug#begin('~/.vim/plugged')
" Plugins {

    " themes
    Plug 'morhetz/gruvbox'
    set background=dark    " Setting dark mode

    Plug 'sheerun/vim-polyglot'
    let g:vim_markdown_conceal = 0
    let g:vim_markdown_folding_disabled = 1
    map <Plug> <Plug>Markdown_MoveToCurHeader
    au FileType markdown nnoremap <silent><buffer> <Space>t :Toc<CR>

    Plug 'othree/javascript-libraries-syntax.vim'
    Plug 'ianks/vim-tsx'

    Plug 'sbdchd/neoformat'

    ""match tags and navigate through %
    Plug 'tmhedberg/matchit'

    Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
    let g:mkdp_auto_close = 0

    Plug 'scrooloose/nerdcommenter'
    let g:NERDCustomDelimiters = { 'typescript': { 'left': '// '} }
    Plug 'scrooloose/nerdtree'
    Plug 'Xuyuanp/nerdtree-git-plugin'
    let g:NERDTreeQuitOnOpen = 1
    let g:NERDTreeChDirMode  = 2
    let NERDTreeShowHidden = 1
    let NERDTreeWinSize=70
    noremap <space>p :NERDTreeFind<CR>zz
    noremap <silent> <F4> :NERDTreeToggle<CR>

    Plug 'mhinz/vim-startify'
    let g:startify_change_to_dir = 0
    let g:startify_change_to_vcs_root = 1
    let g:startify_session_persistence = 1

    Plug 'airblade/vim-gitgutter'
    nmap <space>h <Plug>(GitGutterPreviewHunk)
    nmap <space>x <Plug>(GitGutterUndoHunk)
    nmap <space>v <Plug>(GitGutterStageHunk)

    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    let g:coc_global_extensions = [ 'coc-emmet', 'coc-git', 'coc-vimlsp',
      \ 'coc-lists', 'coc-snippets', 'coc-html', 'coc-tsserver', 'coc-jest',
      \ 'coc-css', 'coc-json', 'coc-java', 'coc-pyright', 'coc-yank', 'coc-prettier', 'coc-omnisharp' ]

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
    nnoremap <silent> <space>ta :call CocAction('runCommand', 'jest.projectTest')<CR>
    nnoremap <silent> <space>tc :call CocAction('runCommand', 'jest.fileTest', ['%'])<CR>
    nnoremap <silent> <space>tt :call CocAction('runCommand', 'jest.singleTest')<CR>
    nnoremap <silent> <space>1 :call CocAction('runCommand', 'eslint.executeAutofix')<CR>

    " Remap keys for gotos
    nmap <silent> ,d <Plug>(coc-definition)
    nmap <silent> gd <Plug>(coc-type-definition)
    nmap <silent> ,i <Plug>(coc-implementation)
    nmap <silent> ,6 <Plug>(coc-references)
    nmap <silent> ,w <Plug>(coc-codelens-action)

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
    nmap ,R <Plug>(coc-refactor)

    " Remap for format selected region
    xmap <space>f  <Plug>(coc-format-selected)
    nmap <space>f  <Plug>(coc-format)

    xmap if <Plug>(coc-funcobj-i)
    xmap af <Plug>(coc-funcobj-a)

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
    nmap <space>j  :CocListResume<cr>
    nmap <space>l  <Plug>(coc-codeaction)
    nmap <space>k  :CocList<cr>
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
    nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
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

    Plug 'kana/vim-smartword'
    map w  <Plug>(smartword-w)
    map b  <Plug>(smartword-b)
    map e  <Plug>(smartword-e)

    Plug 'bkad/camelcasemotion'
    map <silent> W <Plug>CamelCaseMotion_w
    map <silent> B <Plug>CamelCaseMotion_b
    nmap <silent> E gE

    Plug 'duganchen/vim-soy'
    Plug 'mg979/vim-visual-multi'
    let g:VM_mouse_mappings = 1
    map <F2> \\A
    map <F3> \\C

    Plug 'haya14busa/incsearch.vim'
    map /  <Plug>(incsearch-forward)
    map ?  <Plug>(incsearch-backward)

    Plug 'easymotion/vim-easymotion'
    let g:EasyMotion_smartcase = 1
    let g:EasyMotion_keys = 'asdghklqwertyuiopzxcvbnmfj'

    " move to single character
    nmap f <Plug>(easymotion-overwin-f2)
    nmap F <Plug>(easymotion-overwin-line)

    "Plug 'rking/ag.vim'
    " This addon does the oposite of 'J' in vim
    Plug 'AndrewRadev/splitjoin.vim'
    " changing the default gS and gJ
    let g:splitjoin_split_mapping = 'gs'
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

    Plug 'Yggdroot/LeaderF', { 'do': './install.sh' }
    let g:Lf_WindowPosition = 'popup'
    let g:Lf_PreviewInPopup = 1
    nmap ,f :Leaderf file<cr>
    let g:Lf_UseMemoryCache = 0
    let g:Lf_DefaultMode = 'NameOnly'
    let g:Lf_CommandMap = {'<C-K>': ['<Up>'], '<C-J>': ['<Down>'], '<C-]>': ['<C-V>']}
    xnoremap gf :<C-U><C-R>=printf("Leaderf! rg -F -e %s ", leaderf#Rg#visual())<CR>

    Plug 'dyng/ctrlsf.vim'
    let g:ctrlsf_ackprg = 'rg'
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
    noremap <leader>r :CtrlSF<space>
    noremap <Space>r :CtrlSFOpen<CR><space>
    vnoremap <leader>r y:CtrlSF \b<C-R>"\b -R
    " bind R to search and replace word under the cursor or visual selection
    nnoremap R :CtrlSF <C-R><C-W> -R -W<CR>
    vnoremap R y:CtrlSF "<C-R>""<CR>


    "git tools blame, log, view files in other branches
    Plug 'tpope/vim-fugitive'
    nnoremap gM :Gvsplit origin/master:%<cr>
    nnoremap gm :Gvdiffsplit origin/master:%<cr>
    nnoremap gb :Gblame<cr>
    vnoremap gb :Gbrowse<cr>
    noremap ,g :G<CR>

    Plug 'junegunn/gv.vim'
    Plug 'tpope/vim-rhubarb'
    " change surrounding brancjes
    Plug 'tpope/vim-surround'
    vmap s S

    let g:ragtag_global_maps = 1

    Plug 'kien/ctrlp.vim'
    let g:ctrlp_max_files=0
    let g:ctrlp_show_hidden = 1
    let g:ctrlp_working_path_mode = 'rw'
    let g:ctrlp_by_filename = 1
    let g:ctrlp_mruf_exclude = '/tmp/.*\|/temp/.*\|/private/.*\|.*/node_modules/.*\|.*/.pyenv/.*' " MacOSX/Linux

    Plug 'itchyny/lightline.vim'
    let g:lightline = {
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'cocstatus', 'readonly', 'filename', 'modified' ] ],
    \ 'right': [ [ 'lineinfo' ],
    \            [ 'percent' ],
    \            [ 'filetype' ] ],
    \ },
    \ 'component_function': {
    \   'cocstatus': 'coc#status'
    \ },
    \ }

    " Use autocmd to force lightline update.
    autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

    Plug 'jlanzarotta/bufexplorer'
    nnoremap ,b :BufExplorer<CR>
    "BufExplorer show relative paths by default
    let g:bufExplorerShowRelativePath=1  " Show relative paths.

    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    nmap <F1> :Helptags<cr>
    "nmap <leader>f :FZF<cr>
    command! -bang -nargs=* Rg
      \ call fzf#vim#grep(
      \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
      \   <bang>0 ? fzf#vim#with_preview('up:60%')
      \           : fzf#vim#with_preview('right:50%:hidden', '?'),
      \   <bang>0)

    Plug 'junegunn/vim-easy-align'

    Plug 'Yggdroot/indentLine'
    let g:indent_guides_enable_on_vim_startup = 1

    Plug 'bronson/vim-visual-star-search'
    Plug 'terryma/vim-expand-region'
    Plug 'wellle/targets.vim'

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

    Plug 'chrisbra/csv.vim'
    au FileType csv nnoremap <buffer> <Space><Space> :WhatColumn!<CR>

    Plug 'editorconfig/editorconfig-vim'
" }
call plug#end()
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

    nnoremap db V$%d
    "yank/change/visual inside closest brackets
    nmap c9 ci(
    nmap d9 di(
    nmap y9 yi(
    nmap v9 vi(

    nmap ds9 ds(
    nmap da9 da(

    nmap c[ ci{
    nmap d[ di{
    nmap y[ yi{

    nmap c5 cib
    nmap d5 dib
    nmap y5 yib

    nmap yb yiB
    nmap cb ciB
    nmap db diB

    nnoremap cw cw
    nnoremap dw dw
    nmap yw yiw

    nmap cq caq
    nmap dq daq
    nmap yq yiq
    nmap vq vaq

    nmap c' ciq
    nmap d' diq
    nmap y' yiq
    nmap v' viq

    nmap d4 d$
    nnoremap c6 c^
    nnoremap ~ ~h

    nnoremap yl ^y$
    vnoremap = yO<Esc>P
    nnoremap dl ^d$"_dd

    "TODO add all crazy number shortcuts

    nnoremap <up> 8<C-y>
    vnoremap <up> 8<C-y>
    nnoremap <down> 8<C-e>
    vnoremap <down> 8<C-e>
    nnoremap <left> <C-w>h
    nnoremap <right> <C-w>l
    nnoremap <s-up> <C-w>k
    nnoremap <s-down> <C-w>j

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
    noremap <leader>s :Ack!<space>

    " quick-paste last yanked text
    noremap ; "0p

    nnoremap ,v :CtrlPMRU<CR>

    " bind K to search grep word under the cursor
    nnoremap K :Ack! <cword><CR>
    vnoremap K y:Ack! "<C-R>""<CR>
    vnoremap <leader>s y:Ack! "<C-R>""<space>
    "search for the visually selected text
    vnoremap // y/<C-R>"<CR>

    vnoremap < c<<space>/><Esc>hhP
    vnoremap > c<><Esc>Pf>a</><Esc>P
    vmap ( S(
    vmap 9 S)
    vmap ) S)
    vmap [ S[
    vmap ] S]
    vmap { S{
    vmap } S}
    vmap " S"
    vmap ' S'
    vmap ` S`
    nmap g] <Plug>(coc-git-nextconflict)
    nmap g[ <Plug>(coc-git-prevconflict)

    ""replace word under cursor
    "nnoremap ,r :%s/\<<C-r><C-w>\>//g<Left><Left>
    "close window
    noremap Q q
    noremap q <C-w>c
    "create new vertical split
    noremap ,n :vnew<CR>

    nnoremap ,o :only<CR>

    " add space after
    noremap <Space>a a<Space><Esc>h
    " add space before
    noremap <Space>i i<Space><Esc>l

    "jump to the closest opening bracket of type {
    nnoremap { [{

    nnoremap <Tab> >>
    nnoremap <S-Tab> <<
    vnoremap <Tab> >gv
    vnoremap <S-Tab> <gv

    noremap <C-e> 8<C-e>
    noremap <C-y> 8<C-y>

    noremap <D-j> 8<C-e>
    noremap <D-k> 8<C-y>
    nnoremap vv <C-w>

    command! -nargs=0 -range SortWords call SortWords()
    " Add a mapping, go to your string, then press vi",s
    " vi" selects everything inside the quotation
    " ,s calls the sorting algorithm
    vmap ,s :SortWords<CR>

    "yank current full file path to clipboard
    nnoremap yp :let @+=expand('%:p')<CR>

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
    set termguicolors
    colorscheme gruvbox

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

    set smartindent

    filetype plugin indent on

    au FileType gitcommit           setlocal spell
    "disable continuous comments vim
    au FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
    au BufEnter *.bg* setlocal keymap=bulgarian-phonetic
    au FileType help setlocal number
" }

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
