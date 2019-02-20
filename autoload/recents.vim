let s:save_cpo = &cpo
set cpo&vim

let s:oldfiles = []
let s:recents = []
let s:regex = '*'
let s:default_winid = 0

function! s:oldfiles()
  let oldfiles = filter(copy(v:oldfiles), {i, v -> filereadable(expand(v))})
  return oldfiles
endfunction

function! s:open(action)
  let bufnum = bufnr('^Recents$')
  let line = line('.') - 1
  let recents = len(s:recents) == 0 ? s:oldfiles : s:recents
  let path = recents[line]
  let ret = win_gotoid(s:default_winid)
  if ret
    execute a:action . path
    " Close
    execute 'bdelete ' . bufnum
    redraw!
  endif
endfunction

function! s:detect(i, v, input)
  let pattern = '\(' . join(split(a:input, ' '), '\|') . '\)'
  if match(a:v, pattern) > 0
    return 1
  endif
  return 0
endfunction

function! s:on_change(input)
  if a:input[0] == ''
    let s:recents = s:oldfiles
  else

    let s:recents = filter(copy(s:oldfiles), {i, v -> s:detect(i, v, a:input[0])})
  endif
  call s:preview(s:recents)
endfunction

function! s:on_enter(input)
  " call s:open('edit')
endfunction

function! s:complete(input)
  let ret = split(glob(a:input[0] . s:regex), "\n")
  return ret
endfunction

function s:prompt()
  call prompter#input({
  \ 'color': 'Normal',
  \ 'prompt': '>>> ',
  \ 'on_complete': function('s:complete'),
  \ 'on_enter':  function('s:on_enter'),
  \ 'on_change':  function('s:on_change'),
  \ })
endfunction

function! s:preview(recents) abort
  let _splitbelow = &splitbelow
  set splitbelow
  let winnum = bufwinnr(bufnr('^Recents$'))
  if winnum != -1
    if winnum != bufwinnr('%')
      execute winnum 'wincmd w'
    endif
  else
    execute 'silent noautocmd 10split Recents'
  endif
  setlocal modifiable
  silent %d

  call setline(1, a:recents)

  setlocal buftype=nofile bufhidden=delete noswapfile
  setlocal nomodified
  setlocal nomodifiable
  nmapclear <buffer>
  auto CursorMoved <buffer> setlocal cursorline
  "syntax clear
  nnoremap <silent> <buffer> <CR> :call <SID>open('edit')<CR>
  nnoremap <silent> <buffer> <C-t> :call <SID>open('tab split')<CR>
  nnoremap <silent> <buffer> <C-x> :call <SID>open('split')<CR>
  nnoremap <silent> <buffer> <C-v> :call <SID>open('vsplit')<CR>
  nnoremap <silent> <buffer> i :call <SID>prompt()<CR>
  nnoremap <silent> <buffer> q :close<cr>
  nnoremap <silent> <buffer> <ESC> :close<cr>
  let &splitbelow = _splitbelow
endfunction

function! recents#run()
  let s:default_winid = win_getid()
  let s:oldfiles = s:oldfiles()
  call s:preview(s:oldfiles)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
