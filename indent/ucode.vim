" Vim indent file
" Language: UCODE (OpenWrt scripting language)
" Maintainer: Generated with Claude Code  
" Last Change: 2025-09-07

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=GetUcodeIndent()
setlocal indentkeys=0{,0},0],0),!^F,o,O,e,*<Return>,=*/,=case,=default,=break

" Only define the function once
if exists("*GetUcodeIndent")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

function! GetUcodeIndent()
  " Find a non-blank line above the current line
  let lnum = prevnonblank(v:lnum - 1)

  " At the start of the file use zero indent
  if lnum == 0
    return 0
  endif

  let ind = indent(lnum)
  let prevline = getline(lnum)
  let line = getline(v:lnum)

  " Add indent after opening braces, control structures, etc.
  if prevline =~ '{\s*$' || prevline =~ '{\s*\/\/.*$' || prevline =~ '{\s*\/\*.*\*\/\s*$'
    let ind = ind + shiftwidth()
  elseif prevline =~ '\<\(if\|else\|elseif\|for\|while\|do\|switch\|try\|catch\|finally\|function\)\>'
    if prevline !~ ';\s*$' && prevline !~ '}\s*$'
      let ind = ind + shiftwidth()
    endif
  elseif prevline =~ '\<case\>.*:\s*$' || prevline =~ '\<default\>.*:\s*$'
    let ind = ind + shiftwidth()
  endif

  " Subtract indent for closing braces and break statements
  if line =~ '^\s*}'
    let ind = ind - shiftwidth()
  elseif line =~ '^\s*\(case\|default\)\>'
    if prevline !~ '\<switch\>'
      let ind = ind - shiftwidth()
    endif
  elseif line =~ '^\s*\(else\|elseif\|catch\|finally\)\>'
    let ind = ind - shiftwidth()
  endif

  " Handle multi-line statements
  if prevline =~ '[,+\-*/|&]\s*$' || prevline =~ '\\\s*$'
    if line !~ '^\s*[)}]'
      let ind = ind + shiftwidth()
    endif
  endif

  " Template mode indentation
  if prevline =~ '{%\s*\(if\|for\|while\|block\)\>'
    let ind = ind + shiftwidth()
  elseif line =~ '{%\s*\(endif\|endfor\|endwhile\|endblock\)\>'
    let ind = ind - shiftwidth()
  endif

  return ind
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ts=2 sw=2 et