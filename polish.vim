" this is simply ctrl-i:
"nnoremap <Tab>   za
nnoremap <C-i>   za
"cnoremap <silent> x<CR>  :call ConfirmQuit(1)<CR>
"  "Yank constent with D and C:
nnoremap Y         y$
nnoremap ,l        :LazyGit<CR>
nnoremap ,q        :q!<CR>
nnoremap ,Q        :Q!<cr>
nnoremap ,d        :wq!<CR>
nnoremap ,1        :source ~/.config/nvim/init.lua<CR>
nnoremap ,2        :edit ~/.config/nvim/lua/user/init.lua<CR>
nnoremap ,c        :close<CR> " close just a split or a tab
nmap     ,f        za "folds


nnoremap <silent> ,3  :FloatermNew! --autoclose=2 --wintype=vsplit cd %:p:h<CR>

"" Line join better, position cursor at join point:
" (J is 5 lines jumps)
nnoremap gj $mx<cmd>join<CR>0$[`dmx

" Universal python scriptable file or browser opener over word:
"nmap ,g viW"ay:lua require('utils').smart_open([[<C-R>a]])<CR><CR>
nmap ,g viW"ay:lua require('user.utils').smart_open([[<C-R>a]])<CR>
vmap ,g :lua require('user.utils').smart_open([[visualsel]])<CR><CR>

" tabularize:
nmap ga   :Tabularize/
xmap ga   :Tabularize/
nmap tt  vip:s:,,:\|:ge<CR>vip:Tabularize/\|<CR>
" markdown table
nnoremap ,ta       vip:s/$/\|/ge<CR>vip:s:,,:\|:ge<CR>vip:s:^:\|:ge<CR>vip:s:\|\|:\|:ge<CR>vip:Tabularize/\|<CR> 

nnoremap S :%s//gI<Left><Left><Left>
" move between splits with alt-jk
nnoremap <M-j> <C-W><C-W>
nnoremap <M-k> <C-W><C-W>
inoremap <M-j> <ESC><C-W><C-W>
inoremap <M-k> <ESC><C-W><C-W>
nnoremap <C-L> <C-W><C-J>
nnoremap <C-H> <C-W><C-K>

nmap <silent> <Leader><Leader> <Leader>ff
nnoremap <silent> <Leader>h  :Telescope buffers<cr>
nnoremap <silent> <Leader>g  :Telescope live_grep<cr>


" go to the position I was when last editing the file
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif

"colorscheme pinkmare"colorscheme kanagawa
nmap ,w  :FormatAndSave<CR>
function! s:format_and_save()
    lua vim.lsp.buf.formatting()
    update
endfunction
command! -bang FormatAndSave call s:format_and_save()


"" AutoSave
nmap ,s  :AutoSave<CR>
function! s:autosave(enable)
  augroup autosave
    autocmd!
    " at $IDE we call this at ANY BufEnter, with enable=2
    if a:enable == 2
        if $IDE != 'true'
            return
        endif
    endif
    if a:enable
      autocmd TextChanged,InsertLeave <buffer>
            \  if empty(&buftype) && !empty(bufname(''))
            \|   silent! update
            \| endif
      :lua require("notify")("Autosave is on.", "info", {timeout=2000, title="Autosave"})
    endif
  augroup END
endfunction
command! -bang AutoSave call s:autosave(<bang>1)
autocmd BufEnter *.* :call s:autosave(2) " $IDE -> always

"" Yank hilite
augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=400})
augroup END

"" Packer
augroup packer_conf
  autocmd!
  autocmd BufWritePost plugins.lua source <afile> | PackerSync
augroup end


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





let g:EasyMotion_do_mapping = 0 " Disable default mappings

" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
"nmap s <Plug>(easymotion-overwin-f)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
nmap s <Plug>(easymotion-overwin-f2)

" Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
"TSDisableAll indent
" -----------------------------------------------------------------
" we often have old stuff at end of files:
nnoremap  G      G?begin_archive<CR>
" https://discordapp.com/channels/939594913560031363/939857762043695165/958793017932800061
execute 'TSDisableAll indent'
colorscheme pinkmare

