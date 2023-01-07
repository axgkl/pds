return {
	-- For markdown:
	-- "AXGKl/vim-minimd",
	-- colors:
	"arcticicestudio/nord-vim",
	"cocopon/iceberg.vim",
	"cormacrelf/vim-colors-github",
	"ellisonleao/gruvbox.nvim",
	"folke/tokyonight.nvim",
	"dracula/vim",
	"joshdick/onedark.vim",
	"matsuuu/pinkmare",
	"rebelot/kanagawa.nvim",
	"rose-pine/neovim",

	-- misc:
	"axiros/vpe",
	-- markdown / presentations:
	"mikeboiko/vim-markdown-folding",
	"junegunn/limelight.vim",
	"junegunn/goyo.vim",
	"tpope/vim-markdown",
	{
		"iamcco/markdown-preview.nvim",
		run = "cd app && npm install",
		setup = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},

	-- misc
	"mbbill/undotree",
	"Pocco81/auto-save.nvim",
	"ThePrimeagen/refactoring.nvim",
	"godlygeek/tabular",
	"kshenoy/vim-signature",

	--"masukomi/vim-markdown-folding",
	"tpope/vim-repeat",
	"tpope/vim-surround",
	-- "easymotion/vim-easymotion",
	--"edluffy/hologram.nvim", (images in buffers)
	-- "voldikss/vim-floaterm",
	"jez/vim-superman",
	"michaeljsmith/vim-indent-object",
	"vim-python/python-syntax",
	-- { "wakatime/vim-wakatime", event = "BufRead" },
	{
		"uga-rosa/cmp-dictionary",
		after = "nvim-cmp",
		config = function()
			local cmp = require("cmp")
			local config = cmp.get_config()
			table.insert(config.sources, { name = "dictionary", keyword_length = 2 })
			cmp.setup(config)
		end,
	},
}
