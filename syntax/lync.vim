if exists("b:current_syntax")
    finish
endif

let b:current_syntax="lync"

syntax match lync_timestamp "\v.*: \(\d\d:\d\d [AP]M\)$"
highlight link lync_timestamp Comment
