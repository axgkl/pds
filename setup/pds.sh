#!/usr/bin/env bash
# ______________________________________________________________________ DEFAULTS
set -a
pds_repo="${pds_repo:-github.com:AXGKl/pds}"
pds_distri="${pds_distri:-astro}"
pds_d_mamba="${pds_d_mamba:-$HOME/pds}"
pds_v_mamba="${pds_v_mamba:-22.9.0-2}"
pds_v_nvim="${pds_v_nvim:-0.8.1}"
#pds_v_shfmt="${pds_v_shfmt:-3.6.0}"
pds_binenv_tools="${pds_binenv_tools:-
bat
fd
fzf
gdu
}"
pds_mamba_tools="${pds_mamba_tools:-
blue
git
gxx_linux-64:-
gcc
jq
lazygit
neovim:-
prettier
ripgrep:rg
tmux
tree
unzip
}"
pds_mason_tools="${pds_mason_tools:-
bash-language-server
lua-language-server
marksman
prettierd
python-lsp-server
ruff-lsp
shfmt
stylua
typescript-language-server
vim-language-server
}"
pds_mamba_prefer_system_tools=${pds_mamba_prefer_system_tools:-false}
pds_pin_distri=${pds_pin_distri:-true}
pds_pin_mamba=${pds_pin_mamba:-true}
pds_pin_mamba_pkgs=${pds_pin_mamba_pkgs:-false}
pds_pin_nvim_pkgs=${pds_pin_nvim_pkgs:-false}
set +a

# _______________________________________________________________________________________ SOURCING
# when sourced, no spamming of namespace with stuff req. for the process
#
# Note: sourcing should be fast, `pds vi` may be an alias
pds_is_sourced=false
if [ -n "$ZSH_VERSION" ]; then
    me="$0"
    grep -q "toplevel" <<<"$ZSH_EVAL_CONTEXT" && pds_is_sourced=true
elif [ -n "${BASH_SOURCE[0]}" ]; then
    me="${BASH_SOURCE[0]}"
    test "$me" == "$0" || pds_is_sourced=true
else
    echo "Only zsh or bash. Sry!"
    return 2>/dev/null || exit 1
fi

#
here="$(builtin cd "$(dirname "$me")" && pwd)"
pds_tmux_sock="/tmp/pds_inst_tmux.$UID.sock"

function run_with_pds_bin_path {
    # conda activate too slow to start vim. We need the tools as well, so we add to path:
    local p="$pds_d_mamba/bin"
    if [[ "$PATH" != *"$p"* ]]; then
        test -z "$1" && echo "pds tools at $p in \$PATH" >&2
        export PATH="$p:$PATH" # our bins are newer
    fi
    test -z "$1" && return
    if [[ "$1" == "deact" ]]; then
        shift
        export PATH="${PATH/$p:/}"
        echo "removed pds tools from \$PATH"
        return
    fi
    "$@"
}
# function run-in-bash {
#     # in zsh a tool wants to have all funcs here, must go bash to source this:
# }
function run_tools {
    # access to further tools. w/o $1 or match we display fzf.
    # with func name we  call it directly
    test "${in_pds_shell:-}" = "true" || {
        pds shell run_tools "$@"
        return $?
    }
    local match="${1:-}"
    function list { grep -E "^function " <"$here/tools.sh" | grep '\{ #' | sed -e 's/function //g' | sort | grep "$match"; }
    function pretty_list { list | sed -e 's/{//g;s/^/\x1b\[32m/g;s/#/\x1b[37m/g'; }
    local func ts
    test "${1:-}" = "-h" && {
        match=""
        list
        return
    }
    shift
    ts="$(list)"
    test "$(list | wc -l)" = "1" || {
        ts="$(pretty_list | run_with_pds_bin_path fzf --tac --ansi --exact --height=30% --query "${1:-}" -0 -1)"
    }
    test -z "$ts" && {
        hint 'no match'
        return
    }
    ts="$(echo "$ts" | cut -d ' ' -f 1)"
    sh "$ts" "$@"
    #
    # # given a tool func name right away?
    # test -n "$1" && {
    #     type "$1" >/dev/null 2>&1 && {
    #         pds shell "$@" # run in subshell with all sourced with-tools
    #         return $?
    #     }
    # }
    #
    # notify-send "$ts"
    # run_with_pds_bin_path 2>/dev/null
    # shift
    # set -x
    # eval "$ts # $*"
    # set +x
}
function search {
    local all=false
    test "$1" = "-a" && {
        shift
        all=true
    }
    run_with_pds_bin_path
    echo "Install those with: binenv install"
    binenv search "$1"
    $all || return
    echo -e "\n\nInstall the following with: mamba install"
    mamba search "$1"
}

function handle_sourced {
    local r func
    func="${1:--h}"
    test -z "$1" || shift
    r=run_with_pds_bin_path
    # backslashed the shorts, to avoid zsh global alias resolution. compat. with bash

    case "$func" in
        #F a|activate:    Adds pds bin dir to $PATH
        \a | activate) $r "$@" ;;
        #F d|deactivate:  Removes from $PATH
        \d | deactivate) $r deact ;;
        #F e|edit:        cd to user dir, edit init.lua
        \e | edit)
            cd "$here/$pds_distri" || true
            pds vi init.lua
            ;;
        #F search [-a]:   Searches binenv and with -a also mamba
        \s | search) search "$@" ;;
        #F source:        Sources ALL the pds functions
        source) return ;;
        #F s|tools:       Opens tools menu, except when exact match
        \t | tools) run_tools "$@" ;;
        -x | -s | -h | --help | att | clean-all | \i | install | shell | stash | swaps | test | \r | restore | status | \u | update | \v | version)
            "$here/pds.sh" "$func" "$@"
            ;;
        #F any, except action:  Runs the argument(s) with activated pds
        *) ($r "$func" "$@") ;;
    esac
}

$pds_is_sourced && {
    handle_sourced "$@"
    ret=$?
    test "${1:-}" = "source" || return $ret
    test -n "$ZSH_VERSION" && {
        echo 'Full sourcing of all functions only in bash, sorry.'
        return 1
    }
}
# --------------------------------------------------------------------------------------- PROCESS
set -e
pds_is_traced="${pds_is_traced:-false}"
pds_is_stepped="${pds_is_stepped:-false}"

test "$1" == "-x" && {
    export pds_is_traced=true
    shift
}
test "$1" == "-s" && {
    export pds_is_stepped=true
    shift
}
$pds_is_traced && set -x

function set_constants {
    set -a
    fn_done="/tmp/pds.done.$UID" # indicates a command done in tmux
    have_tmux=false
    tmx_pane=1
    d_stash="$HOME/.local/share/stashed_nvim"
    d_conf_nvim="$HOME/.config/nvim"
    d_nvim_dirs=("${d_conf_nvim:-/tmp/x}" "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim")
    inst_log="/tmp/pds_install.$UID.log"  # cmds sent
    captures="/tmp/pds_captures.$UID.log" # tmux shots
    set +a
    d_="$H1\nPDS Tools $O
        $I
        USAGE$O: pds [-x] [-s] [-h] <function|action> [params]
        $I
        SWITCHES$O:
         -x:        Tracemode on
         -s:        Stepmode on (confirm each action)
         -h|--help: Help

        $I
        FUNCTIONS$O:
        <FUNCS>
        $I
        ACTIONS$O:
        <ACTIONS>

        ---
        ${L}Functions change your environ, actions are processes.
        If arg is not a function nor an action it will be run with activated pds bin dir. 
        Examples: pds vi myfile or ls | pds fzf
        $O
        "

    det_help="$I\nREQUIREMENTS$O:
        - (Any) Linux - all binaries by conda
        - The repo containing this file (anywhere)
        - Using bash (we set "pds" convenience function into .bashrc). Other shells: do it manually.
        $I
        ACTION DETAILS$O:
        $M
        install$O:
        - Ensures pds function within ~/.bashrc and/or ~/.zshrc
        - Creates Mamba/Conda Environment at '$pds_d_mamba'. Tools/libs:
        $L$pds_mamba_tools$O
        - Creates binenv Environment at '$pds_d_mamba'. Tools/libs:
        $L$pds_binenv_tools$O
        - Installs NeoVim '$pds_v_nvim'
        - Installs Nvim '$pds_distri' Distribution 
        - Installs Mason Tools:
        $L$pds_mason_tools$O
        - Installs User Config

        Set install params into "'$here'/environ" or export them before install.
        $M
        clean-all [-f]$O:
        - Removes $L${d_nvim_dirs[*]}$O
        - Leaves the mamba env at '$pds_d_mamba' - remove manually 
        - -f forces (e.g. to run non interactively)
        $M
        shell$O: Enter a shell with '$pds_d_mamba' activated
        $M
        status$O: Shows status of all installables and stashes
        $M
        stash <name>$O: Moves (mv) current config into $L$d_stash/<name>$O
        $M
        restore <name>$O: Restore current config by removing(!) existing, then copying back from stash
        "
    d_="${d_//        /}"
    det_help="${det_help//        /}"
}
function set_helper_vars {
    platform="$(uname)"
    archi="amd64"
    source "$here/$pds_distri/environ" || true # maybe non needed, but show error
    # spell='http://ftp.vim.org/pub/vim/runtime/spell/de.utf-8.spl'
    # 10k: https://raw.githubusercontent.com/neoclide/coc-sources/master/packages/word/10k.txt
    #
    url_binenv="https://github.com/devops-works/binenv/releases/download/v0.19.0/binenv_${platform}_$archi"
    url_nvim_appimg="https://github.com/neovim/neovim/releases/download/v$pds_v_nvim/nvim.appimage"
    #shfmt="https://github.com/mvdan/sh/releases/download/v$pds_v_shfmt/shfmt_v${pds_v_shfmt}_linux_amd64"
    _stashes_have="$(ls "$d_stash" 2>/dev/null | sort | xargs)"
}

function activate_mamba {
    # deactivate all condas, lsp install would fail with different nodejs
    function a_m {
        conda activate "$pds_d_mamba" 2>/dev/null
        #conda init -q bash
    }
    . "$pds_d_mamba/etc/profile.d/conda.sh" || die "could not source conda"
    while [ -n "$CONDA_PREFIX" ]; do conda deactivate; done
    a_m || die "Could not activate mamba"
    test "$CONDA_PREFIX"=="$pds_d_mamba" || {
        echo "Could not activate $pds_d_mamba"
        return
    }
    echo "Activated $pds_d_mamba"
}

function deactivate_mamba {
    d() { echo "Deactivated $pds_d_mamba"; }
    if [[ "${pds_shell:-}" == "true" ]]; then
        d
        exit
    fi
    conda deactivate
}

if true; then
    function T {
        test "$1" == "-q" && shift || hint "tmux: $*"
        tmux -S "$pds_tmux_sock" "$@"
    }
    function C { eval T -q capture-pane -t 1 -p "${1:-}"; } # -e to have colors

    function hex {
        # tmux send-key convenience, this way we can send anything w/o space problems:
        # -> safer way to send to tmux - appends an Enter (the a) No all tmux have it, new option:
        python -c 'import sys; l=[hex(ord(c))[2:] for c in sys.argv[1]];print(" ".join(l) + " a", end="")' "$1"
    }

    # tmux send keys
    function TSK {
        local cmd
        hint "⌨️  $1"
        cmd="$(hex "$1")"
        eval T -q send-keys -t "$tmx_pane" -H "$cmd"
    }

    function TSC {
        # tmux send comand, return when done or run all after 'then'
        local cmd
        cmd="$1 && touch \$fn_done"
        shift
        rm -f "$fn_done"
        TSK "$cmd"
        wait_for_file "$fn_done" "$@"
        rm -f "$fn_done"
    }

    function TMIF {
        if [ "$have_tmux" == "true" ]; then
            TSC "$*"
        else
            "$@"
        fi
    }

    function wait_for {
        local dt
        dt="${wait_100_dt:-0.1}"
        hintn '.'
        for i in {1..100}; do
            eval "$1" && return 0
            hintn "."
            sleep "$dt"
        done
        test "$test_mode" = "true" && C
        die "timed out, (waiting $dt*100s)"
    }

    # wait for file then do action
    function wait_for_file {
        wait_for 'test -e "'$1'"'
        hint "✔️ $1"
        test "$2" == "then" && {
            shift
            shift
            eval "$*"
        }
        true
    }
fi
true && {
    O="\x1b["
    H1="$O;1;32;40m"
    M="$O;1;32m"
    I="$O;1;31m"
    L="$O;2;37m"
    O="$O;0m"

    function hintn { echo -en "$L$*$O"; } # .... dots
    function hint { hintn "$*\n"; }       # hint with new line
    function title { echo -e "\n\x1b[1;38;5;119m$*\x1b[0m\n"; }
    function sh {
        local m out
        local shcmd="$1"
        test "${1:-}" = "-a" && {
            shift
            shcmd="$*"
        }
        T -q rename-window "⚙️ $*" 2>/dev/null || true
        out="\x1b[31m⚙️\x1b[0m\x1b[1m $shcmd\x1b[0m"
        echo -e "$out" | tee -a "$captures" | tee -a "$inst_log"

        $pds_is_stepped && {
            $have_tmux && hint "Hint: Attach via tmux -S $pds_tmux_sock att"
            echo -e '\x1b[41m❓Continue / Run / Trace / Quit [cYtq]? \x1b[0m'
            read -r m
            m="$(echo "$m" | tr '[:upper:]' '[:lower:'])"
            if [ "$m" == "q" ]; then exit 1; fi
            if [ "$m" == "c" ]; then
                pds_is_stepped=false
                m=y
            fi
            if [ "$m" == "t" ]; then
                if [ "$pds_is_traced" == "true" ]; then
                    pds_is_traced=false
                    set +x
                else
                    pds_is_traced=true
                    set -x
                fi
            fi

        }
        "$@" || die "Failed: $*"
    }

    function have {
        local dt b args
        test -z "$start_time" && start_time=$(date +%s)
        b=s
        # time is total
        test "$1" == "t" && {
            shift
            b=t
        }
        dt=$(($(date +%s) - start_time))
        start_time=$(date +%s)
        local msg h="$1"
        shift
        #have="$(echo -n "$have" | sed -e 's/1m/2m/g')"
        args="$(echo "$*" | xargs)"
        msg="$(printf "\x1b[2m%5s$b\x1b[0m \x1b[1;34m✔️\x1b[0m %-30s %s\x1b[0m\n" "$dt" "\x1b[1m$h" "\x1b[2m $args")"
        echo -e "$msg" | tee -a "$captures" | tee -a "$inst_log"
    }

    function die {
        kill_tmux
        echo -e "\n💀 \x1b[1;31m$1\x1b[0m"
        shift
        echo "$@"
        exit 1
    }

    function show_help {
        local f F a A
        F="F"
        A="A"
        f="$(grep "#$F " <"$me" | sed -e 's/#F/\x1b[1;33m/g' | sed -e 's/^    //g' | sed -e 's/:/\x1b[2m/' | sed -e 's/$/\x1b[0m/')"
        a="$(grep "#$A " <"$me" | sed -e 's/#A/\x1b[1;37m/g' | sed -e 's/^    //g' | sed -e 's/:/\x1b[2m/' | sed -e 's/$/\x1b[0m/')"
        f="$(echo -e "${d_/<FUNCS>/$f}")"
        echo -e "${f/<ACTIONS>/$a}"
        if [[ "${1:-x}" == "--help" ]]; then
            echo -e "${det_help}"
        fi
    }
}

function disk {
    du -h "$1" | tail -n 1
}
function set_pds_function_to_user_shell {
    local a fn h
    for sh in "bash" "zsh"; do
        fn="$HOME/.${sh}rc"
        test -e "$fn" || continue
        h="$h $(basename "$fn")" #for have info
        a='function pds { source "'$here'/pds.sh" "$@"; }'
        grep -A 3 'function pds' <"$fn" | grep source | head -n 1 | grep "$here" 1>/dev/null 2>&1 && hint "Already present in $h" || {
            echo "writing pds function to $fn => pls source it"
            echo "$a" >>"$fn"
        }
        for k in BINENV_BINDIR BINENV_LINKDIR; do
            grep $k <"$fn" || echo "export $k=$pds_d_mamba/bin" >>"$fn"
        done
    done
    have 'Shell function' "$a in $h"
}
function ensure_dirs {
    local dd
    dd=""
    for d in .local/share .local/state .cache .config; do
        mkdir -p "$HOME/$d"
        dd="$dd$d "
    done
    have "Directories" "$dd"
}
function install_mamba {
    bash "$1" -b -p "$pds_d_mamba" || {
        set -x
        head -n 1 "$1"
        set +x
        rm -f "$1"
        die "Installer failed - removed it."
    }
    "$pds_d_mamba/bin/conda" init
}

# we support d_mamba v_mamba pin_mamba
function install_mamba_binary_pkg_mgr {
    local hv_mamba fn url name
    # prevent accidental nightmares:
    test "$pds_d_mamba" == "$HOME" && die "$pds_d_mamba cannot be equal to \$HOME"

    test -e "$pds_d_mamba/bin/mamba" || {
        test -d "$pds_d_mamba" && {
            hint "removing non functional $pds_d_mamba dir"
            rm -rf "$pds_d_mamba"
        }
    }
    test -d "$pds_d_mamba" || {
        name="Mambaforge-$pds_v_mamba-$(uname)-$(uname -m).sh"
        url="https://github.com/conda-forge/miniforge/releases/download/$pds_v_mamba/$name"
        #test "$pin_mamba" == true -o "$pds_v_mamba" == "latest" && {
        test "$pds_v_mamba" == "latest" && {
            name="Mambaforge-$(uname)-$(uname -m).sh"
            url="https://github.com/conda-forge/miniforge/releases/latest/download/$name"
        }
        echo "Installer: $name"
        fn="$HOME/.cache/$name"
        test -f "$fn" || (
            local crl
            crl=false #  have curl
            type curl 2>/dev/null 1>&2 && crl=true
            echo "Not present - downloading $url"
            $crl && curl -L -o "$fn" "$url"
            $crl || wget "$url" -O "$fn"
            test -e "$fn" || die "could not download $url"
            have "Mamba Installer" "$fn"
        )
        sh install_mamba "$fn"
    }
    test -e "$pds_d_mamba/bin/mamba" || die "Mamba install at $pds_d_mamba failed."
    hv_mamba="$("$pds_d_mamba/bin/mamba" --version | xargs)"
    test -z "$hv_mamba" && die "mamba not executable here"
    # die when pinned but different:
    local msg
    msg="Mamba version conflict at $pds_d_mamba (wanted: $pds_v_mamba, have: $hv_mamba). Remove manually or change \$pds_d_mamba to different location."
    test "$pds_v_mamba" == "latest" && pds_v_mamba="-" # only have minor not -<build>
    $pds_pin_mamba && grep "${pds_v_mamba%%-*}" <<<"$hv_mamba" 1>/dev/null || die "$msg"
    have "Mamba Binary Pkg Env" "$hv_mamba $(disk "$pds_d_mamba")"
}
function ensure_single_tool {
    # $1: tool $2: checker if present.
    # we temporary set pds_mamba_tools to $1 and call install_binary_tools_mamba:
    local p1 t1
    t1="$pds_mamba_tools"
    p1="$pds_mamba_prefer_system_tools"
    pds_mamba_tools="$1"
    pds_mamba_prefer_system_tools=false
    eval "$2" && pds_mamba_prefer_system_tools=true
    install_binary_tools_mamba
    export pds_mamba_tools="$t1"
    export pds_mamba_prefer_system_tools="$p1"
    have "$1" "$(type "$1")"
}
function ensure_tmux { ensure_single_tool tmux "tmux -V | grep -q 'tmux 3'"; }
function ensure_git { ensure_single_tool git "git --version"; }
function install_pips {
    # todo: versions... For now we need those, for vpe vi plugin
    q 12 source "$me" activate python -c 'import emoji_fzf' || TMIF pip install --upgrade emoji-fzf pyyaml
    have PIPs "emoji-fzf pyyaml"
}
function create_vman {
    # this only required alias man='pds vman'
    local fn
    fn="$HOME/pds/bin/vman"
    local s
    echo '#!/usr/bin/env bash
    if [ $# -eq 0 ]; then
        echo "What manual page do you want?"
        exit 0
    elif ! /usr/bin/man -w "$@" >/dev/null; then
        # Check that manpage exists to prevent visual noise.
        exit 1
    fi
    . ~/.config/pds/setup/pds.sh vi -c "SuperMan $*"' >"$fn"
    chmod +x "$fn"
    have vman 'Man pages in vi (alias man=vman)'
}

function line_seped { echo "$1" | xargs | tr ' ' '\n'; }
function install_graph_easy {
    # the best ascii art tool
    q 12 type graph-easy || {
        mamba install -y -c bioconda perl-app-cpanminus && env PERL5LIB="" PERL_LOCAL_LIB_ROOT="" PERL_MM_OPT="" PERL_MB_OPT="" cpanm Graph::Easy
    }
    have graph-easy "Asci drawing tool"
}
function install_binary_tools_binenv {
    for t in $(echo -e "$pds_binenv_tools"); do
        "$pds_d_mamba/bin/binenv" install "$t"
    done
    have binenv_tools "$pds_binenv_tools"
}
# support ripgrep[=ver][:<rg|->]  (- for library, no name on system)
function install_binary_tools_mamba {
    local f v pkg name spkgs pkgs vers vt
    local wanted
    vt=""
    for f in "$here/$pds_distri" "$here"; do
        test -e "$f/versions_mamba.txt" || continue
        vers="$(cat "$f/versions_mamba.txt")"
    done
    wanted="$(line_seped "$pds_mamba_tools")"
    for t in $(echo -e "$wanted"); do
        pkg="${t%:*}"
        name="${t#*:*}"
        test "$name" == "-" || {
            test "$pds_mamba_prefer_system_tools" == "true" && type "$name" 2>/dev/null 1>&2 && {
                spkgs="$spkgs $pkg"
                continue
            }
        }
        test "$pkg" == "gxx_linux-64" && {
            test "$pds_mamba_prefer_system_tools" == "true" && {
                type cpp gcc cc 2>/dev/null && {
                    spkgs="$spkgs $pkg"
                    hint 'skipping install of C build toolchain'
                    continue
                }
            }
        }
        pkgs="$pkgs $pkg"
        test "$pds_pin_mamba_pkgs" == "true" && {
            v="$(grep "^$pkg=" <<<$vers)"
            pkg="${v:-$pkg}"
        }
        vt="$pkg $vt"
    done

    function have_missing_installed {
        local e
        e="$(mamba list --export)"
        # try be fast at re-installs and search the tools in pkgs:
        vers=""
        for k in $vt; do
            grep -q "^$k" <<<"$e" || vers="$k $vers"
        done
        test -z "${vers/ /}"
    }
    # with slow internet this may take 5 minutes:
    have_missing_installed || wait_100_dt=3 TMIF mamba install -c conda-forge -y $vt
    have Tools "$pkgs $spkgs"
    test -z "${spkgs/ /}" || have "Tools Present" "$spkgs"
}

function install_binenv {
    local fn fnm
    fn="$pds_d_mamba/bin/binenv"
    export BINENV_BINDIR="$pds_d_mamba/bin"
    export BINENV_LINKDIR="$pds_d_mamba/bin"
    test -e "$fn" || {
        wget -q "$url_binenv" -O /tmp/binenv
        chmod +x /tmp/binenv
        /tmp/binenv update
        /tmp/binenv install binenv
    }
    have "binenv" "BINENV_BINDIR=$pds_d_mamba/bin"
}

function install_neovim {
    local a="$pds_d_mamba/bin/nvim.appimg"
    local d="$pds_d_mamba/bin/nvimfs"
    test -d "$d" || {

        local s="squashfs-root"
        rm -rf "$s"
        rm -rf "$pds_d_mamba/bin/vi"
        test -e "$a" || TSC "curl -L -o '$a' '$url_nvim_appimg'" "then" chmod +x "$a"
        TSC "'$a' --appimage-extract" "then" mv "$s" "$d"
        ln -s "$d/AppRun" "$pds_d_mamba/bin/vi"
    }
    have NeoVim "$d" "$(vi -v | head -n 1)"
}

# function lsp() {
#     # done batch wise now
#     local fn
#     fn="$HOME/.local/share/nvim/mason/bin/${2:-$1}"
#     test -e "$fn" || {
#         echo "lsp install $1 ($2)"
#         sleep 0.5
#         T send-keys Escape
#         TSK ":LspInstall $1"
#         wait_100_dt=0.2 wait_for_file "$fn"
#         T send-keys Escape
#     }
#     have LSP "$1"
# }

function clone_astronvim_version {
    test -e "$d_conf_nvim" || TSC "git clone 'https://github.com/AstroNvim/AstroNvim' '$d_conf_nvim'"
    TSC 'here="$(pwd)"'
    TSC "builtin cd '$d_conf_nvim'"
    TSC 'git fetch'
    TSC "git checkout '$pds_inst_astro_branch'"
    test -n "$pds_inst_astro_ver" && {
        wait_100_dt=0.01
        TSC "git checkout '$pds_inst_astro_ver'"
    }
    #$pds_pin_distri && TSC "( builtin cd '$d_conf_nvim' && git status && git reset --hard '$pds_v_distri'; )"
    TSC 'builtin cd "$here"'
    have "AstroNvim $branch version" "$(builtin cd "$d_conf_nvim" && git log | grep Date | head -n 1)"
}

function packer_sync {
    _packer_sync
    TSC 'echo synced'
}
function _packer_sync {
    # not so sexy looking but pretty robust over errs confirms and even needed retries:
    local i j
    for i in 1 2 3; do
        # todo: set a unique match string, if this runs in parallel for >1 user we fckup:
        for j in 15 9; do pgrep -f PackerComplete | xargs kill -$j 2>/dev/null; done
        sleep 0.1
        TSK "$pds_d_mamba/bin/vi -c 'autocmd User PackerComplete quitall' -c 'PackerSync'"
        sleep 1
        hint "waiting for vi process to exit"
        for j in {1..100}; do
            pgrep -f PackerComplete || return
            C | grep -C 3 'y/N' && TSK y
            C | grep -C 3 'Y/n' && TSK y
            C | grep -C 3 'Press ENTER' && T send-keys Enter
            sleep 1 # max 100 sec waiting for package installs
        done
        echo "Retrying packer sync"
    done
    C
    die "Packer sync failed"
    #
    # TSK "$pds_d_mamba/bin/vi"
    # sleep 1
    # while C | grep 'Press ENTER'; do
    #     T send-keys Enter
    #     sleep 0.1
    # done
    # wait_for 'C | grep "Find File"'
    # TSK ":PackerSync"
    # until C | grep 'finished'; do
    #     C | grep 'y/N' && TSK 'y'
    #     sleep 0.1
    # done
    # sleep 0.1
    # TSK q
    # wait_for 'C | grep "Find File"'
    # TSK ":quitall!"
    # wait_for 'C | grep "$ "'
    # TSC ls
}

function first_start_astronvim {
    #
    # #t resize-window -x 150 -y 50
    local d ts fn tss
    q 12 test -e "$HOME/.local/share/nvim/mason/bin" || {
        #local t0=$(date +%s) # total
        TSK "$pds_d_mamba/bin/vi"
        hint "is first start - bootstrapper running..."
        # we just start it, install begins autom:
        wait_for 'C | grep Mason'
        hint "Waiting for: 'Mason' to disappear"
        wait_for 'C | grep -v Mason'
        safe_quit_vi
    }
    have "AstroNVim self install" "Plugins and Mason Binary Pkg Tool"
    #packer_sync
}

function install_treesitter_parsers {
    open_vi
    d="$HOME/.local/share/nvim/site/pack/packer/opt/nvim-treesitter/parser"
    tss="python bash css javascript vim help"
    for ts in $(echo "$tss" | xargs); do
        fn="$d/$ts.so"
        test -e "$fn" && {
            hint "Have already: $ts"
            continue
        }
        TSK ":TSInstall $ts"
        until test -e "$fn"; do sleep 0.1; done
        sleep 0.1
    done
    safe_quit_vi
    have "Treesitter parsers" "$tss"
}
function open_vi {
    TSK "$pds_d_mamba/bin/vi"
    until C | grep "${1:-Find File}"; do
        C | grep -q ENTER | grep -v grep && T send-keys Enter
        sleep 0.2
    done
}

function mason_missing_tools {
    local tool_bin
    local map="$HOME/.local/share/nvim/site/pack/packer/opt/mason-lspconfig.nvim/doc/mason-lspconfig-mapping.txt"
    local dm="$HOME/.local/share/nvim/mason/bin"
    local mt=""
    wanted="$(line_seped "$pds_mason_tools")"
    for t in $(echo -e "$wanted"); do
        tool_bin="$(grep "$t" <"$map" | cut -d ' ' -f 2- | xargs)"
        # may happen, e.g. prettierd. Can still install though :-/
        test -z "$tool_bin" && hint "Mason tool unknown: $t"
        # only when we found it.
        test -n "$tool_bin" && test -e "$dm/$tool_bin" && continue
        test -e "$dm/$t" && continue
        mt="$mt $t"
    done
    mason_missing="$(echo "$mt" | xargs)"
}

function install_lsps {
    mason_missing_tools
    test -z "$mason_missing" && {
        have "Found All Mason Tools" "$(echo "$pds_mason_tools" | xargs)"
        return 0
    }
    open_vi "Find File"
    TSK ":MasonInstall $mason_missing"
    sleep 1
    until C | grep -q mason.nvim; do sleep 0.5; done
    C -e
    hint "Patience pls..."
    # we exit the mason popup and wait until for sure no more little mason install notify popups are there:
    # for k in 1 2 3 4; do
    #     sleep 0.1
    #     while C | grep -q mason.nvim; do sleep 0.5; done
    # done
    until C | grep -q Installed; do sleep 0.1; done
    for i in 1 2 3; do
        while C | grep -q Installing; do sleep 0.1; done
        sleep 0.1
    done
    C -e
    safe_quit_vi
    have "Mason Tools" "$(echo "$pds_mason_tools" | xargs)"
    # return
    # TSK "$pds_d_mamba/bin/vi"
    # sh lsp bashls "bash-language-server"
    # sh lsp marksman
    # sh lsp pylsp
    # sh lsp sumneko_lua "lua-language-server"
    # sh lsp tsserver "typescript-language-server"
    # sh lsp vimls "vim-language-server"
    # sh lsp ruff_lsp "ruff-lsp"
}

function safe_quit_vi {
    T send-keys Escape
    T send-keys Escape
    TSK ':quitall!'
    sleep 0.1
    TSK ':quitall!'
    sleep 0.1
    TSC 'echo done'
}

function install_pds_flavor {
    local S="$here/$pds_distri"
    function set_user_symlinks {
        local s=""
        local T="$d_conf_nvim"
        rm -f "$T/lua/user"
        ln -s "$S" "$T/lua/user"
        for k in after ftplugin snippets; do
            s="$s $k"
            rm -f "$T/$k"
            TSC "ln -s '$S/$k' '$T/$k'"
        done
        rm -f "$T/spell"
        ln -s "$here/../assets/spell" "$T/spell"
        have 'User Config' "Symlinks:$s"
    }
    function install_user_plugins {
        packer_sync
        #wait_100_dt=0.3 TSC "$pds_d_mamba/bin/vi -c 'autocmd User PackerComplete quitall' -c 'PackerSync'"
        have "User Packages" "see $S/plugins/init.lua"
    }
    sh set_user_symlinks
    sh install_user_plugins
    #TSK "$pds_d_mamba/bin/vi"
    #lsp ruff_lsp "ruff-lsp"
}

function clean_all {
    local have
    have=false
    test "${1:-x}" == "-f" || {
        for d in "${d_nvim_dirs[@]}"; do test -e "$d" && have=true; done
        $have && {
            for d in "${d_nvim_dirs[@]}"; do echo "$d"; done
            echo 'Really remove (consider stash) [y/N]? '
            read -r d
            test "${d:-x}" == "y" || die "unconfirmed"
        }
    }
    for d in "${d_nvim_dirs[@]}"; do
        test -e "$d" || continue
        set -x
        rm -rf "$d"
        set +x
    done
}

function stash {
    local name
    name="${1:?Require name of stash}"
    local D
    D="${d_stash:?req stash}/$name"
    test -e "$D" && die "Already present: $D"
    set -x
    rm -rf "$D"
    mkdir -p "$D"
    mv "$d_conf_nvim" "$D/nvim"
    mv "$HOME/.local/state/nvim" "$D/state"
    mv "$HOME/.local/share/nvim" "$D/share"
    set +x
    have "Stashed away config" "Name $name"
}
function unstash {
    local name
    name="${1:?Require name of stash}"
    local D
    D="${d_stash}/$name"
    test -d "$D" || die "Not found: $D"
    set -x
    kmv() {
        rm -rf "$2"
        cp -a "$1" "$2"
    }
    kmv "$D/nvim" "$d_conf_nvim"
    kmv "$D/state" "$HOME/.local/state/nvim"
    kmv "$D/share" "$HOME/.local/share/nvim"
    set +x
    have "Copied back config" "Name $name"
}
function q {
    local f
    f="$1"
    shift
    if [ "$f" = "12" ]; then
        "$@" 1>/dev/null 2>/dev/null
    elif [ "$f" = "2" ]; then
        "$@" 2>/dev/null
    elif [ "$f" = "1" ]; then
        "$@" 1>/dev/null
    else
        "$f" "$@" 1>/dev/null
    fi
}

function start_tmux {
    kill_tmux
    sleep 0.5
    export SHELL="/bin/bash"
    T -f "$here/tmux.conf" new-session -d "/bin/bash"
    T set-environment "fn_done" "$fn_done"
    # important. Otherwise we get 'Press Enter to continue...'
    T resize-window -y 40 -x 100
    T set -g status-position top
    have_tmux=true
    sh start_tmux_screenshotter >>"$captures" &
    sleep 0.2
    TSC 'echo "New tmux session. Defining pds function:"'
    TSC 'pds () { . "$HOME/.config/pds/setup/pds.sh" "$@"; }'
    have Tmux "$(T ls)"
}

function start_tmux_screenshotter {
    local int
    int=0.5
    local out outo
    #tail -f "$pds_tmux_cmds_log" & #| sed -r "/^\r?$/d;s/^/💻 /g" &; tailer=$!
    out=''
    outo=''
    while true; do
        out="$(q 2 C)"
        test "$out" != "$outo" && echo -e "$out" || hintn '.'
        outo="$out"
        q 12 T ls || return
        sleep "$int"
    done #kill $tailer
    have 'Screenshotter' "Interval: $int. Captures:  tail -f $captures"
}

function rm_logs {
    rm -f "$inst_log"
    test "${1:-}" = "all" || return
    rm -f "$captures"
    rm -f "$pds_tmux_cmds_log"
}
function enter {
    local key
    echo 'hit a key to continue'
    read -r key
}
# function nstall {
#     rm_logs all
#     function inst {
#         rm_logs
#         # subshell since may die (exit):
#         (sh try_install "$@") && echo -e "Version: $1" && rm_logs all && return 0
#         echo -e "Failure, with $1"
#         return 1
#     }
#     inst 'nightly, newest plugins' && return
#     hint 'Plugins to snapshot versions'
#     # can't use Packer in vi, might be broken. We do our own:
#     source "$here/tools.sh"
#     q 2 sh plugins-revert-to-snapshot
#     inst 'nightly, versioned plugins' && return
#     die "No more options to stabilize the install. Now show me who's the man 💪😎 ..."
# }

function set_installing_flag { TSC 'export pds_installing=true'; }
function unset_installing_flag { TSC 'unset pds_installing'; }
function parse_install_opts {
    pds_inst_astro_branch="main"
    pds_inst_astro_ver=""
    while test -n "$1"; do
        case "$1" in
            -av | astro-ver)
                pds_inst_astro_ver="$2"
                shift 2
                ;;
            -ab | astro-branch)
                pds_inst_astro_branch="$2"
                shift 2
                ;;
            *) die "$1 not supported" ;;
        esac
    done
}
function Install {
    # run the install within an outer tmux, 2 pane mode:
    test "$1" = "watch" && {
        local sck="/tmp/pds.watch.$UID"
        q 12 type tmux || die 'No tmux. Run install w/o watch.'
        q 12 tmux -S $sck kill-server
        sleep 0.5
        tmux -S $sck -f "$here/tmux.conf" new-session -d "$HOME/.config/pds/setup/pds.sh install"
        tmux -S $sck split-pane -h
        sleep 1
        for k in "$HOME/.config/pds/setup/pds.sh" space install space watchinstall; do
            tmux -S $sck send-keys -t 2 ''$k''
        done
        tmux -S $sck send-keys -t 2 Enter
        tmux -S $sck att
        cat "$inst_log"
        exit $?
    }
    test "$1" = "watchinstall" && {
        # we are second pane of the outer tmux. we stop looping when first pane done
        while true; do
            q 12 $HOME/.config/pds/setup/pds.sh att
            q 12 tmux send-keys -t 2 Enter || tmux -S /tmp/pds.watch.$UID kill-server
            sleep 0.5
        done
    }

    (DoInstall "$@") && return
    echo 'Install Failure'
    title Captures:
    cat "$captures"
    title Log:
    cat "$inst_log"
    die 'Install failed'
}
function DoInstall {
    rm_logs all
    parse_install_opts "$@"
    start_time=$(date +%s)
    sh ensure_dirs
    sh install_mamba_binary_pkg_mgr
    sh activate_mamba
    sh ensure_tmux
    sh start_tmux
    sh install_binary_tools_mamba
    sh install_binenv
    sh install_binary_tools_binenv
    sh install_graph_easy
    sh install_pips
    sh install_neovim
    sh set_installing_flag
    sh clone_astronvim_version
    sh first_start_astronvim
    sh install_pds_flavor
    sh unset_installing_flag
    sh install_treesitter_parsers
    sh install_lsps
    #sh install_shfmt
    sh create_vman
    sh core_tests
    sh set_pds_function_to_user_shell
    title 'Finished.'
    echo -e '\n\nInstall Settings\n'
    env | grep pds_ | sort

    echo -e '\n\nInstall Progress Log\n'
    cat "$inst_log"
    echo ''
    echo -e "- Size: $(disk "$pds_d_mamba") - you may delete the pkgs folder."
    echo -e "- Source your ~/.bashrc or ~/.zshrc, to have pds function available."
    echo -e "- ${M}pds vi$O to start editor with all tools."
    echo -e "- When you have no nerdfont installed (e.g. on servers), run: pds tools dev-icons false"
    echo -e "${L}\nDocs: "
    echo -e "- https://mamba.readthedocs.io"
    echo -e "- https://astronvim.github.io"
    echo -e "- $pds_repo $O"
}

function status {
    local d
    $req_bootstrap && die "Require bootstrap"
    title 'Version pds:'
    test -e "$HOME/.config/pds" && (cd "$HOME/.config/pds" && git show -s -2) || echo "(no pds repo)"
    title 'Version astronvim:'
    test -e "$HOME/.config/nvim" && (cd "$HOME/.config/nvim" && git show -s -2) || echo "(no pds repo)"
    title 'Stashes:'
    [ "$(ls -A "$d_stash")" ] && for k in "$d_stash"/*; do disk "$k"; done || echo "(no stashed installs)"
    title 'Tools:'
    test -e "$HOME/pds" && disk "$HOME/pds" || echo "(no pds tools dir)"
    d="$HOME/.local/share/nvim/site/pack/packer"
    test -e "$d/start" && title "Start plugins" && ls "$d/start"
    test -e "$d/opt" && title "Optional plugins" && ls "$d/opt"
    d="$HOME/.local/share/nvim/mason/bin"
    test -e "$d" && title "LSPs" && ls "$d"
    d="$HOME/.local/share/nvim/site/pack/packer/opt/nvim-treesitter/parser"
    test -e "$d" && title "Treesitter parsers" && ls "$d"
    hint '\nTip: In vi run :checkhealth'
}

function kill_tmux {
    local key
    q 12 T list-sessions || return 0
    T list-session | grep -q attached && {
        echo -e '\nThere is a session attached - not killing tmux. Enter a key here to continue, once done with inspections.'
        test "${install_watch_mode:-x}" = "true" || read -r key
    }
    T kill-server || true
}

function shell {
    # w/o arg: Run *interactive* shell with all tools
    # w arg: run the tool with all params at hand
    local fn="/tmp/pds.sh.$UID"
    local h="" c="" sw="-c"
    test "${1:-}" = "" && {
        h=". $HOME/.bashrc"
        sw="--rcfile"
    }
    test "${1:-}" = "" || c="$*"
    echo -e "#!/usr/bin/env bash
    $h
    shopt -u expand_aliases # avoid collisions
    export PATH=\"$HOME/pds/bin:$PATH\"
    function pds { . '$me' \$@; }
    in_pds_shell=true
    . $me source with-tools
    $c
    " >"$fn"
    chmod +x "/tmp/pds.sh.$UID"
    eval bash $sw $fn
}

function ensure_stash_dir { mkdir -p "$d_stash"; }

function bootstrap_git {
    # not even git on the system. We install the same mamba we'll anyway use for install.
    # This relies on version compat of version params, though.
    sh ensure_dirs
    sh install_mamba_binary_pkg_mgr
    sh activate_mamba
    sh ensure_git
}

function Bootstrap {
    local D grepo
    D="$HOME/.config"
    test -e "$D/pds" && die "Cloned pds already on the system. Run $D/pds/setup/pds.sh and not $me!"
    type git || sh bootstrap_git
    echo havegit
    export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
    mkdir -p "$D"
    hint "Trying ssh clone first, https is fallback"
    (builtin cd "$D" && { git clone "git@$pds_repo" || git clone "https://${pds_repo/://}"; })
    title 'Finished Bootstrapping.'
    hint 'Calling installer...'
    sh "$D/pds/setup/pds.sh" install "$@"
}
function core_tests {
    # run in bg to not stand still - we want auto role back
    "$me" test -f "test-p1-tmux" || die 'core tests failed'
    have Tests "Core functionality tests passed"
}

function run_tests {
    local fnm ret
    fnm=""
    kill_tmux || true
    test "${1:-}" == '-v' && {
        export verbose=true
        shift
    }
    test "${1:-}" == '-f' && {
        fnm="$2"
        shift 2
    }
    (
        builtin cd "$HOME/.config/pds/test"
        for t in *; do
            grep -q test <<<"$t" || continue
            grep -q "$fnm" <<<"$t" || continue
            title "Test: $t"
            "./$t" "$@" || die "Failed: $t"
        done
    )
    ret=$?
    kill_tmux
    return $ret
}

function att {
    local tm
    # have to use THE SAME TMUX THAN THE SERVER. Otherwise option incompatibilities
    tm="$(run_with_pds_bin_path which tmux)"
    echo "Using $tm"
    test -z "$1" && {
        "$tm" -S "$pds_tmux_sock" att
        return $?
    }
    echo 'Reattach loop starting...'
    while true; do
        att || true
        sleep 0.5
    done
}
function update {
    function update_repo {
        local fn="$HOME/.config/$1"
        hint "Repo: $fn"
        cd "$fn"
        git branch -vv | grep detached && git checkout -
        git pull || die "Could not git pull $1"
    }
    for k in pds nvim; do sh update_repo "$k"; done
    source "$here/tools.sh"
    packer-interactive-sync 2>/dev/null
}
function version_write {
    local fn="$1"
    echo "written: $(date). first 2 are: 1. pds, 2. astro" >"$fn"
    (cd "$HOME/.config/pds" && git rev-parse --short HEAD >>"$fn")
    (cd "$HOME/.config/nvim" && git rev-parse --short HEAD >>"$fn")
    plugins-create-snapshot >>"$fn"
    hint "Written $fn"
}
function version_use {
    local v fn="$1"
    test -e "$fn" || die "Not found: $fn"
    hint "Setting .config/pds and .config/nvim:"
    v="$(cat "$fn" | head -n 2 | tail -n 1)"
    (cd "$HOME/.config/pds" && git checkout "$v")
    v="$(cat "$fn" | head -n 3 | tail -n 1)"
    (cd "$HOME/.config/nvim" && git checkout "$v")
    sh packer-sync # so that we *have* all plugins, that should work - always￼
    sh plugins-revert-to-snapshot "$fn" 2>/dev/null
}
function version {
    source "$here/tools.sh"
    local act="${1:-x}"
    local fn="${2:-$HOME/.config/pds/setup/$pds_distri/versions}"
    test "$act" = "write" && sh version_write "$fn"
    test "$act" = "use" && sh version_use "$fn"
}
function main {
    set_constants
    if [[ -d "$here/../.git" && -d "$here/../setup" && -d "$here/../ftplugin" ]]; then
        req_bootstrap=false
        set_helper_vars
        ensure_stash_dir
    else
        req_bootstrap=true
        title 'This pds requires bootstrapping. Run install!'
    fi

    local action
    action="${1:-x}"
    shift
    case "$action" in
        #A att [-l]:                Watch install and test progress by attaching to tmux (-l in a loop).
        att) att "$@" ;;
        #A clean-all [-f]:          Removes all nvim
        clean-all) clean_all "$@" ;;
        #A i|install:               Installs a personal dev sandbox on this machine
        \i | install)
            if [[ $req_bootstrap == true ]]; then
                sh Bootstrap "$@"
            else
                sh Install "$@"
            fi
            ;;
        #A r|restore <name>:        Restores stashed pds (-d: deletes stash, i.e. mv, not cp)
        \r | restore) unstash "$@" ;;
        #A shell [cmd]:             Enters a shell with all pds tools sourced
        shell) shell "$@" ;;
        source)
            test "$1" = "with-tools" && source "$here/tools.sh" || true
            return
            ;;
        #A stash <name>:            Moves away an existing install, restorable
        stash) stash "$@" ;;
        #A status:                  Status infos
        status) status "$@" ;;
        #A test [-v] [-f <m>] [m]:  Runs all test scripts (optional -f filematch, test match)
        test) run_tests "$@" ;;
        #A u|update:                Update the pds config repo & sync plugins
        \u | update) update "$@" ;;
        #A v|version write [file]:  Write versions of all repos to a file
        #A      "    use   [file]:  Fallback all versions to given file
        \v | version) version "$@" ;;
        #A -h|--help:               Help (detailed with --help)
        --help) show_help --help ;;
        *) show_help "$@" ;;
    esac
}
main "$@"
set +e
