# Personal Development Sandbox

This installs an IDE and tools, organized so that it won't collide with anything else on the system.


It is intended for

- local and server operation, based on [Mamba][mamba] and [NeoVim][neovim].
- Neovim is your IDE
- Mamba is the package manager for underlying tools the IDE is based upon, incl. a compiler
- python, javascript, lua, shell, markdown lsp support ootb but extendable

It does not require elevated perms to install.

Customization of NeoVim is based on a distri, currently [AstroNVim][astronvim]

## Bootstrap Installation

```bash
wget https://raw.githubusercontent.com/AXGKl/pds/master/setup/pds.sh
chmod +x pds.sh
./pds.sh i[nstall]
```

Requirements: bash, wget.

OS: Currently only tested on Linux.

💡 OSX and BSDs should work as well. We do use the Linux style config directories though.


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


## Further Personalization

TBD


---

[astronvim]: https://astronvim.github.io/
[mamba]:  https://github.com/mamba-org/mamba
[neovim]: https://neovim.io
[pde]: https://www.youtube.com/watch?v=IK_-C0GXfjo
