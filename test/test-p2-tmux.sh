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
}

return 2>/dev/null || test_in_tmux "$@"
