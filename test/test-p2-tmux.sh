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
    $HOME/pds/bin/vi -c '! echo $VIMRUNTIME>foo1' -c 'q'
    ls -lts $HOME/pds/bin/nvimfs/usr/share/nvim/runtime/ftplugin/man.vim
    TSC "alias man='pds vman'"
    TSC man
    ✔️ shows 'What manual page do you want'
    TSK "set -x"
    TSK "man ls"
    ✔️ max 1.4 shows "SYNOPSIS"
    vi_quit
    TSK "set +x"
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

function test-pds-plugs-list {
    TSK 'pds s plugins-list'
    sleep 0.05
    TSK "'mason-null-ls.nvim"
    sleep 0.05 # time for fzf
    📷
    T send-keys Enter
    TSC pwd
    ✔️ shows "$HOME/.local/share/nvim/site/pack/packer/opt/mason-null-ls.nvim"
}

return 2>/dev/null || test_in_tmux "$@"
