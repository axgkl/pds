return {
    opt = {

        foldenable = false,
        foldexpr = 'nvim_treesitter#foldexpr()', -- set Treesitter based folding
        foldmethod = 'expr',
        foldlevel = 99,
        list = false, -- show whitespace characters
        listchars = { tab = '│→', extends = '⟩', precedes = '⟨', trail = '·', nbsp = '␣' },
        number = true, -- sets vim.opt.number
        relativenumber = true, -- sets vim.opt.relativenumber
        signcolumn = 'auto', -- sets vim.opt.signcolumn to auto
        showbreak = '↪ ',
        spell = false, -- sets vim.opt.spell
        spellfile = vim.fn.expand('~/.config/nvim/spell/en.utf-8.add'),
        thesaurus = vim.fn.expand('~/.config/nvim/lua/user/spell/mthesaur.txt'),
        wrap = false, -- no soft wrap lines
    },
    g = {
        --mapleader = " ", -- sets vim.g.mapleader
        autoformat_enabled = false, -- we have ,w for format->save. We need to save w/o autoformat (other style conventions)
        cmp_enabled = true, -- enable completion at start
        autopairs_enabled = false, -- enable autopairs at start
        diagnostics_enabled = true, -- enable diagnostics at start
        status_diagnostics_enabled = true, -- enable diagnostics in statusline
icons_enabled = true, -- disable icons in the ui (disable if no nerd font is available, requires :packersync after changing)
        ui_notifications_enabled = true, -- disable notifications when toggling ui elements
        heirline_bufferline = true, -- enable new heirline based bufferline (requires :packersync after changing)
    },
}
