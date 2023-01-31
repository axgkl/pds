return {
    n = {
        ['K'] = false,
        ['s'] = {
            function()
                vim.lsp.buf.hover()
            end,
            desc = 'Hover symbol details',
        },

        ['<leader>lx'] = { UU.toggle_diag_displ, desc = 'Toggle Diag. Display' },
        -- ["gd"] = {
        -- 	function()
        -- 		vim.lsp.buf.definition()
        -- 	end,
        -- 	desc = "Goto definition",
        -- },
    },
}
