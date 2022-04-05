local user_plugins = {
	"joshdick/onedark.vim",
	"ThePrimeagen/refactoring.nvim",
	"arcticicestudio/nord-vim",
	"godlygeek/tabular",
	"iamcco/markdown-preview.nvim",
	"kdheepak/lazygit.nvim",
	"matsuuu/pinkmare",
	"rebelot/kanagawa.nvim",
	"tpope/vim-repeat",
	"tpope/vim-surround",
	"easymotion/vim-easymotion",
	"voldikss/vim-floaterm",
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

if os.getenv("setup_mode") then
	return { plugins = { init = user_plugins } }
end

local config = {

	-- Set colorscheme
	colorscheme = "default_theme",
	-- colorscheme = "catppuccin",

	-- Default theme configuration
	default_theme = {
		diagnostics_style = "none",
		-- Modify the color table
		-- colors = { fg = "#abb2bf", bg = "#1e242a" },
		colors = { fg = "#abb2bf", bg = "-" },
		-- Modify the highlight groups
		highlights = function(highlights)
			local C = require("default_theme.colors")

			highlights.Normal = { fg = C.fg, bg = C.bg }
			return highlights
		end,
	},

	-- Disable default plugins
	enabled = {
		bufferline = true,
		nvim_tree = true,
		lualine = true,
		gitsigns = true,
		colorizer = true,
		toggle_term = true,
		comment = true,
		symbols_outline = true,
		indent_blankline = true,
		dashboard = true,
		which_key = true,
		neoscroll = true,
		ts_rainbow = true,
		ts_autotag = true,
	},
	plugins = {
		cmp = function(table)
			local cmp = require("cmp") -- lazy loaded -> requireable
			local luasnip = require("luasnip")
			local t = table.mapping
			local has_words_before = function()
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				local lines = vim.api.nvim_buf_get_lines
				return col ~= 0 and lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			t["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				elseif has_words_before() then
					cmp.complete()
				else
					fallback()
				end
			end, { "i", "s" })

			t["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s" })
			return table
		end,

		init = user_plugins,
		-- { "andweeb/presence.nvim" },
		-- {
		--   "ray-x/lsp_signature.nvim",
		--   event = "BufRead",
		--   config = function()
		--     require("lsp_signature").setup()
		--   end,
		-- },
		-- All other entries override the setup() call for default plugins
		treesitter = { ensure_installed = { "lua" } },
		packer = {
			compile_path = vim.fn.stdpath("config") .. "/lua/packer_compiled.lua",
		},
	},

	-- Add paths for including more VS Code style snippets in luasnip
	luasnip = {
		vscode_snippet_paths = {},
	},

	-- Modify which-key registration
	["which-key"] = {
		-- Add bindings to the normal mode <leader> mappings
		-- register_n_leader = {["N"] = {"<cmd>tabnew<cr>", "New Buffer"}}
	},

	-- Extend LSP configuration
	lsp = {
		-- add to the server on_attach function
		-- on_attach = function(client, bufnr)
		-- end,

		-- override the lsp installer server-registration function
		-- server_registration = function(server, opts)
		--   server:setup(opts)
		-- end

		-- Add overrides for LSP server settings, the keys are the name of the server
		["server-settings"] = {
			-- example for addings schemas to yamlls
			-- yamlls = {
			--   settings = {
			--     yaml = {
			--       schemas = {
			--         ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*.{yml,yaml}",
			--         ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
			--         ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
			--       },
			--     },
			--   },
			-- },
		},
	},

	-- Diagnostics configuration (for vim.diagnostics.config({}))
	diagnostics = { virtual_text = true, underline = true },

	-- null-ls configuration
	["null-ls"] = function()
		-- Formatting and linting
		-- https://github.com/jose-elias-alvarez/null-ls.nvim
		local status_ok, null_ls = pcall(require, "null-ls")
		if not status_ok then
			return
		end

		-- Check supported formatters
		-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting

		-- Check supported linters
		-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
		local b = null_ls.builtins
		local txt = { filetypes = { "markdown", "text" } }

		null_ls.setup({
			debug = true,
			sources = {
				-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
				b.code_actions.refactoring,
				b.code_actions.shellcheck,
				--b.completion.spell.with(txt),
				b.diagnostics.misspell.with(txt),
				b.diagnostics.shellcheck,
				b.diagnostics.write_good,
				-- NO! THAT IS BREAKING STUFF (elastic.py):
				-- b.formatting.black.with({ extra_args = { "--fast" } }),
				b.formatting.black,
				b.formatting.prettier.with({ filetypes = { "html", "json", "yaml" } }),
				b.formatting.shfmt,
				b.formatting.stylua,
				b.hover.dictionary.with(txt), -- shift-k is hover
			},
			-- NOTE: You can remove this on attach function to disable format on save
			-- on_attach = function(client)
			-- 	if client.resolved_capabilities.document_formatting then
			-- 		vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting()")
			-- 	end
			-- end,
		})
	end,
	polish = function()
		-- require("lspconfig").pyright.setup({ typeCheckingMode = "strict", })
		local opts = { noremap = true, silent = true }
		local map = vim.api.nvim_set_keymap
		-- Set options
		local set = vim.opt
		require("luasnip.loaders.from_snipmate").lazy_load()
		local has_, p = pcall(require, "cmp_dictionary")
		if has_ then
			p.setup({
				dic = {
					["markdown"] = { "~/.config/nvim.gk/10k.txt" },
					--["markdown"] = { "/usr/share/dict/words" },
					-- ["lua"] = "path/to/lua.dic",
				},
				-- The following are default values, so you don't need to write them if you don't want to change them
				-- exact = 2,
				-- first_case_insensitive = false,
				-- document = false,
				-- document_command = "wn %s -over",
				-- damn, that does not work with true, mpack missing in nvim:
				async = false,
				-- capacity = 5,
				-- debug = false,
			})
		end

		-- cmp.formatting.fields = {"kind"}
		U = require("user.utils") -- allows :lua U.dump(vim.lsp)
		--require("luasnip.loaders.from_vscode").lazy_load()

		set.shiftwidth = 4 -- Number of space inserted for indentation
		set.tabstop = 4 -- Number of spaces in a tab
		set.foldmethod = "indent"
		set.foldlevel = 99 -- open all
		set.relativenumber = true
		--set.dict = "/usr/share/dict/words" -- much more
		set.dict = "~/.config/nvim.gk/10k.txt"
		-- map("n", "<C-s>", ":w!<CR>", opts)
		map("n", ",4", ":ToggleTerm size=100 <CR>", opts)
		map("n", ",D", ":lua vim.diagnostic.config({virtual_text = false})<CR>", opts)
		-- all viml:
		vim.cmd("source ~/.config/nvim.gk/polish.vim")
		-- do this only here so that require mpack works for async:
	end,
}

return config
