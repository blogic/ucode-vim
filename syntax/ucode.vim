" Vim syntax file
" Language:    ucode (OpenWrt scripting language)
" Maintainer:  John Crispin <john@phrozen.org>
" URL:         https://github.com/blogic/ucode-vim
"
" Keywords, builtins, globals and module names are transcribed from the ucode
" sources rather than from recollection:
"
"   reserved_words[]        lexer.c   28 keywords
"   uc_stdlib_functions[]   lib.c     71 builtins
"   uc_vm_init_scope()      vm.c      global bindings
"   lib/*.c                           bundled modules
"
" Options:
"   g:ucode_space_errors     flag trailing whitespace and space-before-tab (1)
"   g:ucode_no_jsism_errors  suppress JavaScript-ism error highlighting (0)
"   g:ucode_fold             fold function bodies and block comments (0)

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn case match

" Block comments and template literals both span lines, so a windowed sync
" mis-colours the tail of a long file.
syn sync fromstart

" Trailing whitespace ------------------------------------------------------
" Contained as well as top level, so that it stays visible inside comments and
" strings. Modelled on cSpaceError in the shipped syntax/c.vim.

if get(g:, "ucode_space_errors", 1)
  syn match ucodeSpaceError display excludenl "\s\+$"
  syn match ucodeSpaceError display " \+\t"me=e-1
  syn match ucodeSpaceErrorC display excludenl "\s\+$" contained
  syn match ucodeSpaceErrorC display " \+\t"me=e-1 contained
endif

" Comments -----------------------------------------------------------------
" ucode has // and /* */ only. A leading # is a lexer error outside the
" shebang, see parse_comment() in lexer.c.

syn keyword ucodeTodo contained TODO FIXME XXX NOTE TBD HACK WARNING

if get(g:, "ucode_fold", 0)
  syn region ucodeCommentBlock start="/\*" end="\*/"
        \ contains=ucodeTodo,ucodeSpaceErrorC,@Spell fold extend
else
  syn region ucodeCommentBlock start="/\*" end="\*/"
        \ contains=ucodeTodo,ucodeSpaceErrorC,@Spell extend
endif

syn region ucodeCommentLine start="//" skip="\\$" end="$" keepend
      \ contains=ucodeTodo,ucodeSpaceErrorC,@Spell

" Keywords -----------------------------------------------------------------
" The alternative block syntax is real: `if (x): ... elif (y): ... endif;`
" and the matching endfor, endwhile and endfunction forms.

syn keyword ucodeConditional if elif else endif switch case default
syn keyword ucodeRepeat while endwhile for endfor
syn keyword ucodeBranch break continue return
syn keyword ucodeException try catch
syn keyword ucodeOperatorKeyword delete in
syn keyword ucodeBoolean true false
syn keyword ucodeNull null
syn keyword ucodeThis this

syn keyword ucodeDeclaration let const
      \ nextgroup=ucodeVariableName,ucodeJsDestructure skipwhite
syn keyword ucodeFunction function endfunction
      \ nextgroup=ucodeFunctionName skipwhite
syn keyword ucodeImport import export

syn match ucodeVariableName contained "[A-Za-z_]\w*"
syn match ucodeFunctionName contained "[A-Za-z_]\w*"

" Module system ------------------------------------------------------------
" `from` and `as` are contextual, not reserved, so they only highlight in the
" shape an import actually takes.

syn match ucodeImportFrom "\<from\>\ze\s*['\"]"
      \ nextgroup=ucodeModulePath skipwhite
syn match ucodeImportAs "\%(\*\s*\)\@<=\<as\>"

" require() is declared apart from the builtin list below only so that it can
" carry a nextgroup; a keyword outranks any match, so a separate match rule
" would never see the call.
syn keyword ucodeBuiltin require nextgroup=ucodeRequireParen skipwhite
syn match ucodeRequireParen contained "("
      \ nextgroup=ucodeModulePath skipwhite

syn region ucodeModulePath contained oneline
      \ start=+'+ end=+'+ contains=ucodeModuleName
syn region ucodeModulePath contained oneline
      \ start=+"+ end=+"+ contains=ucodeModuleName

syn keyword ucodeModuleName contained
      \ debug digest fs io log math nl80211 resolv rtnl socket struct
      \ ubus uci udebug uloop zlib

" Builtins and globals -----------------------------------------------------

syn keyword ucodeBuiltin
      \ arrtoip assert b64dec b64enc call chr clock die exists exit filter
      \ gc getenv gmtime hex hexdec hexenc include index int iptoarr join
      \ json keys lc length loadfile loadstring localtime ltrim map match
      \ max min ord pop print printf proto push regexp render replace
      \ reverse rindex rtrim shift signal sleep slice sort
      \ sourcepath split splice sprintf substr system time timegm timelocal
      \ trace trim type uc uchr uniq unshift values warn wildcard

syn keyword ucodeGlobal ARGV REQUIRE_SEARCH_PATH modules NaN Infinity global

" Shebang ------------------------------------------------------------------
" Defined ahead of the regexp region below; the interpreter path must not be
" mistaken for a regexp literal.

syn match ucodeShebang "\%^#!.*$"

" Strings ------------------------------------------------------------------
" Escape set from parse_escape() in lexer.c: \uHHHH, \xHH, up to three octal
" digits, and the letters abefnrtv. Anything else yields the literal char.

syn match ucodeStringEscape contained "\\u\x\{4}"
syn match ucodeStringEscape contained "\\x\x\{2}"
syn match ucodeStringEscape contained "\\[0-7]\{1,3}"
syn match ucodeStringEscape contained "\\[abefnrtv\\'\"`$]"

syn region ucodeString start=+"+ skip=+\\\\\|\\"+ end=+"+
      \ contains=ucodeStringEscape,ucodeSpaceErrorC,@Spell
syn region ucodeString start=+'+ skip=+\\\\\|\\'+ end=+'+
      \ contains=ucodeStringEscape,ucodeSpaceErrorC,@Spell

syn region ucodeTemplateString matchgroup=ucodeTemplateStringDelim
      \ start=+`+ skip=+\\\\\|\\`+ end=+`+
      \ contains=ucodeTemplateExpr,ucodeStringEscape,@Spell
syn region ucodeTemplateExpr contained matchgroup=ucodeTemplateExprDelim
      \ start="${" end="}" contains=@ucodeExpression

" Numbers ------------------------------------------------------------------
" No digit separators: 1_000 is a syntax error. Legacy 0NNN octal is accepted
" alongside the 0o form.

syn match ucodeNumber "\<0[xX]\x\+\>"
syn match ucodeNumber "\<0[bB][01]\+\>"
syn match ucodeNumber "\<0[oO][0-7]\+\>"
syn match ucodeNumber "\<0[0-7]\+\>"
syn match ucodeNumber "\<\d\+\>"
syn match ucodeFloat "\<\d\+\.\d*\%([eE][+-]\=\d\+\)\=\>"
syn match ucodeFloat "\<\d\+[eE][+-]\=\d\+\>"

" Operators and punctuation ------------------------------------------------

syn match ucodeOperator "\.\.\."
syn match ucodeOperator "=>"
syn match ucodeOperator "\*\*=\="
syn match ucodeOperator "[-+*%]=\="
syn match ucodeOperator "/="
syn match ucodeOperator "[!=]==\="
syn match ucodeOperator "[<>]="
syn match ucodeOperator "<<=\=\|>>=\="
syn match ucodeOperator "[<>]"
syn match ucodeOperator "&&=\=\|||=\=\|??=\="
syn match ucodeOperator "[&|^~]=\="
syn match ucodeOperator "++\|--"
syn match ucodeOperator "[?:]"
" A bare slash is division, but // and /* open comments and must not be
" claimed here: at an equal start position vim prefers the later definition.
syn match ucodeOperator "/[/*]\@!"
syn match ucodeOperator "="

syn match ucodePunctuation "[()\[\]{};,]"

" Regexp literals ----------------------------------------------------------
" A slash opens a regexp only where an operand is expected. This mirrors the
" no_regexp flag the compiler feeds back into the lexer, set in
" uc_compiler_parse_precedence() in compiler.c. Anywhere else the slash is
" division, which is why the old unguarded rule swallowed everything between
" two divisions on the same line.
"
" The context is tested with a bounded lookbehind so that the region starts on
" the slash itself. Folding the context character into the start pattern and
" pulling the region back with ms=e-1 does not work: vim ranks candidates by
" the offset-adjusted start, so such a region always loses the context
" character to whichever operator or punctuation rule also claims it, and then
" never starts at all.
"
" This block sits after the operator rules on purpose. Both claim the slash
" from the same column, and vim settles that tie in favour of the item defined
" last. The start pattern is delimited with " rather than +, because the
" context character class contains a + of its own.

syn region ucodeRegex oneline keepend
      \ start="\%(\%(^\|[-+*%(,;:=!&|?^~<>[{]\)\s*\|\<\%(return\|case\|in\|delete\)\s\+\)\@30<=/[^/*]"
      \ skip=+\\\\\|\\/+
      \ end=+/[gis]*+
      \ contains=ucodeRegexClass,ucodeRegexEscape

syn match ucodeRegexEscape contained "\\."
syn region ucodeRegexClass contained oneline start="\[\^\=" skip="\\." end="\]"

" Names --------------------------------------------------------------------
" ucode identifiers are [A-Za-z_][A-Za-z0-9_]*; a $ is a lexer error.
"
" The dot carries the property name via nextgroup rather than a lookbehind, so
" that both `a.b` and the optional-chaining `a?.b` reach the same group. The
" spread operator above is matched first and swallows all three dots.

" A dot with no dot behind it, so that the three dots of the spread operator
" are left to the operator rule above rather than read as property access.
syn match ucodeDotOperator "?\=\.\.\@!" nextgroup=ucodePropertyName skipwhite
syn match ucodePropertyName contained "[A-Za-z_]\w*"
" Restricted to the position an object key actually occupies, so that the
" middle operand of a ternary is not mistaken for one. Like the regexp rule,
" the preceding context goes in a lookbehind rather than a \zs: a match whose
" effective start is moved forward loses its column to the punctuation rule.
syn match ucodeObjectKey "\%(\%(^\|[{,]\)\s*\)\@30<=[A-Za-z_]\w*\ze\s*:"
syn match ucodeFunctionCall "\<[A-Za-z_]\w*\ze\s*("

" JavaScript-isms ----------------------------------------------------------
" Every construct below parses in JavaScript and is rejected by ucode. Each is
" matched in the shape the JavaScript construct takes, not as a bare word, so
" that the same name stays usable as an identifier.

if !get(g:, "ucode_no_jsism_errors", 0)
  syn match ucodeJsError "\<undefined\>"
  syn match ucodeJsError "\<elseif\>"
  syn match ucodeJsError "\<new\>\ze\s\+[A-Za-z_]"
  syn match ucodeJsError "\<class\>\ze\s\+[A-Za-z_]"
  syn match ucodeJsError "\<extends\>\ze\s\+[A-Za-z_]"
  syn match ucodeJsError "\<do\>\ze\s*{"
  syn match ucodeJsError "\<finally\>\ze\s*{"
  syn match ucodeJsError "\<throw\>\ze\s\+[^=]"
  syn match ucodeJsError "\<typeof\>\ze\s*[({A-Za-z_'\"]"
  syn match ucodeJsError "\<async\>\s\+function\>"
  syn match ucodeJsError "\<await\>\ze\s\+[A-Za-z_('\"]"
  syn match ucodeJsError "\<yield\>\ze\s\+[A-Za-z_('\"]"
  syn match ucodeJsDestructure contained "[[{]"
  syn match ucodeJsError "#"
endif

" The shebang is restated after the error rules: it starts in the same column
" as the stray-hash rule, and vim resolves that tie in favour of the item
" defined last.
syn match ucodeShebang "\%^#!.*$"

" Clusters -----------------------------------------------------------------

syn cluster ucodeExpression contains=ucodeBoolean,ucodeNull,ucodeThis,
      \ucodeNumber,ucodeFloat,ucodeString,ucodeTemplateString,ucodeRegex,
      \ucodeOperator,ucodePunctuation,ucodeBuiltin,ucodeGlobal,
      \ucodeFunctionCall,ucodeDotOperator,ucodeObjectKey,ucodeCommentLine,
      \ucodeCommentBlock

" Highlight links ----------------------------------------------------------

hi def link ucodeCommentLine Comment
hi def link ucodeCommentBlock Comment
hi def link ucodeTodo Todo
hi def link ucodeShebang PreProc

hi def link ucodeConditional Conditional
hi def link ucodeRepeat Repeat
hi def link ucodeBranch Keyword
hi def link ucodeException Exception
hi def link ucodeDeclaration StorageClass
hi def link ucodeFunction Keyword
hi def link ucodeImport Include
hi def link ucodeImportFrom Include
hi def link ucodeImportAs Include
hi def link ucodeRequire Include
hi def link ucodeRequireParen Delimiter
hi def link ucodeOperatorKeyword Operator

hi def link ucodeBoolean Boolean
hi def link ucodeNull Constant
hi def link ucodeThis Keyword
hi def link ucodeGlobal Constant

hi def link ucodeVariableName Identifier
hi def link ucodeFunctionName Function
hi def link ucodePropertyName Identifier
hi def link ucodeObjectKey Identifier
hi def link ucodeFunctionCall Function
hi def link ucodeBuiltin Function
hi def link ucodeModuleName Type
hi def link ucodeModulePath String

hi def link ucodeNumber Number
hi def link ucodeFloat Float
hi def link ucodeString String
hi def link ucodeStringEscape SpecialChar
hi def link ucodeTemplateString String
hi def link ucodeTemplateStringDelim Delimiter
hi def link ucodeTemplateExpr Normal
hi def link ucodeTemplateExprDelim Delimiter
hi def link ucodeRegex String
hi def link ucodeRegexEscape SpecialChar
hi def link ucodeRegexClass SpecialChar

hi def link ucodeOperator Operator
hi def link ucodeDotOperator Operator
hi def link ucodePunctuation Delimiter

hi def link ucodeSpaceError Error
hi def link ucodeSpaceErrorC Error
hi def link ucodeJsError Error
hi def link ucodeJsDestructure Error

let b:current_syntax = "ucode"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ts=8 sw=2 et
