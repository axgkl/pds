return {
	-- Add plugins, the packer syntax without the "use"
	-- For markdown:
	-- "AXGKl/vim-minimd",
	-- colors:
	"ellisonleao/gruvbox.nvim",
	"joshdick/onedark.vim",
	"cocopon/iceberg.vim",
	"cormacrelf/vim-colors-github",
	"matsuuu/pinkmare",
	"rebelot/kanagawa.nvim",
	"rose-pine/neovim",
	"axiros/vpe",
	"mikeboiko/vim-markdown-folding",
	"junegunn/limelight.vim",
	"junegunn/goyo.vim",
	"mbbill/undotree",
	"Pocco81/auto-save.nvim",
	"ThePrimeagen/refactoring.nvim",
	"arcticicestudio/nord-vim",
	"dracula/vim",
	"godlygeek/tabular",
	"kshenoy/vim-signature",
	{
		"iamcco/markdown-preview.nvim",
		run = "cd app && npm install",
		setup = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},

	--"masukomi/vim-markdown-folding",
	"tpope/vim-repeat",
	"tpope/vim-surround",
	"tpope/vim-markdown",
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

	-- You can disable default plugins as follows:
	-- ["goolord/alpha-nvim"] = { disable = true },

	-- You can also add new plugins here as well:
	-- { "andweeb/presence.nvim" },
	-- {
	--   "ray-x/lsp_signature.nvim",
	--   event = "BufRead",
	--   config = function()
	--     require("lsp_signature").setup()
	--   end,
	-- },
}
