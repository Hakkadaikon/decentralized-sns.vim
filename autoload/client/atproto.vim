" atproto.vim
"
" use indigo: https://github.com/bluesky-social/indigo

let s:cli_path  = "./indigo/gosky"
let s:auth_path = "./auth.json"
let s:pds_host  = "https://bsky.social"

function! s:set_env() abort
  let s:env_path ="./env.sh"
  call system(s:env_path)
endfunction

function! s:get_feed_array() abort
  let l:feed_cmd        = s:cli_path . " --pds-host=" . s:pds_host . " --auth=" . s:auth_path . " bsky get-feed --raw"
  let l:feed_json       = system(feed_cmd)
  let l:feed_json_array = '[' . substitute(l:feed_json, '}\n{', '},{', 'g') . ']'
  let l:decoded_feed    = json_decode(l:feed_json_array)
  return l:decoded_feed
endfunction

function! s:create_buffer()
  silent noautocmd split __Nostr_TL__
  setlocal buftype=nofile bufhidden=wipe noswapfile
  setlocal wrap nonumber signcolumn=no filetype=markdown
  wincmd p
  return bufwinid("__Nostr_TL__")
endfunction

function! s:draw(winid, rows) abort
  call win_execute(a:winid, 'setlocal modifiable', 1)
  call win_execute(a:winid, 'normal! G', 1)
  call win_gotoid(a:winid)
  call ui#chat#draw(a:winid, a:rows)
  call win_execute(a:winid, 'setlocal nomodifiable nomodified', 1)
endfunction

function! s:convert_feed_to_row(feed) abort
  return {
  \"text": a:feed["post"]["record"]["text"],
  \"user": {
  \  "name": a:feed["post"]["author"]["displayName"],
  \  "screen_name": a:feed["post"]["author"]["handle"],
  \  "url": "https://bsky.social/" . a:feed["post"]["author"]["handle"],
  \},
  \"metadata": {
  \  "created_at_str": a:feed["post"]["record"]["createdAt"],
  \},
  \"reactions": [
  \  {
  \    "action": "👍",
  \    "count": a:feed["post"]["likeCount"],
  \  }
  \]
  \}
endfunction

function! s:main() abort
  let s:winid      = s:create_buffer()
  let s:feed_array = s:get_feed_array()
  let s:rows       = []

  for feed in s:feed_array
    if !has_key(feed, "post")
      continue
    endif

    let s:row  = s:convert_feed_to_row(feed)
    let s:rows += [s:row]
    call s:draw(s:winid, s:rows)
  endfor
endfunction

call s:main()
