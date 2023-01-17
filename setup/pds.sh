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

function run-tools {
    # access to further tools
    local funcs ts
    . "$here/tools.sh"
    test -n "$1" && {
        type "$1" >/dev/null && {
            "$@"
            return $?
        }
    }
    type
    funcs="$(grep -E "^function " <"$here/tools.sh" | grep '\{ #')" # only documented ones
    if [[ "$2" = "nomenu" ]]; then
        shift 2
        ts="$(cut -f 2 -d ' ' <<<"$funcs")"
    else
        ts="$(grep -E '^function' <"$here/tools.sh" |
            sed -e 's/function //g;s/{//g;s/^/\x1b\[1;32m/g;s/#/\x1b[2;37m/g' |
            run_with_pds_bin_path fzf --ansi --exact --height=30% --query "${*:-}" -1)"
    fi
    run_with_pds_bin_path 2>/dev/null
    shift
    eval "$ts $*"
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
        #F source:        Sources ALL the pds functions
        source) return ;;
        #F s|tools:       Opens tools menu, except when exact match
        \s | tools) run-tools "$@" ;;
        -x | -s | -h | --help | att | clean-all | \i | install | shell | stash | swaps | test | \r | restore | status)
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
    url_nvim_appimg="https://github.com/neovim/neovim/releases/download/v$pds_v_nvim/nvim.appimage"
    shfmt="https://github.com/mvdan/sh/releases/download/v$pds_v_shfmt/shfmt_v${pds_v_shfmt}_linux_amd64"
    _stashes_have="$(ls "$d_stash" 2>/dev/null | sort | xargs)"
}

function activate_mamba {
    # deactivate all condas, lsp install would fail with different node
    function a_m {
        conda activate "$pds_d_mamba" 2>/dev/null
        conda init bash
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
    function C { T -q capture-pane -t 1 -p; }

    function hex {
        # tmux send-key convenience, this way we can send anything w/o space problems:
        # -> safer way to send to tmux - appends an Enter (the a):
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
        dt="${wait_dt:-0.1}"
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
        T -q rename-window "⚙️ $*" || true
        out="\x1b[31m⚙️\x1b[0m\x1b[1m $1\x1b[0m"
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
        f="$(grep "#$F " <"$me" | sed -e 's/#F//g' | sed -e 's/^    //g')"
        a="$(grep "#$A " <"$me" | sed -e 's/#A//g' | sed -e 's/^    //g')"
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
    for fn in "$HOME/.bashrc" "$HOME/.zshrc"; do
        test -e "$fn" || continue
        h="$h $(basename "$fn")"
        a='function pds { source "'$here'/pds.sh" "$@"; }'
        grep -A 3 'function pds' <"$fn" | grep source | head -n 1 | grep "$here" 1>/dev/null 2>&1 && hint "Already present in $h" || {
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
    msg="Mamba version conflict at $pds_d_mamba (wanted: $pds_v_mamba, have: $hv_mamba). Remove manually or change \$pds_d_mamba to different location."
    test "$pds_v_mamba" == "latest" && pds_v_mamba="-" # only have minor not -<build>
    $pds_pin_mamba && grep "${pds_v_mamba%%-*}" <<<"$hv_mamba" 1>/dev/null || die "$msg"
    have "Mamba Binary Pkg Env" "$hv_mamba $(disk "$pds_d_mamba")"
}
function ensure_tool {
    local p1 t1
    t1="$pds_mamba_tools"
    p1="$pds_mamba_prefer_system_tools"
    pds_mamba_tools="$1"
    pds_mamba_prefer_system_tools=false
    eval "$2" && pds_mamba_prefer_system_tools=true
    install_binary_tools
    export pds_mamba_tools="$t1"
    export pds_mamba_prefer_system_tools="$p1"
    have "$1" "$(type "$1")"
}
function ensure_tmux { ensure_tool tmux "tmux -V | grep -q 'tmux 3'"; }
function ensure_git { ensure_tool git "git --version"; }
function install_pips {
    # todo: versions... For now we need those, for vpe vi plugin
    q 12 source "$me" a python -c 'import yaml' || TMIF pip install --upgrade emoji-fzf pyyaml
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

# support ripgrep[=ver][:<rg|->]  (- for library, no name on system)
function install_binary_tools {
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
    have_missing_installed || wait_dt=1 TMIF mamba install -c conda-forge -y $vt
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

function lsp() {
    local fn
    fn="$HOME/.local/share/nvim/mason/bin/${2:-$1}"
    test -e "$fn" || {
        echo "lsp install $1 ($2)"
        sleep 0.5
        T send-keys Escape
        TSK ":LspInstall $1"
        wait_dt=0.2 wait_for_file "$fn"
        T send-keys Escape
    }
    have LSP "$1"
}

function clone_astronvim_version {
    test -e "$d_conf_nvim" || TSC "git clone 'https://github.com/AstroNvim/AstroNvim' '$d_conf_nvim'"
    TSC 'here="$(pwd)"'
    TSC "builtin cd '$d_conf_nvim'"
    TSC 'git fetch'
    TSC "git checkout '$pds_inst_astro_branch'"
    test -n "$pds_inst_astro_ver" && {
        wait_dt=0.01
        TSC "git checkout '$pds_inst_astro_ver'"
    }
    #$pds_pin_distri && TSC "( builtin cd '$d_conf_nvim' && git status && git reset --hard '$pds_v_distri'; )"
    TSC 'builtin cd "$here"'
    have "AstroNvim $branch version" "$(builtin cd "$d_conf_nvim" && git log | grep Date | head -n 1)"
}

function first_start_astronvim {
    # not so sexy looking but pretty safe:
    wait_dt=0.4 TSC "$pds_d_mamba/bin/vi -c 'autocmd User PackerComplete quitall' -c 'PackerSync'"
    have "AstroNVim self install" "Plugins and Mason Binary Pkg Tool"
    #
    # #t resize-window -x 150 -y 50
    # local d t0 ts fn tss
    # d="$HOME/.local/share/nvim/mason/bin"
    # local want_mason=false
    # set -x
    # q 12 test -e "$d" || want_mason=true
    # set +x
    # #t0=$(date +%s) # total
    # TSK "$pds_d_mamba/bin/vi"
    # echo "want mason: $want_mason"
    # $want_mason && {
    #     # we just start it, install begins autom:
    #     wait_for 'C | grep Mason'
    #     hint "Waiting for: 'Mason' to disappear"
    #     wait_for 'C | grep -v Mason'
    # }
    # set -x
    # safe_quit_vi
    # set +x
    # echo done
}

function install_treesitter_parsers {
    TSK "$pds_d_mamba/bin/vi"
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

function install_lsps {
    TSK "$pds_d_mamba/bin/vi"
    sh lsp bashls "bash-language-server"
    sh lsp marksman
    sh lsp pylsp
    sh lsp sumneko_lua "lua-language-server"
    sh lsp tsserver "typescript-language-server"
    sh lsp vimls "vim-language-server"
    sh lsp ruff_lsp "ruff-lsp"
    safe_quit_vi
    have "LSPs" "$tss"
}

function safe_quit_vi {
    T send-keys Escape
    T send-keys Escape
    TSK ':q!'
    sleep 0.1
    TSK ':q!'
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
            TSC "ln -s "$S/$k" "$T/$k""
        done
        rm -f "$T/spell"
        ln -s "$here/../assets/spell" "$T/spell"
        have 'User Config' "Symlinks:$s"
    }
    function install_user_plugins {
        wait_dt=0.3 TSC "$pds_d_mamba/bin/vi -c 'autocmd User PackerComplete quitall' -c 'PackerSync'"
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
    sh install_binary_tools
    sh install_pips
    sh install_neovim
    sh set_installing_flag
    sh clone_astronvim_version
    sh first_start_astronvim
    sh install_pds_flavor
    sh unset_installing_flag
    sh install_treesitter_parsers
    sh install_lsps
    sh install_shfmt
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
    echo -e "${L}\nDocs: "
    echo -e "- https://mamba.readthedocs.io"
    echo -e "- https://astronvim.github.io"
    echo -e "- $pds_repo $O"
}

function status {
    $req_bootstrap && die "Require bootstrap"
    title 'Stashes:'
    for k in $(ls "$d_stash"); do disk "$d_stash/$k"; done
}

function kill_tmux {
    local key
    q 12 T list-sessions || return 0
    T list-session | grep -q attached && {
        echo -e '\nThere is a session attached - not killing tmux. Enter a key here to continue, once done with inspections.'
        read -r key
    }
    T kill-server || true
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
        #A shell:                   Enters a shell with pds tools available
        shell) shell ;;
        source) return ;;
        #A stash <name>:            Moves away an existing install, restorable
        stash) stash "$@" ;;
        #A test [-v] [-f <m>] [m]:  Runs all test scripts (optional -f filematch, test match)
        test) run_tests "$@" ;;
        #A r|restore <name>:        Restores stashed pds (-d: deletes stash, i.e. mv, not cp)
        \r | restore) unstash "$@" ;;
        #A status:                  Status infos
        status) status "$@" ;;
        #A -h|--help:               Help (detailed with --help)
        --help) show_help --help ;;
        *) show_help "$@" ;;
    esac
}

main "$@"
