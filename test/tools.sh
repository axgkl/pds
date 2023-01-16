# # Most tools for tmux mode sourced from pds.sh itself.
# function fn_tmux_log { test -z "${tmux_sock:-}" && echo '/dev/null' || echo "$tmux_sock.log"; }
# # if we need a joint file
# function fn_tres_log { test -z "${tmux_sock:-}" && echo '/dev/null' || echo "$tmux_sock.res.log"; }
#fn_tmux_err_exit="/tmp/pds.tmux.$UID.err"
fn_vi_file="/tmp/pds.vi.$UID"

function shows {
    C | grep "$1"
}
function print {
    echo -e "$*" # | tee -a "$(fn_tmux_log)"
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
    echo -e 'tst_die. will exit 1'
    set +x
    C
    #tail -n 100 "${tmux_cmds_log:-}" || true
    out 196 "Failed" "${cur_test:-}"
    test -n "$1" && echo -e "$*"
    echo 'Run "pds att" to see the error'
    exit 1
}

function all_testfuncs {
    for t in $(grep '^function test-' <"$1" | cut -d ' ' -f 2); do "$2" "$t"; done
}

function test_in_tmux {

    export wait_dt=0.01
    export test_mode=true
    rm -f "$HOME"/.local/state/nvim/swap/%tmp%pds.vi*
    . "$HOME/.config/pds/setup/pds.sh" source
    q 12 T ls || sh start_tmux # don't kill when running, want to retest
    hint 'tmux started'
    test_match="${1:-}"
    all_testfuncs "$0" tst
    safe_quit_vi
}

function pds { source "$HOME/.config/pds/setup/pds.sh" "$@"; }

function tst {
    cur_test="$1"
    grep -q "${test_match:-}" <<<"$cur_test" || {
        out 125 "Skipped" "$cur_test"
        return
    }
    out 119 "Test" "$*"
    "$@" || exit 1
}
tst_tries=1
tst_dt=0.1
function parse_args() {
    test "$1" = "max" && {
        tst_tries=10
        tst_dt="$(bc <<<"scale=3; $2 / $tst_tries")"
        shift 2
    }
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
function ico { $fail && echo -n '🚫' || echo -n '✅ '; }
function testit {
    print "\x1b[37;2m[$(ico)] ${cmd[*]} $asserts\x1b[0m"
    if [[ -n "$asserts" ]]; then
        eval "${cmd[*]} $asserts"
    else
        "${cmd[@]}"
    fi
    local ret="$?"
    if [[ "$fail" == "true" && "$ret" != "0" ]]; then
        return
    fi
    if [[ "$fail" == "false" && "$ret" == "0" ]]; then
        return
    fi
    return 1
}

function open {
    # puts given content into a file with given name then opens vi on it
    local fn="$fn_vi_file.$1"
    # default (no other currently supported): 4 deindent (for folding) and first line removed:
    echo -e "$2" | tail -n +2 | sed -e 's/^    //g' >"$fn"
    TSK 'pds vi "'$fn'"'
    wait_dt=0.2 wait_for 'C | grep "'$3'"' || tst_die "Opening the file I did not even see '"$3"'"
}

function vi_quit {
    sleep 0.1
    TSK ':q!'
    TSC echo 'vi done' # the && touch done will be failing if not on shell again
}
function set_test_dt {
    test_dt=$(($(date +%s) - test_start))
}

function tst_loop {
    # sometimes max is given, then we have to loop
    local test_start
    test_start=$(date +%s)
    parse_args "$@"
    for i in $(seq $tst_tries); do
        #date -I"ns"
        testit && set_test_dt && return
        sleep $tst_dt
    done
    set_test_dt
    $fail || tst_die "Failed: $errmsg"
    tst_die "Should have failed: $errmsg"
}

# shellcheck disable=SC1083
function ✔️ { fail=false && tst_loop "$@"; }
function 🚫 { fail=true && tst_loop "$@"; }
function ⌨️ { TSK "$@"; }
# shellcheck disable=SC1083
function 📷 { #C is capture (pds.sh)
    #C | sed -r "/^\r?$/d;s/^/out: /g" | tee -a "$captures"
    (
        echo -e "\x1b[32m📷\x1b[0m\x1b[48;5;242m"
        C | sed -r "/^\r?$/d;s/^/| /g "
        echo -e "\x1b[0m"
    ) | tee -a "$captures"
}
