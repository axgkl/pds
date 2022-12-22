#!/usr/bin/env bash

# --------------------------------------------------------------------------------------- sourcing
# when sourced, handle only act/deact - w/o spamming the process namespace with stuff below
set +x; test "$1" == "-x" && { shift; set -x; }
is_sourced=true
echo "$0" | grep nvs.sh >/dev/null 2>&1 && is_sourced=false

here="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$here/environ"
d_mamba="${d_mamba:-$dflt_d_mamba}"


function activate_mamba {
	source "$d_mamba/etc/profile.d/conda.sh"
	conda activate "$d_mamba"
	test "$CONDA_PREFIX" == "$d_mamba" || die "Could not activate $d_mamba"
	echo "Activated $d_mamba"
}

function deactivate_mamba {
	_() { echo "Deactivated $d_mamba"; }
	test "${nvs_shell:-}" == "true" && _ && exit
	conda deactivate
}

function handle_sourced {
	case "${1:-x}" in
	a | activate)
		activate_mamba
		$is_sourced || bash
		;;
	d | deactivate)
		deactivate_mamba
		$is_sourced || bash
		;;
	*) "$here/nvs.sh" "$@" ;;
	esac
}

# return when sourced
$is_sourced && {
	handle_sourced "$@"
	return
}

# --------------------------------------------------------------------------------------- process
set -a
distri="${distri:-$dflt_distri}"
d="$here/$distri"
test -d "$d" || { echo "Not found: $d"; exit 1; }
source "$d/environ"
v_distri="${v_distri:-$dflt_v_distri}"
d_mamba="${d_mamba:-$dflt_d_mamba}"
v_nvim="${v_nvim:-$dflt_v_nvim}"
v_mamba="${v_mamba:-$dflt_v_mamba}"
v_shfmt="${v_shfmt:-$dflt_v_shfmt}"
mamba_prefer_system_tools="${mamba_prefer_system_tools:-$dflt_mamba_prefer_system_tools}"
mamba_tools="${mamba_tools:-$dflt_mamba_tools}"
pin_mamba="${pin_mamba:-$dflt_pin_mamba}"
pin_mamba_pkgs="${pin_mamba_pkgs:-$dflt_pin_mamba_pkgs}"
pin_distri="${pin_distri:-$dflt_pin_distri}"
pin_nvim_pkgs="${pin_nvim_pkgs:-$dflt_pin_nvim_pkgs}"
set +a



#
d_conf_nvim="$HOME/.config/nvim"
d_stash="$HOME/.local/share/stashed_nvim"
url_nvim_appimg="https://github.com/neovim/neovim/releases/download/v$v_nvim/nvim.appimage"
shfmt="https://github.com/mvdan/sh/releases/download/v$v_shfmt/shfmt_v${v_shfmt}_linux_amd64"
inst_log="$HOME/nvs_have.log"

d_='NeoVim Setup Tools

USAGE: nvs i(nstall)
           a(ctivate)
           d(eactivate)
           clean-all
           shell
           stash <name> (not yet)
           restore <name> (not yet)
           status (not yet)

REQUIREMENTS:

- (Any) Linux
- The repo containing this file (anywhere)
- Using bash (we set "nvs" convenience function into .bashrc). Other shells: do it manually.

ACTIONS:

[DE]Activate:
- When this script is sourced (via nvs function), we (de)activate '$d_mamba' in current shell

Install:
- Ensures nvs function to this script in .bashrc
- Creates conda(mamba) environment at '$d_mamba', with tools:
  '$mamba_tools'
- Installs NeoVim '$v_nvim'
- Installs Nvim '$distri' Distribution 
- Installs User Config

Set install params into "'$here'/environ" or export them before install.

Clean All:
- Removes .config/nvim, .local/share/nvim and .local/state/nvim
- Leaves the mamba tools at '$d_mamba'

Shell: Enter a shell with '$d_mamba' activated

Status: Shows status of all installables and stashes

Stash <name>: TBD
Restore: <name>: TBD
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

function T { t_ "$tmux_sock" "$@"; }
function C { T capture-pane -p; }

# tmux send-key convenience, this way we can send anything w/o space problems:
function hex {
	python -c 'import sys; l=[hex(ord(c))[2:] for c in sys.argv[1]];print(" ".join(l) + " a", end="")' "$1"
}

# tmux send keys
function TSK {
	local cmd
	cmd="$(hex "$1")"
	eval T send-keys -H "$cmd"
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

# wait for file then do action
function waitfor {
	while ! test -e "$1"; do sleep 0.1; done
	test "$2" == "then" && {
		shift
		shift
		eval "$*"
	}
}

# pretty output:
function sh {
	echo -e "\x1b[31m$1\x1b[0m"
	"$@"
}

function have {
	local dt b
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
	msg="$(printf "\x1b[2m%5s$b\x1b[0m \x1b[1;34m✔️\x1b[0m %-30s %s\x1b[0m\n" "$dt" "\x1b[1m$h" "\x1b[2m $*")"
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
    local dd; dd=""
    for d in .local/share .local/state .cache .config; do
        mkdir -p "$HOME/$d"
        dd="$dd$d "
    done
    have "Directories" "$dd"
}
function install_mamba {
    bash "$1" -b -p "$d_mamba" || { set -x; head -n 1 "$1"; set +x; rm -f "$1"; die "Installer failed - removed it."; }
}

# we support d_mamba v_mamba pin_mamba
function install_mamba_binary_pkg_mgr {
	local hv_mamba fn crl url name; crl=false
	test -d "$d_mamba" || {
		name="Mambaforge-$v_mamba-$(uname)-$(uname -m).sh"
        url="https://github.com/conda-forge/miniforge/releases/download/$v_mamba/$name"
        #test "$pin_mamba" == true -o "$v_mamba" == "latest" && {
        test "$v_mamba" == "latest" && {
		    name="Mambaforge-$(uname)-$(uname -m).sh"
            url="https://github.com/conda-forge/miniforge/releases/latest/download/$name"
        }
        echo "Installer: $name"
        fn="$HOME/.cache/$name"
		test -f "$fn" || (
            type curl 2>/dev/null 1>&2 && crl=true
            echo "Not present - downloading $url"
            $crl &&  curl -L -o "$fn" "$url"
            $crl ||  wget "$url" -O "$fn"
            test -e "$fn" || die "could not download $url"
            have "Mamba Installer" "$fn"
		)
        sh install_mamba "$fn"
	}
    test -e "$d_mamba/bin/mamba" || die "No mamba dir: $d_mamba"
    hv_mamba="$($d_mamba/bin/mamba --version | xargs)"
    # die when pinned but different:
    local msg; msg="Mamba ver conflict at $d_mamba (wanted: $v_mamba, have: $hv_mamba). Remove manually or change \$d_mamba to different location."
    test "$v_mamba" == "latest" && v_mamba="-" # only have minor not -<build>
    $pin_mamba && grep "${v_mamba%%-*}" <<< "$hv_mamba" 1>/dev/null || die "$msg"
	have "Mamba Binary Pkg Env" "$hv_mamba $(disk $d_mamba)"
}

# support ripgrep[=ver][:<rg|->]  (- for library, no name on system)
function install_binary_tools {
    local f v pkg name spkgs pkgs vers vt; vt="" 
    for f in "$here/$distri" "$here"; do
        test -e "$f/versions_mamba.txt" || continue
        vers="$(cat "$f/versions_mamba.txt")"
    done
    IFS=' ' && for t in $mamba_tools
    do
       pkg="${t%:*}"
       name="${t#*:*}"
       test "$name" == "-" || {
           test "$mamba_prefer_system_tools" == "true" && type "$name" 2>/dev/null 1>&2 && {
                    spkgs="$spkgs $pkg"
                    continue
            }
       }
       pkgs="$pkgs $pkg"
       test "$pin_mamba_pkgs" == "true" && {
             v="$(grep "^$pkg=" <<< $vers)"
             pkg="${v:-$pkg}"
        }
             vt="$pkg $vt"
    done
    function have_installed {
        local e;e="$(mamba list --export)"
        # try be fast at re-installs and search the tools in pkgs:
        vers=""
        for k in $vt; do
            grep -q "^$k" <<< "$e" || vers="$k $vers"
        done
        test -z "${vers/ /}"
    }
    have_installed || eval mamba install -y "$vt"
	have Tools "$pkgs $spkgs"
    
    test -z "${spkgs/ /}" || have "Tools Present" "$spkgs"
}

# avoiding install golang
function install_shfmt {
	local fn
	fn="$d_mamba/bin/shfmt"
	test -e "$fn" || {
		TSC "curl -L -o shfmt '$shfmt' && mv shfmt '$fn'" "then" chmod +x "$fn"
	}
	have ShellFormatter "$fn"
}

function install_neovim {
	local a="$d_mamba/bin/nvim.appimg"
	local d="$d_mamba/bin/nvimfs"
	test -d "$d" || {
		local s="squashfs-root"
		rm -rf "$s"
		rm -rf "$d_mamba/bin/vi"
		test -e "$a" || TSC "curl -L -o '$a' '$url_nvim_appimg'" "then" chmod +x "$a"
		TSC "'$a' --appimage-extract" "then" mv "$s" "$d"
		ln -s "$d/AppRun" "$d_mamba/bin/vi"
	}
	have NeoVim "$d" "$(vi -v | head -n 1)"
}

function clone_astronvim {
	if [ -e "$d_conf_nvim" ]; then
		TSC "( cd '$d_conf_nvim' && git pull )"
	else
		TSC "git clone 'https://github.com/AstroNvim/AstroNvim' '$d_conf_nvim'"
	fi
    $pin_distri && TSC "( cd '$d_conf_nvim' && git status && git reset --hard '$v_distri'; )"
	have "AstroNvim Repo" "$(cd "$d_conf_nvim" && git log | grep Date | head -n 1)"
}

function install_astronvim {
	#t resize-window -x 150 -y 50
	local d
	local ts
	ts=$(date +%s) # total
	d="$HOME/.local/share/nvim/mason/bin"
	test -e "$d/pyright-langserver" 2>/dev/null || {
		TSK vi
		until (C | grep Mason); do sleep 0.2; done
		while (C | grep Mason >/dev/null); do sleep 0.2; done
		sleep 0.1
		TSK ':q!'
		sleep 0.1
	}
	have "Mason Binary Pkg Tool"
	test -e "$d/marksman" || {
		TSK vi
		sleep 1
		TSK ":TSInstall python bash css javascript"
		until (C | grep '[4/4]' | grep 'has been installed'); do sleep 0.1; done
		have Treesitter "python bash css javascript"

		lsp() {
			echo "lsp install $1"
			sleep 0.5
			T send-keys Escape
			TSK ":LspInstall $1"
			until (C | grep -q "$2"); do sleep 0.1; done
			T send-keys Escape
			have LSP "$1"
		}
		#lsp bashls '"bash-language-server" was successfully installed' # we have shellcheck
		lsp marksman '"marksman" was successfully installed'
		lsp pyright '"pyright" was successfully installed'
		lsp sumneko_lua '"lua-language-server" was successfully installed'
		lsp vimls '"vim-language-server" was successfully installed'
		TSK ':q!'
	}
	start_time="$ts"
	have t AstroNvim "$(ls --format=commas "$d")"
}

function install_vim_user {
	set_symlinks() {
		local s=""
		local S="$here"
		local T="$d_conf_nvim"
		rm -f "$T/lua/user"
		ln -s "$S" "$T/lua/user"
		for k in after spell ftplugin snippets; do
			s="$s $k"
			rm -f "$T/$k"
			TSC "ln -s "$S/$k" "$T/$k""
		done
		have 'User Config' "Symlinks:$s"
	}
	set_symlinks
    TSC "vi -c 'autocmd User PackerComplete quitall' -c 'PackerSync'"
	have "User Packages" '.config/user.nvim/plugins/init.lua'
	T kill-session
}

function clean_all {
	set -x
	rm -rf "$d_conf_nvim"
	rm -rf "$HOME/.local/share/nvim"
	rm -rf "$HOME/.local/state/nvim"
	rm -rf "$HOME/.cache/nvim"
	set +x
}

function show_help {
	echo -e "$d_"
}
function Install {
	test "$1" == "in_tmux" || {
		export start_time
		start_time=$(date +%s)
		rm -f "$inst_log"
		sh ensure_dirs
		sh install_mamba_binary_pkg_mgr
		sh activate_mamba
		sh install_binary_tools
		echo 'Switching into tmux'
		shift
		T ls 2>/dev/null && {
			T kill-session
			sleep 0.4
		}
		T new "$0" install in_tmux "$@"
		start_time=$(date +%s)
		sh set_nvs_function_to_bashrc
		echo 'Finished.'
		echo -e '\n\nInstall Progress Log\n'
		cat "$inst_log"
		echo ''
		echo -e "- \x1b[1m$d_mamba/bin/vi\x1b[0m to start."
		echo -e "- \x1b[1mnvs <a|shell>\x1b[0m then vi to start with all tools available\n"
		echo "Docs: "
		echo "- https://mamba.readthedocs.io"
		echo "- https://astronvim.github.io"
		rm -f "$inst_log"
		return $?
	}
	# in tmux from here
	T split-pane -h
	T resize-window -x 200
	T resize-pane -x 110
	sh install_shfmt
	sh install_neovim
	sh clone_astronvim
	sh install_astronvim
echo foo
read -p foo
return
	sh install_vim_user
	return
}
function shell {
	activate_mamba
	have "Mamba" "Shell"
	echo 'Deactive or exit to leave'
	export nvs_shell=true
	bash
}

function main {
	local action
	action="${1:-x}"
	shift
	case "$action" in
	shell) shell ;;
	clean-all) clean_all ;;
	stash) stash "$@" ;;
	i | install) Install "$@" ;;
	*) show_help ;;
	esac
}

test "${1:-}" == "funcs" && {
	unset have
	return
}
main "$@"
