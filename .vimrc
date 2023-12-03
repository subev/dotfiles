
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
  "rmagatti/goto-preview",
  "neovim/nvim-lspconfig",
  "nvim-treesitter/nvim-treesitter",
  "RRethy/nvim-treesitter-textsubjects",
  "nvim-treesitter/playground",
  -- 'sainnhe/gruvbox-material',
  'sainnhe/sonokai',
  'posva/vim-vue',
  'ianding1/leetcode.vim',
  'sbdchd/neoformat',
  { 'aaronhallaert/advanced-git-search.nvim', dependencies = "ibhagwan/fzf-lua" },
  { "junegunn/fzf", build = "./install --bin" },
  'github/copilot.vim',
  'tmhedberg/matchit',
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
  'airblade/vim-gitgutter',
  'honza/vim-snippets',
  'elixir-editors/vim-elixir',
  { 'neoclide/coc.nvim', build = "npm ci" },
  'dnlhc/glance.nvim',
  'm-pilia/vim-ccls',
  'tpope/vim-repeat',
  'tpope/vim-unimpaired',
  'kana/vim-smartword',
  'bkad/camelcasemotion',
  'mg979/vim-visual-multi',
  'haya14busa/incsearch.vim',
  'easymotion/vim-easymotion',
  'AndrewRadev/switch.vim',
  'AndrewRadev/splitjoin.vim',
  'AndrewRadev/sideways.vim',
  'jiangmiao/auto-pairs',
  'NvChad/nvim-colorizer.lua',
  'nvim-treesitter/nvim-treesitter-context',
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
  'haya14busa/vim-textobj-function-syntax',
  'chrisbra/csv.vim',
  'editorconfig/editorconfig-vim'
})
EOF

"let g:python3_host_prog = '/usr/local/bin/python3'

nnoremap gpp <cmd>lua require('goto-preview').goto_preview_definition()<CR>
nnoremap gpt <cmd>lua require('goto-preview').goto_preview_type_definition()<CR>
nnoremap gpi <cmd>lua require('goto-preview').goto_preview_implementation()<CR>
nnoremap gp <cmd>lua require('goto-preview').close_all_win()<CR>
nnoremap gpr <cmd>lua require('goto-preview').goto_preview_references()<CR>
" not working tbh
nnoremap gpd <cmd>lua require('goto-preview').goto_preview_declaration()<CR>

" Plugins followed by their mappings and/or custom settings {{{
" plugin mappings and settings
  " themes
  "settings for 'morhetz/gruvbox'
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

  "settings for 'sbdchd/neoformat'

  "settings for 'aaronhallaert/advanced-git-search.nvim'
  noremap ,ga :AdvancedGitSearch<CR>
  " dependency to the one above
  "settings for 'ibhagwan/fzf-lua', {'branch': 'main'}

  "settings for 'github/copilot.vim'
  imap <silent><script><expr> <c-cr> copilot#Accept("")
  let g:copilot_no_tab_map = v:true
  imap <C-n> <Plug>(copilot-next)
  imap <C-p> <Plug>(copilot-previous)

  ""match tags and navigate through %
  "settings for 'tmhedberg/matchit'

  "settings for 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
  let g:mkdp_auto_close = 0

  "settings for 'numToStr/Comment.nvim'

  "settings for 'scrooloose/nerdtree'
  "settings for 'Xuyuanp/nerdtree-git-plugin'
  let g:NERDTreeQuitOnOpen = 1
  let g:NERDTreeChDirMode  = 2
  let NERDTreeShowHidden = 1
  let NERDTreeWinSize = 70
  noremap <space>p :NERDTreeFind<CR>zz
  noremap <silent> <F4> :NERDTreeToggle<CR>

  "settings for 'mhinz/vim-startify'
  let g:startify_change_to_dir = 0
  let g:startify_change_to_vcs_root = 1
  let g:startify_session_persistence = 1

  "settings for 'skanehira/gh.vim'

  "settings for 'airblade/vim-gitgutter'
  nmap <space>h <Plug>(GitGutterPreviewHunk)
  nmap <space>x <Plug>(GitGutterUndoHunk)

  "settings for 'honza/vim-snippets'
  "treesitter throwing exceptions so use the alternative
  "Plug 'elixir-editors/vim-elixir'

  "settings for 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
  "settings for 'RRethy/nvim-treesitter-textsubjects'
  "settings for 'nvim-treesitter/playground'


  " CoC Config {{{

    "settings for 'neoclide/coc.nvim', {'branch': 'release'}"
    "let g:coc_node_path = '~/.nvm/versions/node/v16.3.0/bin/node'
    let g:coc_global_extensions = [ 'coc-emmet', 'coc-git', 'coc-vimlsp',
      \ 'coc-lists', 'coc-snippets', 'coc-html', 'coc-tsserver', 'coc-jest', 'coc-eslint', 'coc-marketplace',
      \ 'coc-css', 'coc-json', 'coc-java', 'coc-pyright', 'coc-yank', 'coc-prettier', 'coc-omnisharp', 'coc-elixir', 'coc-explorer',
      \ 'coc-vetur', '@yaegassy/coc-volar', '@yaegassy/coc-typescript-vue-plugin'] "vue specific

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
    nmap <silent> <space><left> <Plug>(coc-diagnostic-prev)
    nmap <silent> <space><right> <Plug>(coc-diagnostic-next)

    nnoremap <silent> <space>1 :call CocAction('runCommand', 'eslint.executeAutofix')<CR>
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

    " those does not seem to work
    "nnoremap <silent> <space><right> <cmd>lua vim.lsp.diagnostic.goto_next()<CR>
    "nnoremap <silent> <space><left> <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>

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

  "settings for 'haya14busa/incsearch.vim'
  map /  <Plug>(incsearch-forward)
  map ?  <Plug>(incsearch-backward)
  map g/ <Plug>(incsearch-stay)

  "settings for 'easymotion/vim-easymotion'
  let g:EasyMotion_smartcase = 1
  let g:EasyMotion_keys = 'asdghklqwertyuiopzxcvbnmfj'

  " move to single character
  nmap f <Plug>(easymotion-overwin-f2)

  " This addon does the oposite of 'J' in vim
  "settings for 'AndrewRadev/switch.vim'
  let g:switch_mapping = "7"
  let g:switch_custom_definitions =
  \ [
  \   ['!==', '==='],
  \   ['!=', '==']
  \ ]

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
  noremap ,gh :DiffviewFileHistory %<cr>
  noremap ,gm :DiffviewOpen origin/<C-r>=GetMasterBranchName()<CR>...HEAD<cr>

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

  nnoremap <space>` :CustomBLines<cr>'
  nnoremap ,s :BLines<cr>
  vnoremap ,s y:BLines <c-r>"<cr>
  "vnoremap ,s y:Telescope current_buffer_fuzzy_find<cr>i<c-r>"<backspace><backspace>
  nnoremap <space>s :Rg<cr>
  nnoremap <space>6 :Rg <<c-r>=expand('%:t:r')<CR>\b<CR>
  nnoremap <space>^ :Rg \b<c-r>=expand('%:t:r')<CR>\b<CR>
  vnoremap <space>s y:Rg <c-r>"<cr>
  vnoremap <space>` y:CustomBLines <c-r>"<cr>

  "more useful commands https://github.com/junegunn/fzf.vim#commands

  command! -bang -nargs=* CustomBLines
  \ call fzf#vim#grep(
  \   'rg --with-filename --column --line-number --no-heading --smart-case . '.fnameescape(expand('%:p')), 1,
  \   fzf#vim#with_preview({'options': '--no-sort --layout reverse --query '.shellescape(<q-args>).' --with-nth=4.. --delimiter=":"'}, 'right:50%'))

  "settings for 'kien/ctrlp.vim'
  let g:ctrlp_max_files = 0
  let g:ctrlp_show_hidden = 1
  let g:ctrlp_working_path_mode = 'rw'
  let g:ctrlp_by_filename = 1
  let g:ctrlp_mruf_exclude = '/tmp/.*\|/temp/.*\|/private/.*\|.*/node_modules/.*\|.*/.pyenv/.*' " MacOSX/Linux
  "nnoremap ,v :Buffers<CR>
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

  " vertical guides
  "settings for 'Yggdroot/indentLine'
  let g:indent_guides_enable_on_vim_startup = 1

  "settings for 'bronson/vim-visual-star-search'

  "" use + and _ to incrementally visually select
  "Plug 'terryma/vim-expand-region'

  " adds text objects for pairs such as brackets and quiotes, commas etc.
  "settings for 'wellle/targets.vim'

  "settings for 'haya14busa/vim-textobj-function-syntax'

  nmap <expr> - (foldclosed(line(".")) == -1) ? 'za':'zA'
  nmap zf :setlocal foldmethod=syntax<cr>:setlocal foldlevel=1<cr>zN
  vnoremap - <esc>:setlocal foldmethod=manual<cr>gvzf
  nmap _ zc
  set nofoldenable

  "settings for 'chrisbra/csv.vim'

  " use workspace properties if project uses editorconfig
  "settings for 'editorconfig/editorconfig-vim'

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

" }}}

" LUA-SETUPS
lua <<EOF
require'advanced_git_search.fzf'.setup {
  diff_plugin = "fugitive",
}

require('Comment').setup{
  opleader = {
    block = 'gB',
  }
}

require'glance'.setup {
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

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,              -- false will disable the whole extension
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

require"octo".setup{
  enable_builtin = true
}

require'nvim-web-devicons'.setup {
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
 };
 -- globally enable different highlight colors per icon (default to true)
 -- if set to false all icons will have the default icon's color
 color_icons = true;
 -- globally enable default icons (default to false)
 -- will get overriden by `get_icons` option
 default = true;
 -- globally enable "strict" selection of icons - icon will be looked up in
 -- different tables, first by filename, and if not found by extension; this
 -- prevents cases when file doesn't have any extension but still gets some icon
 -- because its name happened to match some extension (default to false)
 strict = true;
 -- same as `override` but specifically for overrides by filename
 -- takes effect when `strict` is true
 override_by_filename = {
  [".gitignore"] = {
    icon = "",
    color = "#f1502f",
    name = "Gitignore"
  }
 };
 -- same as `override` but specifically for overrides by extension
 -- takes effect when `strict` is true
 override_by_extension = {
  ["log"] = {
    icon = "",
    color = "#81e043",
    name = "Log"
  }
 };
}

require'lspconfig'.elixirls.setup{
    -- sadly the below path cannot be expanded
    cmd = { "/Users/petur/nvim-lsp/elixir/elixir-ls-v0.16.0/language_server.sh" };
}
require'lspconfig'.tsserver.setup {}
require'lspconfig'.volar.setup {}
-- require'lspconfig'.pyright.setup{}
-- require'lspconfig'.vuels.setup{}
-- require'lspconfig'.eslint.setup{}
EOF

source ~/dotfiles/vimrc-keybindings.vim
source ~/dotfiles/vimrc-functions.vim
source ~/dotfiles/vimrc-general-variables.vim
source ~/dotfiles/vimrc-autocommands.vim
