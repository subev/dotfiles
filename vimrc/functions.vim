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

  function! FindImport()
    let lastsearch = @/
    let @/ = '^import '
    normal! gg
    call search(@/, 'c')
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

  function! DiffFoldLevel()
    let l:line=getline(v:lnum)

    if l:line =~# '^diff --git'
      return '>1'
    elseif l:line =~# '^commit'
      return '<1'
    else
      return '='
    endif
  endfunction

  function! MoveFile(newfile)
    let oldfile = expand('%')
    execute 'saveas ' . a:newfile
    if filereadable(oldfile)
      execute '!rm ' . shellescape(oldfile)
      echo "Moved " . oldfile . " to " . a:newfile
    else
      echo "Error moving file!"
    endif
  endfunction

  command! -nargs=1 MoveFile call MoveFile(<q-args>)

  function! GetMasterBranchName()
   let l:main_exists = system('git branch --list main')
   if l:main_exists =~ 'main'
    return 'main'
   else
    return 'master'
   endif
  endfunction

  command! -nargs=1 Redir silent call Redir(<f-args>)

  function! UpdateMappingBasedOnFile(filename)
      if filereadable(a:filename)
        nnoremap <buffer> <Space>tt :call CocAction('runCommand', 'vitest.singleTest')<CR>

        nnoremap <buffer> <Space>tC :call CocAction('runCommand', 'vitest.fileTest')<CR>
        nnoremap <buffer> <Space>tc <c-w>v:<C-U>call OpenTerminalAndRunVitestForCurrentFileAndWatch()<CR>

        nnoremap <buffer> <Space>ta <c-w>v:<C-U>call OpenTerminalAndRunVitestForCurrentFileAndWatch('all')<CR>G
        nnoremap <buffer> <Space>tA :call CocAction('runCommand', 'vitest.projectTest')<CR>
      endif
  endfunction

  function! OpenTerminalAndRunVitestForCurrentFileAndWatch(...)
    if a:0 > 0 && a:1 == 'all'
      :terminal npm run test:unit -- --watch
    else
      let $currentFP=expand('%:p')
      :terminal npm run test:unit $currentFP -- --watch
    endif
  endfunction

  autocmd BufEnter,BufWinEnter * call UpdateMappingBasedOnFile('vitest.config.ts')

" }}}
