" We call this NOT markdown.vim because ftplugin style loading is too early
" for the inline code coloring with TS. Also we noted that the file is loaded
" twice then.
"
" Fix: We load via a BufEnter in init.lua, pointing to this file for markdown

colorscheme gruvbox
nnoremap ,t vip:Tabularize/\|<CR>
setlocal spell
"setlocal spelllang=de,en
setlocal spelllang=en_us

function! Present()
	:Goyo 120
	:Limelight
	:Gitsigns detach_all
	:lua astronvim.ui.toggle_syntax()
  let g:markdown_fenced_languages = [ "vim", "python", "lua", "bash=sh", "javascript", "typescript", "yaml", "json" ]
	:lua astronvim.ui.toggle_syntax()
endfunction
" :lua astronvim.ui.toggle_syntax()
:lua astronvim.ui.toggle_syntax()
let g:markdown_fenced_languages = [ "vim", "python", "lua", "bash=sh", "javascript", "typescript", "yaml", "json" ]
:lua astronvim.ui.toggle_syntax()

command! Present call Present()
nmap <silent><buffer> ,p :Present<CR>

nmap <silent><buffer> ,P :MarkdownPreviewToggle<CR>

" " Must be in ftplugin folder because of folding
" maps.n["<leader>uy"] = { function() astronvim.ui.toggle_syntax() end, desc = "Toggle syntax highlight" }
" "setlocal nowrap
" setlocal spell
" setlocal spelllang=de,en
" setlocal nolist
" setlocal colorcolumn=
" "setlocal foldexpr=markdown#FoldExpression(v:lnum)
" "setlocal foldmethod=expr
" " autowrap at textwidth:
" setlocal formatoptions+=t 
" setlocal textwidth=100
" " setlocal foldlevel=99
" " let g:markdown_folding = 1
" let g:markdown_fenced_languages = [ "vim", "python", "lua", "bash=sh", "javascript", "typescript", "yaml", "json" ]
"
" "colorscheme stellarized
" setlocal conceallevel=0
"
" let g:vim_markdown_toc_autofit = 0
"
" set nowrap " for long tables
" set linebreak
"
" let g:md_preview_tools = "/home/gk/inst/tb-my-editor/"
" let g:mkdp_browser = g:md_preview_tools .. "browser.sh"
"
" nnoremap ,p <cmd>MarkdownPreviewToggle<cr>
" nnoremap ,[ :lua require('utils').write_dom()<CR>
" nnoremap ,t vip:Tabularize/\|<CR>
" inoremap <M-t> <Esc>vip:Tabularize/\|<CR>
"
" au QuitPre <buffer> lua require('user.utils').write_dom()
"
" " colorscheme default_theme
"
" " show existing tab with 4 spaces width
" set tabstop=4
" " when indenting with '>', use 4 spaces width
" set shiftwidth=4
" " On pressing tab, insert 4 spaces
" set expandtab
" set syntax=markdown
" colorscheme kanagawa
" " set foldexpr=NestedMarkdownFolds()
" "let g:mkdp_browserfunc = 'RunPreviewBrowser'
" "
" "
"
" " [S-Tab] to open and close ALL folds:
" nmap <silent><buffer> <S-Tab> gg<CR><CR>
" " adfasfs
" " " Presentation
" " function! fa#Present()
" " 	:Goyo 120
" " 	:Limelight
" " 	:Gitsigns detach_all
" " endfunction
" "
" " command! Present call Present()
" " nmap <silent><buffer> ,P :Present<CR>
" "
" " " autocmd! User GoyoEnter Limelight
" " autocmd User GoyoEnter Gitsigns detach_all
" " autocmd! User GoyoLeave Limelight!
"
