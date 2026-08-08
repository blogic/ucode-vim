" Autoload functions shared by the ucode filetype plugins.
" Maintainer:  John Crispin <john@phrozen.org>
" URL:         https://github.com/blogic/ucode-vim

let s:cpo_save = &cpo
set cpo&vim

" Turns what 'include' left behind into a path 'gf' can open. The match keeps
" the quotes and whatever punctuation followed it, and a bare module name may
" be written with dots rather than slashes, the shape REQUIRE_SEARCH_PATH
" expects. 'suffixesadd' supplies the extension.
function! ucode#include_expr(fname) abort
  let name = substitute(a:fname, '^[''"]\+', '', '')
  let name = substitute(name, '[''");,]\+$', '', '')

  if name !~# '[/\\]' && name !~# '\.uc$'
    let name = substitute(name, '\.', '/', 'g')
  endif

  return name
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ts=8 sw=2 et
