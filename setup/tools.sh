d_packer="$HOME/.local/share/nvim/site/pack/packer"

function lsp-show-all { # open null-ls BUILTINS in browser
    open 'https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md'
}

function cd-swaps { # cs: cd to swapfiles dir
    cd "$HOME/.local/state/nvim/swap" && "$SHELL"
}
function plugins-list { # pl: fzf over all plugins, then cd into selected
    cd "$d_packer" && cd "$(fd . -t d -E .git | fzf)" && tree -L 2
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
function fn_pvers { echo "$HOME/.config/pds/setup/$pds_distri/versions_plugins"; }
function plugins-revert-to-snapshot { # prs: Revert to snapshots file vers when given. Else: Use default file
    local fn
    test -z "$1" && fn="$(fn_pvers)" || fn="$1"
    echo "Versions file: $fn" >&2
    fn="$(readlink -e "$fn")"
    test -e "$fn" || {
        echo "req snapshots file"
        return 1
    }
    plugins-create-snapshot -r "$fn"
}

function packer-sync { # ps: non interactive packer sync
    vi -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
}
function packer-interactive-sync { # pis: interactive packer sync
    vi +PackerSync
}
