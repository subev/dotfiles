echom '>>>>>'

function! Mapped(fn, l)
    let new_list = deepcopy(a:l)
    call map(new_list, string(a:fn) . '(v:val)')
    return new_list
endfunction

function! Reversed(l)
    return reverse(a:l)
endfunction

"let mylist = [[1, 2,3, 4]]
"echo Mapped(function("Reversed"), mylist)
let myotherlist = [3,3,4,43,2,2,1,1,1,1,1,1]
echom map(myotherlist, function('Inc')  )

function Inc(x, y, ...) abort
  return string(a:x) . '-' . string(a:y) . '+' . (a:length)
endfunction

