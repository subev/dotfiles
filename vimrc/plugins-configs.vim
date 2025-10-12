  " LSP related keybindings
  nnoremap ,r :lua vim.lsp.buf.rename()<CR>
  nnoremap <silent> <F7> :LspRestart<CR>
  nnoremap <silent> <space><space> <cmd>lua vim.lsp.buf.hover()<CR>

  "settings for 'github/copilot.vim'
  imap <silent><script><expr> <c-cr> copilot#Accept("")
  let g:copilot_no_tab_map = v:true
  imap <C-n> <Plug>(copilot-next)
  imap <C-p> <Plug>(copilot-previous)

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
  nnoremap gb :G blame --date=relative<cr>
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

  nnoremap <space>6 :<C-U>call RgFileReferences()<CR>
  nnoremap <space>8 :<C-U>call RgXDefault(0)<CR>
  vnoremap <space>` y:CustomBLines <c-r>"<cr>

  nnoremap g1 :<C-U>call MergeKeepLeft()<CR>

  function! RgXDefault(bang) abort
    " Full absolute path of current buffer
    let l:abs = expand('%:p')
    if empty(l:abs)
      echoerr "RgX: current buffer has no file"
      return
    endif

    " Basename without extension -> initial search pattern
    let l:tail = expand('%:t')
    let l:pattern = substitute(l:tail, '\..*$', '', '')
    if empty(l:pattern)
      echoerr "RgX: cannot determine file basename"
      return
    endif

    " Try to compute path relative to git root (if in a git repo),
    " otherwise relative to vim's cwd (:pwd).
    let l:rel = ''
    let l:git_top = systemlist('git rev-parse --show-toplevel 2>/dev/null')
    if !empty(l:git_top) && v:shell_error == 0
      let l:git_top = substitute(l:git_top[0], '/\+$', '', '')
      " only strip git root if the file path starts with it
      if stridx(l:abs, l:git_top) == 0
        let l:rel = l:abs[len(l:git_top) + 1 : ]     " path after git root + slash
      endif
    endif

    " fallback to relative to current working directory
    if empty(l:rel)
      let l:rel = fnamemodify(l:abs, ':.')
    endif

    " Normalize Windows backslashes to forward slashes (rg expects /)
    let l:rel = substitute(l:rel, '\\\\', '/', 'g')

    " Anchor the exclusion to the search root (leading slash) so we exclude exactly that file:
    let l:exclude_glob = '--glob ' . shellescape('!/' . l:rel)

    " Build rg command: pattern after -- (safe quoting)
    let l:rg_cmd = 'rg --column --line-number --no-heading --color=always -s -F '
    let l:rg_cmd .= l:exclude_glob . ' -- ' . l:pattern
    echom l:rg_cmd

    " Call fzf.vim's grep wrapper with preview (pass the bang flag through)
    call fzf#vim#grep(l:rg_cmd, fzf#vim#with_preview(), a:bang)
  endfunction

  " Command accepts a bang; only allow no-args use (as requested)
  command! -bang -nargs=0 RgX call RgXDefault(<bang>0)

  function! RgFileReferences()
    let currentExtension = expand('%:e')
    if currentExtension == 'vue' || currentExtension == 'jsx' || currentExtension == 'tsx'
      execute ':Rg <' . expand('%:t:r') . '\b'
    else
      execute ':Rg ' . expand('%:t:r') . '\('
    endif
  endfunction

  "more useful commands https://github.com/junegunn/fzf.vim#commands

  command! -bang -nargs=* CustomBLines
  \ call fzf#vim#grep(
  \   'rg --with-filename --column --line-number --no-heading --smart-case . '.fnameescape(expand('%:p')), 1,
  \   fzf#vim#with_preview({'options': '--no-sort --layout reverse --query '.shellescape(<q-args>).' --with-nth=4.. --delimiter=":"'}, 'right:50%'))

  inoremap <expr> <c-x><c-f> fzf#vim#complete#path('rg --files')

  "THE BEST FONT IS 1) Meslo 2) Hack
  "settings for 'nvim-tree/nvim-web-devicons'
  " octo is a github pr review plugin
  "settings for 'pwntester/octo.nvim'

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

