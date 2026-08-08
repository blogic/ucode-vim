" Vim filetype plugin
" Language:    ucode template (ucode -T)
" Maintainer:  John Crispin <john@phrozen.org>
" URL:         https://github.com/blogic/ucode-vim

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

setlocal commentstring={#\ %s\ #}
setlocal comments=
setlocal formatoptions-=t
setlocal formatoptions-=c

setlocal suffixesadd=.uc,.ut,.utpl
let &l:include = '{%.*\<include\s*('
setlocal includeexpr=ucode#include_expr(v:fname)

if exists("loaded_matchit")
  let b:match_ignorecase = 0
  let b:match_words = '{%:%},{{:}},{#:#},'
        \ . '\<if\>:\<elif\>:\<else\>:\<endif\>,'
        \ . '\<for\>:\<endfor\>,'
        \ . '\<while\>:\<endwhile\>'
endif

let b:undo_ftplugin = "setlocal commentstring< comments< formatoptions<"
      \ . " suffixesadd< include< includeexpr<"
      \ . " | unlet! b:match_words b:match_ignorecase"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ts=8 sw=2 et
