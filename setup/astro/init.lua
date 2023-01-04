UU = require("user.utils") -- allows :lua U.dump(vim.lsp)
-- TS = require("telescope.builtin")
local config = {
	header = {
		"                  ◢ ▨ ▨ ◣         ◢ ▨ ▨ ▨ ◤  ",
		"                ◢ ▨ ▨ ▨ ▨ ◣     ◢ ▨ ▨ ▨ ◤  ",
		"              ◢ ▨ ▨ ▨ ▨ ▨ ▨ ◣ ◢ ▨ ▨ ▨ ◤  ",
		"            ◢ ▨ ▨ ▨ ◤ ◥ ▨ ▨ ▨ ▨ ▨ ▨ ◤  ",
		"          ◢ ▨ ▨ ▨ ◤     ◥ ▨ ▨ ▨ ▨ ◤    ",
		"        ◢ ▨ ▨ ▨ ◤       ◢ ▨ ▨ ▨ ▨ ◣       ",
		"      ◢ ▨ ▨ ▨ ◤       ◢ ▨ ▨ ▨ ▨ ▨ ▨ ◣      ",
		"    ◢ ▨ ▨ ▨ ◤       ◢ ▨ ▨ ▨ ◤ ◥ ▨ ▨ ▨ ◣    ",
		"  ◢ ▨ ▨ ▨ ◤       ◢ ▨ ▨ ▨ ◤     ◥ ▨ ▨ ▨ ◣  ",
		"◢ ▨ ▨ ▨ ◤       ◢ ▨ ▨ ▨ ◤         ◥ ▨ ▨ ▨ ◣  ",
		"",
		"Type H for README"
	},
	-- Configure AstroNvim updates
	updater = {
		remote = "origin", -- remote to use
		channel = "nightly", -- "stable" or "nightly"
		version = "latest", -- "latest", tag name, or regex search like "v1.*" to only do updates before v2 (STABLE ONLY)
		branch = "main", -- branch name (NIGHTLY ONLY)
		commit = nil, -- commit hash (NIGHTLY ONLY)
		pin_plugins = nil, -- nil, true, false (nil will pin plugins on stable only)
		skip_prompts = false, -- skip prompts about breaking changes
		show_changelog = true, -- show the changelog after performing an update
		auto_reload = false, -- automatically reload and sync packer after a successful update
		auto_quit = false, -- automatically quit the current session after a successful update
		-- remotes = { -- easily add new remotes to track
		--   ["remote_name"] = "https://remote_url.come/repo.git", -- full remote url
		--   ["remote2"] = "github_user/repo", -- GitHub user/repo shortcut,
		--   ["remote3"] = "github_user", -- GitHub user assume AstroNvim fork
		-- },
	},

	-- Set colorscheme
	colorscheme = "default_theme",
	-- Override highlight groups in any theme
	highlights = {
		colors = {
			bg = "#abb2bf",
		},

		-- duskfox = { -- a table of overrides/changes to the default
		--   Normal = { bg = "#000000" },
		-- },
		default_theme = function(highlights) -- or a function that returns a new table of colors to set
			local C = require("default_theme.colors")

			-- -- New approach instead of diagnostic_style
			-- highlights.DiagnosticError.italic = true
			-- highlights.DiagnosticHint.italic = true
			-- highlights.DiagnosticInfo.italic = true
			-- highlights.DiagnosticWarn.italic = true

			highlights.Normal = { fg = C.fg, bg = C.bg }
			return highlights
		end,
	},

	-- set vim options here (vim.<first_key>.<second_key> =  value)
	options = {
		opt = {
			-- set to true or false etc.
			relativenumber = true, -- sets vim.opt.relativenumber
			number = true, -- sets vim.opt.number
			spell = false, -- sets vim.opt.spell
			signcolumn = "auto", -- sets vim.opt.signcolumn to auto
			wrap = false, -- sets vim.opt.wrap
		},
		g = {
			mapleader = " ", -- sets vim.g.mapleader
			autoformat_enabled = false, -- enable or disable auto formatting at start (lsp.formatting.format_on_save must be enabled)
			cmp_enabled = true, -- enable completion at start
			autopairs_enabled = false, -- enable autopairs at start
			diagnostics_enabled = true, -- enable diagnostics at start
			status_diagnostics_enabled = true, -- enable diagnostics in statusline
			icons_enabled = true, -- disable icons in the ui (disable if no nerd font is available, requires :packersync after changing)
			ui_notifications_enabled = true, -- disable notifications when toggling ui elements
			heirline_bufferline = false, -- enable new heirline based bufferline (requires :packersync after changing)
		},
	},
	-- If you need more control, you can use the function()...end notation
	-- options = function(local_vim)
	--   local_vim.opt.relativenumber = true
	--   local_vim.g.mapleader = " "
	--   local_vim.opt.whichwrap = vim.opt.whichwrap - { 'b', 's' } -- removing option from list
	--   local_vim.opt.shortmess = vim.opt.shortmess + { I = true } -- add to option list
	--
	--   return local_vim
	-- end,
	--
	-- Default theme configuration
	default_theme = {
		diagnostics_style = { italic = true },
		-- Modify the color table
		colors = {
			fg = "#abb2bf",
		},
		plugins = { -- enable or disable extra plugin highlighting
			aerial = true,
			beacon = false,
			bufferline = true,
			dashboard = true,
			highlighturl = true,
			hop = false,
			indent_blankline = true,
			lightspeed = false,
			["neo-tree"] = true,
			notify = true,
			["nvim-tree"] = false,
			["nvim-web-devicons"] = true,
			rainbow = false,
			symbols_outline = false,
			telescope = true,
			vimwiki = false,
			["which-key"] = true,
		},
	},

	-- Disable AstroNvim ui features
	ui = {
		nui_input = true,
		telescope_select = true,
	},

	-- Configure plugins (in user/plugins.lua)
	--
	plugins = {
		-- All other entries override the setup() call for default plugins
		["null-ls"] = function(config)
			local null_ls = require("null-ls")
			local methods = require("null-ls.methods")
			local helpers = require("null-ls.helpers")
			-- Check supported formatters and linters
			-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
			-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
			-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
			-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
			local b = null_ls.builtins
			config.sources = {
				b.code_actions.refactoring,
				-- bash:
				-- we ahve bashls:
				-- b.code_actions.shellcheck,
				-- b.diagnostics.shellcheck,
				b.formatting.shfmt,
				-- python
				b.formatting.blue,
				b.formatting.stylua,
				-- Set a linter
				b.diagnostics.rubocop,
				b.formatting.prettier.with({
					filetypes = {
						--"javascript",
						"javascriptreact",
						"typescript",
						"typescriptreact",
						"vue",
						"css",
						"scss",
						"less",
						"html",
						"json",
						"jsonc",
						"yaml",
						--"markdown",
						"graphql",
						"handlebars",
					},
				}),
			}
			-- set up null-ls's on_attach function
			config.on_attach = function(client)
				-- NOTE: You can remove this on attach function to disable format on save
				-- gk: done, we only format on ,w (collides when auto-save is on)
				-- if client.resolved_capabilities.document_formatting then
				-- 	vim.api.nvim_create_autocmd("BufWritePre", {
				-- 		desc = "Auto format before save",
				-- 		pattern = "<buffer>",
				-- 		callback = vim.lsp.buf.formatting_sync,
				-- 	})
				-- end
			end
			return config -- return final config table
		end,

		treesitter = {
			ensure_installed = { "lua" },
		},
		["nvim-lsp-installer"] = {
			--ensure_installed = { "sumneko_lua", "pyright" },
			ensure_installed = { "sumneko_lua" },
		},
		packer = {
			compile_path = vim.fn.stdpath("data") .. "/packer_compiled.lua",
		},
	},
	-- Extend LSP configuration
	lsp = {
		-- enable servers that you already have installed without lsp-installer
		servers = {},
		-- easily add or disable built in mappings added during LSP attaching
		mappings = {
			n = {
				["K"] = false,
				["s"] = {
					function()
						vim.lsp.buf.hover()
					end,
					desc = "Hover symbol details",
				},
				-- ["<leader>lf"] = false -- disable formatting keymap
				-- ["gd"] = {
				-- 	function()
				-- 		vim.lsp.buf.definition()
				-- 	end,
				-- 	desc = "Goto definition",
				-- },
			},
		},
		-- add to the server on_attach function

		on_attach = function(client, bufnr)
			vim.cmd('echo "attach"')
		end,

		-- override the lsp installer server-registration function
		-- server_registration = function(server, opts)
		--   require("lspconfig")[server].setup(opts)
		-- end,

		-- Add overrides for LSP server settings, the keys are the name of the server
		["server-settings"] = {
			pylsp = {
				-- https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
				settings = {
					pylsp = {
						plugins = {
							pycodestyle = { enabled = false }, -- not very useful with blue
							pyflakes = { enabled = false }, -- by ruff
							pylint = { enabled = true },
						},
					},
				},
			},

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

	-- LuaSnip Options
	luasnip = {
		-- Add paths for including more VS Code style snippets in luasnip
		vscode_snippet_paths = {},
		-- Extend filetypes
		filetype_extend = {
			javascript = { "javascriptreact" },
		},
	},

	-- Modify which-key registration
	["which-key"] = {
		-- Add bindings
		register_mappings = {
			-- first key is the mode, n == normal mode
			n = {
				-- second key is the prefix, <leader> prefixes
				["<leader>"] = {
					-- which-key registration table for normal mode, leader prefix
					-- ["N"] = { "<cmd>tabnew<cr>", "New Buffer" },
				},
			},
		},
	},

	-- CMP Source Priorities
	-- modify here the priorities of default cmp sources
	-- higher value == higher priority
	-- The value can also be set to a boolean for disabling default sources:
	-- false == disabled
	-- true == 1000
	cmp = {
		source_priority = {
			nvim_lsp = 1000,
			luasnip = 750,
			buffer = 500,
			path = 250,
		},
	},

	-- Diagnostics configuration (for vim.diagnostics.config({}))
	diagnostics = {
		virtual_text = true,
		underline = true,
	},
	-- https://github.com/nvim-telescope/telescope.nvim#pickers
	--
	mappings = {
		-- first key is the mode
		-- ALL mappings to a file:               SUUUPER: https://stackoverflow.com/questions/7642746/is-there-any-way-to-view-the-currently-mapped-keys-in-vim
		-- :redir! > vim_keys.txt
		-- :silent verbose map # gk: or imap or vmap
		-- :redir END
		n = {
			-- second key is the lefthand side of the map
			-- TAB IS Ctrl-I -> this would loose jump previous:
			--["<Tab>"] = { "za", desc = "Toggle Fold" },
			[",s"] = { ":ASToggle<CR>", desc = "Toggle Autosave (all buffers)" },
			["<S-Tab>"] = { "zR", desc = "Open ALL Folds" },
			["<C-s>"] = { ":w!<cr>", desc = "Save File" },
			["<M-0>"] = { "^", desc = "Jump to first character in line" },
			--["<CR>"] = { "o<Esc>k", desc = "Insert new lines w/o insert mode" },
			-- ["<CR>"] = { "zA", desc = "Toggle Global Fold" },
			[",D"] = {
				function()
					require("telescope.builtin").diagnostics({ bufnr = 0 })
				end,
				desc = "BufferDiagnostics",
			},
			[",C"] = {
				function()
					require("telescope.builtin").colorscheme({ enable_preview = true })
				end,
				desc = "ColorSchemes",
			},
		},
		v = {
			["<CR>"] = { "zO", desc = "Fold all open" },
		},
		t = {
			-- setting a mapping to false will disable it
			-- ["<esc>"] = false,
		},
	},

	-- This function is run last
	-- good place to configuring augroups/autocommands and custom filetypes
	polish = function()
		if os.getenv("nvs_installing") then
			return
		end

		-- Set key binding
		-- Set autocommands
		-- vim.api.nvim_create_augroup("ftplugs", { clear = true })
		-- vim.api.nvim_create_autocmd("BufEnter", {
		-- 	desc = "Load ft plugs",
		-- 	group = "ftplugs",
		-- 	pattern = "*.md",
		-- 	-- command = "source ~/.config/nvim/lua/user/ftplugin/mdown.vim",
		-- 	command = function()
		-- 		print("adsfa")
		-- 	end,
		-- })
		-- https://neovim.io/doc/user/lua.html#lua-filetype
		-- Set up custom filetypes
		-- vim.filetype.add {
		--   extension = {
		--     foo = "fooscript",
		--   },
		--   filename = {
		--     ["Foofile"] = "fooscript",
		--   },
		--   pattern = {
		--     ["~/%.config/foo/.*"] = "fooscript",
		--   },
		-- }
		local cnf = require("auto-save.config").opts
		cnf.enabled = false
		cnf.write_all_buffers = false
		vim.cmd("source ~/.config/nvim/lua/user/polish.vim")
		-- vim.cmd("echo '" .. vim.bo.filetype .. "'")
		-- vim.cmd("echo 'foo'")
		vim.lsp.set_log_level("info")
		require("vim.lsp.log").set_format_func(vim.inspect)
	end,
}

return config
