# AX AstroNVim Flavor (<TAB> expands)

Customizes [AstroNVim](https://github.com/AstroNvim/AstroNvim)


## Leader Keys

- `<SPACE>`: AstroNVim's map leader. Left unchanged.
- `,`: Additional Meta Key for custom shortcuts

👉 Type those, to see keychords starting with them (whichkey plugin)

## Config Files

All in ~/.config/nvim/lua/user

- init.lua
- polish.vim
- plugins/init.lua
- smart_vi_open.py

👉 `,g` on those filenames to open (see ,g below)

- Files are symlinked, from ~/.config/user.nvim into nvim's ~/.config/nvim
- Some ext tools, e.g. lazygit, blue, require ~/nvim activation (i.e. ~/nvim/bin in $PATH)

## Custom Shortcuts

Some defined in our `init.lua` (mappings, lsp.mappings) most still in `polish.vim`

👉 All default AstroNVim Shortcuts: https://astronvim.github.io/Basic%20Usage/mappings
👉 `:map` lists them all



### Folding

Foldmethod is "indent", globally.

- `<TAB>`: Opens all folds. `zM` closes all.
- `<Enter>`: Opens current fold
 
### Navigation

- `0`       Start of line
- `1`       First character in line (`^`)
- `;`       Currently open buffers
- `<Ctl>o`  Go back 
- `<Alt>o`  Go forward
- `<SPC>↩️`  Last edited buffer
- `<Alt>w`  Close buffer
- `,c`      Close window, close buffer
- `,d`      Done, write quit.
- `fj`      Better line concat, replacing J
- `J` `K`   Paragraph (next, previous)
- `H` `L`   Window left/right selection
- `,g`      Smart open[1]
- `,q`      ":q!" Leave file, forget changes
- `,Q`      ":quitall!" Leave all buffers, forget changes
- `,u`      Undo Tree
- `,w`      Autoformat file, then write

[1]: e.g. in browser if URL, or nvim if file, resolves md links) via smart_vi_open.py

### LSP

- `gd`      Goto definition (e.g. over function name)
- `,D`      All buffer Diagnostics
- `<Spc>lr` Rename e.g. function name
- `<Spc>lR` Find references
- `s`       Hover (code context help)

### Misc

- `,1`      Sources our init.lua
- `,2`      Opens our init.lua
- `,3`      Terminal in dir of current buffer
- `,C`      Colors (theme picker)
- `,r`      Evaluates as python, see https://github.com/axiros/vpe
- `,s`      Autosave mode on
- `ysiw]`   Wrap word into (e.g. ])

### File Type Specific

#### Markdown

- `,p`: Toggle presentation mode
- `,P`: Toggle rendering in $BROWSER (requires X/Wayland)
- `,t`: Pretty format tables

#### Python

- `,b`: Breakpoint, correctly indented
- `,e`: Wrap line into try-except block 


---

## Server Operation

### Clipbaord

To paste stuff *OUT* of a vi session running on a server, we have set +unnamedplus, i.e.
nvim tries X tools to copy into, on y.

=> Currently we expect a forwarded X session (`ssh -XY <host>` or via your
`~/.ssh/config`)

A compromised server might attack your X session. Decide for yourself.

---

## Install

- On a new linux machine, clone this repo into "~/.config/user.nvim"
- `~/.config/user.nvim/setup/nvs.sh i` or `... install`

### Handle Existing Installs

(Before installing)

To remove existing nvim config in ~.config/nvim and .local/share/nvim:

`~/.config/user.nvim/setup/nvs.sh clean-all` 

To move it away to a backup dir:

`~/.config/user.nvim/setup/nvs.sh stash <name>`

---

## 4 Noobs

- `:set tw=100`  Set width for wrapping
- `vip` Select paragraph
- `gq`  Rewrap paragraph

And 1 Mio others.  

----

> 👉 Live is a lesson. You've learned it when you're through.



