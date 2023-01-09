function lsp-show-all { # open null-ls BUILTINS in browser
    open 'https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md'
}

function cd-swaps { # cs: cd to swapfiles dir
    cd "$HOME/.local/state/nvim/swap" && "$SHELL"
}
function plugins-list { # pl: fzf over all plugins, then cd into selected
    cd "$HOME/.local/share/nvim/site/pack/packer" && cd "$(fd . -t d -E .git | fzf)" && tree -L 2
}
function packer-sync { # ps: non interactive packer sync
    vi -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
}
function packer-interactive-sync { # pis: interactive packer sync
    vi +PackerSync
}
