#!/usr/bin/env bash
set -e

function test_bootstrap {
    cd
    wget https://raw.githubusercontent.com/AXGKl/pds/master/setup/pds.sh
    chmod +x 'pds.sh'
    ./pds.sh
    ./pds.sh install
    export PATH="$HOME/pds/bin:$PATH"
    vi --version | grep NVIM
}

function main {
    (test_bootstrap)

}

main "$@"
