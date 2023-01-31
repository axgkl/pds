# Mappings

**❗Hit ,r (anywhere) after changes**
That will rebuild ./mappings.lua

## Mode n

| Mapping    | What                        | How                                            | Cmt                                                                                                                                   |
| ---------- | --------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| <C-s>      | Save File                   | w!                                             |
| <M-o>      | Jump newer (after C-o)      | <C-i>                                          | " C-o jump older -> alt-o is jump newer (since C-i is tab which we need elsewhere)                                                    |
| <M-H>      | pds help                    | :edit ~/.config/nvim/lua/user/README.md<CR>    |
| <S-Tab>    | Close ALL Folds             | zM                                             |
| <Up>       | Resize split up             | `require("smart-splits").resize_up(2)`         |
| <Down>     | Resize split down           | `require("smart-splits").resize_down(2)`       |
| <Left>     | Resize split left           | `require("smart-splits").resize_left(2)`       |
| <Right>    | Resize split right          | `require("smart-splits").resize_right(2)`      |
| <leader>fg | Git files                   | `TS().git_files()`                             |
| <leader>mm | Mind Main                   | :MindOpenMain                                  |
| <leader>mp | Mind Project                | :MindOpenSmartProject                          |
| <leader>d  | Delete noregister           | v`"_d`                                         |
| 11         | First char in line          | ^                                              |
| Y          | Yank (like C and D)         | y$                                             |
| fl         | Hop-line                    | :HopLine                                       |
| fk         | Hop-char                    | :HopChar1                                      |
| gq         | Format w/o formatexpr       | gwgw                                           | null-ls messes with formatexpr for some reason, which messes up `gq` (https://github.com/jose-elias-alvarez/null-ls.nvim/issues/1131) |
| ,s         | Toggle Autosave all buffers | :ASToggle                                      |
| ,D         | Buffer Diagnostics          | `TS().diagnostics({ bufnr = 0 } )`             |
| ,C         | Color Schemes               | `TS().colorscheme({ enable_preview = true } )` |

## Mode v

| Mapping   | What                  | How    |
| --------- | --------------------- | ------ |
| <CR>      | Fold all open         | zO     |
| <leader>d | Delete noregister     | v`"_d` |
| gq        | Format w/o formatexpr | gwgw   |

## Parse

### Code

```python @parser :clear :silent
import time, os
vpe.vim.command('write!')
os.chdir(vpe.fnd().here)
r = [f'-- Autocreated @{time.ctime()} by parsing mappings.md', '']
add = lambda k, r=r: r.append(k)
add('function TS() return require("telescope.builtin") end')
add('return {')
s = '\n'.join(vpe.ctx.src_buf)

def add_line(l, add=add):
    l  += '|||'
    key, what, how,  cmt = [i.strip() for i in l.split('|')[1:5]]
    if how and (how[0], how[-1]) == ('`', '`'):
        how = f'function () {how[1:-1]} end'
    else:
        if (how[:2], how[-1]) == ('v`', '`'):
            how = how[2:-1]
        how = how.replace('"', '\\"')
        if how[0] == ':':
            how += '<CR>'
        how = f'"{how}"'
    if cmt:
        add(f'-- {cmt}')
    add(f'["{key}"] = {{ {how}, desc = "{what}" }},')

def add_mode(m, add=add, s=s):
    sep = f'\n## Mode {m}'
    if not sep in s:
        return
    add(f'{m} = {{')
    s = s.split(sep, 1)[1].split('\n## ', 1)[0].strip().splitlines()
    s = [i for i in s if i and i[0] == '|' and len(i.split('|')) > 3][2:]
    [add_line(i) for i in s]
    add('},')


[add_mode(m) for m in  ['n', 'v', 'i', 'x']]
add('}')
with open('mappings.lua', 'w') as fd: fd.write('\n'.join(r))
cmd = 'PATH="$HOME/.local/share/nvim/mason/bin:$PATH" stylua ./mappings.lua'
os.system(cmd)
vpe.notify(msg='Have written mappings.lua')
vpe.vim.command(f'edit {os.getcwd()}/mappings.lua')
vpe.vim.current.buffer = vpe.ctx.src_buf



```

<!--
:vpe /gg/@parser/ # :vpe_on_any  only found at max 3  lines from end!
vi: fdl=1 fen
-->
