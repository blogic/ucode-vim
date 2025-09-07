" Vim syntax file for UCODE Template Mode
" Language: UCODE Template (OpenWrt template language)
" Maintainer: Generated with Claude Code
" Last Change: 2025-09-07

if exists("b:current_syntax")
  finish
endif

" Include HTML as base syntax for templates
runtime! syntax/html.vim
unlet! b:current_syntax

" Load ucode syntax into @ucodeCode cluster
syn include @ucodeCode syntax/ucode.vim
unlet! b:current_syntax

" Template tags and blocks
syn region ucodeTemplateBlock matchgroup=ucodeTemplateDelimiter start="{%" end="%}" contains=@ucodeCode keepend
syn region ucodeTemplateBlockTrim matchgroup=ucodeTemplateDelimiter start="{%-" end="-%}" contains=@ucodeCode keepend
syn region ucodeTemplateOutput matchgroup=ucodeTemplateDelimiter start="{{" end="}}" contains=@ucodeCode keepend
syn region ucodeTemplateOutputTrim matchgroup=ucodeTemplateDelimiter start="{{-" end="-}}" contains=@ucodeCode keepend
syn region ucodeTemplateComment start="{#" end="#}" contains=ucodeTodo

" Template control structures
syn keyword ucodeTemplateKeyword if else elseif endif for endfor while endwhile block endblock include extends contained containedin=ucodeTemplateBlock,ucodeTemplateBlockTrim
syn keyword ucodeTemplateFunction include print printf sprintf contained containedin=ucodeTemplateBlock,ucodeTemplateBlockTrim

" Template filters (common ones)
syn match ucodeTemplateFilter "|" contained containedin=ucodeTemplateOutput,ucodeTemplateOutputTrim nextgroup=ucodeTemplateFilterName skipwhite
syn match ucodeTemplateFilterName "\<[a-zA-Z_][a-zA-Z0-9_]*\>" contained

" Highlighting
hi def link ucodeTemplateDelimiter PreProc
hi def link ucodeTemplateComment Comment
hi def link ucodeTemplateKeyword Statement
hi def link ucodeTemplateFunction Function
hi def link ucodeTemplateFilter Operator
hi def link ucodeTemplateFilterName Function

let b:current_syntax = "ucode_template"

" vim: ts=2 sw=2 et