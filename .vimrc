packadd nvim-treesitter
let g:python3_host_prog = '/usr/local/bin/python3'

" Load vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Plugins followed by their mappings and/or custom settings {{{
call plug#begin('~/.vim/plugged')
  " themes
  Plug 'morhetz/gruvbox'
  set background=dark    " Setting dark mode

  Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
  if exists('g:started_by_firenvim')
    set guifontwide=0
    set guifont=monospace:h10
  endif
  Plug 'raghur/vim-ghost', {'do': ':GhostInstall'}
  Plug 'ianding1/leetcode.vim'
  let g:leetcode_browser = 'firefox'
  let g:leetcode_solution_filetype = 'javascript'
  nnoremap <space>4 :LeetCodeTest<cr>

  set conceallevel=0
  " hidden characters
  let g:vim_json_conceal = 0
  let g:vim_markdown_conceal = 0
  let g:vim_markdown_folding_disabled = 1
  map <Plug> <Plug>Markdown_MoveToCurHeader

  Plug 'sbdchd/neoformat'

  Plug 'github/copilot.vim'

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
  let NERDTreeWinSize = 70
  noremap <space>p :NERDTreeFind<CR>zz
  noremap <silent> <F4> :NERDTreeToggle<CR>

  Plug 'mhinz/vim-startify'
  let g:startify_change_to_dir = 0
  let g:startify_change_to_vcs_root = 1
  let g:startify_session_persistence = 1

  Plug 'skanehira/gh.vim'

  Plug 'airblade/vim-gitgutter'
  nmap <space>h <Plug>(GitGutterPreviewHunk)
  nmap <space>x <Plug>(GitGutterUndoHunk)
  nmap <space>v <Plug>(GitGutterStageHunk)

  Plug 'honza/vim-snippets'

  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
  Plug 'RRethy/nvim-treesitter-textsubjects'
  Plug 'nvim-treesitter/playground'
lua <<EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,              -- false will disable the whole extension
    -- disable = { "c", "rust" },  -- list of language that will be disabled
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    -- additional_vim_regex_highlighting = false,
  },
  textsubjects = {
      enable = true,
      keymaps = {
          ['.'] = 'textsubjects-smart',
          ['+'] = 'textsubjects-container-outer',
      }
  },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
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
  }
}
EOF

  " CoC Config {{{

    Plug 'neoclide/coc.nvim', {'branch': 'release'}"
    let g:coc_node_path = '~/.nvm/versions/node/v16.3.0/bin/node'
    let g:coc_global_extensions = [ 'coc-emmet', 'coc-git', 'coc-vimlsp',
      \ 'coc-lists', 'coc-snippets', 'coc-html', 'coc-tsserver', 'coc-jest', 'coc-eslint',
      \ 'coc-css', 'coc-json', 'coc-java', 'coc-pyright', 'coc-yank', 'coc-prettier', 'coc-omnisharp' ]

    " You will have bad experience for diagnostic messages when it's default 4000.
    set updatetime=500
    autocmd CursorHold * silent call CocActionAsync('highlight')
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

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

    " jump through predefined locations in current snippet
    let g:coc_snippet_next = '<tab>'

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

    nnoremap <silent> <space><space> :call <SID>show_documentation()<CR>:call CocAction('highlight')<CR>
    nmap <silent> <space><backspace> <Plug>(coc-references)

    function! s:show_documentation()
      if CocAction('doHover')
      elseif (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
      endif
    endfunction

    :nmap <space>e :CocCommand explorer<CR>

    " Remap for rename current word
    nmap ,r <Plug>(coc-rename)
    nmap ,R <Plug>(coc-refactor)

    " Remap for format selected region
    xmap <space>f  <Plug>(coc-format-selected)
    nmap <space>f  <Plug>(coc-format)

    " select inside function and all function
    xmap if <Plug>(coc-funcobj-i)
    omap if <Plug>(coc-funcobj-i)

    omap af <Plug>(coc-funcobj-a)
    xmap af <Plug>(coc-funcobj-a)

    " select inside class/struct/interface and all function
    xmap ic <Plug>(coc-classobj-i)
    omap ic <Plug>(coc-classobj-i)

    xmap ac <Plug>(coc-classobj-a)
    omap ac <Plug>(coc-classobj-a)

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

    "show all functions that are calling the one under the cursor
    nnoremap <silent> <space>u :call CocAction('showIncomingCalls')<CR><C-w>H
    nnoremap <silent> <space>U :call CocAction('showOutgoingCalls')<CR><C-w>H
    " Find symbol of current workspace
    nnoremap <silent> <space>O  :<C-u>CocList symbols<cr>
    " Search workspace symbols
    nnoremap <silent> <space>cs  :<C-u>CocList -I symbols<cr>
    " Do default action for next item.
    nnoremap <silent> <space>cj  :<C-u>CocNext<CR>
    " Do default action for previous item.
    nnoremap <silent> <space>ck  :<C-u>CocPrev<CR>
    " Resume latest coc list
    nnoremap <silent> <space>cp  :<C-u>CocListResume<CR>
    " Show yanks history
    nnoremap <silent> <space>y  :<C-u>CocList -A --normal yank<cr>

  " end of coc config }}}}

  Plug 'm-pilia/vim-ccls'

  Plug 'tpope/vim-repeat'
  Plug 'tpope/vim-unimpaired'

  Plug 'kana/vim-smartword'
  nmap w  <Plug>(smartword-w)
  nmap b  <Plug>(smartword-b)
  nmap e  <Plug>(smartword-e)

  Plug 'bkad/camelcasemotion'
  map <silent> W <Plug>CamelCaseMotion_w
  map <silent> B <Plug>CamelCaseMotion_b
  nmap <silent> E gE

  Plug 'mg979/vim-visual-multi'
  let g:VM_mouse_mappings = 1
  map <F2> \\A
  map <F3> \\C

  Plug 'haya14busa/incsearch.vim'
  map /  <Plug>(incsearch-forward)

  Plug 'easymotion/vim-easymotion'
  let g:EasyMotion_smartcase = 1
  let g:EasyMotion_keys = 'asdghklqwertyuiopzxcvbnmfj'

  " move to single character
  nmap F <Plug>(easymotion-overwin-f2)

  " This addon does the oposite of 'J' in vim
  Plug 'AndrewRadev/switch.vim'
  let g:switch_mapping = "7"
  let g:switch_custom_definitions =
  \ [
  \   ['!==', '==='],
  \   ['!=', '==']
  \ ]

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
  nnoremap gD :Gvdiffsplit<cr>
  nnoremap gb :G blame<cr>
  vnoremap gb :GBrowse<cr>
  noremap ,g :G<CR>
  noremap ,g<space> :G<space>
  noremap ,gg :G<CR><c-w>H
  noremap ,gp :G pull
  noremap ,gs :G push
  noremap ,gf :G fetch
  " restore mappings
  " use 2X to call `checkout --ours` or 3X to call `checkout --theirs`

  Plug 'junegunn/gv.vim'
  Plug 'tpope/vim-rhubarb'
  " change surrounding brancjes
  Plug 'tpope/vim-surround'
  vmap s S

  Plug 'itchyny/lightline.vim'
  let g:lightline = {
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'readonly', 'lightfilepath', 'modified', 'cocstatus' ]],
  \   'right': [ [ 'lineinfo' ],
  \            [ 'percent' ] ],
  \ },
  \ 'component_function': {
  \   'cocstatus': 'coc#status',
  \   'lightfilepath': 'LightlineFilepath',
  \ },
  \ 'component': {
  \   'lineinfo': "%{line('.') . ':' . col('.') . '/' . line('$')}",
  \ }}

  function! LightlineFilepath()
    return winwidth(0) > 100 ? expand('%f') : expand('%:t')
  endfunction

  " Use autocmd to force lightline update.
  autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

  Plug 'jlanzarotta/bufexplorer'
  nnoremap ,b :BufExplorerVerticalSplit<CR>
  "BufExplorer show relative paths by default
  let g:bufExplorerShowNoName=1
  let g:bufExplorerShowRelativePath=1  " Show relative paths.

  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'
  Plug 'pbogut/fzf-mru.vim'
  let $FZF_DEFAULT_OPTS = '--layout=reverse'
  nmap <F1> :Helptags<cr>

  nnoremap ,f :Files<cr>
  nnoremap <space>` :CustomBLines<cr>
  nnoremap <space>~ :BLines<cr>
  nnoremap <space>§ :Rg<cr>
  vnoremap <space>§ y:Rg <c-r>"<cr>
  vnoremap <space>` y:CustomBLines <c-r>"<cr>

  "more useful commands https://github.com/junegunn/fzf.vim#commands

  command! -bang -nargs=* CustomBLines
  \ call fzf#vim#grep(
  \   'rg --with-filename --column --line-number --no-heading --smart-case . '.fnameescape(expand('%:p')), 1,
  \   fzf#vim#with_preview({'options': '--layout reverse --query '.shellescape(<q-args>).' --with-nth=4.. --delimiter=":"'}, 'right:50%'))
  " \   fzf#vim#with_preview({'options': '--layout reverse  --with-nth=-1.. --delimiter="/"'}, 'right:50%'))

  Plug 'kien/ctrlp.vim'
  let g:ctrlp_max_files = 0
  let g:ctrlp_show_hidden = 1
  let g:ctrlp_working_path_mode = 'rw'
  let g:ctrlp_by_filename = 1
  let g:ctrlp_mruf_exclude = '/tmp/.*\|/temp/.*\|/private/.*\|.*/node_modules/.*\|.*/.pyenv/.*' " MacOSX/Linux
  nnoremap ,v :CtrlPMRU<CR>

  Plug 'junegunn/vim-easy-align'

  " vertical guides
  Plug 'Yggdroot/indentLine'
  let g:indent_guides_enable_on_vim_startup = 1

  Plug 'bronson/vim-visual-star-search'

  "" use + and _ to incrementally visually select
  "Plug 'terryma/vim-expand-region'

  " adds text objects for pairs such as brackets and quiotes, commas etc.
  Plug 'wellle/targets.vim'

  Plug 'haya14busa/vim-textobj-function-syntax'

  nmap <expr> - (foldclosed(line(".")) == -1) ? 'za':'zA'
  nmap zf :setlocal foldmethod=syntax<cr>:setlocal foldlevel=1<cr>zN
  vnoremap - <esc>:setlocal foldmethod=manual<cr>gvzf
  nmap _ zc
  set nofoldenable

  Plug 'chrisbra/csv.vim'

  " use workspace properties if project uses editorconfig
  Plug 'editorconfig/editorconfig-vim'

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
  " or ripgrep
  if executable ('rg')
    set grepprg=rg\ --color=never
    "set grepformat=%f:%l:%c:%m,%f:%l:%m
    let g:ackprg = 'rg --vimgrep --no-heading'
    let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
  endif

call plug#end()
" }}}

" General Keybindings ---{{{
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
  vnoremap 4 $h
  nnoremap 5 %
  vnoremap 5 %
  nnoremap 6 ^
  vnoremap 6 ^
  nnoremap 8 *
  vnoremap 8 *
  nnoremap 9 <C-o>
  nnoremap 0 <C-i>

  nnoremap db V$%d
  "delete calling a function along with the preceding dot
  nnoremap dc f(bhxdwda(
  "yank/change/visual inside closest brackets
  nmap c9 ci(
  nmap ca9 ca(
  nmap d9 di(
  nmap y9 yi(
  nmap v9 vi(

  nmap ds9 ds(
  nmap da9 da(

  nmap c[ ci[
  nmap d[ di[
  nmap y[ yi[
  nmap v[ vi[

  nmap c{ ci{
  nmap d{ di{
  nmap y{ yi{
  nmap v{ vi{

  nmap c5 cib
  nmap d5 dib
  nmap y5 yib
  nmap v5 vib

  nnoremap cw cw
  nnoremap dw dw
  nmap yw yiw

  nmap cq caq
  nmap dq daq
  nmap yq yiq
  nmap vq vaq

  nmap c' ciq
  nmap d' diq
  nmap da' daq
  nmap y' yiq
  nmap v' viq

  nmap d4 d$
  nmap y4 y$
  nnoremap c6 c^
  nnoremap c<space> ct<space>
  nnoremap ~ ~h

  nnoremap t9 t(
  nnoremap t0 t)

  nnoremap dt9 dt(
  nnoremap dt0 dt)
  nnoremap ct9 ct(
  nnoremap ct0 ct)

  nnoremap f9 f(
  nnoremap f0 f)

  nnoremap dC vf(%d
  nnoremap cC vf(%c

  "yank line without return of carret
  nnoremap yl ^y$
  "yank whole buffer
  nnoremap Y ggVGy<C-o>zz
  " duplicate
  vnoremap Y yO<Esc>P
  nnoremap dl ^d$"_dd

  nnoremap <up> 8<C-y>
  vnoremap <up> 8<C-y>
  nnoremap <down> 8<C-e>
  vnoremap <down> 8<C-e>
  nnoremap § <C-w>v
  nnoremap <left> <C-w>h
  nnoremap <right> <C-w>l
  nnoremap <s-up> <C-w>k
  nnoremap <s-down> <C-w>j

  " disable the highlight search
  nnoremap <CR> :noh<CR>
  nnoremap <f5> :e!<CR>
  nnoremap <f6> :q<CR>
  " preview current file with Google Chrome
  nnoremap <space>7 :silent ! open -a 'Google Chrome' %:p<cr>
  nnoremap <space>g y:silent ! open -a 'Google Chrome' 'http://google.com/search?q='<left>
  vnoremap <space>g y:silent ! open -a 'Google Chrome' 'http://google.com/search?q=<c-r>"'<CR>
  "execute current buffer or current selection in via ts-node (ignoring erros)
  noremap <space>= :w !ts-node-transpile-only<cr>

  "sudo overwrite protect file
  cmap w!! w !sudo tee > /dev/null %

  set backspace=indent,eol,start " make backspace behave consistently with other apps

  " delete trailing whitespace
  nnoremap <silent> <leader>q :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

  " search with ag via the Ack frontend plugin
  noremap <leader>s :Ack!<space>

  " quick-paste last yanked text
  noremap ; "0p

  " bind K to search grep word under the cursor
  nnoremap K :Ack! <cword><CR>
  vnoremap K y:Ack! "<C-R>""<CR>
  vnoremap <leader>s y:Ack! "<C-R>""<space>
  "search for the visually selected text
  vnoremap // y/<C-R>"<CR>N

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
  nnoremap g] :<C-U>call GoNextConflict()<CR>
  nnoremap g[ :<C-U>call GoPrevConflict()<CR>

  nnoremap g1 :<C-U>call MergeKeepLeft()<CR>
  nnoremap g2 :<C-U>call MergeKeepBoth()<CR>
  nnoremap g3 :<C-U>call MergeKeepRight()<CR>


  ""replace word under cursor
  "nnoremap ,r :%s/\<<C-r><C-w>\>//g<Left><Left>
  "close window
  noremap Q q
  noremap q <C-w>c
  "create new vertical split
  noremap ,n :vnew<CR>

  nnoremap ,o <c-w>\|
  nnoremap ,O <c-w>o

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

  "yank current full file path to clipboard
  nnoremap yp :let @+=expand('%:p')<CR>

  "go to sibling style file
  nnoremap gts :e <C-R>=expand('%:r') . '.scss'<CR><CR>
  "go to tsx
  nnoremap gtt :e <C-R>=expand('%:r') . '.tsx'<CR><CR>
  "go to js
  nnoremap gtj :e <C-R>=expand('%:r') . '.js'<CR><CR>
  "go migrate flow and go to tsx
  nmap gtf :!flow-to-ts %:p -o tsx<cr>:e <C-R>=expand('%:r') . '.tsx'<CR><CR>

  noremap <leader>ve :e $MYVIMRC<CR>
  noremap <leader>vE :vsplit $MYVIMRC<CR>
  noremap <leader>vu :source %<CR>

  tnoremap <ESC><ESC> <C-\><C-N>

  " Settings for VimDiff as MergeTool
  if &diff
    noremap <leader>1 :diffget LOCAL<CR>
    noremap <leader>2 :diffget BASE<CR>
    noremap <leader>3 :diffget REMOTE<CR>
    colorscheme darkBlue
  endif
  if has("patch-8.1.0360")
    set diffopt+=internal,algorithm:patience,iwhteall
  endif
" }}}

" Functions {{{
  function! GoNextConflict()
    let lastsearch = @/
    let @/ = '<<<<<<<'
    execute "normal! /\<cr>"

    let @/ = lastsearch
  endfunction

  function! GoPrevConflict()
    let lastsearch = @/
    let @/ = '<<<<<<<'
    execute "normal! ?\<cr>"

    let @/ = lastsearch
  endfunction

  function! MergeKeepLeft()
    let lastsearch = @/
    let @/ = '<<<<<<<'
    execute "normal! ?\<cr>dd"

    let @/ = '|||||||'
    execute "normal! /\<cr>V"

    let @/ = '>>>>>>>'
    execute "normal! /\<cr>d"

    let @/ = lastsearch
  endfunction

  function! MergeKeepBoth()
    let lastsearch = @/
    let @/ = '<<<<<<<'
    execute "normal! ?\<cr>dd"

    let @/ = '|||||||'
    execute "normal! /\<cr>V"

    let @/ = '======='
    execute "normal! /\<cr>d"

    let @/ = '>>>>>>>'
    execute "normal! /\<cr>dd"

    let @/ = lastsearch
  endfunction

  function! MergeKeepRight()
    let lastsearch = @/
    let @/ = '<<<<<<<'
    execute "normal! ?\<cr>V"

    let @/ = '======='
    execute "normal! /\<cr>d"

    let @/ = '>>>>>>>'
    execute "normal! /\<cr>dd"

    let @/ = lastsearch
  endfunction

  " redirect the output of a Vim or external command into a scratch buffer
  " similar to :r!ls -a
  function! Redir(cmd)
    if a:cmd =~ '^!'
      execute "let output = system('" . substitute(a:cmd, '^!', '', '') . "')"
    else
      redir => output
      execute a:cmd
      redir END
    endif
    vnew
    setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
    call setline(1, split(output, "\n"))
    put! = a:cmd
    put = '----'
  endfunction

  command! -nargs=1 Redir silent call Redir(<f-args>)

" }}}

" General variables set {{{
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

" AutoCommands {{{
  augroup autocommands
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

    au FileType markdown nnoremap <silent><buffer> <Space>o :Toc<CR>

    au FileType markdown nnoremap <silent><buffer> <Space>7 :MarkdownPreview<CR>

    au FileType ctrlsf nnoremap <silent><buffer> <space>` :BLines<cr>

    au FileType ctrlsf vnoremap <silent><buffer> <space>` y:BLines <c-r>"<cr>

    au FileType ctrlsf nnoremap <silent><buffer> gn n

    au FileType fugitive nnoremap <buffer> 2 2

    au FileType fugitive nnoremap <buffer> 3 3

    "use 'ours' when merge conflict
    au FileType fugitive nmap <buffer> g1 2X

    "use 'theirs' when merge conflict
    au FileType fugitive nmap <buffer> g3 3X

    au FileType csv nnoremap <buffer> <Space><Space> :WhatColumn!<CR>

    au FileType gitcommit setlocal spell
    "disable continuous comments vim
    au FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
    " enable vim motions to work while writing in bulgarian
    au BufEnter *.bg.* setlocal keymap=bulgarian-phonetic
    au FileType help setlocal number
    au FileType vim setlocal shiftwidth=2
    au FileType vim vnoremap <buffer> <Space>= :<C-u>@*<CR>
  augroup end
" }}}

" Vimscript file settings {{{
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END
" }}}
