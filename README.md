# UCODE Vim Syntax Plugin

Enhanced Vim syntax highlighting and support for the UCODE scripting language used in OpenWrt.

## Features

### Comprehensive Syntax Highlighting
- **All UCODE keywords**: Control flow (`if`, `else`, `for`, `while`), declarations (`let`, `const`, `function`)
- **Built-in functions**: Organized by category (Type, I/O, Array, Object, String, Number, JSON, System)
- **Advanced literals**: Strings with escape sequences, template strings, regex patterns
- **Number formats**: Decimal, hexadecimal, binary, octal, scientific notation with separators
- **Operators**: All arithmetic, logical, bitwise, assignment, and special operators
- **Template mode**: Full Jinja-like template syntax support
- **Error detection**: Highlights common syntax mistakes from other languages

### Smart Indentation
- Automatic indentation for control structures and blocks
- Template block indentation support
- Multi-line statement handling
- Configurable with standard Vim indent settings

### Template Mode Support
- Specialized highlighting for `.tmpl`, `.ut`, and `.utpl` files
- Mixed HTML/UCODE syntax highlighting
- Template tags, filters, and control structures
- Trim markers support (`{%-` and `-%}`)

## Installation

### Manual Installation
```bash
# Copy plugin files to your Vim directory
cp -r syntax indent ~/.vim/

# Add filetype detection to your ~/.vimrc
echo "\" UCODE filetype detection
au BufRead,BufNewFile *.uc,*.ucode set ft=ucode
au BufRead,BufNewFile *.uc.tmpl,*.ucode.tmpl,*.ut,*.utpl set ft=ucode_template
au BufRead * if getline(1) =~ '^#!/.*\\bucode\\>' | set ft=ucode | endif" >> ~/.vimrc
```

## File Types

The plugin detects these file types when properly configured in `~/.vimrc`:
- `*.uc`, `*.ucode` - UCODE script files
- `*.uc.tmpl`, `*.ucode.tmpl` - UCODE template files
- `*.ut`, `*.utpl` - UCODE template files (short forms)
- Files with `#!/...ucode` shebang

## Configuration

### Custom Highlighting
```vim
" Make built-in functions bold
highlight ucodeBuiltinFunction cterm=bold gui=bold

" Custom template delimiter colors
highlight ucodeTemplateDelimiter ctermfg=magenta guifg=#ff00ff
```

## Directory Structure

```
ucode-vim/
├── syntax/
│   ├── ucode.vim           # Main syntax file
│   └── ucode_template.vim  # Template mode syntax
├── indent/
│   └── ucode.vim           # Smart indentation
└── README.md
```

## Syntax Groups Reference

| Group | Description | Default Link |
|-------|-------------|--------------|
| `ucodeKeyword` | Control flow keywords | Statement |
| `ucodeDeclaration` | Variable declarations | StorageClass |
| `ucodeFunction` | Function keyword | Keyword |
| `ucodeBuiltin*` | Built-in functions (by category) | Function |
| `ucodeBoolean` | true/false | Boolean |
| `ucodeNull` | null value | Constant |
| `ucodeNumber` | All number formats | Number |
| `ucodeString` | String literals | String |
| `ucodeTemplateString` | Template strings | String |
| `ucodeRegex` | Regular expressions | String |
| `ucodeOperator` | All operators | Operator |
| `ucodeComment*` | Comments | Comment |
| `ucodeTemplate*` | Template syntax | PreProc |
| `ucodeError` | Syntax errors | Error |

## Contributing

Contributions are welcome! Please submit issues and pull requests on GitHub.

## Language Documentation

For complete UCODE language documentation, see the included `UCODE.md` file.
