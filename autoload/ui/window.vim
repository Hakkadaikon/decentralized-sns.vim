" window.vim

function! ui#window#width() abort
  let wininfo = getwininfo(win_getid())[0]
  let width = winwidth(0)
  if has_key(wininfo, 'textoff')
    let width += wininfo.textoff
  endif
  return width
endfunction
