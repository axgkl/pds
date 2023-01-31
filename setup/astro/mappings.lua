-- Autocreated @Tue Jan 31 15:26:32 2023 by parsing mappings.md

function TS()
    return require('telescope.builtin')
end
return {
    n = {
        ['<C-s>'] = { 'w!', desc = 'Save File' },
        -- " C-o jump older -> alt-o is jump newer (since C-i is tab which we need elsewhere)
        ['<M-o>'] = { '<C-i>', desc = 'Jump newer (after C-o)' },
        ['<M-H>'] = { ':edit ~/.config/nvim/lua/user/README.md<CR><CR>', desc = 'pds help' },
        ['<S-Tab>'] = { 'zM', desc = 'Close ALL Folds' },
        ['<Up>'] = {
            function()
                require('smart-splits').resize_up(2)
            end,
            desc = 'Resize split up',
        },
        ['<Down>'] = {
            function()
                require('smart-splits').resize_down(2)
            end,
            desc = 'Resize split down',
        },
        ['<Left>'] = {
            function()
                require('smart-splits').resize_left(2)
            end,
            desc = 'Resize split left',
        },
        ['<Right>'] = {
            function()
                require('smart-splits').resize_right(2)
            end,
            desc = 'Resize split right',
        },
        ['<leader>fg'] = {
            function()
                TS().git_files()
            end,
            desc = 'Git files',
        },
        ['<leader>mm'] = { ':MindOpenMain<CR>', desc = 'Mind Main' },
        ['<leader>mp'] = { ':MindOpenSmartProject<CR>', desc = 'Mind Project' },
        ['<leader>d'] = { '"_d', desc = 'Delete noregister' },
        ['11'] = { '^', desc = 'First char in line' },
        ['Y'] = { 'y$', desc = 'Yank (like C and D)' },
        ['fl'] = { ':HopLine<CR>', desc = 'Hop-line' },
        ['fk'] = { ':HopChar1<CR>', desc = 'Hop-char' },
        -- null-ls messes with formatexpr for some reason, which messes up `gq` (https://github.com/jose-elias-alvarez/null-ls.nvim/issues/1131)
        ['gq'] = { 'gwgw', desc = 'Format w/o formatexpr' },
        [',s'] = { ':ASToggle<CR>', desc = 'Toggle Autosave all buffers' },
        [',D'] = {
            function()
                TS().diagnostics({ bufnr = 0 })
            end,
            desc = 'Buffer Diagnostics',
        },
        [',C'] = {
            function()
                TS().colorscheme({ enable_preview = true })
            end,
            desc = 'Color Schemes',
        },
    },
    v = {
        ['<CR>'] = { 'zO', desc = 'Fold all open' },
        ['<leader>d'] = { '"_d', desc = 'Delete noregister' },
        ['gq'] = { 'gwgw', desc = 'Format w/o formatexpr' },
    },
}
