#!/usr/bin/env bash
set -o errexit
source test/tools.sh
# ✔️ pds status \| grep mytest - 'must be still available'
# ❌ test -e "$tf"
#
function plugs-list {
    TSK 'pds plugins-list'
    TSK "'mason-null-ls.nvim"
    📷
    T send-keys Enter
    #TSC "pwd > $(fn_tres_log)"
    TSC pwd
    ✔️ shows "$HOME/.local/share/nvim/site/pack/packer/opt/mason-null-ls.nvim"
}
test_in_tmux "$@"
