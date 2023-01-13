#!/usr/bin/env bash
## These tests may fail, depending on user config
set -o errexit
. "$(dirname "$0")/tools.sh"

function test-markdown_folds { # initially, folds shall stay open
    M1='# Head1
intro
## H2
h2 stuff
## H3
h3 stuff
## H4
h4 stuff

'
    open 'm1.md' "$M1" Head1
    ✔️ shows intro
    ✔️ shows H2
    ✔️ shows H3
    ✔️ shows 'h4 stuff'
    vi_quit
}

function test-man-pages {
    TSC "alias man='pds vman'"
    TSC man
    ✔️ shows 'What manual page do you want'
    TSK "man ls"
    ✔️ max 0.4 shows "list directory contents"
    vi_quit
}

function test-diag-show-toggle {
    # diag off at start up.
    # have to wait hover timeout vim.o.update
    function diag { shows "Undefined"; }
    M1='class foo(noexist):
    stuff=42'
    open 'p1.py' "$M1" pylsp
    ✔️ shows stuff
    ⌨️ G
    🚫 diag
    ⌨️ gg
    ✔️ max 1 diag
    ⌨️ G
    🚫 max 1 diag
    ⌨️ ' lx' # switch it on
    ✔️ max 1 diag
    vi_quit
}

return 2>/dev/null || test_in_tmux "$@"
