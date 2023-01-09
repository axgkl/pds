" "syntax keyword Normal foo conceal cchar=🟧
"
" " stolen from lsp_markdown:
" " Conceal backticks (which delimit code fragments). We ignore g:markdown_syntax_conceal here.
" " syn region markdownCode matchgroup=markdownCodeDelimiter start="`" end="`" keepend contains=markdownLineStart concealends
" " syn region markdownCode matchgroup=markdownCodeDelimiter start="`` \=" end=" \=``" keepend contains=markdownLineStart concealends
" " syn region markdownCode matchgroup=markdownCodeDelimiter start="^\s*````*.*$" end="^\s*````*\ze\s*$" keepend concealends
" " Highlight code fragments.
" hi def link markdownCode Special
" hi def link markdownBlockquote            Error
"
" " syn match  mkdListBullet1                              "\*"                                                                                  contained conceal cchar=
"
" syn region htmlH1              matchgroup=mkdDelimiter start="^\s*#"                                  end="\($\|[^\\]#\+\)"                  concealends contains=@Spell,mkdEscapeChar
" syn match markdownListMarker1 "^\s[A]\%(\s\+\S\)\@="  conceal cchar=X
" hi link markdownListMarker1           htmlH1
" highlight MyGroup ctermbg=green guibg=green
" match MyGroup /asdf/

" Copy Clear
" ◉ ○ ◌ ◍ ◎ ● ◐ ◑ ◒ ◓ ◔ ◕ ◖ ◗ ❂ ☢ ⊗ ⊙ ◘ ◙ ◚ ◛ ◜ ◝ ◞ ◟ ◠ ◡ ◯ 〇 〶 ⚫ ⬤ ◦ ∅ ∘ ⊕ ⊖ ⊘ ⊚ ⊛ ⊜ ⊝ ❍ ⦿
"syn match header1 "^# " conceal cchar=X
"
" 🟡🟨🟧🟥🟦🟩🟫🟪◉ ○ ◌ ◍ ◎ ● ◐ ◑ ◒ ◓ ◔ ◕ ◖ ◗ ❂ ☢ ⊗ ⊙ ◘ ◙ ◚ ◛ ◜ ◝ ◞ ◟ ◠ ◡ ◯ 〇 〶 ⚫ ⬤ ◦ ∅ ∘ ⊕ ⊖ ⊘ ⊚ ⊛ ⊜ ⊝ ❍ ⦿
"syntax match header4 "^#### " conceal cchar=🟥 



" ◌ vi: tw=60 -> don't show in present mode
syntax match hide1 "◌\s.*$" conceal
hi link hide1 Comment
syntax match header4 "^## " conceal cchar=🟥 
"
