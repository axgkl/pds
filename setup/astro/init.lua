P = function(v)
    print(vim.inspect(v))
    return v
end

if os.getenv('pds_installing') then
    return {}
end

local config = {
    -- Configure AstroNvim updates
    updater = {
        -- 	remote = "origin", -- remote to use
        -- 	channel = "nightly", -- "stable" or "nightly"
        -- 	version = "latest", -- "latest", tag name, or regex search like "v1.*" to only do updates before v2 (STABLE ONLY)
        -- 	branch = "main", -- branch name (NIGHTLY ONLY)
        -- 	commit = nil, -- commit hash (NIGHTLY ONLY)
        -- 	pin_plugins = nil, -- nil, true, false (nil will pin plugins on stable only)
        -- 	skip_prompts = false, -- skip prompts about breaking changes
        -- 	show_changelog = true, -- show the changelog after performing an update
        -- 	auto_reload = false, -- automatically reload and sync packer after a successful update
        -- 	auto_quit = false, -- automatically quit the current session after a successful update
        -- 	-- remotes = { -- easily add new remotes to track
        -- 	--   ["remote_name"] = "https://remote_url.come/repo.git", -- full remote url
        -- 	--   ["remote2"] = "github_user/repo", -- GitHub user/repo shortcut,
        -- 	--   ["remote3"] = "github_user", -- GitHub user assume AstroNvim fork
        -- 	-- },
    },
    --
    -- Set colorscheme
    colorscheme = 'default_theme',

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
            fg = '#abb2bf',
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
            ['neo-tree'] = true,
            notify = true,
            ['nvim-tree'] = false,
            ['nvim-web-devicons'] = true,
            rainbow = false,
            symbols_outline = false,
            telescope = true,
            vimwiki = false,
            ['which-key'] = false,
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

        ['better_escape'] = { mapping = { 'jk' } }, -- no jj
        ['null-ls'] = function(config)
            local null_ls = require('null-ls')
            local methods = require('null-ls.methods')
            local helpers = require('null-ls.helpers')
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
                b.formatting.shfmt.with({ extra_args = { '-i', '4', '-ci' } }),
                -- python
                b.formatting.blue,
                b.formatting.stylua,
                -- Set a linter
                b.diagnostics.rubocop,
                b.formatting.prettier.with({
                    filetypes = {
                        --"javascript",
                        'javascriptreact',
                        'typescript',
                        'typescriptreact',
                        'vue',
                        'css',
                        'scss',
                        'less',
                        'html',
                        'json',
                        'jsonc',
                        'yaml',
                        --"markdown",
                        'graphql',
                        'handlebars',
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
            ensure_installed = { 'lua' },
        },
        ['nvim-lsp-installer'] = {
            --ensure_installed = { "sumneko_lua", "pyright" },
            ensure_installed = { 'sumneko_lua' },
        },
        packer = {
            compile_path = vim.fn.stdpath('data') .. '/packer_compiled.lua',
        },
    },

    -- LuaSnip Options
    luasnip = {
        -- Add paths for including more VS Code style snippets in luasnip
        vscode_snippet_paths = {},
        -- Extend filetypes
        filetype_extend = {
            javascript = { 'javascriptreact' },
        },
    },

    -- Modify which-key registration
    ['which-key'] = {
        -- Add bindings
        register_mappings = {
            -- first key is the mode, n == normal mode
            n = {
                -- second key is the prefix, <leader> prefixes
                ['<leader>'] = {
                    -- which-key registration table for normal mode, leader prefix
                    -- ["N"] = { "<cmd>tabnew<cr>", "New Buffer" },
                },
            },
        },
    },

    -- Diagnostics configuration (for vim.diagnostics.config({}))
    diagnostics = {
        virtual_text = true,
        underline = true,
    },
    -- https://github.com/nvim-telescope/telescope.nvim#pickers
    --
    -- This function is run last
    -- good place to configuring augroups/autocommands and custom filetypes
    polish = function()
        -- local hop = require('hop')
        -- local function hopk(k, dir, offs)
        --     vim.keymap.set('', k, function()
        --         hop.hint_char1({ direction = k, current_line_only = true, hint_offset = offs })
        --     end, { remap = true })
        -- end
        --
        -- local d = require('hop.hint').HintDirection
        -- hopk(',f', d.AFTER_CURSOR, 0)
        -- hopk(',t', d.AFTER_CURSOR, -1)
        -- hopk(',F', d.BEFORE_CURSOR, 0)
        -- hopk(',T', d.BEFORE_CURSOR, -1)

        local cnf = require('auto-save.config').opts
        cnf.enabled = false
        cnf.write_all_buffers = false

        -- all our older viml style configs:
        vim.cmd('source ~/.config/nvim/lua/user/polish.vim')

        -- lsp logging - unreadable without this all on one line:
        vim.lsp.set_log_level('info')
        require('vim.lsp.log').set_format_func(vim.inspect)
        -- don't get flooded by lsp diag. <spc>lx toggles
        vim.o.updatetime = 250
        require('user.utils').toggle_diag_displ()

        -- local s = ls.snippet
        -- local t = ls.text_node

        -- local f = ls.function_node
        -- local snippets = {}
        -- local target_dates = {
        --     'today',
        --     'tomorrow',
        --     'next monday',
        --     'next tuesday',
        --     'next wednesday',
        --     'next thursday',
        --     'next friday',
        --     'next week',
        --     'next month',
        -- }
        -- for _, target_date in pairs(target_dates) do
        --     table.insert(
        --         snippets,
        --         s('bj_' .. target_date:gsub(' ', '_'), {
        --             t('# '),
        --             f(function(args, snip, user_arg_1)
        --                 return vim.fn.trim(vim.fn.system([[date -d ']] .. target_date .. [[' +'%F %a']]))
        --             end, {}),
        --         })
        --     )
        -- end

        --return snippets
    end,
    -- vim.api.nvim_create_autocmd('User', {
    --     pattern = 'LuasnipInsertNodeEnter',
    --     callback = function()
    --         local node = require('luasnip').session.event_node
    --         print(table.concat(node:get_text(), '\n'))
    --     end,
    -- }),
    -- vim.api.nvim_create_autocmd('User', {
    --     pattern = 'LuasnipPostExpand',
    --     callback = function()
    --         -- get event-parameters from `session`.
    --         local snippet = require('luasnip').session.event_node
    --         local expand_position = require('luasnip').session.event_args.expand_pos
    --         vim.cmd('!notify-send foo')
    --     end,
    -- }),
    --
}

local userfn = os.getenv('PDS_USER')
if userfn then
    local u = require(userfn)
    u.setup(config, config['polish'])
end

return config
