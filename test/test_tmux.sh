#!/usr/bin/env bash
set -o errexit
source test/tools.sh
# ✔️ pds status \| grep mytest - 'must be still available'
# ❌ test -e "$tf"
#
function plugs-list {
    TSK 'pds plugins-list'
    TSK "'mason-null-ls.nvim"
    📷
    T send-keys Enter
    TSC pwd
    ✔️ shows "$HOME/.local/share/nvim/site/pack/packer/opt/mason-null-ls.nvim"
}

M1='# Head1
intro
## H2
h2 stuff
## H3
h3 stuff
'

function markdown_folds {
    open 'm1.md' "$M1"
    sleep 1
    ✔️ shows intro
    ✔️ shows H2
    ✔️ shows H3
    ❌ shows 'h2 stuff'
    ❌ shows 'h3 stuff'
}

function tests {
    tst plugs-list
    tst markdown_folds
    echo foo
}

test_in_tmux "$@"
