# Personal Development Sandbox

[![gh-ci][gh-ci-img]][gh-ci]

[gh-ci]: https://github.com/AXGKl/pds/actions/workflows/main.yml
[gh-ci-img]: https://github.com/AXGKl/pds/actions/workflows/main.yml/badge.svg

This installs an IDE and tools, organized so that it won't collide with anything else on the system.


It is intended for

- local and server operation, based on [Mamba][mamba] and [NeoVim][neovim].
- Neovim is your IDE
- Mamba is the package manager for underlying tools the IDE is based upon, incl. a compiler
- python, javascript, lua, shell, markdown lsp support ootb - but extendable

It does not require elevated perms to install.

Customization of NeoVim is based on the **[AstroNVim][astronvim]** distribution.

## Bootstrap Installation

```bash
wget https://raw.githubusercontent.com/AXGKl/pds/master/setup/pds.sh
chmod +x pds.sh
./pds.sh i[nstall]
```

Requirements: bash, wget.

OS: Currently only tested on Linux.

💡 OSX and BSDs *should* work as well. We do use the Linux style configuration directories though.


This is a run on a minimal debian server:

[![asciicast](https://asciinema.org/a/QObqodPheKWM7A7fUzkveDvzr.svg)](https://asciinema.org/a/QObqodPheKWM7A7fUzkveDvzr)

💡 The installation look and feel may be further improved in the future but you get the idea...

### Existing NeoVim Install

Before installing pds, you might want to run `pds.sh stash mybackup`.

This moves `~/.config/nvim`, `~/.local/state/nvim`, `~/.local/share/nvim` to an archive, ready for
later restoration via `pds restore mybackup`.

`pds clean-all` would erase the existing install.

## Features

[Here](./setup/astro/README.md) is what you get, currently.


## Usage

vi (opening neovim) is installed callable from the app image into `~/pds/bin/vi`.

At pds install time, we've set a function to your `.bashrc` (and `.zshrc`, if in use):

    function pds { source "/home/gk/.config/pds/setup/pds.sh" "$@"; }

This allows to call neovim in 3 different ways:

- `$HOME/bin/vi`: runs neovim - but additional mamba tools are not in your $PATH
- `pds <tool, e.g. vi>`: calls `( insert ~/pds/bin to $PATH && <tool> )`, i.e. you have
  the PATH set, while executing vi.
- `pds a[ctivate]` and subsequently `vi`: First adds the path permanently, then will find
  `vi` (or other tools later)

We recommend the last way, calling `pds a` e.g. in `.profile`:

When activating virtual environments after `pds a`, you'll have their tools (e.g. python)
AND the ones from pds - in the right search order - available in your editor.



## Further Personalization

TBD


---

[astronvim]: https://astronvim.github.io/
[mamba]:  https://github.com/mamba-org/mamba
[neovim]: https://neovim.io
[pde]: https://www.youtube.com/watch?v=IK_-C0GXfjo
