" Test runner for the ucode syntax files.
"
" Drives a real vim over each fixture in test/cases and checks the syntax group
" vim actually assigns to a given position, via synID(). Nothing is mocked, so
" a passing run means the shipped syntax files behave as stated.
"
"   test/run.sh                 run every case
"   test/run.sh --dump FILE     print the group map for FILE, to author a .exp
"   test/run.sh --smoke DIR     assert no error group fires anywhere under DIR
"
" Expectation file syntax, one directive per line, # starts a comment:
"
"   ft <filetype>          the filetype ftdetect settled on
"   <lnum> <col> <group>   group at that position, NONE for unhighlighted
"   <lnum> <col> !<group>  group at that position is anything but this
"   absent <group>         group fires nowhere in the fixture
"   present <group>        group fires somewhere in the fixture

let s:repo = fnamemodify(expand('<sfile>:p'), ':h:h')

set nocompatible
set nomore
set noswapfile
execute 'set runtimepath^=' . fnameescape(s:repo)
filetype plugin indent on
syntax enable

let s:checks = 0
let s:failures = []

function! s:say(msg) abort
  call writefile([a:msg], '/dev/stderr', 'a')
endfunction

function! s:group(lnum, col) abort
  let name = synIDattr(synID(a:lnum, a:col, 1), 'name')
  return name ==# '' ? 'NONE' : name
endfunction

" Group map for the whole buffer, collapsed into runs so that both the dump and
" the absent/present directives stay cheap on large files.
function! s:runs() abort
  let out = []
  for lnum in range(1, line('$'))
    let width = col([lnum, '$']) - 1
    let prev = ''
    let start = 0
    for c in range(1, width)
      let name = s:group(lnum, c)
      if name !=# prev
        if start > 0 && prev !=# 'NONE'
          call add(out, [lnum, start, c - 1, prev])
        endif
        let prev = name
        let start = c
      endif
    endfor
    if start > 0 && prev !=# 'NONE'
      call add(out, [lnum, start, width, prev])
    endif
  endfor
  return out
endfunction

function! s:fail(case, msg) abort
  call add(s:failures, printf('%s: %s', a:case, a:msg))
endfunction

function! s:check_case(fixture) abort
  let name = fnamemodify(a:fixture, ':t')
  let expfile = fnamemodify(a:fixture, ':r') . '.exp'

  if !filereadable(expfile)
    call s:fail(name, 'no expectation file ' . fnamemodify(expfile, ':t'))
    return
  endif

  execute 'silent! edit! ' . fnameescape(a:fixture)
  " A fixture may be re-read within one session; force the syntax to settle.
  syntax sync fromstart

  let groups = {}
  for run in s:runs()
    let groups[run[3]] = 1
  endfor

  for raw in readfile(expfile)
    " An opt value may itself contain a #, as the template commentstring does,
    " so those lines carry no trailing comment.
    let line = substitute(raw, '^\s*\|\s*$', '', 'g')
    if line !~# '^opt\>'
      let line = substitute(line, '\s*#.*$', '', '')
      let line = substitute(line, '\s*$', '', '')
    endif
    if line ==# ''
      continue
    endif

    let s:checks += 1
    let parts = split(line)

    " Consumed by the parse check in run.sh, not by the syntax checks.
    if parts[0] ==# 'invalid'
      continue
    endif

    if parts[0] ==# 'ft'
      if &filetype !=# parts[1]
        call s:fail(name, printf('filetype is %s, expected %s', &filetype, parts[1]))
      endif
      continue
    endif

    " opt <name> <value>: a buffer-local option the ftplugin is expected to set.
    if parts[0] ==# 'opt'
      let want = join(parts[2:])
      let got = eval('&l:' . parts[1])
      if got !=# want
        call s:fail(name, printf("'%s' is %s, expected %s",
              \ parts[1], string(got), string(want)))
      endif
      continue
    endif

    if parts[0] ==# 'absent'
      if has_key(groups, parts[1])
        call s:fail(name, printf('%s fires but should not', parts[1]))
      endif
      continue
    endif

    if parts[0] ==# 'present'
      if !has_key(groups, parts[1])
        call s:fail(name, printf('%s never fires', parts[1]))
      endif
      continue
    endif

    let lnum = str2nr(parts[0])
    let cnum = str2nr(parts[1])
    let want = parts[2]
    let got = s:group(lnum, cnum)

    if want[0] ==# '!'
      if got ==# want[1:]
        call s:fail(name, printf('%d:%d is %s, expected anything else (%s)',
              \ lnum, cnum, got, getline(lnum)))
      endif
    elseif got !=# want
      call s:fail(name, printf('%d:%d is %s, expected %s (%s)',
            \ lnum, cnum, got, want, getline(lnum)))
    endif
  endfor
endfunction

" Indent cases: re-indent test/indent/NAME.in with = and require the result to
" match NAME.out byte for byte.
function! s:check_indent(infile) abort
  let name = fnamemodify(a:infile, ':t')
  let outfile = fnamemodify(a:infile, ':r') . '.out'

  if !filereadable(outfile)
    call s:fail(name, 'no expected output ' . fnamemodify(outfile, ':t'))
    return
  endif

  " The .in extension carries no filetype, so name it here rather than teach
  " ftdetect about fixtures.
  execute 'silent! edit! ' . fnameescape(a:infile)
  setlocal filetype=ucode
  setlocal noexpandtab shiftwidth=8 tabstop=8 softtabstop=0
  silent! normal! gg=G

  let got = getline(1, '$')
  let want = readfile(outfile)
  let s:checks += 1

  if got ==# want
    return
  endif

  for i in range(max([len(got), len(want)]))
    let g = get(got, i, '<missing>')
    let w = get(want, i, '<missing>')
    if g !=# w
      call s:fail(name, printf('line %d indented as %s, expected %s',
            \ i + 1, string(g), string(w)))
    endif
  endfor
endfunction

function! s:dump(file) abort
  execute 'silent! edit! ' . fnameescape(a:file)
  syntax sync fromstart
  call s:say(printf('# %s (filetype=%s)', a:file, &filetype))
  let lnum = 0
  for run in s:runs()
    if run[0] != lnum
      let lnum = run[0]
      call s:say(printf('# %3d %s', lnum, getline(lnum)))
    endif
    if run[1] == run[2]
      call s:say(printf('%d %d %s', run[0], run[1], run[3]))
    else
      call s:say(printf('%d %d %s   # cols %d-%d %s', run[0], run[1], run[3],
            \ run[1], run[2], strpart(getline(run[0]), run[1] - 1, run[2] - run[1] + 1)))
    endif
  endfor
endfunction

" Smoke pass over a tree of real ucode. Any character landing in an error group
" is a false positive that the hand-written fixtures did not catch.
function! s:smoke(dir) abort
  let files = split(globpath(a:dir, '**/*.uc'), '\n')
  call s:say(printf('smoke: %d files under %s', len(files), a:dir))
  let bad = 0
  for file in files
    execute 'silent! edit! ' . fnameescape(file)
    syntax sync fromstart
    for run in s:runs()
      if run[3] =~# 'Error$'
        call s:say(printf('%s:%d:%d: %s  %s', file, run[0], run[1], run[3],
              \ strpart(getline(run[0]), run[1] - 1, run[2] - run[1] + 1)))
        let bad += 1
      endif
    endfor
  endfor
  call s:say(printf('smoke: %d error hits', bad))
  return bad
endfunction

let s:argv = get(g:, 'ucode_test_args', [])

if len(s:argv) >= 2 && s:argv[0] ==# '--dump'
  call s:dump(s:argv[1])
  qall!
elseif len(s:argv) >= 2 && s:argv[0] ==# '--smoke'
  if s:smoke(s:argv[1]) > 0
    cquit 1
  endif
  qall!
endif

let s:cases = sort(split(globpath(s:repo . '/test/cases', '*.uc') . "\n"
      \ . globpath(s:repo . '/test/cases', '*.ut'), '\n'))

if empty(s:cases)
  call s:say('no fixtures found under test/cases')
  cquit 1
endif

for s:case in s:cases
  call s:check_case(s:case)
endfor

let s:indents = sort(split(globpath(s:repo . '/test/indent', '*.in'), '\n'))

for s:case in s:indents
  call s:check_indent(s:case)
endfor

if empty(s:failures)
  call s:say(printf('ok: %d syntax cases, %d indent cases, %d checks',
        \ len(s:cases), len(s:indents), s:checks))
  qall!
endif

for s:failure in s:failures
  call s:say('FAIL ' . s:failure)
endfor
call s:say(printf('%d of %d checks failed across %d cases',
      \ len(s:failures), s:checks, len(s:cases)))
cquit 1
