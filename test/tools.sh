# Most tools for tmux mode sourced from pds.sh itself.
function fn_tmux_log { test -z "${tmux_sock:-}" && echo '/dev/null' || echo "$tmux_sock.log"; }
function fn_tres_log { test -z "${tmux_sock:-}" && echo '/dev/null' || echo "$tmux_sock.res.log"; }
fn_tmux_err_exit="/tmp/pds.tmux.$UID.err"
function shows {
    C | grep "$1"
}
function print {
    echo -e "$*" | tee -a "$(fn_tmux_log)"
}

out() {
    local col="$1"
    shift
    local t="$1"
    shift
    print "\x1b[1;48;5;${col};30m $t \x1b[1;48;5;255m $* \x1b[0m"

}
function tst_die {
    # die is in pds.sh
    set +x
    out 196 "Failed" "${cur_test:-}"
    test -n "$1" && echo -e "$*"
    $in_tmux && touch "$fn_tmux_err_exit" && sh kill_tmux_session
    exit 1
}

function test_in_tmux {
    rm -f "$fn_tmux_err_exit"
    . "$HOME/.config/pds/setup/pds.sh" source
    test "$1" == "in_tmux" || {
        run_in_tmux "$0" in_tmux "$@"
        test -e "$fn_tmux_err_exit" && exit 1
        exit 0
    }
    shift
    export in_tmux=true
    tmx_split_pane
    TSC 'function pds { source "$HOME/.config/pds/setup/pds.sh" "$@"; }'
    tst plugs-list
    kill_tmux_session
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
    local test_start ret
    test_start=$(date +%s)
    print "\x1b[37;2m[$1] ${cmd[*]} $asserts\x1b[0m"
    if [[ -n "$asserts" ]]; then
        eval "${cmd[*]} $asserts"
    else
        "${cmd[@]}"
    fi
    ret=$?
    test_dt=$(($(date +%s) - test_start))
    return $ret
}
function ✔️ {
    parse_args "$@"
    testit '✅ ' || tst_die "Failed: $errmsg"
}

function ❌ {
    parse_args "$@"
    testit '❌' && tst_die "Should have failed: $errmsg"
    true
}
