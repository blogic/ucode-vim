# ucode-vim

Vim support for [ucode](https://github.com/jow-/ucode), the scripting language
OpenWrt uses: syntax highlighting, indentation, filetype detection, a filetype
plugin and a `:make` compiler, for both plain `.uc` scripts and `ucode -T`
templates.

The language model is transcribed from the ucode sources rather than from
JavaScript habits, and a test suite keeps it that way.

## Install

### As a vim package

```
mkdir -p ~/.vim/pack/ucode/start
git clone https://github.com/blogic/ucode-vim ~/.vim/pack/ucode/start/ucode-vim
```

Add this to `~/.vimrc` if it is not there already, otherwise the filetype
plugin, the indent file and `:make` stay dormant:

```vim
syntax on
filetype plugin indent on
```

`syntax on` alone enables filetype *detection* only, which is enough for
highlighting but not for anything under `ftplugin/` or `indent/`.

Nothing else is needed. Detection ships in `ftdetect/`, so there is no reason
to add `au BufRead ... set ft=ucode` lines by hand.

### With a plugin manager

```vim
Plug 'blogic/ucode-vim'          " vim-plug
Plugin 'blogic/ucode-vim'        " Vundle
```

## Filetypes

| Pattern | Filetype |
|---|---|
| `*.uc`, `*.ucode` | `ucode` |
| `*.uc.tmpl`, `*.ucode.tmpl`, `*.ut`, `*.utpl` | `ucode_template` |
| `#!` line naming `ucode` | `ucode`, or `ucode_template` when it passes `-T` |

Vim's own `filetype.vim` maps `*.uc` to UnrealScript. `ftdetect/ucode.vim`
overrides that with an explicit `:set filetype=`, because `:setf` is a no-op
once the builtin rule has fired.

Nothing distinguishes a template from a script by name alone, and no
`.ut`/`.utpl`/`.tmpl` convention is widespread yet, so a `.uc` file that is
really a template needs either a modeline or:

```vim
let g:ucode_detect_templates = 1   " promote a .uc file whose first 50 lines
                                   " contain a line-leading {%
```

## Options

| Variable | Default | Effect |
|---|---|---|
| `g:ucode_space_errors` | `1` | Flag trailing whitespace and space-before-tab, including inside comments and strings |
| `g:ucode_no_jsism_errors` | `0` | Set to `1` to stop flagging JavaScript constructs ucode rejects |
| `g:ucode_fold` | `0` | Fold block comments |
| `g:ucode_detect_templates` | `0` | Content-sniff `.uc` files for template tags |
| `g:ucode_template_base` | `""` | Filetype to layer under a template's literal text, for example `"html"` |

## What it knows

Every table comes from the ucode sources, not from memory:

| Table | Source |
|---|---|
| 28 keywords | `reserved_words[]` in `lexer.c` |
| 71 builtins | `uc_stdlib_functions[]` in `lib.c` |
| `ARGV`, `REQUIRE_SEARCH_PATH`, `modules`, `NaN`, `Infinity`, `global` | `uc_vm_init_scope()` in `vm.c` |
| 16 bundled modules | `lib/*.c` |
| Regexp flags `g`, `i`, `s` | `parse_regexp()` in `lexer.c` |
| Escape sequences | `parse_escape()` in `lexer.c` |
| Template tag shapes | the template state machine in `lexer.c` |

Consequences worth knowing:

- A slash opens a regexp only where the compiler would accept one, mirroring
  the `no_regexp` flag in `compiler.c`. Division stays division.
- `elif` and the `endif` / `endfor` / `endwhile` / `endfunction` block forms
  are real ucode and are highlighted and indented as such.
- `throw`, `finally`, `elseif`, `new`, `class`, `typeof`, `undefined`,
  `do`-`while`, destructuring and `async`/`await` are **not** ucode. They are
  flagged as errors rather than highlighted as valid keywords.
- Module names highlight only inside an `import ... from '<mod>'` or
  `require('<mod>')` source string, so a variable named `fs` stays a variable.
- ucode templates have no Jinja filter pipeline. `{{ 6 | 1 }}` renders `7`.
- The template indent file switches auto-indenting **off**. Text outside a tag
  is the rendered output, so re-indenting it changes the file the template
  produces.

## Filetype plugin

`gf` follows an import path, including the dotted `libs.mymodule` form that
`REQUIRE_SEARCH_PATH` resolves. `:make` syntax-checks the buffer with
`ucode -c` and fills the quickfix list.

`:make` cannot check a module: `ucode -c` refuses any file containing `export`.
Point it at a script that imports the module instead.

With matchit loaded, `%` jumps between `if` / `elif` / `else` / `endif` and the
other colon-form pairs.

## Tests

```
test/run.sh                 # every fixture
test/run.sh --dump FILE     # print FILE's syntax group map, to author a .exp
test/run.sh --smoke DIR     # assert no error group fires on real code in DIR
```

The suite drives a real vim and asks `synID()` what group it assigned at a
given position, so it tests the shipped files rather than a model of them.
Indent cases re-indent a fixture with `=` and compare byte for byte. Every
fixture that is meant to be valid ucode is also handed to `ucode -c`, so the
tests cannot drift into asserting things about code the language rejects.

`--smoke` is the false-positive check: it runs the syntax over a tree of real
ucode and fails if any character lands in an error group.

## Licence

ISC. See `LICENSE`.
