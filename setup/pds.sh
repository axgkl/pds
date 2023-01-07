#!/usr/bin/env bash
# _______________________________________________________________________________________ DEFAULTS
set -a
pds_repo="${pds_repo:-github.com:AXGKl/pds}"
pds_distri="${pds_distri:-astro}"
pds_d_mamba="${pds_d_mamba:-$HOME/pds}"
pds_v_mamba="${pds_v_mamba:-22.9.0-2}"
pds_v_nvim="${pds_v_nvim:-0.8.1}"
pds_v_shfmt="${pds_v_shfmt:-3.6.0}"
pds_mamba_tools="${pds_mamba_tools:-bat blue fd-find:fd fzf git gxx_linux-64:- gcc jq lazygit ncdu neovim:- ripgrep:rg prettier pyright shellcheck tmux tree unzip}"
pds_mamba_prefer_system_tools=${pds_mamba_prefer_system_tools:-true}
pds_pin_distri=${pds_pin_distri:-true}
pds_pin_mamba=${pds_pin_mamba:-true}
pds_pin_mamba_pkgs=${pds_pin_mamba_pkgs:-false}
pds_pin_nvim_pkgs=${pds_pin_nvim_pkgs:-false}
set +a

# _______________________________________________________________________________________ SOURCING
# when sourced, no spamming of namespace with stuff req. for the process
pds_is_sourced=false
if [ -n "$ZSH_VERSION" ]; then
    me="$0"
    grep -q "toplevel" <<<"$ZSH_EVAL_CONTEXT" && pds_is_sourced=true
elif [ -n "${BASH_SOURCE[0]}" ]; then
    me="${BASH_SOURCE[0]}"
    grep -q "bash" <<<"$0" && pds_is_sourced=true
else
    echo "Only zsh or bash. Sry!"
    return 2>/dev/null || exit 1
fi

#
here="$(builtin cd "$(dirname "$me")" && pwd)"

function run_with_pds_bin_path {
    # conda activate got slow
    local p="$pds_d_mamba/bin"
    if [[ "$PATH" != *"$p"* ]]; then
        echo "pds tools at $p in \$PATH"
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
function handle_sourced {
    local func="${1:--h}" r=run_with_pds_bin_path
    case "$func" in
        #F a|activate:    Adds pds bin dir to $PATH
        a | activate) $r ;;
        #F d|deactivate:  Removes from $PATH
        d | deactivate) $r deact ;;
        #F e|edit:        cd to user dir, edit init.lua
        e | edit)
            cd "$here/$pds_distri" || true
            pds vi init.lua
            ;;
        #F pl|plugs-list: fzf over plugins dirs, cd to selected
        pl | plugins-list)
            $r
            cd "$HOME/.local/share/nvim/site/pack/packer" && cd "$(fd . -t d -E .git | fzf)" && tree -L 2
            ;;
        #F ps|packer-sync: Syncs your plugins/init.lua
        ps | packer-sync) vi +PackerSync ;;
        -x | -s | -h | --help | clean-all | i | install | shell | stash | restore | status)
            "$here/pds.sh" "$@"
            ;;
        #F any, except action:  Runs the argument(s) with activated pds
        *) $r "$@" ;;
    esac
}
$pds_is_sourced && {
    handle_sourced "$@"
    return $?
}
# --------------------------------------------------------------------------------------- PROCESS
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
in_tmux=false
function set_constants {
    T="\x1b[1;32;40m"
    M="\x1b[1;32m"
    I="\x1b[1;31m"
    L="\x1b[2;37m"
    O="\x1b[0m"
    d_stash="$HOME/.local/share/stashed_nvim"
    inst_log="$HOME/pds_install.log"
    d_="$T\nPDS Tools $O
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
        - Creates conda(mamba) environment at '$pds_d_mamba', with tools:
        $L$pds_mamba_tools$O
        - Installs NeoVim '$pds_v_nvim'
        - Installs Nvim '$pds_distri' Distribution 
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
    source "$here/$pds_distri/environ" || true # maybe non needed, but show error
    # spell='http://ftp.vim.org/pub/vim/runtime/spell/de.utf-8.spl'
    # 10k: https://raw.githubusercontent.com/neoclide/coc-sources/master/packages/word/10k.txt
    #
    d_conf_nvim="$HOME/.config/nvim"
    d_nvim_dirs=("${d_conf_nvim:-/tmp/x}" "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim")
    url_nvim_appimg="https://github.com/neovim/neovim/releases/download/v$pds_v_nvim/nvim.appimage"
    shfmt="https://github.com/mvdan/sh/releases/download/v$pds_v_shfmt/shfmt_v${pds_v_shfmt}_linux_amd64"
    _stashes_have="$(ls "$d_stash" | sort | xargs)"
}

function activate_mamba {
    # deactivate all condas, lsp install would fail with different node
    function a_m { conda activate "$pds_d_mamba" 2>/dev/null; }
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

tmux_sock="/tmp/nvimsetup.$UID.sock"
S="Space"
t_() {
    local sock
    sock="$1"
    shift
    tmux -S "$sock" "$@"
    local r="$?"
    sleep 0.1
    return "$r"
}

function T {
    test "$1" == "-q" && shift || hint "tmux: $*"
    t_ "$tmux_sock" "$@"
}
function C { T capture-pane -t 2 -p; }

function hex {
    # tmux send-key convenience, this way we can send anything w/o space problems:
    # -> safer way to send to tmux - appends an Enter (the a):
    python -c 'import sys; l=[hex(ord(c))[2:] for c in sys.argv[1]];print(" ".join(l) + " a", end="")' "$1"
}

# tmux send keys
function TSK {
    local cmd
    hint "Sending: $*"
    cmd="$(hex "$1")"
    eval T -q send-keys -t 2 -H "$cmd"
}

# tmux send comand, return when done
function TSC {
    local cmd
    cmd="$1 && touch .done"
    shift
    rm -f ".done"
    TSK "$cmd"
    waitfor ".done" "$@"
}

function TMIF {
    test "$in_tmux" == "true" && TSC "$*"
    test "$in_tmux" == "true" || "$@"
}
# wait for file then do action
function waitfor {
    hint "Waiting for: $1"
    while ! test -e "$1"; do sleep 0.1; done
    test "$2" == "then" && {
        shift
        shift
        eval "$*"
    }
}

# pretty output:
function hint { echo -e "$L$*$O"; }
function sh {
    echo -e "\x1b[31m⚙️\x1b[0m\x1b[1m $1\x1b[0m"
    local m
    $pds_is_stepped && {
        $in_tmux && {
            tmux select-pane -t 0
            hint "Hint: Attach via tmux -S $tmux_sock att"
        }
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
    $in_tmux && tmux select-pane -t 1
    "$@"
}

function have {
    local dt b args
    test -z "$start_time" && start_time=$(date +%s)
    b=s
    test "$1" == "t" && {
        shift
        b=t
    } # time is total
    dt=$(($(date +%s) - $start_time))
    start_time=$(date +%s)
    local msg h="$1"
    shift
    #have="$(echo -n "$have" | sed -e 's/1m/2m/g')"
    args="$(echo "$*" | xargs)"
    msg="$(printf "\x1b[2m%5s$b\x1b[0m \x1b[1;34m✔️\x1b[0m %-30s %s\x1b[0m\n" "$dt" "\x1b[1m$h" "\x1b[2m $args")"
    echo -e "$msg"
    echo -e "$msg" >>"$inst_log"
}

function die {
    echo -e "FATAL: \x1b[1;31m$1\x1b[0m"
    shift
    echo "$@"
    exit 1
}

function disk {
    du -h "$1" | tail -n 1
}
function install_plugins {
    export setup_mode=true
    nvim +PackerSync
}

function set_pds_function_to_user_shell {
    local a fn h
    for fn in "$HOME/.bashrc" "$HOME/.zshrc"; do
        test -e "$fn" || continue
        h="$h $(basename "$fn")"
        a='function pds { source "'$here'/pds.sh" "$@"; }'
        grep -A 3 'function pds' <"$fn" | grep source | head -n 1 | grep "$here" 1>/dev/null 2>&1 || {
            echo "writing pds function to $fn => pls source it"
            echo "$a" >>"$fn"
        }
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
    local hv_mamba fn crl url name
    crl=false
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
            type curl 2>/dev/null 1>&2 && crl=true
            echo "Not present - downloading $url"
            $crl && curl -L -o "$fn" "$url"
            $crl || wget "$url" -O "$fn"
            test -e "$fn" || die "could not download $url"
            have "Mamba Installer" "$fn"
        )
        sh install_mamba "$fn"
    }
    test -e "$pds_d_mamba/bin/mamba" || die "No mamba dir: $pds_d_mamba"
    hv_mamba="$("$pds_d_mamba/bin/mamba" --version | xargs)"
    test -z "$hv_mamba" && die "mamba not executable here"
    # die when pinned but different:
    local msg
    msg="Mamba ver conflict at $pds_d_mamba (wanted: $pds_v_mamba, have: $hv_mamba). Remove manually or change \$pds_d_mamba to different location."
    test "$pds_v_mamba" == "latest" && pds_v_mamba="-" # only have minor not -<build>
    $pds_pin_mamba && grep "${pds_v_mamba%%-*}" <<<"$hv_mamba" 1>/dev/null || die "$msg"
    have "Mamba Binary Pkg Env" "$hv_mamba $(disk "$pds_d_mamba")"
}
function ensure_tool {
    local p1 t1
    t1="$pds_mamba_tools"
    p1="$mamba_prefer_system_tools"
    pds_mamba_tools="$1"
    mamba_prefer_system_tools=false
    eval "$2" && mamba_prefer_system_tools=true
    install_binary_tools
    export pds_mamba_tools="$t1"
    export mamba_prefer_system_tools="$p1"
    have "$1" "$(type "$1")"
}
function ensure_tmux {
    ensure_tool tmux "tmux -V | grep -q 'tmux 3'"
}
function ensure_git {
    ensure_tool git "git --version"
}

# support ripgrep[=ver][:<rg|->]  (- for library, no name on system)
function install_binary_tools {
    echo "tools $pds_mamba_tools"
    local f v pkg name spkgs pkgs vers vt
    vt=""
    for f in "$here/$pds_distri" "$here"; do
        test -e "$f/versions_mamba.txt" || continue
        vers="$(cat "$f/versions_mamba.txt")"
    done
    IFS=' ' && for t in $pds_mamba_tools; do
        pkg="${t%:*}"
        name="${t#*:*}"
        test "$name" == "-" || {
            test "$mamba_prefer_system_tools" == "true" && type "$name" 2>/dev/null 1>&2 && {
                spkgs="$spkgs $pkg"
                continue
            }
        }
        # huge - don't install when not needed:
        test "$pkg" == "gxx_linux-64" && {
            test "$mamba_prefer_system_tools" == "true" && {
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
    have_missing_installed || TMIF mamba install -c conda-forge -y $vt
    have Tools "$pkgs $spkgs"
    test -z "${spkgs/ /}" || have "Tools Present" "$spkgs"
}

function install_shfmt {
    # avoiding install golang
    local fn fnm
    fn="$pds_d_mamba/bin/shfmt"
    fnm="$HOME/.local/share/nvim/mason/bin/shfmt" # always in nvim path
    test -e "$fn" || {
        TSC "curl -L -o shfmt '$shfmt' && mv shfmt '$fn'" "then" chmod +x "$fn"
    }
    rm -f "$fnm"
    ln -s "$fn" "$fnm"
    have ShellFormatter "$fn"
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

function clone_astronvim {
    if [ -e "$d_conf_nvim" ]; then
        TSC "( builtin cd '$d_conf_nvim' && git pull )"
    else
        TSC "git clone 'https://github.com/AstroNvim/AstroNvim' '$d_conf_nvim'"
    fi
    $pds_pin_distri && TSC "( builtin cd '$d_conf_nvim' && git status && git reset --hard '$pds_v_distri'; )"
    have "AstroNvim Repo" "Pinned: $pds_pin_distri. $(cd "$d_conf_nvim" && git log | grep Date | head -n 1)"
}

function lsp() {
    local fn
    fn="$HOME/.local/share/nvim/mason/bin/${2:-$1}"
    test -e "$fn" && return 0
    echo "lsp install $1 ($2)"
    sleep 0.5
    T send-keys Escape
    TSK ":LspInstall $1"
    until test -e "$fn"; do sleep 0.1; done
    T send-keys Escape
    have LSP "$1"
}

function install_astronvim {
    #t resize-window -x 150 -y 50
    local d t0 ts fn tss
    t0=$(date +%s) # total
    d="$HOME/.local/share/nvim/mason/bin"
    test -e "$d" 2>/dev/null || {
        # we just start it, install begins autom:
        TSK "$pds_d_mamba/bin/vi"
        until (C | grep Mason); do sleep 0.2; done
        hint "Waiting for: 'Mason' to disappear"
        while (C | grep Mason >/dev/null); do sleep 0.2; done
        sleep 0.1
        TSK ':q!'
        sleep 0.1
    }
    have "Mason Binary Pkg Tool"
    TSK "$pds_d_mamba/bin/vi"
    d="$HOME/.local/share/nvim/site/pack/packer/opt/nvim-treesitter/parser"
    tss="python bash css javascript vim help"
    for ts in $(echo "$tss" | xargs); do
        fn="$d/$ts.so"
        test -e "$fn" && {
            hint "Have $ts"
            continue
        }
        TSK ":TSInstall $ts"
        until test -e "$fn"; do sleep 0.1; done
        sleep 0.1
    done
    have "Treesitter parsers" "$tss"

    lsp bashls "bash-language-server"
    lsp marksman
    lsp pylsp
    lsp sumneko_lua "lua-language-server"
    lsp tsserver "typescript-language-server"
    lsp vimls "vim-language-server"
    T send-keys Escape
    T send-keys Escape
    TSK ':q!'
    TSK ':q!'
    start_time="$t0"
    have t AstroNvim "$(ls --format=commas "$d")"
}

function install_vim_user {
    set_symlinks() {
        local s=""
        local S="$here/$pds_distri"
        local T="$d_conf_nvim"
        rm -f "$T/lua/user"
        ln -s "$S" "$T/lua/user"
        for k in after ftplugin snippets; do
            s="$s $k"
            rm -f "$T/$k"
            TSC "ln -s "$S/$k" "$T/$k""
        done
        rm -f "$T/spell"
        ln -s "$here/../assets/spell" "$T/spell"
        have 'User Config' "Symlinks:$s"
    }
    set_symlinks
    TSC "$pds_d_mamba/bin/vi -c 'autocmd User PackerComplete quitall' -c 'PackerSync'"
    #TSC "$pds_d_mamba/bin/vi +PackerSync"
    TSK "$pds_d_mamba/bin/vi"
    lsp ruff_lsp "ruff-lsp"
    T send-keys Escape
    T send-keys Escape
    TSK ':q!'
    TSK ':q!'
    have "User Packages" "$S/plugins/init.lua"
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
    set -x
    rm -rf "$D"
    mkdir -p "$D"
    mv "$d_conf_nvim" "$D/nvim"
    mv ".local/state/nvim" "$D/state"
    mv ".local/share/nvim" "$D/share"
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
    kmv "$D/state" ".local/state/nvim"
    kmv "$D/share" ".local/share/nvim"
    set +x
    have "Copied back config" "Name $name"
}

function show_help {
    local f F a A
    F="F"
    A="A"
    f="$(grep "#$F " <"$me" | sed -e 's/#F//g' | sed -e 's/^    //g')"
    a="$(grep "#$A " <"$me" | sed -e 's/#A//g' | sed -e 's/^    //g')"
    f="$(echo -e "${d_/<FUNCS>/$f}")"
    echo -e "${f/<ACTIONS>/$a}"

    if [[ "${1:-x}" == "--help" ]]; then
        echo -e "${det_help}"
    fi
}

function Install {
    test "$in_tmux" == "false" && {
        export start_time
        export pds_installing=true
        start_time=$(date +%s)
        rm -f "$inst_log"
        sh ensure_dirs
        sh install_mamba_binary_pkg_mgr
        sh activate_mamba
        sh ensure_tmux
        echo 'Switching into tmux'
        T ls 2>/dev/null && {
            T kill-session
            sleep 0.4
        }
        export SHELL="/bin/bash" && T -f "$here/tmux.conf" new "$0" in_tmux install "$@"
        start_time=$(date +%s)
        sh set_pds_function_to_user_shell
        echo -e '\x1b[1;38;5;119mFinished.\x1b[0m'
        echo -e '\n\nInstall Settings\n'
        env | grep pds_ | sort

        echo -e '\n\nInstall Progress Log\n'
        cat "$inst_log"
        echo ''
        echo -e "- Source your ~/.bashrc or ~/.zshrc, to have pds function available."
        echo -e "- ${M}pds vi$O to start editor with all tools."
        echo -e "${L}\nDocs: "
        echo -e "- https://mamba.readthedocs.io"
        echo -e "- https://astronvim.github.io"
        echo -e "- $pds_repo $O"
        rm -f "$inst_log"
        return $?
    }
    sh source_bashrc
    # in tmux from here
    T split-pane -h
    #T resize-window -x 200
    T resize-pane -x 110
    sh activate_mamba_in_tmux
    sh install_binary_tools
    sh install_neovim
    sh clone_astronvim
    sh install_astronvim
    sh install_shfmt
    sh install_vim_user
    sh kill_tmux_session
}
function status {
    $req_boostrap && die "Require bootstrap"
    echo -e 'Stashes:'
    ls -lta "$d_stash"
}

function activate_mamba_in_tmux {
    TSC ". $HOME/.bashrc"
    TSC "conda activate $pds_d_mamba"
}
function kill_tmux_session {
    T kill-session
}
function shell {
    activate_mamba
    have "Mamba" "Shell"
    echo 'Deactive or exit to leave'
    export pds_shell=true
    bash
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

function bootstrap {
    local D grepo
    D="$HOME/.config"
    test -e "$D/pds" && die "Default dest $D/pds already on the system but environ was not sourced. Smells. Refusing."
    type git || sh bootstrap_git
    echo havegit
    export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
    mkdir -p "$D"
    (cd "$D" && { git clone "git@$pds_repo" || git clone "https://${pds_repo/://}"; })
    sh "$D/pds/setup/pds.sh" install "$@"
}

function main {
    test "$1" == "in_tmux" && {
        in_tmux=true
        shift
    }
    set_constants
    set -x
    if [[ -d "$here/../.git" && -d "$here/../setup" && -d "$here/../ftplugin" ]]; then
        req_bootstrap=false
        set_helper_vars
        ensure_stash_dir
    else
        req_boostrap=true
    fi

    local action
    action="${1:-x}"
    shift
    case "$action" in
        #A clean-all [-f]:      Removes all nvim
        clean-all) clean_all "$@" ;;
        #A i|install:           Installs a personal dev sandbox on this machine
        i | install)
            if [[ $req_bootstrap == true ]]; then
                sh bootstrap "$@"
            else
                sh Install "$@"
            fi
            ;;
        #A shell:               Enters a shell with pds tools available
        shell) shell ;;
        #A stash <name>:        Moves away an existing install, restorable
        stash) stash "$@" ;;
        #A r|restore <name>:    Restores stashed pds (-d: deletes stash, i.e. mv, not cp)
        r | restore) unstash "$@" ;;
        #A status:              Status infos
        status) status "$@" ;;
        #A -h|--help:           Help (detailed with --help)
        --help) show_help --help ;;
        *) show_help "$@" ;;
    esac
}

main "$@"
