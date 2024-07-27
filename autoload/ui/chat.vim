" chat.vim

" row's structure is bellow
"
" {
"   "text": "hello\nmy name is godzilla",
"   "user": {
"     "name": "godzilla",
"     "screen_name": "ゴジラ",
"     "url": "https://example.com/godzilla",
"   },
"   "metadata": {
"     "created_at_str": "2024-01-01 01:00:00",
"   },
"   "reactions": [
"     {
"       "action": "👍",
"       "count": 1,
"     },
"     {
"       "action": "😂",
"       "count": 4,
"     },
"   ]
" }
function! ui#chat#draw(winid, rows) abort
  let found = win_gotoid(a:winid)
  " if not found specified window, do nothing
  if found ==# 0
    return
  endif

  let b:rows = a:rows

  call s:draw()
  call s:define_plugin_keymaps()
endfunction

function! s:draw() abort
  setlocal modifiable
  let start = 1
  let idx = 0
  for row in b:rows
    let line = s:make_lines(row)
    let end = start + len(line)
    let row.position = {
          \ 'idx': idx,
          \ 'start': start,
          \ 'end': end-1,
          \ }
    call setline(start, line)
    let start = end
    let idx += 1
  endfor
  setlocal nomodifiable
endfunction

function! s:make_lines(row) abort
  let width = ui#window#width()
  let message = split(a:row.text, "\n")

  let row = a:row
  if has_key(a:row, "rerowed_status")
    let row = a:row.rerowed_status
  endif

  let reactions = join(map(copy(a:row.reactions), { _, reaction -> reaction.action .. "" .. reaction.count }), " ")

  let metadata = join(values(row.metadata), " ")

  let head = join([
        \   a:row.user.name,
        \   a:row.user.screen_name,
        \   metadata
        \ ], " | ")

  let lines = [
        \ head,
        \ "",
        \ ]

  let lines += message

  let lines += [
        \ "",
        \ reactions,
        \ repeat("─", width),
        \ ]

  return lines
endfunction

function! ui#chat#row() abort
  let position = line(".")
  let rows = filter(copy(b:rows),  
        \ { _, row -> 
        \   row.position.start <= position && 
        \   position <= row.position.end
        \ }
        \)
  if len(rows) == 0
    return {}
  endif
  return rows[0]
endfunction

function! ui#chat#rows() abort
  return b:rows
endfunction

function! ui#chat#message_prev() abort
  let cur = ui#chat#row()
  if empty(cur)
    return
  endif
  let idx = cur.position.idx-1
  if 0 > idx
    return
  endif

  let prev = b:rows[idx]
  call cursor([prev.position.start, 0])
endfunction

function! ui#chat#message_next() abort
  let cur = ui#chat#row()
  if empty(cur)
    return
  endif

  let idx = cur.position.idx+1
  if len(b:rows) <= idx
    return
  endif

  let next = b:rows[idx]
  call cursor([next.position.start, 0])
endfunction

function! s:define_plugin_keymaps() abort
  nnoremap <buffer> <silent> <Plug>(ui:chat:next)
        \ <Cmd>call ui#chat#message_next()<CR>

  nnoremap <buffer> <silent> <Plug>(ui:chat:prev)
        \ <Cmd>call ui#chat#message_prev()<CR>
endfunction
