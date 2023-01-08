#!/usr/bin/env bash
set -e
function run {
    echo -e "\x1b[1;48;5;119mRunning: $*\x1b[0m"
    ("$@")
}
function test_bootstrap_nvim {
    cd
    wget https://raw.githubusercontent.com/AXGKl/pds/master/setup/pds.sh
    chmod +x 'pds.sh'
    ./pds.sh && ./pds.sh install
    export PATH="$HOME/pds/bin:$PATH"
    vi --version | grep NVIM
}

function main {
    run test_bootstrap_nvim
}

main "$@"
