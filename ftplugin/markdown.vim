" Must be in ftplugin folder because of folding
"setlocal nowrap
setlocal spell
setlocal spelllang=de,en
setlocal nolist
setlocal colorcolumn=
"setlocal foldexpr=markdown#FoldExpression(v:lnum)
"setlocal foldmethod=expr
" autowrap at textwidth:
setlocal formatoptions+=t 
setlocal textwidth=100
setlocal foldlevel=99
let g:markdown_folding = 1
let g:markdown_fenced_languages = [ "vim", "python", "lua", "bash=sh", "javascript", "typescript", "yaml", "json" ]
"colorscheme stellarized
setlocal conceallevel=0
set conceallevel=0

let g:vim_markdown_toc_autofit = 0

set nowrap " for long tables
set linebreak

let g:md_preview_tools = "/home/gk/inst/tb-my-editor/"
let g:mkdp_browser = g:md_preview_tools .. "browser.sh"

nnoremap ,p <cmd>MarkdownPreviewToggle<cr>
nnoremap ,[ :lua require('utils').write_dom()<CR>

au QuitPre <buffer> lua require('user.utils').write_dom()



"let g:mkdp_browserfunc = 'RunPreviewBrowser'

