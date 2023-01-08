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
    echo -e "\x1b[37;2m[$1] ${cmd[*]} $asserts\x1b[0m"
    if [[ -n "$asserts" ]]; then
        eval "${cmd[*]} $asserts"
    else
        "${cmd[@]}"
    fi
}
function ✔️ {
    parse_args "$@"
    testit '✅ ' || die "Failed: $errmsg"
}

function ❌ {
    parse_args "$@"
    testit '❌' && die "Should have failed: $errmsg"
    true
}
