#!/usr/bin/env bash
here="$(
	builtin cd "$(dirname "${BASH_SOURCE[0]}")" || exit
	pwd
)"
d_assets="$HOME/.local/share/nvim.assets"
function set_symlinks {
	S="$here"
	T="$HOME/.config/nvim"
	rm -f "$T/lua/user"
	ln -s "$S" "$T/lua/user"
	for k in spell ftplugin snippets; do
		rm -f "$T/$k"
		ln -s "$S/$k" "$T/$k"
	done
}
function download_spell {
	local fn="$here/spell/de.utf-8.spl"
	test -e "$fn" && return
	rm -f "$fn"
	(cd "$d_assets" && wget 'http://ftp.vim.org/pub/vim/runtime/spell/de.utf-8.spl') || exit 1
	ln -s "$d_assets/de.utf-8.spl" "$fn"
}
function download_10 {
	local fn="$here/10k.txt"
	test -e "$fn" && return
	rm -f "$fn"
	(cd "$d_assets" && wget "https://raw.githubusercontent.com/neoclide/coc-sources/master/packages/word/10k.txt") || exit 1
	ln -s "$d_assets/10k.txt" "$fn"
}

function main {
	test -n "$here" || exit 1
	mkdir -p "$d_assets"
	download_spell
	download_10
	set_symlinks
}

main "$@"
