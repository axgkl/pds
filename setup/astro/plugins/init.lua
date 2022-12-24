return {
	-- Add plugins, the packer syntax without the "use"
	-- For markdown:
	-- "AXGKl/vim-minimd",
	"axiros/vpe",
	"mikeboiko/vim-markdown-folding",
	"junegunn/limelight.vim",
	"junegunn/goyo.vim",
	"mbbill/undotree",
	"Pocco81/auto-save.nvim",
	"ellisonleao/gruvbox.nvim",
	"joshdick/onedark.vim",
	"ThePrimeagen/refactoring.nvim",
	--"arcticicestudio/nord-vim",
	"dracula/vim",
	"cocopon/iceberg.vim",
	"godlygeek/tabular",
	"cormacrelf/vim-colors-github",
	"kshenoy/vim-signature",
	"matsuuu/pinkmare",
	"rose-pine/neovim",
	{
		"iamcco/markdown-preview.nvim",
		run = "cd app && npm install",
		setup = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},

	--"masukomi/vim-markdown-folding",
	"rebelot/kanagawa.nvim",
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
