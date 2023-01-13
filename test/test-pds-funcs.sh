#!/usr/bin/env bash
set -o errexit
. "$(dirname "$0")/tools.sh"
pds="$HOME/.config/pds/setup/pds.sh"

function test-pds-act-add-path {
    local v p; p="$PATH"; v="$HOME/pds/bin"
    export PATH=/usr/bin:/usr/sbin
    . "$pds" a eval 'echo $PATH' >/dev/null
    echo "$PATH" | grep -q "$v"
    export PATH="$p"
}

function test-pds-run-any {
    local p; p="$PATH"
    export PATH=/usr/bin:/usr/sbin
    . "$pds" env | grep 'PATH' | grep -q "$HOME/pds/bin:$PATH" || return 1
    export PATH="$p"
}

function test-pds-source-not-all {
     . "$pds" xfoox 2>/dev/null && return 1
     type Install 2>/dev/null && return 1 || return 0
}

function test-pds-tools-exact-match {
    local s="$SHELL" d="$(pwd)"
    SHELL=echo
    . "$pds" s cd-swaps
    pwd | grep -q '/nvim/swap' || return 1
    cd "$d"; SHELL="$s"
}

function test-pds-plugs-list {
    TSK 'pds t plugins-list'
    TSK "'mason-null-ls.nvim"
    📷
    T send-keys Enter
    TSC pwd
    ✔️ shows "$HOME/.local/share/nvim/site/pack/packer/opt/mason-null-ls.nvim"
}
#test_in_tmux "$@"
tst test-pds-tools-exact-match 
tst test-pds-act-add-path
tst test-pds-run-any
tst test-pds-source-not-all
echo ok
