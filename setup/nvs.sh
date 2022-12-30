#!/usr/bin/env bash
# --------------------------------------------------------------------------------------- sourcing
# when sourced, handle only act/deact - w/o spamming the process namespace with stuff below

me="${BASH_SOURCE[0]:-${(%):-%x}}" # this script
test -z "$me" && {
	echo "Only zsh or bash. Sry!"
	return || exit 1
}
#
here="$(builtin cd "$(dirname "$me")" && pwd)"
. "$here/environ"

nvs_is_sourced=false
echo "bash $0"
grep -q "toplevel" <<<"$ZSH_EVAL_CONTEXT" && nvs_is_sourced=true
grep -q "bash" <<<"$0" && nvs_is_sourced=true

nvs_d_mamba="${nvs_d_mamba:-$nvs_dflt_d_mamba}"
nvs_distri="${nvs_distri:-$nvs_dflt_distri}"

function activate_mamba {
	# deactivate all condas, lsp install would fail with different node
	function a_m { conda activate "$nvs_d_mamba" 2>/dev/null; }
	. "$nvs_d_mamba/etc/profile.d/conda.sh" || die "could not source conda"
	while [ -n "$CONDA_PREFIX" ]; do conda deactivate; done
	a_m || die "Could not activate mamba"
	test "$CONDA_PREFIX"=="$nvs_d_mamba" || {
		echo "Could not activate $nvs_d_mamba"
		return
	}
	echo "Activated $nvs_d_mamba"
}

function deactivate_mamba {
	d() { echo "Deactivated $nvs_d_mamba"; }
	if [[ "${nvs_shell:-}" == "true" ]]; then
		d
		exit
	fi
	conda deactivate
}

function handle_sourced {
	# we are called as function
	proc=false
	case "${1:-x}" in
	a | activate)
		activate_mamba
		;;
	d | deactivate)
		deactivate_mamba
		;;
	e | edit)
		cd "$here/$nvs_distri" || true
		vi init.lua
		;;
	ps | packer-sync) vi +PackerSync ;;
	*)
		proc=true
		"$here/nvs.sh" "$@"
		;;
	esac
	$proc || $nvs_is_sourced || bash
}

# return when sourced
$nvs_is_sourced && {
	handle_sourced "$@"
	return
}

# --------------------------------------------------------------------------------------- process
nvs_is_traced="${nvs_is_traced:-false}"
nvs_is_stepped="${nvs_is_stepped:-false}"

test "$1" == "-x" && {
	export nvs_is_traced=true
	shift
}
test "$1" == "-s" && {
	export nvs_is_stepped=true
	shift
}
$nvs_is_traced && set -x
in_tmux=false
set -a
distri="${distri:-$nvs_dflt_distri}"
d="$here/$distri"
test -d "$d" || {
	echo "Not found: $d"
	exit 1
}
source "$d/environ"
nvs_v_distri="${nvs_v_distri:-$nvs_dflt_v_distri}"
nvs_d_mamba="${nvs_d_mamba:-$nvs_dflt_d_mamba}"
nvs_v_nvim="${nvs_v_nvim:-$nvs_dflt_v_nvim}"
nvs_v_mamba="${nvs_v_mamba:-$nvs_dflt_v_mamba}"
nvs_v_shfmt="${nvs_v_shfmt:-$nvs_dflt_v_shfmt}"
nvs_mamba_prefer_system_tools="${nvs_mamba_prefer_system_tools:-$nvs_dflt_mamba_prefer_system_tools}"
nvs_mamba_tools="${nvs_mamba_tools:-$nvs_dflt_mamba_tools}"
nvs_pin_mamba="${nvs_pin_mamba:-$nvs_dflt_pin_mamba}"
nvs_pin_mamba_pkgs="${nvs_pin_mamba_pkgs:-$nvs_dflt_pin_mamba_pkgs}"
nvs_pin_distri="${nvs_pin_distri:-$nvs_dflt_pin_distri}"
nvs_pin_nvim_pkgs="${nvs_pin_nvim_pkgs:-$nvs_dflt_pin_nvim_pkgs}"
set +a

#
d_conf_nvim="$HOME/.config/nvim"
d_stash="$HOME/.local/share/stashed_nvim"
url_nvim_appimg="https://github.com/neovim/neovim/releases/download/v$nvs_v_nvim/nvim.appimage"
shfmt="https://github.com/mvdan/sh/releases/download/v$nvs_v_shfmt/shfmt_v${nvs_v_shfmt}_linux_amd64"
inst_log="$HOME/nvs_have.log"
_stashes_have="$(ls "$d_stash" | sort | xargs)"
d_='\x1b[32mNeoVim Setup Tools\x1b[0m

USAGE: nvs [-x] [-s] <action> [params]

SWITCHES:

-x: Tracemode on
-s: Stepmode on (confirm each action)

ACTIONS:

 i(nstall)
 a(ctivate) 
 d(eactivate)
 clean-all
 shell
 stash <name> 
 restore <name> [have: '$_stashes_have']
 status

REQUIREMENTS:

- (Any) Linux
- The repo containing this file (anywhere)
- Using bash (we set "nvs" convenience function into .bashrc). Other shells: do it manually.

DETAILS:

[DE]Activate:
- When this script is sourced (via nvs function), we (de)activate '$nvs_d_mamba' in current shell

Install:
- Ensures nvs function to this script in .bashrc
- Creates conda(mamba) environment at '$nvs_d_mamba', with tools:
'$nvs_mamba_tools'
- Installs NeoVim '$nvs_v_nvim'
- Installs Nvim '$nvs_distri' Distribution 
- Installs User Config

Set install params into "'$here'/environ" or export them before install.

Clean All:
- Removes .config/nvim, .local/share/nvim and .local/state/nvim
- Leaves the mamba env at '$nvs_d_mamba' - remove manually 

Shell: Enter a shell with '$nvs_d_mamba' activated

Status: Shows status of all installables and stashes

Stash <name>: Moves (mv) current config into '$d_stash'/<name>

Restore: <name>: Restore current config by removing(!) existing, then copying back from stash
'

# spell='http://ftp.vim.org/pub/vim/runtime/spell/de.utf-8.spl'
# 10k: https://raw.githubusercontent.com/neoclide/coc-sources/master/packages/word/10k.txt

tmux_sock="/tmp/nvimsetup.sock"
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
	t_ "$tmux_sock" "$@";
}
function C { T capture-pane -t 2 -p; }

# tmux send-key convenience, this way we can send anything w/o space problems:
function hex {
	# appends an Enter (the a):
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
function hint {
	echo -e "\x1b[2;37m$*\x1b[0m"
}
function sh {
	echo -e "\x1b[31m⚙️\x1b[0m\x1b[1m $1\x1b[0m"
	local m
	$nvs_is_stepped && {
		$in_tmux && {
			tmux select-pane -t 0
	    hint "Hint: Attach via tmux -S $tmux_sock att"
		}
		echo -e '\x1b[41m❓Continue / Run / Trace / Quit [cYtq]? \x1b[0m'
		read -r m
		m="$(echo "$m" | tr '[:upper:]' '[:lower:'])"
		if [ "$m" == "q" ]; then exit 1; fi
		if [ "$m" == "c" ]; then
			nvs_is_stepped=false
			m=y
		fi
		if [ "$m" == "t" ]; then
			if [ "$nvs_is_traced" == "true" ]; then
				nvs_is_traced=false
				set +x
			else
				nvs_is_traced=true
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

function set_nvs_function_to_bashrc {
	local a fn
	fn="$HOME/.bashrc"
	a='function nvs { source "'$here'/nvs.sh" "$@"; }'
	grep -A 3 'function nvs' <"$fn" | grep source | head -n 1 | grep "$here" 1>/dev/null 2>&1 || {
		echo "writing nvs function to .bashrc => source .bashrc"
		echo "$a" >>"$HOME/.bashrc"
	}
	have '.bashrc' "$a"
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
	bash "$1" -b -p "$nvs_d_mamba" || {
		set -x
		head -n 1 "$1"
		set +x
		rm -f "$1"
		die "Installer failed - removed it."
	}
}

# we support d_mamba v_mamba pin_mamba
function install_mamba_binary_pkg_mgr {
	local hv_mamba fn crl url name
	crl=false
	test -d "$nvs_d_mamba" || {
		name="Mambaforge-$nvs_v_mamba-$(uname)-$(uname -m).sh"
		url="https://github.com/conda-forge/miniforge/releases/download/$nvs_v_mamba/$name"
		#test "$pin_mamba" == true -o "$nvs_v_mamba" == "latest" && {
		test "$nvs_v_mamba" == "latest" && {
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
	test -e "$nvs_d_mamba/bin/mamba" || die "No mamba dir: $nvs_d_mamba"
	hv_mamba="$("$nvs_d_mamba/bin/mamba" --version | xargs)"
	# die when pinned but different:
	local msg
	msg="Mamba ver conflict at $nvs_d_mamba (wanted: $nvs_v_mamba, have: $hv_mamba). Remove manually or change \$nvs_d_mamba to different location."
	test "$nvs_v_mamba" == "latest" && nvs_v_mamba="-" # only have minor not -<build>
	$nvs_pin_mamba && grep "${nvs_v_mamba%%-*}" <<<"$hv_mamba" 1>/dev/null || die "$msg"
	have "Mamba Binary Pkg Env" "$hv_mamba $(disk "$nvs_d_mamba")"
}

function ensure_tmux {
	local p1 t1
	t1="$nvs_mamba_tools"
	p1="$mamba_prefer_system_tools"
	nvs_mamba_tools="tmux"
	mamba_prefer_system_tools=false
	tmux -V | grep -q 'tmux 3' && mamba_prefer_system_tools=true
	install_binary_tools
	export nvs_mamba_tools="$t1"
	export mamba_prefer_system_tools="$p1"
	have Tmux "$(type tmux)"
}
# support ripgrep[=ver][:<rg|->]  (- for library, no name on system)
function install_binary_tools {
	echo "tools $nvs_mamba_tools"
	local f v pkg name spkgs pkgs vers vt
	vt=""
	for f in "$here/$nvs_distri" "$here"; do
		test -e "$f/versions_mamba.txt" || continue
		vers="$(cat "$f/versions_mamba.txt")"
	done
	IFS=' ' && for t in $nvs_mamba_tools; do
		pkg="${t%:*}"
		name="${t#*:*}"
		test "$name" == "-" || {
			test "$mamba_prefer_system_tools" == "true" && type "$name" 2>/dev/null 1>&2 && {
				spkgs="$spkgs $pkg"
				continue
			}
		}
		pkgs="$pkgs $pkg"
		test "$nvs_pin_mamba_pkgs" == "true" && {
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
	have_missing_installed || TMIF mamba install -y $vt
	have Tools "$pkgs $spkgs"
	test -z "${spkgs/ /}" || have "Tools Present" "$spkgs"
}

function install_shfmt {
	# avoiding install golang
	local fn fnm
	fn="$nvs_d_mamba/bin/shfmt"
	fnm="$HOME/.local/share/nvim/mason/bin/shfmt" # always in nvim path
	test -e "$fn" || {
		TSC "curl -L -o shfmt '$shfmt' && mv shfmt '$fn'" "then" chmod +x "$fn"
	}
	rm -f "$fnm"
	ln -s "$fn" "$fnm"
	have ShellFormatter "$fn"
}

function install_neovim {
	local a="$nvs_d_mamba/bin/nvim.appimg"
	local d="$nvs_d_mamba/bin/nvimfs"
	test -d "$d" || {
		local s="squashfs-root"
		rm -rf "$s"
		rm -rf "$nvs_d_mamba/bin/vi"
		test -e "$a" || TSC "curl -L -o '$a' '$url_nvim_appimg'" "then" chmod +x "$a"
		TSC "'$a' --appimage-extract" "then" mv "$s" "$d"
		ln -s "$d/AppRun" "$nvs_d_mamba/bin/vi"
	}
	have NeoVim "$d" "$(vi -v | head -n 1)"
}

function clone_astronvim {
	if [ -e "$d_conf_nvim" ]; then
		TSC "( builtin cd '$d_conf_nvim' && git pull )"
	else
		TSC "git clone 'https://github.com/AstroNvim/AstroNvim' '$d_conf_nvim'"
	fi
	$nvs_pin_distri && TSC "( builtin cd '$d_conf_nvim' && git status && git reset --hard '$nvs_v_distri'; )"
	have "AstroNvim Repo" "Pinned: $nvs_pin_distri. $(cd "$d_conf_nvim" && git log | grep Date | head -n 1)"
}

function lsp() {
	echo "lsp install $1"
	sleep 0.5
	T send-keys Escape
	TSK ":LspInstall $1"
	hint "Waiting for: $2"
	until (C | grep -q "$2"); do sleep 0.1; done
	T send-keys Escape
	have LSP "$1"
}

function install_astronvim {
	#t resize-window -x 150 -y 50
	local d
	local ts
	ts=$(date +%s) # total
	d="$HOME/.local/share/nvim/mason/bin"
	test -e "$d/pylsp" 2>/dev/null || {
		# we just start it, install begins autom:
		TSK "$nvs_d_mamba/bin/vi"
		until (C | grep Mason); do sleep 0.2; done
	  hint "Waiting for: 'Mason' to disappear"
		while (C | grep Mason >/dev/null); do sleep 0.2; done
		sleep 0.1
		TSK ':q!'
		sleep 0.1
	}
	have "Mason Binary Pkg Tool"
	test -e "$d/marksman" || {
		TSK "$nvs_d_mamba/bin/vi"
		sleep 1
		TSK ":TSInstall python bash css javascript vim"
		hint "Waiting for '[5/5]' and 'has been installed'"
		until (C | grep '[5/5]' | grep 'has been installed'); do sleep 0.1; done
		have Treesitter "python bash css javascript vim"

		lsp bashls '"bash-language-server" was successfully installed' # we have shellcheck
		lsp marksman '"marksman" was successfully installed'
		lsp pylsp '"python-lsp-server" was successfully installed'
		lsp sumneko_lua '"lua-language-server" was successfully installed'
		lsp vimls '"vim-language-server" was successfully installed'
		T send-keys Escape
		T send-keys Escape
		TSK ':q!'
		TSK ':q!'
	}
	start_time="$ts"
	have t AstroNvim "$(ls --format=commas "$d")"
}

function install_vim_user {
	set_symlinks() {
		local s=""
		local S="$here/$nvs_distri"
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
	TSC "$nvs_d_mamba/bin/vi -c 'autocmd User PackerComplete quitall' -c 'PackerSync'"
	#TSC "$nvs_d_mamba/bin/vi +PackerSync"
	TSK "$nvs_d_mamba/bin/vi"
	lsp ruff_lsp '"ruff-lsp" was successfully installed'
	T send-keys Escape
	T send-keys Escape
	TSK ':q!'
	TSK ':q!'
	have "User Packages" '.config/user.nvim/plugins/init.lua'
}

function clean_all {
	set -x
	rm -rf "$d_conf_nvim"
	rm -rf "$HOME/.local/share/nvim"
	rm -rf "$HOME/.local/state/nvim"
	rm -rf "$HOME/.cache/nvim"
	set +x
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
	echo -e "${d_:-}"
}

function Install {
	test "$in_tmux" == "false" && {
		export start_time
		export nvs_installing=true
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
		T new "$0" in_tmux install "$@"
		start_time=$(date +%s)
		sh set_nvs_function_to_bashrc
		echo -e '\x1b[1;38;5;119mFinished.\x1b[0m'
		echo -e '\n\nInstall Settings\n'
		env | grep nvs_ | sort

		echo -e '\n\nInstall Progress Log\n'
		cat "$inst_log"
		echo ''
		echo -e "- \x1b[1m$nvs_d_mamba/bin/vi\x1b[0m to start."
		echo -e "- \x1b[1mnvs <a|shell>\x1b[0m then vi to start with all tools available\n"
		echo "Docs: "
		echo "- https://mamba.readthedocs.io"
		echo "- https://astronvim.github.io"
		rm -f "$inst_log"
		return $?
	}
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
	echo -e 'Stashes:'
	ls -lta "$d_stash"
}
function activate_mamba_in_tmux {
	TSC "conda activate $nvs_d_mamba"
}
function kill_tmux_session {
	T kill-session
}
function shell {
	activate_mamba
	have "Mamba" "Shell"
	echo 'Deactive or exit to leave'
	export nvs_shell=true
	bash
}
function main {
	mkdir -p "$d_stash"
	test "$1" == "in_tmux" && {
		in_tmux=true
		shift
	}
	local action
	action="${1:-x}"
	shift
	case "$action" in
	clean-all) clean_all ;;
	i | install) Install "$@" ;;
	shell) shell ;;
	stash) stash "$@" ;;
	r | restore) unstash "$@" ;;
	status) status "$@" ;;
	*) show_help ;;
	esac
}

test "${1:-}" == "funcs" && {
	unset have
	return
}
main "$@"
