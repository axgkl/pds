#!/usr/bin/env bash
set -o errexit
source test/tools.sh
function bootstrap_nvim {
    cd
    rm -rf pds.sh
    ✔️ wget https://raw.githubusercontent.com/AXGKl/pds/master/setup/pds.sh
    ✔️ chmod +x 'pds.sh'
    ✔️ ./pds.sh install
}
function main {
    tst bootstrap_nvim
}
return 2>/dev/null || true
main "$@"
