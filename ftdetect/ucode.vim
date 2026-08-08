" Vim filetype detection for ucode.
"
" *.uc already belongs to vim's own filetype.vim, which maps it to UnrealScript
" (filetype "uc"). :setf is a no-op once that has fired, so the rules below use
" an explicit :set. ftdetect scripts are sourced at the end of filetype.vim,
" after the builtin rules, so the later :set wins the tie.
"
" Option:
"   g:ucode_detect_templates  treat a .uc file whose first 50 lines contain a
"                             line-leading {% as a template (0)

if exists("g:did_load_ucode_ftdetect")
  finish
endif
let g:did_load_ucode_ftdetect = 1

function! s:ucode_shebang() abort
  let first = getline(1)
  if first !~# '^#!.*\<ucode\>'
    return
  endif
  " ucode -T selects template mode.
  if first =~# '\s-\a*T\>'
    set filetype=ucode_template
  else
    set filetype=ucode
  endif
endfunction

function! s:ucode_sniff() abort
  if !get(g:, "ucode_detect_templates", 0)
    return
  endif
  for lnum in range(1, min([50, line('$')]))
    if getline(lnum) =~# '^\s*{%'
      set filetype=ucode_template
      return
    endif
  endfor
endfunction

au BufRead,BufNewFile *.uc,*.ucode set filetype=ucode | call s:ucode_sniff()
au BufRead,BufNewFile *.uc.tmpl,*.ucode.tmpl,*.ut,*.utpl set filetype=ucode_template
au BufRead * call s:ucode_shebang()
