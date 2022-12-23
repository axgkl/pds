setlocal textwidth=200
setlocal foldmethod=indent
setlocal foldlevel=99
let g:SimpylFold_docstring_preview = 1
map ,b Obreakpoint() # FIXME BREAKPOINT<C-c>
map ,e   Otry:<Esc>j^i<TAB><Esc>oexcept Exception as ex:<CR>print('breakpoint set')<CR>breakpoint()<CR>keep_ctx=True<Esc>^
map ,l J0fdxxxxf(xi=lambda <Esc>f)xllcw
nnoremap ,L ^idef <Esc>f d2f i(<Esc>f:i)<Esc>lli return 
setlocal expandtab
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal autoindent
setlocal cindent
let g:python_highlight_all = 1



" on demand, pyright LSP is just the right amount of information for me:
":ALEDisable


