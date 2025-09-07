" Vim syntax file
" Language: UCODE (OpenWrt scripting language)
" Maintainer: Generated with Claude Code
" Last Change: 2025-09-07
" Version: 2.0

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" Sync settings for better performance on large files
syn sync fromstart
syn sync maxlines=100

" Comments
syn keyword ucodeTodo TODO FIXME XXX NOTE TBD HACK WARNING contained
syn match ucodeCommentLine "\/\/.*" contains=@Spell,ucodeTodo
syn region ucodeCommentBlock start="/\*" end="\*/" contains=@Spell,ucodeTodo
" Template comments (Jinja-like)
syn region ucodeTemplateComment start="{#" end="#}" contains=@Spell,ucodeTodo

" Keywords - Control flow
syn keyword ucodeConditional if else elseif endif switch case default
syn keyword ucodeRepeat while for in do
syn keyword ucodeBranch break continue return
syn keyword ucodeException try catch finally throw

" Keywords - Declarations
syn keyword ucodeDeclaration let const nextgroup=ucodeVariableName skipwhite
syn keyword ucodeFunction function nextgroup=ucodeFunctionName skipwhite

" Keywords - Operators
syn keyword ucodeOperatorKeyword delete typeof in new

" Keywords - Module system
syn keyword ucodeImport import from export as require include

" Special values
syn keyword ucodeBoolean true false
syn keyword ucodeNull null
syn keyword ucodeUndefined undefined

" Identifiers and Names
syn match ucodeVariableName "\<[a-zA-Z_$][a-zA-Z0-9_$]*\>" contained
syn match ucodeFunctionName "\<[a-zA-Z_$][a-zA-Z0-9_$]*\>" contained
syn match ucodePropertyAccess "\.\s*\<[a-zA-Z_$][a-zA-Z0-9_$]*\>"
syn match ucodeObjectKey "\<[a-zA-Z_$][a-zA-Z0-9_$]*\>\s*:" contains=ucodeColon

" Numbers - Enhanced with all formats
syn match ucodeNumber "\<\d\+\%(_\d\+\)*\>" " Integers with separators
syn match ucodeNumber "\<0[xX][0-9a-fA-F]\+\%(_[0-9a-fA-F]\+\)*\>" " Hex
syn match ucodeNumber "\<0[bB][01]\+\%(_[01]\+\)*\>" " Binary
syn match ucodeNumber "\<0[oO][0-7]\+\%(_[0-7]\+\)*\>" " Octal
syn match ucodeNumber "\<\d\+\.\d\+\%([eE][+-]\?\d\+\)\?\>" " Float
syn match ucodeNumber "\<\.\d\+\%([eE][+-]\?\d\+\)\?\>" " Float starting with .
syn match ucodeNumber "\<\d\+[eE][+-]\?\d\+\>" " Scientific notation

" Template strings with embedded expressions - MUST come before regular strings for priority
syn region ucodeTemplateString matchgroup=ucodeTemplateDelimiter start="`" end="`" contains=ucodeTemplateExpression,ucodeStringEscape
syn region ucodeTemplateExpression matchgroup=ucodeTemplateExprDelimiter start="${" end="}" contained contains=@ucodeExpression
" Regular strings
syn region ucodeString start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=ucodeStringEscape,@Spell
syn region ucodeString start=+'+ skip=+\\\\\|\\'+ end=+'+ contains=ucodeStringEscape,@Spell

" String escape sequences
syn match ucodeStringEscape "\\[nrtbfav\\'\"\\]" contained
syn match ucodeStringEscape "\\x[0-9a-fA-F]\{2}" contained
syn match ucodeStringEscape "\\u[0-9a-fA-F]\{4}" contained
syn match ucodeStringEscape "\\U[0-9a-fA-F]\{8}" contained
syn match ucodeStringEscape "\\[0-7]\{1,3}" contained

" Regular expressions (POSIX style in ucode)
syn region ucodeRegex start=+/[^/*]+ skip=+\\\\\|\\/+ end=+/[gimuy]*+ contains=ucodeRegexEscape oneline
syn match ucodeRegexEscape "\\." contained

" Template mode syntax (Jinja-like) - Enhanced
syn region ucodeTemplateBlock matchgroup=ucodeTemplateDelimiter start="{%" end="%}" contains=@ucodeTemplateCode
syn region ucodeTemplateOutput matchgroup=ucodeTemplateDelimiter start="{{" end="}}" contains=@ucodeExpression
syn region ucodeTemplateBlockTrim matchgroup=ucodeTemplateDelimiter start="{%-\?" end="-\?%}" contains=@ucodeTemplateCode
syn region ucodeTemplateOutputTrim matchgroup=ucodeTemplateDelimiter start="{{-\?" end="-\?}}" contains=@ucodeExpression

" Operators
syn match ucodeOperator "[-+*/%]"
syn match ucodeOperator "[<>]=\?"
syn match ucodeOperator "[!=]==\?"
syn match ucodeOperator "&&\|||"
syn match ucodeOperator "[&|^~]"
syn match ucodeOperator "<<\|>>"
syn match ucodeOperator "[-+*/%&|^]=\?"
syn match ucodeOperator "<<=\|>>="
syn match ucodeOperator "++\|--"
syn match ucodeOperator "??\|?\|:"
syn match ucodeOperator "\.\.\." " Spread operator
syn match ucodeOperator "=>" " Arrow function

" Punctuation
syn match ucodePunctuation "[{}()\[\];,]"
syn match ucodeColon ":" contained
syn match ucodeDot "\."

" Built-in functions - Organized by category
" Type and Information
syn keyword ucodeBuiltinType type length exists

" I/O Functions
syn keyword ucodeBuiltinIO print warn printf sprintf

" Array Functions
syn keyword ucodeBuiltinArray push pop shift unshift slice splice sort reverse
syn keyword ucodeBuiltinArray join index rindex uniq values
syn keyword ucodeBuiltinArray map filter reduce

" Object Functions
syn keyword ucodeBuiltinObject keys values

" String Functions
syn keyword ucodeBuiltinString substr split trim ltrim rtrim lc uc
syn keyword ucodeBuiltinString replace match ord chr

" Number Functions
syn keyword ucodeBuiltinNumber int min max abs round floor ceil

" JSON Functions
syn keyword ucodeBuiltinJSON json jsonstr

" System Functions
syn keyword ucodeBuiltinSystem gc require include sourcepath

" Module objects
syn keyword ucodeModule fs uci uloop

" Error patterns - Common mistakes
" Note: PHP-style variables ($var) removed to avoid conflicts with template strings (${var})
syn match ucodeError "\<fn\s\+[a-zA-Z_]" " Rust-style function
syn match ucodeError "@[a-zA-Z_][a-zA-Z0-9_]*" " Python decorators
syn match ucodeError "#[a-zA-Z_][a-zA-Z0-9_]*" " Shell/Python comments as code

" Clusters for contained elements
syn cluster ucodeExpression contains=ucodeBoolean,ucodeNull,ucodeUndefined,ucodeNumber,ucodeString,ucodeTemplateString,ucodeRegex,ucodeOperator,ucodeBuiltinType,ucodeBuiltinIO,ucodeBuiltinArray,ucodeBuiltinObject,ucodeBuiltinString,ucodeBuiltinNumber,ucodeBuiltinJSON,ucodeBuiltinSystem,ucodeFunctionCall,ucodePropertyAccess,ucodeVariableName,ucodeThis,ucodeArguments,ucodePunctuation,ucodeDot
syn cluster ucodeTemplateCode contains=ucodeKeyword,ucodeConditional,ucodeRepeat,ucodeBranch,ucodeDeclaration,ucodeFunction,@ucodeExpression

" Function calls (matches function names followed by parentheses)
syn match ucodeFunctionCall "\<[a-zA-Z_$][a-zA-Z0-9_$]*\>\s*(" contains=ucodeBuiltinType,ucodeBuiltinIO,ucodeBuiltinArray,ucodeBuiltinObject,ucodeBuiltinString,ucodeBuiltinNumber,ucodeBuiltinJSON,ucodeBuiltinSystem

" Special this keyword
syn keyword ucodeThis this

" Arguments object
syn keyword ucodeArguments arguments


" Define highlighting groups
hi def link ucodeCommentLine Comment
hi def link ucodeCommentBlock Comment
hi def link ucodeTemplateComment Comment
hi def link ucodeTodo Todo

hi def link ucodeConditional Conditional
hi def link ucodeRepeat Repeat
hi def link ucodeBranch Keyword
hi def link ucodeException Exception
hi def link ucodeDeclaration StorageClass
hi def link ucodeFunction Keyword
hi def link ucodeImport Include
hi def link ucodeOperatorKeyword Operator

hi def link ucodeBoolean Boolean
hi def link ucodeNull Constant
hi def link ucodeUndefined Constant
hi def link ucodeThis Keyword
hi def link ucodeArguments Keyword

hi def link ucodeVariableName Identifier
hi def link ucodeFunctionName Function
hi def link ucodePropertyAccess Identifier
hi def link ucodeObjectKey Identifier

hi def link ucodeNumber Number
hi def link ucodeString String
hi def link ucodeTemplateString String
hi def link ucodeTemplateExpression Special
hi def link ucodeTemplateExprDelimiter Delimiter
hi def link ucodeStringEscape SpecialChar
hi def link ucodeRegex String
hi def link ucodeRegexEscape SpecialChar

hi def link ucodeTemplateBlock PreProc
hi def link ucodeTemplateBlockTrim PreProc
hi def link ucodeTemplateOutput Identifier
hi def link ucodeTemplateOutputTrim Identifier
hi def link ucodeTemplateDelimiter Delimiter

hi def link ucodeOperator Operator
hi def link ucodePunctuation Delimiter
hi def link ucodeColon Delimiter
hi def link ucodeDot Delimiter

hi def link ucodeBuiltinType Type
hi def link ucodeBuiltinIO Function
hi def link ucodeBuiltinArray Function
hi def link ucodeBuiltinObject Function
hi def link ucodeBuiltinString Function
hi def link ucodeBuiltinNumber Function
hi def link ucodeBuiltinJSON Function
hi def link ucodeBuiltinSystem Function
hi def link ucodeModule PreProc

hi def link ucodeFunctionCall Function
hi def link ucodeError Error

let b:current_syntax = "ucode"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ts=2 sw=2 et