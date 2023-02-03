# AX AstroNVim Flavor

<!--toc:start-->

- [AX AstroNVim Flavor](#ax-astronvim-flavor)
  - [Leader Keys](#leader-keys)
  - [Config Files](#config-files)
  - [Custom Shortcuts](#custom-shortcuts)
    - [File Type Specific](#file-type-specific)
      - [Explorer ([NeoTree][neotree])](#explorer-neotreeneotree)
      - [Man Pages](#man-pages)
      - [Markdown](#markdown)
      - [Python](#python)
  - [Vim Helpers](#vim-helpers)
  - [Lua Helpers](#lua-helpers)
  - [Server Operation](#server-operation)
    - [Clipbaord](#clipbaord)
  - [Install](#install)
    - [Handle Existing Installs](#handle-existing-installs)
  - [Vim 4 Noobs](#vim-4-noobs)
  - [Links](#links)
  <!--toc:end-->

Customizes [AstroNVim](https://github.com/AstroNvim/AstroNvim)

Usage:

- `<Enter>` expands,
- `<TAB>` expands all.
- `,P` Read in browser (when on your machine)

## Leader Keys

- ` `: AstroNVim's map leader (space bar). Left unchanged.
- `,`: Additional Meta Key for custom shortcuts

👉 Type those, to [see keychords starting with them][whichkey]

## Config Files

All in ~/.config/nvim/lua/user

Main files:

- init.lua
- polish.vim
- plugins/init.lua
- smart_vi_open.py
- mappings.md

👉 `,g` on those filenames to open (see ,g below)

- Files are symlinked, from ~/.config/pds into nvim's ~/.config/nvim
- Some ext tools, e.g. lazygit, blue, require access to these tools (i.e. ~/pds/bin in $PATH)

## Custom Shortcuts

Global ones defined in [mappings.md](./mappings.md).

### File Type Specific

#### Explorer ([NeoTree][neotree])

- ` o`: Open the explorer (`,c` or `alt-w` closes)
- `P`: Enter preview mode
- `?`: Help

#### Man Pages

You can view man pages in vim like so: `alias man='pds vman'`

#### Markdown

- `,p`: Toggle presentation mode
- `,P`: Toggle rendering in $BROWSER (requires X/Wayland)
- `,t`: Pretty format tables

#### Python

- `,b`: Breakpoint, correctly indented
- `,e`: Wrap line into try-except block

---

## Vim Helpers

- `Redir: <cmd>` redirects command output to scratch buffer. Ex: `:Redir !ls -lta`

## Lua Helpers

Available as `:lua require('user.utils')` or `:lua UU`

- `dump(<table)`: Prints table recursively. Ex: `:lua UU.dump(vim.lsp)`
- `P(<table)`: Prints table recursively. Ex: `:lua P(vim.lsp)`

## Server Operation

### Clipbaord

To copy selected stuff _OUT_ of a vi session running on a server, we have set +unnamedplus. I.e.
nvim tries X tools to copy into your clipboard, on y.

=> Currently we expect a forwarded X session (`ssh -XY <host>` or via your `~/.ssh/config`)

> ❗ A compromised server might attack your X session. Decide for yourself.  
> `set mouse=n` gives you mouse based selection and copying.

---

## Install

- On a new linux machine, clone this repo into "~/.config/pds"
- `~/.config/pds/setup/pds.sh i` or `... install`

This will add an pds function into your .bashrc. Call it to see supported actions.

### Handle Existing Installs

(Before installing)

To remove existing nvim config in ~.config/nvim and .local/share/nvim:

`~/.config/pds/setup/pds.sh clean-all`

To move it away to a backup dir:

`~/.config/pds/setup/pds.sh stash <name>`

---

## Vim 4 Noobs

- `:messages` Show all messages printed up to now
- `:set tw=100` Set width for wrapping
- `gq` Rewrap paragraph
- `vip` Select paragraph, e.g. `vipga=` to align on "="
- `zM` Closes all folds
- `:!ls -lta` Runs a command
- `:echo &tw` Shows the set value of a vim variable
- `:echo &tw` Shows the set value of a vim variable
- `vip<Ctrl>VI` Block mode vertical editing (rendered for all selected lines after <ESC>)
- `:lua vim.inspect(package.loaded)` Print loaded packages, e.g. Python's "sys.modules".
  Setting one to nil here will trigger a reload at next require of it.

...and 1 Mio others. [Live is a lesson. You learned it when you're through][lp] 🥲

---

## Links
