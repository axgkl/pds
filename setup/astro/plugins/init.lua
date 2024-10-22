return {
    -- For markdown:
    -- "AXGKl/vim-minimd",
    -- colors:
    --
    --
    --'powerman/vim-plugin-AnsiEsc',
    'chrisbra/Colorizer',
    'arcticicestudio/nord-vim',
    'catppuccin/nvim',
    'cocopon/iceberg.vim',
    'cormacrelf/vim-colors-github',
    'ellisonleao/gruvbox.nvim',
    'folke/tokyonight.nvim',
    'dracula/vim',
    'joshdick/onedark.vim',
    'matsuuu/pinkmare',
    'rebelot/kanagawa.nvim',
    'rose-pine/neovim',
    { 'm00qek/baleia.nvim', tag = 'v1.2.0' },
    -- misc:
    'axiros/vpe', -- python evaluation
    -- markdown / presentations:
    'mikeboiko/vim-markdown-folding', -- better than TS
    'junegunn/limelight.vim',
    'junegunn/goyo.vim',
    'AXGKl/vim-markdown',
    --"prurigro/vim-markdown-concealed",
    -- {
    -- 	"nvim-neorg/neorg",
    -- 	run = ":Neorg sync-parsers",
    -- 	ft = "norg",
    -- 	after = { "nvim-treesitter", "nvim-cmp" },
    -- 	config = function()
    -- 		require("neorg").setup({
    -- 			load = {
    -- 				["core.defaults"] = {},
    -- 				["core.norg.concealer"] = {},
    -- 				["core.norg.completion"] = { config = { engine = "nvim-cmp" } },
    -- 				["core.presenter"] = { config = { zen_mode = "truezen" } },
    -- 			},
    -- 		})
    -- 	end,
    -- },
    -- { "nvim-zh/md-nanny" },
    --{ "edluffy/hologram.nvim", { config = function () require("hologram").setup({ auto_display = true }) end }},
    -- {
    --     'Exafunction/codeium.vim',
    --     event = 'InsertEnter',
    --             -- stylua: ignore
    --             -- config = function ()
    --             --   vim.g.codeium_disable_bindings = 1
    --             --   vim.keymap.set("i", "<M-Bslash>", function() return vim.fn["codeium#Accept"]() end, { expr = true })
    --             --   vim.keymap.set("i", "<M-b>", function() return vim.fn["codeium#CycleCompletions"](1) end, { expr = true })
    --             --   vim.keymap.set("i", "<A-b>", function() return vim.fn["codeium#CycleCompletions"](-1) end, { expr = true })
    --             --   vim.keymap.set("i", "<A-x>", function() return vim.fn["codeium#Clear"]() end, { expr = true })
    --             --   vim.keymap.set("i", "<A-s>", function() return vim.fn["codeium#Complete"]() end, { expr = true })
    --             -- end,
    -- },
    { 'epwalsh/obsidian.nvim' },
    {
        'phaazon/mind.nvim',
        branch = 'v2.2',
        config = function()
            require('mind').setup()
        end,
    },

    ['ethanholz/nvim-lastplace'] = {
        opt = true,
        setup = function()
            table.insert(astronvim.file_plugins, 'nvim-lastplace')
        end,
        config = function()
            require('user.plugins.nvim-lastplace')
        end,
    },
    {
        'phaazon/hop.nvim',
        branch = 'v2',
        config = function()
            require('hop').setup({ keys = 'etovxqpdygfblzhckisuran' })
        end,
    },
    -- {
    -- 	"Pocco81/high-str.nvim",
    -- 	setup = function()
    -- 		return {
    -- 			verbosity = 0,
    -- 			saving_path = "/tmp/",
    -- 			highlight_colors = {
    -- 				-- color_id = {"bg_hex_code",<"fg_hex_code"/"smart">}
    -- 				color_0 = { "#0c0d0e", "smart" }, -- Cosmic charcoal
    -- 				color_1 = { "#8bd124", "smart" }, -- Pastel yellow
    -- 				color_2 = { "#7FFFD4", "smart" }, -- Aqua menthe
    -- 				color_3 = { "#8A2BE2", "smart" }, -- Proton purple
    -- 				color_4 = { "#FF4500", "smart" }, -- Orange red
    -- 				color_5 = { "#008000", "smart" }, -- Office green
    -- 				color_6 = { "#0000FF", "smart" }, -- Just blue
    -- 				color_7 = { "#FFC0CB", "smart" }, -- Blush pink
    -- 				color_8 = { "#FFF9E3", "smart" }, -- Cosmic latte
    -- 				color_9 = { "#7d5c34", "smart" }, -- Fallow brown
    -- 			},
    -- 		}
    -- 	end,
    -- },
    --{ "ixru/nvim-markdown" },
    {
        'iamcco/markdown-preview.nvim',
        run = 'cd app && npm install && git reset --hard',
        setup = function()
            vim.g.mkdp_filetypes = { 'markdown' }
        end,
        ft = { 'markdown' },
    },
    ['hrsh7th/cmp-emoji'] = {
        after = 'nvim-cmp',
        config = function()
            astronvim.add_user_cmp_source('emoji')
        end,
    },
    {
        'nvim-treesitter/playground',
        config = function()
            require('nvim-treesitter.configs').setup({
                playground = {
                    enable = true,
                    disable = {},
                    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
                    persist_queries = false, -- Whether the query persists across vim sessions
                    keybindings = {
                        toggle_query_editor = 'o',
                        toggle_hl_groups = 'i',
                        toggle_injected_languages = 't',
                        toggle_anonymous_nodes = 'a',
                        toggle_language_display = 'I',
                        focus_language = 'f',
                        unfocus_language = 'F',
                        update = 'R',
                        goto_node = '<cr>',
                        show_help = '?',
                    },
                },
            })
        end,
    },

    -- misc
    'mbbill/undotree',
    'Pocco81/auto-save.nvim',
    'Pocco81/true-zen.nvim',
    'ThePrimeagen/refactoring.nvim',
    'godlygeek/tabular',
    'kshenoy/vim-signature',

    --"masukomi/vim-markdown-folding",
    'tpope/vim-repeat',
    'tpope/vim-surround',
    -- "easymotion/vim-easymotion",
    --"edluffy/hologram.nvim", (images in buffers)
    -- "voldikss/vim-floaterm",
    --"jez/vim-superman",
    'michaeljsmith/vim-indent-object',
    'vim-python/python-syntax',
    -- { "wakatime/vim-wakatime", event = "BufRead" },
    {
        'uga-rosa/cmp-dictionary',
        after = 'nvim-cmp',
        config = function()
            local cmp = require('cmp')
            local config = cmp.get_config()
            table.insert(config.sources, { name = 'dictionary', keyword_length = 2 })
            cmp.setup(config)
        end,
    },
}
