#!/usr/bin/env bash
set -o errexit
source test/tools.sh
function bootstrap_nvim_again {
    cd
    rm -rf pds.sh
    ✔️ wget "https://raw.githubusercontent.com/AXGKl/pds/master/setup/pds.sh"
    ✔️ chmod +x 'pds.sh'
    🚫 ./pds.sh install
}
function install_idempotent {
    ✔️ pds i \| grep LSP \| grep tsserver
    ✔️ eval '[[ "'${test_dt}'" -lt 60 ]]' - "reinstall took too long"
}
function pds_avail { ✔️ pds; }
function vi_avail { ✔️ pds vi --version \| grep 'NVIM\ v'; }
function pds_no_args {
    ✔️ pds \| grep SWITCHES
    ✔️ pds \| grep FUNCTIONS
    ✔️ pds \| grep ACTIONS
    🚫 pds \| grep nopie
}
function help_short {
    ✔️ pds -h \| grep SWITCHES
    ✔️ pds -h \| grep -q -v 'ACTION\ DETAILS'
}
function help_long {
    ✔️ pds --help \| grep SWITCHES
    ✔️ pds --help \| grep 'ACTION\ DETAILS'
}
function stash {
    local d="$HOME/.local/share/stashed_nvim"
    rm -rf "$d/mytest"
    ✔️ pds stash mytest
    ✔️ test -e "$d/mytest/nvim/init.lua"
    ✔️ test -d "$d/mytest/share"
    ✔️ test -d "$d/mytest/state"
    🚫 test -d "$HOME/.config/nvim" - "nvim dir still present"
    🚫 test -d "$HOME/.local/state/nvim" - "nvim state dir still present"
    🚫 test -d "$HOME/.local/share/nvim" - "nvim share dir still present"
    🚫 pds stash mytest - "could restash with same name"
}
function clean-all {
    ✔️ pds clean-all -f
    🚫 test -d "$HOME/.config/nvim" - "nvim dir still present"
    🚫 test -d "$HOME/.local/state/nvim" - "nvim state dir still present"
    🚫 test -d "$HOME/.local/share/nvim" - "nvim share dir still present"
}
function restore {
    local d="$HOME/.local/share/stashed_nvim"
    local tf="$HOME/.local/share/nvim/foo"
    touch "$tf"
    ✔️ pds restore mytest
    ✔️ test -e "$HOME/.config/nvim/init.lua"
    ✔️ test -e "$d/mytest/nvim/init.lua"
    ✔️ pds status \| grep mytest - 'must be still available'
    🚫 test -e "$tf"
}

function plugs-list {
    ✔️ echo list

}
function main {
    # Testing process calls. THESE MUST BE RUN IN ORDER (after bootstrap)
    # You may comment out previous steps though, when testing locally.
    test_match="${1:-}"
    #
    tst bootstrap_nvim_again
    tst install_idempotent
    tst pds_avail
    tst vi_avail
    tst pds_no_args
    tst help_short
    tst help_long
    tst stash
    tst clean-all
    tst restore
}

main "$@"
