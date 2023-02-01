-- Autocreated @Wed Feb  1 16:53:17 2023 by parsing mappings.md

function TS() return require("telescope.builtin") end
function UU() return require("user.utils") end
return {
n = {
["<C-s>"] = { "w!", desc = "Save File"  },
-- " C-o jump older -> alt-o is jump newer (since C-i is tab which we need elsewhere)
["<M-o>"] = { "<C-i>", desc = "Jump newer (after C-o)"  },
["<M-H>"] = { ":edit ~/.config/nvim/lua/user/README.md<CR>", desc = "pds help"  },
["<S-Tab>"] = { "zM", desc = "Close ALL Folds"  },
["<Up>"] = { function () require("smart-splits").resize_up(2) end, desc = "Resize split up"  },
["<Down>"] = { function () require("smart-splits").resize_down(2) end, desc = "Resize split down"  },
["<Left>"] = { function () require("smart-splits").resize_left(2) end, desc = "Resize split left"  },
["<Right>"] = { function () require("smart-splits").resize_right(2) end, desc = "Resize split right"  },
["<leader>fg"] = { function () TS().git_files() end, desc = "Git files"  },
["<leader>mm"] = { ":MindOpenMain<CR>", desc = "Mind Main"  },
["<leader>mp"] = { ":MindOpenSmartProject<CR>", desc = "Mind Project"  },
["<leader>d"] = { "\"_d", desc = "Delete noregister"  },
["S"] = { ":%s//gI<Left><Left><Left>", desc = "Easy global replace"  },
["11"] = { "^", desc = "First char in line"  },
["Y"] = { "y$", desc = "Yank (like C and D)"  },
["ff"] = { function () TS().find_files() end, desc = "Open file"  },
["fl"] = { ":HopLine", desc = "Hop-line"  },
["fk"] = { ":HopChar1", desc = "Hop-char"  },
-- null-ls messes with formatexpr for some reason, which messes up `gq` (https://github.com/jose-elias-alvarez/null-ls.nvim/issues/1131)
["gq"] = { "gwgw", desc = "Format w/o formatexpr"  },
[",s"] = { ":ASToggle<CR>", desc = "Toggle Autosave all buffers"  },
[",D"] = { function () TS().diagnostics({bufnr=0}) end, desc = "Buffer Diagnostics"  },
[",C"] = { function () TS().colorscheme({enable_preview=true}) end, desc = "Color Schemes"  },
[",G"] = { ":TermExec cmd=lazygit<CR>", desc = "Lazygit"  },
[",q"] = { ":quitall!<CR>" },
[",d"] = { ":wq!<CR>", desc = "done - write quit"  },
[",u"] = { ":UndotreeToggle<CR>" },
[",1"] = { ":source ~/.config/nvim/init.lua<CR>", desc = "reload init.lua"  },
[",2"] = { ":edit ~/.config/nvim/lua/user/init.lua<CR>", desc = "edit init.lua"  },
-- close just a split or a tab
[",c"] = { ":close<CR>", desc = "close"  },
-- " folds
["<C-i>"] = { "zR", desc = "Fold open"  },
-- " toggle
["<Enter>"] = { "za", desc = "toggle fold"  },
[",3"] = { ":ToggleTerm dir=%:p:h<CR>", desc = "Term in dir of buf"  },
-- "" Line join better, position cursor at join point : " (J is 5 lines jumps)
["fj"] = { "$mx<cmd>join<CR>0$[`dmx h" },
-- Universal python scriptable file or browser opener over word:
[",g"] = { "viW\"ay:lua UU().smart_open([[<C-R>a]])<CR>" },
["ga"] = { ":Tabularize/" },
-- " close window
["<M-w>"] = { ":bd!<CR>" },
["<M-j>"] = { "<C-W><C-h>" },
["<M-k>"] = { "<C-W><C-l>" },
["<C-L>"] = { "<C-W><C-J>" },
["<C-H>"] = { "<C-W><C-K>" },
["gI"] = { ":lua require(\"telescope.builtin\").buffers() <CR>" },
["<Leader>g"] = { ":Telescope live_grep<cr>" },
-- :b#<cr> " previous buffer
["<space><enter>"] = { ":ls<cr>" },
-- " Move paragraph wise. s is hover.
["J"] = { "}j" },
["K"] = { "{k{kkJ" },
-- "colorscheme pinkmare"colorscheme kanagawa
[",w"] = { ":FormatAndSave<CR>" },
-- "save all buffers
[",W"] = { ":wa<CR>" },
},
v = {
["<leader>d"] = { "\"_d", desc = "Delete noregister"  },
[",g"] = { ":lua UU().smart_open([[visualsel]])<CR><CR>" },
["<CR>"] = { "zO", desc = "Fold all open"  },
["gq"] = { "gwgw", desc = "Format w/o formatexpr"  },
},
x = {
["ga"] = { ":Tabularize/" },
},
i = {
["<M-j>"] = { "<ESC><C-W><C-W>" },
["<M-k>"] = { "<ESC><C-W><C-W>" },
-- " Jump to end of line in insert mode
["<C-E>"] = { "<C-O>A" },
},
}