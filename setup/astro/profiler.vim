" source this file to get profiling started
:profile start profile.log
:profile func *
:profile file *
" At this point do slow actions
:lua require("notify")("Will create profile.log. Stop profiling via :profile pause")

