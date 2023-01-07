" this is simply ctrl-i:
"nnoremap <Tab>   za
" same size after win resize:
autocmd VimResized * wincmd = 

" C-o jump older -> alt-o is jump newer (since C-i is tab which we need elsewhere)
nnoremap <M-o>   <C-i>
"cnoremap <silent> x<CR>  :call ConfirmQuit(1)<CR>
"  "Yank constent with D and C:
nnoremap Y         y$
nnoremap <M-H>     :edit ~/.config/nvim/lua/user/README.md<CR>
nnoremap ,G        :TermExec cmd=lazygit<CR>
nnoremap ,q        :q!<CR>
nnoremap ,Q        :quitall!<cr>
nnoremap ,d        :wq!<CR>
nnoremap ,u        :UndotreeToggle<CR>
nnoremap ,1        :source ~/.config/nvim/init.lua<CR>
nnoremap ,2        :edit ~/.config/nvim/lua/user/init.lua<CR>
" close just a split or a tab
nnoremap ,c        :close<CR> 
"folds
nnoremap <C-i>   zR
" all close:
nmap     ,f        zM  
" toggle:
nnoremap <buffer> <Enter> za
nnoremap <silent> ,3  :ToggleTerm dir=%:p:h<CR>

"" Line join better, position cursor at join point:
" (J is 5 lines jumps)
nnoremap fj $mx<cmd>join<CR>0$[`dmx

" Universal python scriptable file or browser opener over word:
"nmap ,g viW"ay:lua require('utils').smart_open([[<C-R>a]])<CR><CR>
nmap ,g viW"ay:lua require('user.utils').smart_open([[<C-R>a]])<CR>
vmap ,g :lua require('user.utils').smart_open([[visualsel]])<CR><CR>
"Replaced by :ASToggle
"nmap ,s :lua require('user.utils').autosave()<CR>

" tabularize:
nmap ga   :Tabularize/
xmap ga   :Tabularize/
nmap tt  vip:s:,,:\|:ge<CR>vip:Tabularize/\|<CR>
" markdown table
nnoremap ,ta       vip:s/$/\|/ge<CR>vip:s:,,:\|:ge<CR>vip:s:^:\|:ge<CR>vip:s:\|\|:\|:ge<CR>vip:Tabularize/\|<CR> 
" close window:
nnoremap <M-w> :bd!<CR>
nnoremap S :%s//gI<Left><Left><Left>
" move between splits with alt-jk
nnoremap <M-j> <C-W><C-h>
nnoremap <M-k> <C-W><C-l>
inoremap <M-j> <ESC><C-W><C-W>
inoremap <M-k> <ESC><C-W><C-W>
" Jump to end of line in insert mode:
inoremap <C-E> <C-O>A 
nnoremap <C-L> <C-W><C-J>
nnoremap <C-H> <C-W><C-K>
nnoremap 1 ^

" nnoremap <M-1> 1gt
" nnoremap <M-2> 2gt
" nnoremap <M-3> 3gt
" nnoremap <M-4> 4gt
" nnoremap <M-5> 5gt
" nnoremap <M-6> 6gt
" nnoremap <M>7> 7gt
" nnoremap <M-8> 8gt
" nnoremap <M-9> 9gt

nmap <silent> ff <Leader>ff
" :Telescope buffers<cr>
" nnoremap <silent> <Leader>i :lua require("telescope.builtin").buffers({ sort_lastused = true, ignore_current_buffer = true }) <CR>
"nnoremap <silent> <Leader>i :lua require("telescope.builtin").buffers({ sort_lastused = true }) <CR>
"nnoremap <silent> <Leader>i :lua require("telescope.builtin").buffers() <CR>
"nnoremap <silent> <Leader><Leader> :lua require("telescope.builtin").buffers() <CR>
nnoremap <silent> ;                :lua require("telescope.builtin").buffers() <CR>
nnoremap <silent> <Leader>g  :Telescope live_grep<cr>
" previous buffer:
nnoremap <silent> <space><enter>  :ls<cr>:b#<cr> 

" Move paragraph wise. s is hover.
nmap J }j
nmap K {k{kkJ

" go to the position I was when last editing the file
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif

"colorscheme pinkmare"colorscheme kanagawa
nmap ,w  :FormatAndSave<CR>
"save all buffers
nmap ,W  :wa<CR> 
function! s:format_and_save()
    " did NOT work (Not supported msgs were still popping up): vim.g.ui_notifications_enabled=false
    lua vim.notify = print
    " for lua, every ,w is an undo because of that, even with NO change. But only for lua. tolerated:
    silent! lua k=vim.notify; vim.notify=print;vim.lsp.buf.format { async = true};vim.notify=k
    "Like ":write", but only write when the buffer has been changed:
    silent update
endfunction
command! -bang FormatAndSave call s:format_and_save()



"" Yank hilite
augroup  highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=400})
augroup END

" "" Packer
" augroup packer_conf
"   autocmd!
"   autocmd BufWritePost plugins.lua source <afile> | PackerSync
" augroup end


function! SuperMan(...)
  if exists(":Man") != 2 " No :Man command defined
    " Needed to get access to Man
    source $VIMRUNTIME/ftplugin/man.vim
  endif

  " Build and pass off arguments to Man command
  execute 'Man' join(a:000, ' ')

  " Quit with error code if there is only one line in the buffer
  " (i.e., manpage not found)
  if line('$') == 1 | cquit | endif

  " Why :Man opens up in a split I shall never know
  silent only

  " Set options appropriate for viewing manpages
  setlocal readonly
  setlocal nomodifiable
  setlocal noswapfile

  setlocal noexpandtab
  setlocal tabstop=8
  setlocal softtabstop=8
  setlocal shiftwidth=8
  setlocal nolist
  if exists('+colorcolumn')
    setlocal colorcolumn=0
  endif

  " To make us behave more like less
endfunction

command! -nargs=+ SuperMan call SuperMan(<f-args>)


"TSDisableAll indent
" -----------------------------------------------------------------
"colorscheme iceberg

autocmd! FileType TelescopeResults setlocal nofoldenable
" set notermguicolors
" highlight Search ctermfg=0
" https://discordapp.com/channels/939594913560031363/939857762043695165/958793017932800061
"execute "TSDisableAll indent"

" colorscheme pinkmare
" autopairing: consider tmsvg/pear-tree
"
nnoremap          ,r  :PythonEval<CR>
xnoremap <silent> ,r  :PythonEval<CR>
nnoremap          ,E  :EvalInto<CR>


" we often have old stuff at end of files:
" go all down, then (<bar>, next cmd) search up but silent on no found:
" hi Error guifg=#010101
" hi ErrorMsg guifg=#010101
" hi DiagnosticError guifg=#010101
" hi DiagnosticWarn  guifg=Green
" hi DiagnosticInfo  guifg=Blue
" hi DiagnosticHint  guifg=Green

"colorscheme rose-pine
"colorscheme tokyonight

" leave here:
nnoremap  G        :$<CR><bar>:silent! ?begin_archive<CR>
