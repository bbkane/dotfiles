" Language:    Lync
" Maintainer:  Benjamin Kane
" Last Change: 2017-03-17

" This is a small syntax-highlighting file for copy-pasted Microsoft Lync
" conversations. We've since moved on to Slack, but I've always felt smug
" about making one of these, so I'm keeping it

if exists("b:current_syntax")
    finish
endif

let b:current_syntax="lync"

syntax match lync_timestamp "\v.*: \(\d?\d:\d\d [AP]M\)$"
highlight link lync_timestamp Comment
