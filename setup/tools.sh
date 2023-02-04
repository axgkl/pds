d_packer="$HOME/.local/share/nvim/site/pack/packer"
enter_shell() { sh "$SHELL"; }
function lsp-show-all { # open null-ls BUILTINS in browser
    local cmd=open
    q 12 type xdg-open && cmd="xdg-open"
    $cmd 'https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md'
}
function dev-icons { # set use of icons (true/false) # SH
    local o="$HOME/.config/pds/setup/${pds_distri}/options.lua"
    function setico {
        sed -e "s/$2/icons_enabled = $1/" <"$o" >"$o.r"
        mv "$o.r" "$o"
        packer-sync
        hint "have set icons"
        grep icons_enabled <"$o" # hint for the user
    }
    test -e "$o" || hint "No $o.\n=> For icons see https://astronvim.github.io/"
    test -e "$o" || die "Non matching pds version"
    local s cmd="${1:-show}"
    s="$(grep icons_enabled <"$o" | cut -d , -f 1 | grep -v '\-\-')"
    grep icons_enabled <"$o" # hint for the user
    test "$(echo -e "$s" | grep icons | wc -l)" = "1" || {
        hint "expected 1 line"
        return 1
    }
    test "$cmd" = "true" && echo "$s" | grep -q false && setico true "$s" && return
    test "$cmd" = "false" && echo "$s" | grep -q true && setico false "$s" && return
    test "$cmd" = "true" || { test "$cmd" = "false" || {
        hint "To change call me with true or false as argument"
    }; }
}

function cd-swaps { # cds: cd to swapfiles dir
    local sd
    sd="$HOME/.local/state/nvim/swap"
    mkdir -p "$sd" && cd "$sd" && enter_shell
}
function rm-swaps { # rms: rm all swapfiles
    local sd
    sd="$HOME/.local/state/nvim/swap"
    hint "before"
    sh -a ls -l "$sd"
    cd "$sd" && rm -f ./*"${1:-}"*
    sh -a ls -l "$sd"
    hint "cleared"
}

function plugins-list { # pgl: fzf over all plugins, then cd into selected
    cd "$d_packer" || return
    local d="$(fd . -t d -E .git | fzf --tac --ansi --exact --height=30% --query "${1:-}" -0 -1)"
    test -z "$d" && return
    cd "$d" || return
    tree -L 2
    enter_shell
}
function plugins-create-snapshot { # pcs: plugin versions to stdout
    local fn rev revertmode=false
    test "$1" = "-r" && {
        revertmode=true
        fn="$2"
    }
    for k in start opt; do
        cd "$d_packer/$k" || continue
        for p in *; do
            test -d "$p" || continue
            if [ "$revertmode" = "true" ]; then
                rev="$(cd "$p" && grep ":$p:" <"$fn" | cut -f 1 -d ' ')"
                test -z "$rev" && echo "No snapshot: $p" || (
                    echo "$p"
                    cd "$p" && git checkout "$rev"
                )
            else
                (cd "$p" && echo "$(git rev-parse --short HEAD) :$p:")
            fi
        done
    done
}
function fn-pvers { # output plugin versions file
    echo "$HOME/.config/pds/setup/$pds_distri/versions"
}
function plugins-revert-to-snapshot { # prs: Revert to snapshots file vers when given. Else: Use default file
    local fn fnv
    test -z "$1" && fnv="$(fn-pvers)" || fnv="$1"
    echo "Versions file: $fnv" >&2
    fn="$(readlink -e "$fnv")"
    test -e "$fn" || {
        echo "Require snapshots file $fnv"
        return 1
    }
    plugins-create-snapshot -r "$fn"
}

function packer-sync { # pks: non interactive packer sync
    #vi -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
    sh -a vi --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' 1>/dev/null 2>/dev/null || {
        sh -a vi --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
    }
    echo
}

function packer-interactive-sync { # pki: interactive packer sync
    vi +PackerSync
}
