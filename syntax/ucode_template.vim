" Vim syntax file
" Language:    ucode template (ucode -T)
" Maintainer:  John Crispin <john@phrozen.org>
" URL:         https://github.com/blogic/ucode-vim
"
" Tag shapes are taken from the template state machine in lexer.c:
"
"   {#  {#-   comment   closed by  #}  -#}
"   {{  {{-   expression           }}  -}}
"   {%  {%-  {%+  statement        %}  -%}
"
" A { that is not followed by #, { or % is literal text. There is no {{+, and
" +%} is a syntax error rather than a trim marker.
"
" ucode has no Jinja filter pipeline: {{ 6 | 1 }} renders 7, a bitwise or.
"
" Option:
"   g:ucode_template_base  filetype to layer under the literal text, for
"                          example "html". Empty by default, because a ucode
"                          template usually renders a config file.

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

let s:base = get(g:, "ucode_template_base", "")
if s:base !=# ""
  execute "runtime! syntax/" . s:base . ".vim"
  unlet! b:current_syntax
endif

syn include @ucodeCode syntax/ucode.vim
unlet! b:current_syntax

" A template region can begin anywhere, so the whole file has to be scanned.
syn sync fromstart

syn match ucodeTemplateShebang "\%^#!.*$"

syn region ucodeTemplateComment keepend
      \ matchgroup=ucodeTemplateDelim start="{#-\=" end="-\=#}"
      \ contains=ucodeTodo,@Spell

syn region ucodeTemplateExprBlock keepend
      \ matchgroup=ucodeTemplateDelim start="{{-\=" end="-\=}}"
      \ contains=@ucodeCode

syn region ucodeTemplateStmtBlock keepend
      \ matchgroup=ucodeTemplateDelim start="{%[-+]\=" end="-\=%}"
      \ contains=@ucodeCode

hi def link ucodeTemplateShebang PreProc
hi def link ucodeTemplateDelim PreProc
hi def link ucodeTemplateComment Comment
hi def link ucodeTemplateExprBlock Normal
hi def link ucodeTemplateStmtBlock Normal

let b:current_syntax = "ucode_template"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ts=8 sw=2 et
