" Vim indent file
" Language:    ucode template (ucode -T)
" Maintainer:  John Crispin <john@phrozen.org>
" URL:         https://github.com/blogic/ucode-vim
"
" Templates are deliberately left alone. Everything outside {% %} and {{ }} is
" literal output, so its leading whitespace is part of the rendered file: a
" config file, an ACL, a script. Re-indenting it changes the program's output,
" which is why this file switches auto-indenting off rather than supplying an
" indentexpr. The same goes for 'smartindent', which many vimrcs set globally
" and which would shift a line the moment it begins with a brace.

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=
setlocal nosmartindent
setlocal nocindent
setlocal autoindent

let b:undo_indent = "setlocal indentexpr< smartindent< cindent< autoindent<"

" vim: ts=8 sw=2 et
