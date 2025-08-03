" Plugins followed by their mappings and/or custom settings {{{
" plugin mappings and settings
  " themes
  "settings for 'morhetz/gruvbox'

  " settings for dstein64/nvim-scrollview
  " gitsigns is enabled manually look for 'scrollview.contrib.gitsigns'
  let g:scrollview_signs_on_startup = ['search', 'diagnostics', 'cursor']

  set background=dark    " Setting dark mode
  " Plug 'posva/vim-vue'

  "settings for 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
  if exists('g:started_by_firenvim')
    set guifontwide=0
    set guifont=monospace:h10
  endif
  "settings for 'ianding1/leetcode.vim'
  let g:leetcode_browser = 'firefox'
  let g:leetcode_solution_filetype = 'javascript'
  "nnoremap <space>4 :LeetCodeTest<cr>

  " hides formatting symbols, might be overriden
  set conceallevel=0
  " hidden characters
  let g:vim_json_conceal = 0
  let g:vim_markdown_conceal = 0
  let g:vim_markdown_folding_disabled = 1
  map <Plug> <Plug>Markdown_MoveToCurHeader

  "settings for 'mhartington/formatter.nvim'
  nnoremap <silent> <space>F :Format<CR>

  "settings for 'aaronhallaert/advanced-git-search.nvim'
  noremap ,ga :AdvancedGitSearch<CR>
  " dependency to the one above
  "settings for 'ibhagwan/fzf-lua', {'branch': 'main'}

  "settings for 'github/copilot.vim'
  imap <silent><script><expr> <c-cr> copilot#Accept("")
  let g:copilot_no_tab_map = v:true
  imap <C-n> <Plug>(copilot-next)
  imap <C-p> <Plug>(copilot-previous)

  "settings for 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
  let g:mkdp_auto_close = 0

  "settings for 'numToStr/Comment.nvim'

  "settings for 'scrooloose/nerdtree'
  "settings for 'Xuyuanp/nerdtree-git-plugin'
  let g:NERDTreeQuitOnOpen = 1
  let g:NERDTreeChDirMode  = 0
  let NERDTreeShowHidden = 1
  let NERDTreeWinSize = 70
  noremap <space>p :NERDTreeFind<CR>zz
  noremap <silent> <F4> :NERDTreeToggle<CR>

  "settings for 'mhinz/vim-startify'
  let g:startify_change_to_dir = 0
  let g:startify_change_to_vcs_root = 0
  let g:startify_session_persistence = 0

  "settings for 'honza/vim-snippets'
  "treesitter throwing exceptions so use the alternative
  "Plug 'elixir-editors/vim-elixir'

  "settings for 'michaeljsmith/vim-indent-object'
  " remap to my own needs since you cannot remap the built in ones
  omap ai aI
  vmap ai aI

  " settings for 'jeetsukumaran/vim-indentwise'
  nmap { [%
  nmap } ]%

  "settings for 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
  "settings for 'RRethy/nvim-treesitter-textsubjects'
  "settings for 'nvim-treesitter/playground'


  " CoC Config {{{

    "settings for 'neoclide/coc.nvim', {'branch': 'release'}"
    "let g:coc_node_path = '~/.nvm/versions/node/v16.3.0/bin/node'
    let g:coc_global_extensions = [ 'coc-emmet', 'coc-git', 'coc-vimlsp',
      \ 'coc-lists', 'coc-snippets', 'coc-html', 'coc-tsserver', 'coc-jest', 'coc-eslint', 'coc-marketplace',
      \ 'coc-css', 'coc-json', 'coc-java', 'coc-pyright', 'coc-yank', 'coc-prettier', 'coc-omnisharp', 'coc-elixir', 'coc-explorer',
      \ 'coc-vetur', '@yaegassy/coc-volar'] "vue specific

    " You will have bad experience for diagnostic messages when it's default 4000.
    set updatetime=500
    autocmd CursorHold * silent call CocActionAsync('highlight')
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

    " Use tab for trigger completion with characters ahead and navigate.
    " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
    "Make <tab> used for trigger completion, completion confirm, snippet expand and jump like VSCode.
    inoremap <silent><expr> <tab>
          \ coc#pum#visible() ? coc#pum#next(1):
          \ CheckBackspace() ? "\<Tab>" :
          \ coc#refresh()
    inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
    "old mapping
    "inoremap <silent><expr> <TAB>
      "\ pumvisible() ? "\<C-n>" :
      "\ <SID>check_back_space() ? "\<TAB>" :
      "\ coc#refresh()
    "inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

    function! CheckBackspace() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    " jump through predefined locations in current snippet
    let g:coc_snippet_next = '<tab>'

    " Use <c-space> to trigger completion.
    inoremap <silent><expr> <C-Space> coc#refresh()

    " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
    " Coc only does snippet and additional edit on confirm.
    inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
    "inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

    " Use `[c` and `]c` to navigate diagnostics
    " nmap <silent> <space><left> <Plug>(coc-diagnostic-prev)
    " nmap <silent> <space><right> <Plug>(coc-diagnostic-next)

    nnoremap <silent> <space>1 :call CocAction('runCommand', 'eslint.executeAutofix')<CR>
    nnoremap <silent> <space>^ :call CocAction('runCommand', 'tsserver.findAllFileReferences')<CR>
    nnoremap <silent> <space>! :!npx eslint $(git diff --name-only HEAD \| xargs) --fix --ext .js,.ts,.tsx,.vue<CR>

    " Remap keys for gotos
    nmap <silent> gd <Plug>(coc-definition)
    "nmap <silent> ,d <cmd>lua vim.lsp.buf.definition({reuse_win = true})<CR>
    nmap <silent> ,D <Plug>(coc-type-definition)
    nmap <silent> ,i <Plug>(coc-implementation)
    nmap <silent> ,6 <Plug>(coc-references)
    nmap <silent> ,w <Plug>(coc-codelens-action)

    nnoremap <silent> <space><space> :call <SID>show_documentation()<CR>:call CocAction('highlight')<CR>
    " nnoremap <silent> <space><space> <cmd>lua vim.lsp.buf.hover()<CR>

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
    nnoremap <silent> <F7> :CocRestart<CR>:LspRestart<CR>

    " select inside function and all function
    " xmap if <Plug>(coc-funcobj-i)
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
    nmap <silent> 1 <Plug>(coc-range-select)
    xmap <silent> 1 <Plug>(coc-range-select)
    "  <silent> <S-TAB> <Plug>(coc-range-select-backword)

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

  "settings for 'dnlhc/glance.nvim'

  nmap ,d :Glance definitions<cr>
  nmap gti :Glance implementations<cr>
  nmap gr :Glance references<cr>
  nmap gT :Glance type_definitions<cr>
  nmap <space><backspace> :Glance references<cr>

  "settings for 'm-pilia/vim-ccls'

  "settings for 'tpope/vim-repeat'
  "settings for 'tpope/vim-unimpaired'
  nmap ]t :tabnext<cr>
  nmap [t :tabprevious<cr>

  "settings for 'kana/vim-smartword'
  nmap w  <Plug>(smartword-w)
  nmap b  <Plug>(smartword-b)
  nmap e  <Plug>(smartword-e)

  "settings for 'bkad/camelcasemotion'
  map <silent> W <Plug>CamelCaseMotion_w
  map <silent> B <Plug>CamelCaseMotion_b
  nmap <silent> E gE
  vmap <silent> E <Plug>CamelCaseMotion_e

  "settings for 'mg979/vim-visual-multi'
  let g:VM_mouse_mappings = 1
  map <F2> \\A
  map <F3> \\C

  "settings for 'easymotion/vim-easymotion'
  let g:EasyMotion_smartcase = 1
  let g:EasyMotion_keys = 'asdghklqwertyuiopzxcvbnmfj'

  " move to single character
  nmap f <Plug>(easymotion-overwin-f2)

  " This addon does the oposite of 'J' in vim
  "settings for 'AndrewRadev/switch.vim'
  " let g:switch_mapping = "7"
  let g:switch_custom_definitions =
  \ [
  \   ['!==', '==='],
  \   ['!=', '==']
  \ ]

  nnoremap ! <Plug>(Switch)
  " unmap gs

  "settings for 'AndrewRadev/splitjoin.vim'
  " changing the default gS and gJ
  let g:splitjoin_split_mapping = 'gs'
  let g:splitjoin_join_mapping = 'gj'

  "settings for 'AndrewRadev/sideways.vim'
  nnoremap gh :SidewaysLeft<cr>
  nnoremap gl :SidewaysRight<cr>

  "addon for auto closing brackets
  "settings for 'jiangmiao/auto-pairs'
  let g:AutoPairsShortcutBackInsert = '<C-b>'
  let g:AutoPairsShortcutFastWrap = '<C-e>'

  "settings for 'mbbill/undotree'
  nnoremap <leader>u :UndotreeToggle<cr>

  "this one should be used instead of the keybindings near the end of the file'
  "settings for 'matze/vim-move'
  let g:move_map_keys = 0
  vmap H <Plug>MoveBlockUp
  vmap L <Plug>MoveBlockDown
  nmap H <Plug>MoveLineUp
  nmap L <Plug>MoveLineDown

  "settings for 'dyng/ctrlsf.vim'
  let g:ctrlsf_ackprg = 'rg'
  let g:ctrlsf_mapping = {
    \ "next": "n",
    \ "prev": "N",
    \ "vsplit": "s",
    \ "open": "<cr>",
    \ }
  let g:ctrlsf_auto_focus = {
      \ "at" : "start"
      \ }
  let g:ctrlsf_confirm_save = 0

  " search with sublime-alternative
  noremap <leader>r :CtrlSF<space>
  noremap <Space>r :CtrlSFOpen<CR><space>
  vnoremap <leader>r y:CtrlSF \b<C-R>"\b -R -G !*.test.ts
  " search within the current file
  vnoremap <Space>r y:CtrlSF <C-R>" <C-R>=expand('%:p')<cr><cr>
  " bind R to search and replace word under the cursor or visual selection
  nnoremap R :CtrlSF <C-R><C-W> -W<CR>
  vnoremap R y:CtrlSF "<C-R>""<CR>
  "same as above but ignore test files
  vnoremap T y:CtrlSF "<C-R>"" -G !*.test.ts<CR>


  "git tools blame, log, view files in other branches
  "settings for 'tpope/vim-fugitive'
  nnoremap gD :Gvdiffsplit<cr>
  nnoremap gb :G blame<cr>
  vnoremap gb :GBrowse<cr>
  noremap ,g :G<CR>
  noremap ,g<space> :G<space>
  noremap ,gg :G<CR><c-w>H
  noremap ,gc :GV?<cr><c-w>H
  noremap ,gH :G log --stat -p -U0 --abbrev-commit --date=relative -- %<cr><c-w>H
  noremap ,gp :G pull
  noremap ,gs :G push
  noremap ,gf :G fetch
  noremap ,gx :G merge origin/master
  noremap ,gz :G merge --continue
  nnoremap gM :Gvsplit origin/<C-r>=GetMasterBranchName()<CR>:%<cr>
  nnoremap gm :Gvdiffsplit origin/<C-r>=GetMasterBranchName()<CR>:%<cr>
  noremap ,gM :G diff origin/<C-r>=GetMasterBranchName()<CR>... <cr><c-w>H

  "settings for 'sindrets/diffview.nvim'
  noremap ,gd :CocDisable<cr>:DiffviewOpen<CR>
  noremap ,gh :CocDisable<cr>:DiffviewFileHistory %<cr>
  noremap ,gm :CocDisable<cr>:DiffviewOpen origin/<C-r>=GetMasterBranchName()<CR>...HEAD<cr>

  "settings for 'folke/trouble.nvim'

  " restore mappings
  " use 2X to call `checkout --ours` or 3X to call `checkout --theirs`

  "settings for 'junegunn/gv.vim'
  "settings for 'tpope/vim-rhubarb'
  " change surrounding brancjes
  "settings for 'tpope/vim-surround'
  vmap s S

  "settings for 'itchyny/lightline.vim'
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
  \ 'colorscheme': 'sonokai',
  \ 'component': {
  \   'lineinfo': "%{line('.') . ':' . col('.') . '/' . line('$')}",
  \ }}

  function! LightlineFilepath()
    return winwidth(0) > 100 ? expand('%f') : expand('%:t')
  endfunction

  " Use autocmd to force lightline update.
  autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

  "settings for 'jlanzarotta/bufexplorer'
  nnoremap ,b :BufExplorerVerticalSplit<CR>
  "BufExplorer show relative paths by default
  let g:bufExplorerShowNoName=1
  let g:bufExplorerShowRelativePath=1  " Show relative paths.

  "settings for 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  "settings for 'junegunn/fzf.vim'
  "settings for 'pbogut/fzf-mru.vim'
  let $FZF_DEFAULT_OPTS = '--layout=reverse'
  nnoremap <space>: :History:<cr>

  " migrate to telescope instead of fzf
  nnoremap <space>dd :Files<cr>
  " nnoremap ,F :FZF -q <c-r><c-w><cr>
  " vnoremap ,f y:FZF -q <c-r>"<cr>

  nnoremap <space>` :CustomBLines<cr>
  nnoremap ,s :BLines<cr>
  vnoremap ,s y:BLines <c-r>"<cr>
  "vnoremap ,s y:Telescope current_buffer_fuzzy_find<cr>i<c-r>"<backspace><backspace>
  nnoremap <space>s :Rg<cr>
  " opens and searching for the filename under the cursor and either prepend <
  " nnoremap <space>6 :Rg <<c-r>=expand('%:t:r')<CR>\b<CR>
  " improved version of the above
  nnoremap <space>6 :<C-U>call RgFileReferences()<CR>
  vnoremap <space>s y:Rg <c-r>"<cr>
  vnoremap <space>` y:CustomBLines <c-r>"<cr>

  nnoremap g1 :<C-U>call MergeKeepLeft()<CR>

  function! RgFileReferences()
    let currentExtension = expand('%:e')
    if currentExtension == 'vue' || currentExtension == 'jsx' || currentExtension == 'tsx'
      execute ':Rg <' . expand("%:t:r") .. '\b'
    else
      execute ':Rg ' . expand('%:t:r') .. '\('
    endif
  endfunction

  "more useful commands https://github.com/junegunn/fzf.vim#commands

  command! -bang -nargs=* CustomBLines
  \ call fzf#vim#grep(
  \   'rg --with-filename --column --line-number --no-heading --smart-case . '.fnameescape(expand('%:p')), 1,
  \   fzf#vim#with_preview({'options': '--no-sort --layout reverse --query '.shellescape(<q-args>).' --with-nth=4.. --delimiter=":"'}, 'right:50%'))

  inoremap <expr> <c-x><c-f> fzf#vim#complete#path('rg --files')

  "settings for 'kien/ctrlp.vim'
  let g:ctrlp_max_files = 0
  let g:ctrlp_show_hidden = 1
  let g:ctrlp_working_path_mode = 'rw'
  let g:ctrlp_by_filename = 1
  let g:ctrlp_mruf_max = 2500
  let g:ctrlp_mruf_exclude = '/tmp/.*\|/temp/.*\|/private/.*\|.*/node_modules/.*\|.*/.pyenv/.*' " MacOSX/Linux
  nnoremap ,x :CtrlPMRUFiles<CR>
  nnoremap ,v <cmd>Telescope oldfiles<cr>

  "settings for 'nvim-lua/plenary.nvim'
  "settings for 'nvim-telescope/telescope.nvim'

  nmap <F1> :Telescope help_tags<cr>
  " nnoremap <space>d <cmd>Telescope<cr>
  nnoremap ,f :Telescope find_files<cr>
  nnoremap ,F :Telescope find_files default_text=<c-r><c-w><cr>
  nmap gF :Telescope find_files search_file=<c-r><c-w><cr>

  nnoremap <space>df <cmd>Telescope oldfiles<cr>
  nnoremap <space>dg <cmd>Telescope live_grep<cr>
  nnoremap <space>db <cmd>Telescope buffers<cr>
  nnoremap <space>dh <cmd>Telescope help_tags<cr>
  nnoremap <space>de <cmd>Telescope builtin<cr>


  "THE BEST FONT IS 1) Meslo 2) Hack
  "settings for 'nvim-tree/nvim-web-devicons'
  " octo is a github pr review plugin
  "settings for 'pwntester/octo.nvim'
  nnoremap <space>v :Octo<CR>
  nnoremap <space>vv :Octo<CR>
  nnoremap <leader>pro :Octo pr checkout 
  nnoremap <leader>prr :Octo review start<cr>

  "settings for 'junegunn/vim-easy-align'

  "settings for 'bronson/vim-visual-star-search'

  "" use + and _ to incrementally visually select
  "Plug 'terryma/vim-expand-region'

  " adds text objects for pairs such as brackets and quiotes, commas etc.
  "settings for 'wellle/targets.vim'

  "settings for 'haya14busa/vim-textobj-function-syntax'

  nmap <expr> - (foldclosed(line(".")) == -1) ? 'za':'zA'
  " this was manual way of setting folding, no longer needed because there is nvim-ufo plugin as provided
  vnoremap - zf
  nmap _ zc

  "settings for 'chrisbra/csv.vim'

  " use workspace properties if project uses editorconfig
  "settings for 'editorconfig/editorconfig-vim'

  " if ripgrep
  if executable ('rg')
    set grepprg=rg\ --color=never
    "set grepformat=%f:%l:%c:%m,%f:%l:%m
    let g:ackprg = 'rg --vimgrep --no-heading'
    let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
  endif

  "settings for 'rmagatti/goto-preview'

  nnoremap gpp <cmd>lua require('goto-preview').goto_preview_definition()<CR>
  nnoremap gpt <cmd>lua require('goto-preview').goto_preview_type_definition()<CR>
  nnoremap gpi <cmd>lua require('goto-preview').goto_preview_implementation()<CR>
  nnoremap gp <cmd>lua require('goto-preview').close_all_win()<CR>
  nnoremap gpr <cmd>lua require('goto-preview').goto_preview_references()<CR>
  " not working tbh
  nnoremap gpd <cmd>lua require('goto-preview').goto_preview_declaration()<CR>

" }}}
