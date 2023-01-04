# AX AstroNVim Flavor (<TAB> expands)

Customizes [AstroNVim](https://github.com/AstroNvim/AstroNvim)


## Leader Keys

- `<SPACE>`: AstroNVim's map leader. Left unchanged.
- `,`: Additional Meta Key for shortcuts

👉 Type those, to see keychords starting with them (whichkey plugin)

## Config Files

- ~/.config/nvim/lua/user/init.lua
- ~/.config/nvim/lua/user/polish.vim
- ~/.config/nvim/lua/user/plugins/init.lua
- ~/.config/nvim/lua/user/smart_vi_open.py

👉 `gf` or `,g` on the filenames to open

- Files are symlinked, from ~/.config/user.nvim into nvim's ~/.config/nvim
- Some ext tools, e.g. lazygit, blue, require ~/nvim activation (i.e. ~/nvim/bin in $PATH)

## Custom Shortcuts

Some defined in our init,lua (mappings, lsp.mappings) most still in polish.vim

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
- `,1`      Sources our init.lua
- `,2`      Opens our init.lua
- `,3`      Terminal in dir of current buffer
- `<Ctl>o`  Go back 
- `<Alt>o`  Go forward
- `<SPC>↩️`  Last edited buffer
- `<Alt>w`  Close buffer
- `,c`      Close window, close buffer
- `,C`      Colors (theme picker)
- `,d`      Done, write quit.
- `,D`      All buffer Diagnostics
- `,g`      Smart open (e.g. in browser if URL, or nvim if file, resolves md links) via smart_vi_open.py (👉 try `,g` on this filename)
- `gd`      Goto definition (e.g. over function name)
- `<Spc>lr` Rename e.g. function name
- `<Spc>lR` Find references
- `,q`      ":q!" Leave file, forget changes
- `,Q`      ":quitall!" Leave all buffers, forget changes
- `,r`      Evaluates as python, see https://github.com/axiros/vpe
- `s`       Hover (code context help)
- `,u`      Undo Tree
- `,w`      Autoformat file, then write

### File Type Specific

#### Markdown

- `,p`: Toggle presentation mode
- `,P`: Toggle rendering in $BROWSER (requires X/Wayland)
- `,t`: Pretty format tables

#### Python

- `,b`: Breakpoint, correctly indented
- `,e`: Wrap line into try-except block 


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
