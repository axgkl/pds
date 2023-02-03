#!/usr/bin/env bash
# the vpe plugin should be always there, for the mappings.md
# In readme it makes no sense, that table insert could and should be done elsewhere
# => it's only a demo

pds() { . "$HOME/.config/pds/setup/pds.sh" "$@"; }

function go_home {
    here="$(builtin cd "$(dirname "$0")" && pwd)"
    cd "$here" && cd ..
    test -e "README.md" || exit 1
}

function run_headless_in_page_vpe {
    echo -e "\n\nGenerating $1..."
    vi --headless '+PythonEval' '+quit' "$1" || exit 1
}

run_headless_in_page_vpe "$HOME/.config/nvim/lua/user/mappings.md"
run_headless_in_page_vpe README.md

echo -e '\n\nvpe tests passed'
