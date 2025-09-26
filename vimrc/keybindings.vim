" General Keybindings ---{{{
  noremap <C-S> :w<CR>
  inoremap <C-S> <C-O>:w<CR><Esc>
  nnoremap <PageUp> <C-u>
  nnoremap <PageDown> <C-d>

  noremap <S-CR> <Esc>
  nnoremap U <C-R>
  vnoremap U gU

  "provide alternative to use COUNT
  nnoremap <silent> 2 :w<CR>
  nnoremap <silent> 3 :let @/='\C\<' . expand('<cword>') . '\>'<CR>:let v:searchforward=0<CR>n
  nnoremap 4 $
  vnoremap 4 $h
  nmap 5 %
  vmap 5 %
  nnoremap 6 ^
  vnoremap 6 ^
  nnoremap <silent> 8 :let @/='\C\<' . expand('<cword>') . '\>'<CR>:let v:searchforward=1<CR>n
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

  onoremap <space> iW
  onoremap a<space> aW

  nnoremap v<space> viW
  nnoremap c<space> ciW
  nnoremap d<space> daW

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
  nnoremap Y :%y+<CR>

  " duplicate visual selection and move the cursor to the pasted text bellow
  vnoremap Y ygv']<esc>o<esc>p
  " visually select the whole file and replace it with the content of the default register
  " nnoremap vap ggVGp
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

  " disable the highlight search or search for the word under the cursor
  nnoremap <silent> <expr> <cr> (v:hlsearch == 1) ? ':noh<cr>' : ":let @/ = '\\C\\<'.expand('<cword>').'\\>'<cr>:set hlsearch<cr>"
  "search for the visually selected text
  vnoremap <cr> y:let @/='<C-R>"'<CR>:let v:searchforward=1<CR>:set hlsearch<CR>

  nnoremap <f5> :e!<CR>
  " preview current file with Google Chrome
  nnoremap <space>7 :silent ! open -a 'Google Chrome' %:p<cr>
  "nnoremap <space>g y:silent ! open -a 'Google Chrome' 'http://google.com/search?q='<left>
  vnoremap <space>g y:silent ! open -a 'Google Chrome' 'http://google.com/search?q=<c-r>"'<CR>
  " add a breakpoint above the current line and test just current file with node
  nnoremap <space>td Odebugger<esc>:w<cr>:! open -a 'Google Chrome' 'chrome://inspect/'<CR>:!node --inspect-brk node_modules/.bin/jest --runInBand --no-cache --config jest.config.js -- %<CR>
  " update snapshot of current file
  nnoremap <space>tu :!npm run test:unit -- -u %<CR>

  "execute current buffer or current selection in via ts-node (ignoring erros)

  "sudo overwrite protect file
  cmap w!! w !sudo tee > /dev/null %

  set backspace=indent,eol,start " make backspace behave consistently with other apps

  " delete trailing whitespace
  nnoremap <silent> <leader>q :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

  " quick-paste last yanked text
  noremap ; "0p
  vmap gp <c-n>\\CP<esc>
  vmap gm <c-n>\\C
  noremap gj <S-j>

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
  nnoremap gi :<C-U>call FindImport()<CR>

  ""replace word under cursor
  "nnoremap ,r :%s/\<<C-r><C-w>\>//g<Left><Left>
  "close window
  noremap Q q
  noremap q <C-w>c
  "create new vertical split
  noremap ,n :vnew<CR>
  nnoremap <space>4 <c-6>

  nnoremap ,o <c-w>\|
  nnoremap ,O <c-w>o
  nnoremap ,t <c-w>v:term<cr>i
  nnoremap ,T <c-w>v:term<cr>inpm run typecheck<cr>
  nnoremap ,gl <c-w>v:term<cr>igit ls<cr>
  nnoremap ,gP :lua git_log_patches()<CR>()<CR>
  nnoremap ,gL :lua git_log_file()<CR>()<CR>
  " starts a terminal with with the command `gitco` which is located inside ~/dotfiles/workflows.sh
  nnoremap ,G :vsplit<CR>:term<CR>igitco<CR>
  " same as above but maximizes the window first
  " nnoremap ,G :vsplit<CR>:term<CR><C-w>\|<CR>igitco<CR>
  nnoremap ,gN :lua git_diff_main()<CR>()<CR>

  " add space after
  noremap <Space>a a<Space><Esc>h
  " add space before
  noremap <Space>i i<Space><Esc>l

  "jump to the closest opening bracket of type {
  " nnoremap { [{

  nnoremap <Tab> >>
  nnoremap <S-Tab> <<
  vnoremap <Tab> >gv
  vnoremap <S-Tab> <gv

  noremap <C-e> 8<C-e>
  noremap <C-y> 8<C-y>

  noremap <D-j> 8<C-e>
  noremap <D-k> 8<C-y>
  nnoremap vv <C-w>

  "yank current relative path from cwd to clipboard
  nnoremap yp :let @+ = expand('%')<CR>
  "yank just the file name to clipboard
  nnoremap yF :let @+ = expand('%:t')<CR>
  "yank just the file name without extension to clipboard
  nnoremap yf :let @+ = expand('%:t:r')<CR>

  "go to sibling style file
  nnoremap gts :e <C-R>=expand('%:r') . '.scss'<CR><CR>
  "go to tsx
  nnoremap gtt :e <C-R>=expand('%:r') . '.tsx'<CR><CR>
  "go to js
  nnoremap gtj :e <C-R>=expand('%:r') . '.js'<CR><CR>
  "go migrate flow and go to tsx
  nmap gtf :!flow-to-ts %:p -o tsx<cr>:e <C-R>=expand('%:r') . '.tsx'<CR><CR>

  nnoremap <Space>te <c-w>v:terminal npm run test:e2e<CR>

  noremap <leader>ve :e $MYVIMRC<CR>
  noremap <leader>vE :vsplit $MYVIMRC<CR>
  noremap <leader>vu :source %<CR>

  tnoremap <ESC><ESC> <C-\><C-N>
  nnoremap gf <C-w>F<C-W>H " if the file exists open it in a vertical split on the left most window

  " Settings for VimDiff as MergeTool
  if &diff
    noremap <leader>1 :diffget LOCAL<CR>
    noremap <leader>2 :diffget BASE<CR>
    noremap <leader>3 :diffget REMOTE<CR>
    colorscheme darkBlue
  endif
" }}}
