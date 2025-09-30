" AutoCommands {{{
  augroup autocommands
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

    au FileType ctrlsf nnoremap <silent><buffer> <space>` :BLines<cr>
    au FileType ctrlsf vnoremap <silent><buffer> <space>` y:BLines <c-r>"<cr>
    au FileType ctrlsf nnoremap <silent><buffer> gn n

    au FileType fugitive nnoremap <buffer> 2 2
    au FileType fugitive nnoremap <buffer> 3 3
    "use 'ours' when merge conflict
    au FileType fugitive nmap <buffer> g1 2X
    "use 'theirs' when merge conflict
    au FileType fugitive nmap <buffer> g3 3X
    au FileType fugitive nmap <buffer> o gO<right>q<left>
    au FileType fugitive nmap <buffer> f<space> :G fetch<cr>
    au FileType fugitive nmap <buffer> g<space> :G<space>
    au FileType fugitive nmap <buffer> sm<space> :G switch master<cr>

    au FileType fzf imap <buffer> <esc> <c-c>

    au FileType csv nnoremap <buffer> <Space><Space> :WhatColumn!<CR>

    au FileType gitcommit setlocal spell
    "disable continuous comments vim
    au FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
    " enable vim motions to work while writing in bulgarian
    au BufEnter *.bg.* setlocal keymap=bulgarian-phonetic
    au FileType help setlocal number
    au FileType vim setlocal shiftwidth=2
    au FileType vim vnoremap <buffer> <Space>= :<C-u>@*<CR>
    "execute current buffer or current selection in via ts-node (ignoring erros)
    au FileType typescript,javascript,vue vnoremap <space>= :lua visual_selection_to_node()<CR>
    " same as above but for normal mode, we first select the whole buffer
    au FileType typescript,javascript,vue nnoremap <space>= ggVG:lua visual_selection_to_node()<CR>
:
    au FileType git nmap <buffer> o gO
    au FileType git setlocal foldmethod=expr foldexpr=DiffFoldLevel() foldlevel=0 foldenable
    au FileType git nmap <buffer> <expr> - (foldclosed(line(".")) == -1) ? 'za':'zA'
  augroup end
" }}}

" Vimscript file settings {{{
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END
" }}}
