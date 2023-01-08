#!/usr/bin/env bash
set -o errexit

out() {
    local col="$1"
    shift
    local t="$1"
    shift
    echo -e "\x1b[1;48;5;${col};30m $t \x1b[1;48;5;255m $* \x1b[0m"
}
function die {
    set +x
    out 196 "Failed" "${cur_test:-}"
    test -n "$1" && echo -e "$*"
    exit 1
}

function pds { source "$HOME/.config/pds/setup/pds.sh" "$@"; }

function tst {
    cur_test="$1"
    grep -q "$test_match" <<<"$cur_test" || {
        out 125 "Skipped" "$cur_test"
        return
    }
    out 119 "Test" "$*"
    "$@" || exit 1

    #     ("$@") && {
    #         echo -e "✔️ $*"
    #         return
    #     } || true
    #     out 125 "Error. Running again, traced: $*"
    #     rerurn=true
    #     "$@"
    #     exit 1
}

function parse_args() {
    cmd=()
    asserts=''
    assertmode=false
    errmsg="$*"
    while test -n "$1"; do
        test "$1" == "|" && {
            assertmode=true
        }
        test "$1" == "-" && {
            shift
            errmsg="$1"
            break
        }
        $assertmode && asserts=''$asserts' '$1'' || cmd+=("$1")
        shift
    done
}
function testit {
    echo -e "\x1b[37;2m${cmd[*]} $asserts\x1b[0m"
    if [[ -n "$asserts" ]]; then
        eval "${cmd[*]} $asserts"
    else
        "${cmd[@]}"
    fi
}
function ✔️ {
    parse_args "$@"
    testit || die "Failed: $errmsg"
}
function ❌ {
    parse_args "$@"
    testit && die "Should have failed: $errmsg"
    true
}

function bootstrap_nvim {
    cd
    ✔️ wget https://raw.githubusercontent.com/AXGKl/pds/master/setup/pds.sh
    ✔️ chmod +x 'pds.sh'
    ✔️ ./pds.sh install
}
function pds_avail { ✔️ pds; }
function vi_avail { ✔️ pds vi --version \| grep 'NVIM\ v'; }
function pds_no_args {
    ✔️ pds \| grep SWITCHES
    ✔️ pds \| grep FUNCTIONS
    ✔️ pds \| grep ACTIONS
    ❌ pds \| grep nopie
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
    ❌ test -d "$HOME/.config/nvim" - "nvim dir still present"
    ❌ test -d "$HOME/.local/state/nvim" - "nvim state dir still present"
    ❌ test -d "$HOME/.local/share/nvim" - "nvim share dir still present"
    ❌ pds stash mytest - "could restash with same name"
    ✔️ pds restore mytest
    ✔️ test -e "$HOME/.config/nvim/init.lua"
    ✔️ test -e "$d/mytest/nvim/init.lua"
}
function main {
    # THESE MUST BE RUN IN ORDER.
    # You may comment out previous steps though, when testing locally.
    test_match="${1:-}"
    #
    tst bootstrap_nvim
    tst pds_avail
    tst vi_avail
    tst pds_no_args
    tst help_short
    tst help_long
    tst stash

}

main "$@"
