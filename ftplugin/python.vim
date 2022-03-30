setlocal textwidth=88
setlocal foldmethod=indent
setlocal foldlevel=99
let g:SimpylFold_docstring_preview = 1
map ,b Obreakpoint() # FIXME BREAKPOINT<C-c>
map ,e   Otry:<Esc>j^i<TAB><Esc>oexcept Exception as ex:<CR>print('breakpoint set')<CR>breakpoint()<CR>keep_ctx=True<Esc>^
setlocal expandtab
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal autoindent
setlocal cindent
" on demand, pyright LSP is just the right amount of information for me:
:ALEDisable


