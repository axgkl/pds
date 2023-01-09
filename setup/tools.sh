function plugins-list {
    cd "$HOME/.local/share/nvim/site/pack/packer" && cd "$(fd . -t d -E .git | fzf)" && tree -L 2
}
function cd-swaps {
    cd "$HOME/.local/state/nvim/swap" && "$SHELL"
}
function packer-sync-interactive {
    vi +PackerSync
    return $?
}
function packer-sync {
    vi -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
}
