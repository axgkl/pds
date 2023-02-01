# Mappings

**❗Hit ,r (anywhere) after changes**
That will rebuild ./mappings.lua

| M   | Mapping        | What                        | How                                              | Cmt                                                                                                                                   |
| --- | -------------- | --------------------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| n   | <C-s>          | Save File                   | w!                                               |
| n   | <M-o>          | Jump newer (after C-o)      | <C-i>                                            | " C-o jump older -> alt-o is jump newer (since C-i is tab which we need elsewhere)                                                    |
| n   | <M-H>          | pds help                    | :edit ~/.config/nvim/lua/user/README.md<CR>      |
| n   | <S-Tab>        | Close ALL Folds             | zM                                               |
| n   | <Up>           | Resize split up             | `require("smart-splits").resize_up(2)`           |
| n   | <Down>         | Resize split down           | `require("smart-splits").resize_down(2)`         |
| n   | <Left>         | Resize split left           | `require("smart-splits").resize_left(2)`         |
| n   | <Right>        | Resize split right          | `require("smart-splits").resize_right(2)`        |
| n   | <leader>fg     | Git files                   | `TS().git_files()`                               |
| n   | <leader>mm     | Mind Main                   | :MindOpenMain<CR>                                |
| n   | <leader>mp     | Mind Project                | :MindOpenSmartProject<CR>                        |
| n   | <leader>d      | Delete noregister           | `'"_d'`                                          |
| v   | <leader>d      | Delete noregister           | `'"_d'`                                          |
| n   | S              | Easy global replace         | :%s//gI<Left><Left><Left>                        |
| n   | 11             | First char in line          | ^                                                |
| n   | Y              | Yank (like C and D)         | y$                                               |
| n   | ff             | Open file                   | `TS().find_files()`                              |
| n   | fl             | Hop-line                    | :HopLine                                         |
| n   | fk             | Hop-char                    | :HopChar1                                        |
| n   | gq             | Format w/o formatexpr       | gwgw                                             | null-ls messes with formatexpr for some reason, which messes up `gq` (https://github.com/jose-elias-alvarez/null-ls.nvim/issues/1131) |
| n   | ,s             | Toggle Autosave all buffers | :ASToggle<CR>                                    |
| n   | ,D             | Buffer Diagnostics          | `TS().diagnostics({bufnr=0})`                    |
| n   | ,C             | Color Schemes               | `TS().colorscheme({enable_preview=true})`        |
| n   | ,G             | Lazygit                     | :TermExec cmd=lazygit<CR>                        |
| n   | ,q             |                             | :quitall!<CR>                                    |
| n   | ,d             | done - write quit           | :wq!<CR>                                         |
| n   | ,u             |                             | :UndotreeToggle<CR>                              |                                                                                                                                       |
| n   | ,1             | reload init.lua             | :source ~/.config/nvim/init.lua<CR>              |                                                                                                                                       |
| n   | ,2             | edit init.lua               | :edit ~/.config/nvim/lua/user/init.lua<CR>       |                                                                                                                                       |
| n   | ,c             | close                       | :close<CR>                                       | close just a split or a tab                                                                                                           |
| n   | <C-i>          | Fold open                   | zR                                               | " folds                                                                                                                               |
| n   | <Enter>        | toggle fold                 | za                                               | " toggle                                                                                                                              |
| n   | ,3             | Term in dir of buf          | :ToggleTerm dir=%:p:h<CR>                        |
| n   | fj             |                             | $mx<cmd>join<CR>0$[-BACKTICK-dmx h               | "" Line join better, position cursor at join point : " (J is 5 lines jumps)                                                           |
| n   | `,g`           |                             | `'viW"ay:lua UU().smart_open([[<C-R>a]])<CR>'`   | Universal python scriptable file or browser opener over word:                                                                         |
| v   | ,g             |                             | `':lua UU().smart_open([[visualsel]])<CR><CR>'`  |
| n   | ga             |                             | :Tabularize/                                     |
| x   | ga             |                             | :Tabularize/                                     |
| n   | <M-w>          |                             | :bd!<CR>                                         | " close window                                                                                                                        |
| n   | <M-j>          |                             | <C-W><C-h>                                       |
| n   | <M-k>          |                             | <C-W><C-l>                                       |
| i   | <M-j>          |                             | <ESC><C-W><C-W>                                  |
| i   | <M-k>          |                             | <ESC><C-W><C-W>                                  |
| i   | <C-E>          |                             | <C-O>A                                           | " Jump to end of line in insert mode                                                                                                  |
| n   | <C-L>          |                             | <C-W><C-J>                                       |
| n   | <C-H>          |                             | <C-W><C-K>                                       |
| n   | -SEMICOL-      |                             | :lua require("telescope.builtin").buffers() <CR> |
| n   | <Leader>g      |                             | :Telescope live_grep<cr>                         |
| n   | <space><enter> |                             | :ls<cr>                                          | :b#<cr> " previous buffer                                                                                                             |
| n   | J              |                             | }j                                               | " Move paragraph wise. s is hover.                                                                                                    |
| n   | K              |                             | {k{kkJ                                           |
| n   | ,w             |                             | :FormatAndSave<CR>                               | "colorscheme pinkmare"colorscheme kanagawa                                                                                            |
| n   | ,W             |                             | :wa<CR>                                          | "save all buffers                                                                                                                     |
| v   | <CR>           | Fold all open               | zO                                               |
| v   | gq             | Format w/o formatexpr       | gwgw                                             |

## Arch

```
    | M   | Mapping | What | How                       | Cmt                               |
    | --- | ------- | ---- | ------------------------- | --------------------------------- |
    | n   | S       |      | :%s//gI<Left><Left><Left> | " move between splits with alt-jk |
```

## Parse

You may add more funcs and replacements here.

### Code

```python :clear @parser :silent
REPL = {'-SEMICOL-': 'gI', '-BACKTICK-': '`'}
FUNCS = [
   'function TS() return require("telescope.builtin") end',
   'function UU() return require("user.utils") end',
]

import time, os

vpe.vim.command('write!')
os.chdir(vpe.fnd().here)
r = [f'-- Autocreated @{time.ctime()} by parsing mappings.md', '']
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
        if len(how) > 2 and how[1] + how[-2] == "''":
            how = how[2:-2]
        else:
            lua, how =1,  f'function () {how[1:-1]} end'
    if not lua:
        #if how[0] == ':': how += '<CR>'
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
        if l and l[0] == '' and len(l) > 4 and len(l[1]) == 1 :
            l.insert(2, nr)
            m.setdefault(l[1], []).append(l[2:])
    m.pop('M', 0)
    m.pop('-', 0)
    return m


M = by_mode()
[add_mode(m, l) for m, l in M.items()]
add('}')
with open('mappings.lua', 'w') as fd: fd.write('\n'.join(r))
cmd = 'PATH="$HOME/.local/share/nvim/mason/bin:$PATH" stylua ./mappings.lua'
os.system(cmd)

vpe.notify('✔️ Parsing Success', msg='Written: mappings.lua')
vpe.vim.command(f'edit {os.getcwd()}/mappings.lua')
vpe.vim.current.buffer = vpe.ctx.src_buf

```

<!--
:vpe /gg/@parser/ # :vpe_on_any  only found at max 3  lines from end!
vi: fdl=1 fen
-->
