" Vim indent file
" Language:    ucode (OpenWrt scripting language)
" Maintainer:  John Crispin <john@phrozen.org>
" URL:         https://github.com/blogic/ucode-vim
"
" Handles both block forms the compiler accepts: braces, and the alternative
" colon form with endif, endfor, endwhile and endfunction. Brace-less single
" statements are indented and, unlike the previous version of this file, the
" following line is brought back out again.
"
" Every decision is made on the code content of a line only. Braces and
" keywords inside strings, comments and regexp literals are blanked out first,
" using the syntax groups, so that a { in a string no longer shifts the file.

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal indentexpr=UcodeIndentGet(v:lnum)
setlocal indentkeys=0{,0},0),0],!^F,o,O,=elif,=else,=catch,=case,=default,
      \=endif,=endfor,=endwhile,=endfunction
setlocal nosmartindent

let b:undo_indent = "setlocal indentexpr< indentkeys< smartindent<"

if exists("*UcodeIndentGet")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" Openers of the colon form. else has no colon of its own, see
" uc_compiler_compile_if() in the ucode compiler, and is handled separately
" because the brace-less form spells it the same way.
let s:alt_open = '^\s*\%(if\|elif\|for\|while\|function\)\>.*):\s*$'
let s:alt_close = '^\s*\%(endif\|endfor\|endwhile\|endfunction\)\>'

" if (x) / for (x) / while (x) with no brace and no colon: the next statement
" alone forms the body.
let s:braceless = '^\s*\%(if\|for\|while\)\s*(.*)\s*$'

" Lines that close or continue an enclosing block. case and default sit with
" them so that a switch body follows the OpenWrt C convention, labels level
" with the switch and statements one level in.
let s:dedent = '^\s*\%([}\])]\|\%(elif\|else\|catch\|case\|default\)\>\|'
      \ . '\%(endif\|endfor\|endwhile\|endfunction\)\>\)'

function! s:code_get(lnum) abort
  let line = getline(a:lnum)
  let out = ''
  let col = 1

  while col <= len(line)
    let name = synIDattr(synID(a:lnum, col, 1), 'name')
    let out .= (name =~? 'comment\|string\|regex\|todo\|shebang') ? ' ' : line[col - 1]
    let col += 1
  endwhile

  return out
endfunction

" Brackets a line leaves open. Closers with no opener on the same line are
" ignored: `} else {` leaves one bracket open, and its own leading brace was
" already paid for when that line was indented.
function! s:opens_count(code) abort
  let depth = 0
  let col = 0

  while col < len(a:code)
    let ch = a:code[col]
    if ch =~# '[([{]'
      let depth += 1
    elseif ch =~# '[)\]}]' && depth > 0
      let depth -= 1
    endif
    let col += 1
  endwhile

  return depth
endfunction

" A bare else belongs to the colon form when the if it lines up with carried a
" colon. Without this the alternative form loses a level on every else body.
function! s:else_is_alt(lnum) abort
  let want = indent(a:lnum)
  let lnum = prevnonblank(a:lnum - 1)

  while lnum > 0 && a:lnum - lnum < 100
    if indent(lnum) == want && getline(lnum) =~# '^\s*\%(if\|elif\)\>'
      return getline(lnum) =~# '):\s*$'
    endif
    let lnum = prevnonblank(lnum - 1)
  endwhile

  return 0
endfunction

function! s:opens_block(lnum, code) abort
  if a:code =~# s:alt_open || a:code =~# s:braceless
    return 1
  endif
  return a:code =~# '^\s*else\s*$'
endfunction

" Only a brace-less body gets unwound after its single statement. A colon-form
" body runs until its end keyword and must be left alone.
function! s:unwinds(lnum, code) abort
  if a:code =~# s:braceless
    return 1
  endif
  return a:code =~# '^\s*else\s*$' && !s:else_is_alt(a:lnum)
endfunction

function! UcodeIndentGet(lnum) abort
  let prev = prevnonblank(a:lnum - 1)
  if prev == 0
    return 0
  endif

  let pcode = s:code_get(prev)
  let ccode = s:code_get(a:lnum)
  let opens = s:opens_count(pcode)
  let ind = indent(prev) + shiftwidth() * opens

  if s:opens_block(prev, pcode)
    let ind += shiftwidth()
  endif

  if pcode =~# '^\s*\%(case\|default\)\>.*:\s*$'
    let ind += shiftwidth()
  endif

  " A line that closes or continues a block does its own arithmetic; unwinding
  " a brace-less body as well would take it out two levels. Nor is there
  " anything to unwind while the previous line is still opening something.
  if ccode =~# s:dedent
    let ind -= shiftwidth()
  elseif opens == 0 && !s:opens_block(prev, pcode)
    let lnum = prevnonblank(prev - 1)
    while lnum > 0 && s:unwinds(lnum, s:code_get(lnum))
      let ind -= shiftwidth()
      let lnum = prevnonblank(lnum - 1)
    endwhile
  endif

  return ind < 0 ? 0 : ind
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ts=8 sw=2 et
