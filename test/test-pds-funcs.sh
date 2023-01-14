#!/usr/bin/env bash
set -o errexit
. "$(dirname "$0")/tools.sh"
pds="$HOME/.config/pds/setup/pds.sh"

function set-path {
    PORIG="$PATH"
    export PATH=/usr/bin:/usr/sbin
}

function reset-path {
    export PATH="$PORIG"
}

function test-pds-act-add-path-in-subproc {
    . "$pds" a eval 'echo $PATH' | grep pds || exit 1
    grep pds <<<"$PATH" || return 0
    exit 1
}
function test-pds-act-deact-path {
    . "$pds" a
    grep pds <<<$PATH || exit 1
    type vi | grep pds || exit 1
    . "$pds" d
    grep pds <<<$PATH && exit 1 || true
}

function test-pds-source-not-all {
    # only for the defined actions the whole file is being sourced
    . "$pds" xfoox 2>/dev/null && return 1
    type Install 2>/dev/null && return 1 || return 0
}

function test-pds-tools-exact-match {
    local s
    s="$SHELL"
    local d
    d="$(pwd)"
    SHELL="echo"
    . "$pds" s cd-swaps
    pwd | grep -q '/nvim/swap' || return 1
    cd "$d"
    SHELL="$s"
}

function ptst {
    set-path
    tst "$1"
    reset-path
}

all_testfuncs "$0" ptst
