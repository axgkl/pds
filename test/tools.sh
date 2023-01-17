# # Most tools for tmux mode sourced from pds.sh itself.
# function fn_tmux_log { test -z "${tmux_sock:-}" && echo '/dev/null' || echo "$tmux_sock.log"; }
# # if we need a joint file
# function fn_tres_log { test -z "${tmux_sock:-}" && echo '/dev/null' || echo "$tmux_sock.res.log"; }
#fn_tmux_err_exit="/tmp/pds.tmux.$UID.err"
d_vi_file="/tmp/pdstests.$UID"
verbose="${verbose:-false}"

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
    mkdir -p "$d_vi_file"
    rm -f "$HOME"/.local/state/nvim/swap/%tmp*
    . "$HOME/.config/pds/setup/pds.sh" source
    (cd "$d_vi_file" && q 12 git init || true) # lsps are sensitive here
    q 12 T ls || sh start_tmux                 # don't kill when running, want to retest
    test_match="${1:-}"
    all_testfuncs "$0" tst
    q 12 safe_quit_vi
}

function pds { source "$HOME/.config/pds/setup/pds.sh" "$@"; }

function tst {
    cur_test="$1"
    grep -q "${test_match:-}" <<<"$cur_test" || {
        out 125 "Skipped" "$cur_test"
        return
    }
    out 119 "Test" "$*"
    if [[ "$verbose" == "false" ]]; then
        "$@" 2>/dev/null 1>/dev/null || exit 1
    else
        "$@" || exit 1
    fi
}
#tst_tries=1
tst_dt=''
function parse_args() {
    tst_dt=
    test "$1" = "max" && {
        tst_dt="$2"
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

function deindent { echo -e "$1" | tail -n +2 | sed -e 's/^    //g'; }
function open {
    # puts given content into a file with given name then opens vi on it
    local cont fn
    cont="$3"
    # default (no other currently supported): 4 deindent (for folding) and first line removed:
    # disabled with $1=nd
    test "$1" = 'nd' && shift || cont="$(deindent "$2")"
    fn="$d_vi_file/$1"
    echo -e "$cont" >"$fn"
    TSK 'pds vi "'$fn'"'
    sleep 0.05
    T send-keys Escape
    wait_for 'C | grep "'$3'"' || tst_die "Opening the file I did not even see '"$3"'"
}

function vi_quit {
    sleep 0.1
    TSK ':q!'
    TSC "echo 'vi done'" # the && touch done will be failing if not on shell again
}

function now { date +%s%N | cut -b1-13; } # millis

function tst_loop {
    # sometimes max is given, then we have to loop
    local t0 test_end
    t0="$(now)"
    parse_args "$@"
    if [[ -z "$tst_dt" ]]; then
        testit && return
    else
        test_end=$(($(now) + tst_dt + 10)) # 10 millis for the start time
        #echo $(now)
        #echo $test_end
        while true; do
            testit && return
            if [[ $(now) -gt $test_end ]]; then break; fi
            sleep 0.1 # we fix this, since smaller causes trouble with a single cpu runner doing nothing else
        done
    fi
    echo -e "Started: $t0"
    echo -e "Now    : $(now)"
    $fail || tst_die "Failed: $errmsg"
    tst_die "Should have failed: $errmsg"
}

# shellcheck disable=SC1083
function ✔️ { fail=false && tst_loop "$@"; }
function 🚫 { fail=true && tst_loop "$@"; }
function 👁️ { if [ -n "$2" ]; then ✔️ max "$2" shows "$1"; else ✔️ shows "$1"; fi; }
function 😵 { if [ -n "$2" ]; then 🚫 max "$2" shows "$1"; else 🚫 shows "$1"; fi; }

function ⌨️ {
    while test -n "$1"; do
        T send-keys "$1"
        sleep 0.05
        shift
    done
}
# shellcheck disable=SC1083
function 📷 { #C is capture (pds.sh)
    #C | sed -r "/^\r?$/d;s/^/out: /g" | tee -a "$captures"
    (
        echo -e "\x1b[32m📷\x1b[0m\x1b[48;5;242m"
        C | sed -r "/^\r?$/d;s/^/| /g "
        echo -e "\x1b[0m"
    ) | tee -a "$captures"
}
