#!/usr/bin/env bash
set -e
tst() {
    echo -e "\x1b[1;48;5;119mRunning Test: $*\x1b[0m"
    (source "$HOME/.bashrc" && "$@")
}
function bootstrap_nvim {
    cd
    wget https://raw.githubusercontent.com/AXGKl/pds/master/setup/pds.sh
    chmod +x 'pds.sh'
    ./pds.sh install
}
function vi_avail {
    pds vi --version | grep NXVIM
}
function pds_no_args {
    pds | grep SWITCHES
    pds | grep FUNCTIONS
    pds | grep ACTIONS
}
function help_short {
    pds -h | grep SWITCHES
    pds -h | grep 'ACTION DETAILS'
}
function stash {
    pds stash mytest
    test -d "$HOME/.local/state"

}

function main {
    # THESE MUST BE RUN IN ORDER.
    # You may comment out previous steps though, when testing locally.

    tst bootstrap_nvim
    tst vi_avail
    tst pds_no_args
    tst help_short
    tst stash
}

main "$@"
