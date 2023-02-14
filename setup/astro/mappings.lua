-- Autocreated by parsing mappings.md

function SS()
    return require('smart-splits')
end
function TS()
    return require('telescope.builtin')
end
function UU()
    return require('user.utils')
end

function HopLine(ft)
    if ft == 'f' then
        o = 0
    else
        o = -1
    end
    require('hop').hint_char1({ current_line_only = true, hint_offset = o })
end

return {
    n = {
        -- " folds
        ['<C-i>'] = { 'zR', desc = 'Fold open' },
        ['<Enter>'] = { 'za', desc = 'Toggle fold' },
        -- <C-i> is ident with <TAB>
        ['<S-Tab>'] = { 'zM', desc = 'Close ALL Folds' },
        -- Close just a split or a tab
        [',c'] = { ':close<CR>', desc = 'Close :close' },
        [',q'] = { ':quitall!<CR>', desc = 'Quit all!' },
        [',u'] = { ':UndotreeToggle<CR>', desc = 'Undo Tree' },
        -- 🟥 does not repeat last f t F T
        [';'] = {
            function()
                TS().buffers()
            end,
            desc = 'Buffers open',
        },
        -- C-o jump older -> alt-o is jump newer (since C-i is tab which we need elsewhere)
        ['<M-o>'] = { '<C-i>', desc = 'Jump newer (after C-o)' },
        -- Close window
        ['<M-w>'] = { ':bd!<CR>', desc = 'Buffer delete :bd!' },
        ['<leader>fg'] = {
            function()
                TS().git_files()
            end,
            desc = 'Git files',
        },
        -- in your open buffers (toggle back and forth) :b# ⏎ " previous buffer
        ['<leader><enter>'] = { ':ls<CR>:b#<CR><Space>', desc = 'Previous edited buffer' },
        -- Move stuff you want to keep below a `begin_ archive` comment and G jumps to that
        ['G'] = { ':$<CR><bar>:silent! ?begin_archive<CR>', desc = 'End of file' },
        -- You can open many files at once, by selecting them with TAB in the picker
        ['ff'] = {
            function()
                TS().find_files()
            end,
            desc = 'Open file(from vi start dir)',
        },
        -- 🟥 gw reformat via gq
        ['gw'] = {
            function()
                TS().live_grep()
            end,
            desc = 'Live grep words',
        },
        [',d'] = { ':wq!<CR>', desc = 'Done - write quit' },
        -- See [here][autosave]
        [',s'] = { ':ASToggle<CR>', desc = 'Toggle Autosave all buffers' },
        [',w'] = { ':FormatAndSave<CR>' },
        ['<C-s>'] = { 'w!', desc = 'Save File' },
        ['<Down>'] = {
            function()
                SS().resize_down(2)
            end,
            desc = 'Resize split down',
        },
        ['<Left>'] = {
            function()
                SS().resize_left(2)
            end,
            desc = 'Resize split left',
        },
        ['<Right>'] = {
            function()
                SS().resize_right(2)
            end,
            desc = 'Resize split right',
        },
        ['<Up>'] = {
            function()
                SS().resize_up(2)
            end,
            desc = 'Resize split up',
        },
        -- In visual or normal mode, delete w/o overwriting your "pasteable content"
        ['<leader>d'] = { '"_d', desc = 'Delete noregister' },
        ['S'] = { ':%s//gI<Left><Left><Left>', desc = 'Easy global replace' },
        ['Y'] = { 'y$', desc = 'Yank (like C and D)' },
        -- Line join better, position cursor at join point : " (J is para down)
        ['fj'] = { '$mx<cmd>join<CR>0$[`dmx h', desc = 'Line join' },
        ['ga'] = { ':Tabularize/' },
        -- null-ls messes formatexpr for some reason, which [affects `gq`][gqbugorfeat]
        ['gq'] = { 'gwgw', desc = 'Format w/o formatexpr' },
        [',f'] = {
            function()
                HopLine('f')
            end,
            desc = 'Hop char line',
        },
        -- vtx: select until char 'x'
        [',t'] = {
            function()
                HopLine('t')
            end,
            desc = 'Hop char line',
        },
        -- 🟥 The number 11 as count will work
        ['11'] = { '^', desc = 'First no empty char in line' },
        ['<M-j>'] = { '<C-W><C-h>', desc = 'Jump Left Split' },
        ['<M-k>'] = { '<C-W><C-l>', desc = 'Jump Right Split' },
        -- 🟥 J won't line-join. fj for that
        ['J'] = { '}j', desc = 'Jump paragraph down' },
        ['K'] = { '{k{kkJ', desc = 'Jump paragraph up' },
        ['fk'] = { ':HopChar1<CR>', desc = 'Hop char' },
        ['fl'] = { ':HopLine<CR>', desc = 'Hop line' },
        [',D'] = {
            function()
                TS().diagnostics({ bufnr = 0 })
            end,
            desc = 'Buffer Diagnostics',
        },
        [',1'] = { ':source ~/.config/nvim/init.lua<CR>', desc = 'Reload init.lua' },
        [',2'] = { ':edit ~/.config/nvim/lua/user/init.lua<CR>', desc = 'Edit init.lua' },
        [',3'] = { ':ToggleTerm dir=%:p:h<CR>', desc = 'Term in dir of buf' },
        [',C'] = {
            function()
                TS().colorscheme({ enable_preview = true })
            end,
            desc = 'Color Schemes',
        },
        [',E'] = { ':EvalInto<CR>', desc = 'Vim Eval Into' },
        [',G'] = { ':TermExec cmd=lazygit<CR>', desc = 'Lazygit' },
        [',W'] = { ':wa<CR>', desc = 'Save all buffers' },
        -- https://github.com/axiros/vpe
        [',r'] = { ':PythonEval<CR>', desc = 'VimPythonEval' },
        [',g'] = { ':PythonGoto<CR>', desc = 'VimPythonEval' },
        ['<C-H>'] = { '<C-W><C-K>' },
        ['<C-L>'] = { '<C-W><C-J>' },
        ['<M-H>'] = { ':edit ~/.config/nvim/lua/user/README.md<CR>', desc = 'pds help' },
        ['<leader>mm'] = { ':MindOpenMain<CR>', desc = 'Mind Main' },
        ['<leader>mp'] = { ':MindOpenSmartProject<CR>', desc = 'Mind Project' },
    },
    v = {
        ['<leader>d'] = { '"_d', desc = 'Delete noregister' },
        [',g'] = { ':PythonGotoRange<CR>', desc = 'VimPythonEval' },
        ['gq'] = { 'gwgw', desc = 'Format w/o formatexpr' },
        ['⏎'] = { 'zO', desc = 'Fold all open' },
    },
    x = {
        ['ga'] = { ':Tabularize/' },
        [',E'] = { ':EvalInto<CR>', desc = 'Vim Eval Into' },
        [',r'] = { ':PythonEval<CR>', desc = 'VimPythonEval' },
    },
    i = {
        ['<M-j>'] = { '<ESC><C-W><C-W>', desc = 'Jump Left Split' },
        ['<M-k>'] = { '<ESC><C-W><C-W>', desc = 'Jump Right Split' },
        -- " Jump to end of line in insert mode
        ['<C-E>'] = { '<C-O>A' },
    },
}
