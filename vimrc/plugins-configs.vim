  " LSP related keybindings
  nnoremap ,r :lua vim.lsp.buf.rename()<CR>
  nnoremap <silent> <F7> :LspRestart<CR>
  nnoremap <silent> <space><space> <cmd>lua vim.lsp.buf.hover()<CR>


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

  "settings for 'michaeljsmith/vim-indent-object'
  " remap to my own needs since you cannot remap the built in ones
  omap ai aI
  vmap ai aI

  " settings for 'jeetsukumaran/vim-indentwise'
  nmap { [%
  nmap } ]%

  "settings for 'dnlhc/glance.nvim'
  nmap <silent> ,d :Glance definitions<cr>
  nmap <silent> gti :Glance implementations<cr>
  nmap <silent> gr :Glance references<cr>
  nmap <silent> gT :Glance type_definitions<cr>
  nmap <silent> <space><backspace> :Glance references<cr>

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
  noremap ,gd :DiffviewOpen<CR>
  noremap ,gh :DiffviewFileHistory %<cr>
  noremap ,gm :DiffviewOpen origin/<C-r>=GetMasterBranchName()<CR>...HEAD<cr>

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

  nmap <expr> - (foldclosed(line(".")) == -1) ? 'za':'zA'
  " this was manual way of setting folding, no longer needed because there is nvim-ufo plugin as provided
  vnoremap - zf
  nmap _ zc

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

  nnoremap <silent> <space>l :Lspsaga code_action<CR>
  nnoremap <space>u :Lspsaga outgoing_calls<CR>
  nnoremap <space>U :Lspsaga incoming_calls<CR>
