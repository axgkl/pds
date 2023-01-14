# AX AstroNVim Flavor

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

- init.lua
- polish.vim
- plugins/init.lua
- smart_vi_open.py

👉 `,g` on those filenames to open (see ,g below)

- Files are symlinked, from ~/.config/pds into nvim's ~/.config/nvim
- Some ext tools, e.g. lazygit, blue, require ~/nvim activation (i.e. ~/nvim/bin in $PATH)

## Custom Shortcuts

Some defined in our `init.lua` (mappings, lsp.mappings) most still in `polish.vim`

👉 All default AstroNVim Shortcuts: https://astronvim.github.io/Basic%20Usage/mappings 👉 `:map`
lists them all



### Folding

Foldmethod is "indent", globally, except for markdown

- `<TAB>`: Opens all folds. `zM` closes all.
- `<Enter>`: Opens current fold
 
### Navigation

- `;`       Currently open buffers
- `<Ctl>o`  Go back 
- `<Alt>o`  Go forward
- ` ↩️`  Last edited buffer
- `<Alt>w`  Close buffer
- `,c`      Close window, close buffer
- `,d`      Done, write quit.
- `G`       Jump to end of file - except to string `"begin__archive"` (but with ONE underscore), when found in buffer
- `J` `K`   Paragraph (next, previous)
- `H` `L`   Window left/right selection
- `,g`      Smart open[1]
- `,q`      ":q!" Leave file, forget changes
- `,Q`      ":quitall!" Leave all buffers, forget changes
- `,u`      Undo Tree
- `,w`      Autoformat file, then write

[1]: e.g. in browser if URL, or nvim if file, resolves md links) via smart_vi_open.py

### Editing

- `0`       Start of line
- `1`       First character in line (`^`)
- `fj`      Better line concat, replacing J
- `jk`      Same as `<ESC>` in insert mode
- `ds]`     [Remove delimiters smartly (e.g. here: [foo bar] -> foo bar)][vim-surround] 
- `ysiw]`   [Wrap word into (e.g. here: foo -> [foo])][vim-surround]
- `,s`      [Autosave mode on: Write after insert mode leave][autosave]
- `ga,`     [Align selected lines on sth, e.g. here: on ","][tabularize]


### LSP

- `gd`      Goto definition (e.g. over function name)
- `,D`      All buffer Diagnostics
- ` lr`     Rename e.g. function name
- ` lR`     Find references
- ` lx`     Diagnostics on/off toggle
- `s`       Hover (code context help)

👉 `:LSPInstall`

### Misc

- `,1`      Sources our init.lua
- `,2`      Opens our init.lua
- `,3`      Terminal in dir of current buffer
- `,C`      Colors (theme picker)
- `,r`      Evaluates as python, see https://github.com/axiros/vpe

### File Type Specific

#### Man Pages

You can view man pages in vim like so: alias man='pds vman'

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

To copy selected stuff *OUT* of a vi session running on a server, we have set +unnamedplus. I.e.
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

- `:messages`    Show all messages printed up to now
- `:set tw=100`  Set width for wrapping
- `gq`           Rewrap paragraph
- `vip`          Select paragraph, e.g. `vipga=` to align on "="
- `zM`           Closes all folds
- `:!ls -lta`    Runs a command
- `:echo &tw`    Shows the set value of a vim variable 
- `:echo &tw`    Shows the set value of a vim variable 
- `vip<Ctrl>VI`  Block mode vertical editing (rendered for all selected lines after <ESC>)
- `:lua vim.inspect(package.loaded)` Print loaded packages, e.g. Python's "sys.modules".
  Setting one to nil here will trigger a reload at next require of it.

...and 1 Mio others. [Live is a lesson. You learned it when you're through][lp] 🥲

----

## Links

[vim-surround]: https://github.com/tpope/vim-surround
[autosave]: https://github.com/Pocco81/auto-save.nvim
[whichkey]: https://github.com/folke/which-key.nvim
[tabularize]: https://github.com/godlygeek/tabular
[lp]: https://www.youtube.com/watch?v=HtPL2YhK6h0&t=165s

