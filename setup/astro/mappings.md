# Mappings

This file is the _source_ for `mappings.lua` and **intended to be viewed in vi** or
[raw][mapraw] in the browser. In rendered HTML you can't see the mappings in angle
brackets, e.g. `<Enter>` (we don't clutter the tables with backticks).

<!--toc:start-->

- [Mappings](#mappings)
  - [Folding](#folding)
  - [Navigation](#navigation)
  - [Editing](#editing)
  - [Hopping Around](#hopping-around)
  - [LSP](#lsp)
  - [Misc](#misc)
  - [Usage](#usage)
    - [Symbols](#symbols)
  - [Helpers](#helpers) - [Arch](#arch) - [Links](#links) - [Parser](#parser) - [Code](#code)
  <!--toc:end-->

👉 All default AstroNVim Shortcuts: https://astronvim.github.io/Basic%20Usage/mappings  
👉 `:map` lists them all  

## Folding

| Mapping | M   | What            | How | Cmt                       |
| ------- | --- | --------------- | --- | ------------------------- |
| <C-i>   | 🟣  | Fold open     | zR  | " folds                   |
| <Enter> | 🟣  | Toggle fold     | za  |
| <S-Tab> | 🟣  | Close ALL Folds | zM  | <C-i> is ident with <TAB> |

Type z and let which key help you, regarding other options

## Navigation

| Mapping         | M   | What                          | How                                        | Cmt                                                                              |
| --------------- | --- | ----------------------------- | ------------------------------------------ | -------------------------------------------------------------------------------- |
| ,c              | 🟣  | Close :close                  | :close ⏎                                   | Close just a split or a tab                                                      |
| ,g              | 🟣  | [Open file or URL][vpe_goto]  | :silent call PyEvalSelection('SmartGoto', '') ⏎   | https://github.com/axiros/vpe        |
| ,g              | 🟢  | [Open file or URL][vpe_goto]  | :<C-U> silent call PyEvalSelection('SmartGoto', visualmode()) ⏎                          |
| ,q              | 🟣  | Quit all!                     | :quitall! ⏎                                |
| ,u              | 🟣  | Undo Tree                     | :UndotreeToggle ⏎                          |                                                                                  |
| -SEMICOL-       | 🟣  | Buffers open                  | `TS().buffers()`                           | 🟥 does not repeat last f t F T                                                  |
| <M-o>           | 🟣  | Jump newer (after C-o)        | <C-i>                                      | C-o jump older -> alt-o is jump newer (since C-i is tab which we need elsewhere) |
| <M-w>           | 🟣  | Buffer delete :bd!            | :bd! ⏎                                     | Close window                                                                     |
| <leader>fg      | 🟣  | Git files                     | `TS().git_files()`                         |
| <leader><enter> | 🟣  | Previous edited buffer        | :ls<CR>:b#<CR><Space>                      | in your open buffers (toggle back and forth) :b# ⏎ " previous buffer             |
| G               | 🟣  | End of file                   | :$<CR><bar>:silent! ?begin-UNDER-archive ⏎ | Move stuff you want to keep below a `begin_ archive` comment and G jumps to that |
| ff              | 🟣  | Open file(from vi start dir)  | `TS().find_files()`                        | You can open many files at once, by selecting them with TAB in the picker        |
| gw              | 🟣  | Live grep words               | `TS().live_grep()`                         | 🟥 gw reformat via gq                                                            |

🟥 Arrow keys resize split windows, i.e. **won't** work for navigation (hjkl ftw)

- `<Ctl>o` Jump last place (u knew that)
- `H` `L` Window left/right selection

## Editing

| Mapping   | M   | What                        | How                              | Cmt                                                                          |
| --------- | --- | --------------------------- | -------------------------------- | ---------------------------------------------------------------------------- |
| ,d        | 🟣  | Done - write quit           | :wq! ⏎                           |
| ,s        | 🟣  | Toggle Autosave all buffers | :ASToggle ⏎                      | See [here][autosave]                                                         |
| ,w        | 🟣  |                             | :FormatAndSave ⏎                 |
| <C-s>     | 🟣  | Save File                   | w!                               |
| <Down>    | 🟣  | Resize split down           | `SS().resize_down(2)`            |
| <Left>    | 🟣  | Resize split left           | `SS().resize_left(2)`            |
| <Right>   | 🟣  | Resize split right          | `SS().resize_right(2)`           |
| <Up>      | 🟣  | Resize split up             | `SS().resize_up(2)`              |
| <leader>d | 🟣  | Delete noregister           | `'"_d`                           | In visual or normal mode, delete w/o overwriting your "pasteable content"    |
| <leader>d | 🟠  | Delete noregister           | `'"_d`                           |
| S         | 🟣  | Easy global replace         | :%s//gI<Left><Left><Left>        |
| Y         | 🟣  | Yank (like C and D)         | y$                               |
| fj        | 🟣  | Line join                   | $mx<cmd>join ⏎0$[-BACKTICK-dmx h | Line join better, position cursor at join point : " (J is para down)         |
| ga        | 🟣  |                             | :Tabularize/                     |
| ga        | 🟢  |                             | :Tabularize/                     |
| gq        | 🟣  | Format w/o formatexpr       | gwgw                             | null-ls messes formatexpr for some reason, which [affects `gq`][gqbugorfeat] |

- `0` Start of line
- `jk` Same as `<ESC>` in insert mode
- `ds]` [Remove delimiters smartly (e.g. here: [foo bar] -> foo bar)][vim-surround]
- `ysiw]` [Wrap word into (e.g. here: foo -> [foo])][vim-surround]
- `,s` [Autosave mode on: Write after insert mode leave][autosave]
- `,t` [Format](./ftplugin/markdown.vim) markdown table. ';' is converted to "|"
- `ga,` [Align selected lines on sth, e.g. here: on ","][tabularize]

## Hopping Around

| Mapping | M   | What                        | How             | Cmt                                 |
| ------- | --- | --------------------------- | --------------- | ----------------------------------- |
| ,f      | 🟣  | Hop char line               | `HopLine('f')`  |
| ,t      | 🟣  | Hop char line               | `HopLine('t')`  | vtx: select until char 'x'          |
| 11      | 🟣  | First no empty char in line | ^               | 🟥 The number 11 as count will work |
| <M-j>   | 🟤  | Jump Left Split             | <ESC><C-W><C-W> |
| <M-j>   | 🟣  | Jump Left Split             | <C-W><C-h>      |
| <M-k>   | 🟤  | Jump Right Split            | <ESC><C-W><C-W> |
| <M-k>   | 🟣  | Jump Right Split            | <C-W><C-l>      |
| J       | 🟣  | Jump paragraph down         | }j              | 🟥 J won't line-join. fj for that   |
| K       | 🟣  | Jump paragraph up           | {k{kkJ          |
| fk      | 🟣  | Hop char                    | :HopChar1 ⏎     |
| fl      | 🟣  | Hop line                    | :HopLine ⏎      |

[hop.nvim](https://github.com/phaazon/hop.nvim)

Since `f` alone is already "find forward char on current line", we cannot display help for those

## LSP

| Mapping | M   | What               | How                           | Cmt |
| ------- | --- | ------------------ | ----------------------------- | --- |
| ,D      | 🟣  | Buffer Diagnostics | `TS().diagnostics({bufnr=0})` |

- `gd` Goto definition (e.g. over function name)
- ` lr` Rename e.g. function name
- ` lR` Find references
- ` lx` [Diagnostics on/off toggle](./lsp/mappings.lua)
- `s` [Hover (code context help)](./lsp/mappings.lua) 🟥 Can't see the use of s (delete into register) vs x

👉 `:LSPInstall`

## Misc

| Mapping    | M   | What                  | How                                       | Cmt                                  |
| ---------- | --- | --------------------- | ----------------------------------------- | ------------------------------------ |
| ,1         | 🟣  | Reload init.lua       | :source ~/.config/nvim/init.lua ⏎         |                                      |
| ,2         | 🟣  | Edit init.lua         | :edit ~/.config/nvim/lua/user/init.lua ⏎  |                                      |
| ,3         | 🟣  | Term in dir of buf    | :ToggleTerm dir=%:p:h ⏎                   |
| ,C         | 🟣  | Color Schemes         | `TS().colorscheme({enable_preview=true})` |
| ,E         | 🟣  | Vim Eval Into         | :EvalInto ⏎                               |
| ,E         | 🟢  | Vim Eval Into         | :EvalInto ⏎                               |
| ,G         | 🟣  | Lazygit               | :TermExec cmd=lazygit ⏎                   |
| ,W         | 🟣  | Save all buffers      | :wa ⏎                                     |
| ,r         | 🟣  | [VimPythonEval][vpe]  | :call PyEvalSelection('Eval', '') ⏎       | https://github.com/axiros/vpe        |
| ,r         | 🟢  | VimPythonEval         | :<C-U> call PyEvalSelection('Eval', visualmode()) ⏎  |
| <C-E>      | 🟤  |                       | <C-O>A                                    | " Jump to end of line in insert mode |
| <C-H>      | 🟣  |                       | <C-W><C-K>                                |
| <C-L>      | 🟣  |                       | <C-W><C-J>                                |
| <M-H>      | 🟣  | pds help              | :edit ~/.config/nvim/lua/user/README.md ⏎ |
| <leader>mm | 🟣  | Mind Main             | :MindOpenMain ⏎                           |
| <leader>mp | 🟣  | Mind Project          | :MindOpenSmartProject ⏎                   |
| gq         | 🟠  | Format w/o formatexpr | gwgw                                      |
| ⏎          | 🟠  | Fold all open         | zO                                        |

## Usage

👉 **Everything in the tables is parsed into mappings.lua.**

The rest is informational.
To (re-)generate mappings.lua, hit ,r (anywhere).

Details: Any line in this file is [parsed](#code), which:

- looks like a MD table row
- with a single char in 2nd col.

### Symbols

- `foo`: lua function -> `function () foo end`
- `'foo`: (single apo. after start backtick): vim command, equal to foo (MD workaround)
- -SEMICOL-, -UNDER-, -BACKTICK-: Replaced at parsing (MD and ,t workaround)
- Function like TS(), SS() are defined in python [parser](#code)
- [Aliases](#code): | 🟣 n | 🟠 v | 🟢 x | 🟤 i | ⏎ <CR> |
- 🟥: Dubious - might change.

## Helpers

### Arch

```
    | M   | Mapping | What | How                       | Cmt                               |
    | --- | ------- | ---- | ------------------------- | --------------------------------- |
    | n   | S       |      | :%s//gI<Left><Left><Left> | " move between splits with alt-jk |
```

### Links

[mapraw]: https://raw.githubusercontent.com/AXGKl/pds/master/setup/astro/mappings.md
[vim-surround]: https://github.com/tpope/vim-surround
[autosave]: https://github.com/Pocco81/auto-save.nvim
[whichkey]: https://github.com/folke/which-key.nvim
[tabularize]: https://github.com/godlygeek/tabular
[lp]: https://www.youtube.com/watch?v=HtPL2YhK6h0&t=165s
[neotree]: https://github.com/nvim-neo-tree/neo-tree.nvim
[gqbugorfeat]: https://github.com/jose-elias-alvarez/null-ls.nvim/issues/1131
[vpe]: https://github.com/axiros/vpe
[vpe_goto]: https://github.com/axiros/vpe/blob/main/docs/smart_goto.md

### Parser

#### Code

```python :clear @parser :silent
MODES = {'🟣':'n', '🟠': 'v', '🟢': 'x', '🟤': 'i'}
REPL = {' ⏎': '<CR>', '-SEMICOL-': ';', '-BACKTICK-': '`', '-UNDER-': '_'}
FUNCS = [
   'function SS() return require("smart-splits") end',
   'function TS() return require("telescope.builtin") end',
   'function UU() return require("user.utils") end',
   '''
     function HopLine(ft)
           if ft == 'f' then o = 0 else o = -1 end
           require('hop').hint_char1({current_line_only=true, hint_offset=o})
     end
   '''
]

import time, os

vpe.vim.command('write!')
os.chdir(vpe.fnd().here)
# not time, this is comitted:
r = [f'-- Autocreated by parsing mappings.md', '']
add = lambda k, r=r: r.append(k)
[add(f) for f in FUNCS]
add('return {')
s = '\n'.join(vpe.ctx.src_buf)

def in_backticks(s):
    return s[0]+s[-1] == '``'

def add_line(l, add=add):
    l.extend(['', '', '', ''])
    nr, key, what, how,  cmt = l[:5]
    for k, v in REPL.items():
        key = key.replace(k, v)
        how = how.replace(k, v)
    if not how or not key:
        return vpe.notify(f'wrong line {nr}: {l}')
    key = key[1:-1].strip() if in_backticks(key) else key
    lua = 0
    if in_backticks(how):
        if len(how) > 2 and how[1] == "'":
            how = how[2:-1]
        else:
            lua, how =1,  f'function () {how[1:-1]} end'
    if not lua:
        #if how[0] == ':': how += ' ⏎'
        how = how.replace('"', '\\"')
        how = f'"{how}"'
    if cmt:
        add(f'-- {cmt}')
    what = f', desc = "{what}" ' if what else ''
    add(f'["{key}"] = {{ {how}{what} }},')

def add_mode(m, defs, add=add, s=s):
    add(f'{m} = {{')
    [add_line(i) for i in defs]
    add('},')


def by_mode():
    m = {}
    nr =  0
    for l in vpe.ctx.src_buf:
        nr += 1
        if not l.startswith('|'): continue
        l = [i.strip() for i in l.split('|')]
        if l and len(l) > 4:
            mode = l.pop(2)
            mode = MODES.get(mode, mode)
            if len(mode) != 1: continue
            l[0] = nr
            m.setdefault(mode, []).append(l)
    m.pop('M', 0)
    m.pop('-', 0)
    return m


M = by_mode()
[add_mode(m, l) for m, l in M.items()]
add('}')
with open('mappings.lua', 'w') as fd: fd.write('\n'.join(r))
cmd = 'PATH="$HOME/.local/share/nvim/mason/bin:$PATH" stylua ./mappings.lua'
os.system(cmd)
vpe.notify('💾 Parsing Success', msg='\nHave written: mappings.lua')
vpe.vim.command(f'edit {os.getcwd()}/mappings.lua')
vpe.vim.current.buffer = vpe.ctx.src_buf

```

<!--
:vpe /gg/@parser/ # :vpe_on_any  only found at max 3  lines from end!
vi: fdl=1 fen
-->
