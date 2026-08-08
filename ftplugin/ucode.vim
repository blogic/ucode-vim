" Vim filetype plugin
" Language:    ucode (OpenWrt scripting language)
" Maintainer:  John Crispin <john@phrozen.org>
" URL:         https://github.com/blogic/ucode-vim

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

setlocal commentstring=//\ %s
setlocal comments=s1:/*,mb:*,ex:*/,://
setlocal formatoptions-=t
setlocal formatoptions+=croql

" 'iskeyword' is left alone on purpose. A JavaScript ftplugin adds $ here, but
" a $ in an identifier is a lexer error in ucode.

setlocal suffixesadd=.uc,.ucode
" Assigned rather than :set, so the alternation bar does not have to survive
" two rounds of option escaping.
let &l:include = '^\s*\%(import\>.*\<from\|\<require\s*(\)'
setlocal includeexpr=ucode#include_expr(v:fname)

if exists("loaded_matchit")
  let b:match_ignorecase = 0
  let b:match_words = '\<if\>:\<elif\>:\<else\>:\<endif\>,'
        \ . '\<for\>:\<endfor\>,'
        \ . '\<while\>:\<endwhile\>,'
        \ . '\<function\>:\<endfunction\>'
endif

compiler ucode

let b:undo_ftplugin = "setlocal commentstring< comments< formatoptions<"
      \ . " suffixesadd< include< includeexpr< makeprg< errorformat<"
      \ . " | unlet! b:match_words b:match_ignorecase"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ts=8 sw=2 et
