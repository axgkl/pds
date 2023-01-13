#!/usr/bin/env bash
set -o errexit
builtin cd "$(dirname "$0")/.."
source test/tools.sh
# ✔️ pds status \| grep mytest - 'must be still available'
# ❌ test -e "$tf"
#
function pds-plugs-list {
    TSK 'pds t plugins-list'
    TSK "'mason-null-ls.nvim"
    📷
    T send-keys Enter
    TSC pwd
    ✔️ shows "$HOME/.local/share/nvim/site/pack/packer/opt/mason-null-ls.nvim"
}
function vi-start-no-err {
    TSK vi
    ✔️ shows "Recents"
    ✔️ shows "Find File"
    ❌ shows 'Error'
}
function markdown_folds {
    M1='# Head1
intro
## H2
h2 stuff
## H3
h3 stuff
'
    open 'm1.md' "$M1"
    sleep 1
    ✔️ shows intro
    ✔️ shows H2
    ✔️ shows H3
    ❌ shows 'h2 stuff'
    ❌ shows 'h3 stuff'
}

function tests {
    tst pds-plugs-list
    tst vi-start-no-err
    tst markdown_folds
}

test_in_tmux "$@"
