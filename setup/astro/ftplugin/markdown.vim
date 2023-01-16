" Kills conceal of bold / italic
TSDisable highlight



"colorscheme rose-pine
colorscheme tokyonight
setl colorcolumn=
setl conceallevel=1
" using mikeboiko/vim-markdown-folding, fixing the original for header display
"setl foldexpr=markdown#FoldExpression(v:lnum)
setl foldmethod=expr
setl foldexpr=NestedMarkdownFolds()
setl foldlevel=2
" autowrap at textwidth:
setl formatoptions+=t 
" not show spaces or tabs:
setl nolist
setl spell
"setl spelllang=de,en
setl spelllang=en
setl textwidth=90

let g:markdown_fenced_languages = [ "vim", "python", "lua", "bash=sh", "javascript", "typescript", "yaml", "json" ]

" MD Preview in Browser: '/usr/bin/microsoft-edge-dev'
let g:mkdp_browser = expand($BROWSER)
let g:mkdp_theme = 'dark'
let g:mkdp_echo_preview_url = 1

let g:limelight_paragraph_span = 1
let g:limelight_conceal_guifg = '#999999'
let s:present_enabled = 0
function! TogglePresent()
    if s:present_enabled
	    :Goyo
	    :Limelight!
	    :Gitsigns toggle_signs
      let s:present_enabled = 0
      setl conceallevel=1
      setl concealcursor=
      setl spell
      source ~/.config/nvim/lua/user/after/syntax/markdown.vim
    else
	    :Goyo 122
	    :Limelight


	    :Gitsigns toggle_signs
	    " ugly but maybe needed - maybe only change color...?
	    :delmarks! 
	    " hide fences and * and stuff:
      setl conceallevel=2
      " also hide when over them in normal mode:
      setl concealcursor=nc
      setl nospell
      let s:present_enabled = 1
      source ~/.config/nvim/lua/user/after/syntax/markdown.vim
      " hi NonText ctermbg=none guibg=none
      " hi Normal guifg=None guibg=NONE ctermbg=NONE
    endif
endfunction

" Mappings
nmap <silent><buffer> ,p :call TogglePresent()<CR>
nmap <silent><buffer> ,P :MarkdownPreviewToggle<CR>
" you can use ; for pipes. have to create a ; to not make s fail:
nnoremap ,t    0r;vip:s/;/\|/g<CR>vip:Tabularize/\|<CR>

" Syntax
" In syntax markdown.vim, must be loaded after



" begin_archive
" " only way to get both working, markdown syntax AND fenced code (TS):
" syntax off
" let g:markdown_fenced_languages = [ "vim",  "lua", "python", "bash=sh", "javascript", "typescript", "yaml", "json" ]
" lua vim.g.ui_notifications_enabled=false
" :silent lua astronvim.ui.toggle_syntax()
" lua vim.g.ui_notifications_enabled=true
"let g:markdown_folding = 1
" " autowrap at textwidth:
" setl formatoptions+=t 
" setl textwidth=100
" " setl foldlevel=99
" " let g:markdown_folding = 1
" let g:markdown_fenced_languages = [ "vim", "python", "lua", "bash=sh", "javascript", "typescript", "yaml", "json" ]
"
" "colorscheme stellarized
" setl conceallevel=0
"
" let g:vim_markdown_toc_autofit = 0
"
" set nowrap " for long tables
" set linebreak
" 1
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
