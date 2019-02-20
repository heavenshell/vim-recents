let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_recent') && g:loaded_recent
  finish
endif
let g:loaded_recent = 1

command! Recents :call recents#run()
noremap <silent> <buffer> <Plug>(Recents)  :Recents<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
