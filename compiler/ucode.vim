" Vim compiler file
" Compiler:    ucode
" Maintainer:  John Crispin <john@phrozen.org>
" URL:         https://github.com/blogic/ucode-vim
"
" :make syntax-checks the current file with ucode -c.
"
" Caveat worth knowing before you reach for it: -c refuses any file containing
" an export statement, with "Exports may only appear at top level of a module".
" A module therefore cannot be checked on its own; write a script that imports
" it and check that instead.
"
" ucode reports errors as
"
"   Syntax error: Expecting expression
"   In line 2, byte 9:
"
"    `let b = ;`
"             ^-- Near here
"
" with no file name anywhere, so makeprg prints the name first and %+P picks it
" up as the file every following entry belongs to.

if exists("current_compiler")
  finish
endif
let current_compiler = "ucode"

let s:cpo_save = &cpo
set cpo&vim

CompilerSet makeprg=echo\ %;ucode\ -c\ -o\ /dev/null\ %

CompilerSet errorformat=
      \%+P%f,
      \%ESyntax\ error:\ %m,
      \%EType\ error:\ %m,
      \%EReference\ error:\ %m,
      \%ERuntime\ error:\ %m,
      \%CIn\ line\ %l\\,\ byte\ %v:,
      \%CIn\ %.%#\\,\ line\ %l\\,\ byte\ %v:,
      \%-G%.%#

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ts=8 sw=2 et
