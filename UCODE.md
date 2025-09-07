# ucode Language Reference

## Overview
ucode is a lightweight scripting language used by OpenWrt with ECMAScript-like syntax. It's designed for system scripting, configuration management, and template processing in embedded Linux environments.

**Key Characteristics:**
- Synchronous, procedural programming model
- Built-in JSON parsing and serialization
- 64-bit integer support
- POSIX regular expression support
- Small footprint (~64KB on ARM Cortex A9)
- Reference counting memory management with optional mark-and-sweep GC

## Execution
```bash
# Run a script
ucode script.uc

# Execute inline code
ucode -e "print('Hello World\n')"

# Print expression result
ucode -p "1 + 2"

# Compile to bytecode
ucode -c script.uc

# Template mode (Jinja-like)
ucode -T template.uc

# Enable garbage collection
ucode -g script.uc

# Strict mode
ucode -S script.uc
```

## Data Types

### Primitives
- **Boolean**: `true`, `false`
- **Integer**: 64-bit signed integers (-9223372036854775808 to +9223372036854775807)
- **Double**: Floating-point numbers (-1.7e308 to +1.7e308)
- **String**: `'single quotes'` or `"double quotes"` with escape sequences
- **Null**: `null`

### Complex Types
- **Array**: `[1, 2, "three", true]`
- **Object**: `{ key: "value", "quoted-key": 123 }`

## Variables

```ucode
// Global variable (no keyword)
globalVar = 100;

// Local variable (function/block scoped)
let localVar = 200;

// Constant (cannot be reassigned)
const CONSTANT_VAR = 300;
```

## Operators

### Arithmetic
`+`, `-`, `*`, `/`, `%`, `++`, `--`

### Bitwise
`&`, `|`, `^`, `<<`, `>>`, `~`

### Comparison
`==`, `!=`, `<`, `<=`, `>`, `>=`, `===`, `!==`

### Logical
`&&`, `||`, `!`, `??` (nullish coalescing)

### Assignment
`=`, `+=`, `-=`, `*=`, `/=`, `%=`, `&=`, `|=`, `^=`, `<<=`, `>>=`

### Special
- `in`: Check if key exists in object/array
- `typeof`: Get type as string
- `delete`: Remove object property
- `...`: Spread operator for arrays/objects

## Control Flow

### Conditional Statements
```ucode
if (condition) {
    // code
} else if (another_condition) {
    // code
} else {
    // code
}

// Ternary operator
let result = condition ? value1 : value2;
```

### Loops
```ucode
// While loop
while (condition) {
    // code
}

// For loop
for (let i = 0; i < 10; i++) {
    // code
}

// For...in (iterate over array/object)
for (item in array) {
    print(item);
}

// For...in with destructuring
for (key, value in object) {
    print(key, ": ", value);
}

// Do...while
do {
    // code
} while (condition);
```

### Switch Statement
```ucode
switch (expression) {
    case value1:
        // code
        break;
    case value2:
    case value3:
        // code for both cases
        break;
    default:
        // default code
}
```

### Control Keywords
- `break`: Exit loop or switch
- `continue`: Skip to next iteration
- `return`: Return from function

## Functions

```ucode
// Function declaration
function add(a, b) {
    return a + b;
}

// Function expression
let multiply = function(a, b) {
    return a * b;
};

// Arrow functions (limited support)
let square = (x) => x * x;

// Default parameters
function greet(name = "World") {
    print("Hello, " + name);
}

// Rest parameters
function sum(...numbers) {
    let total = 0;
    for (n in numbers) {
        total += n;
    }
    return total;
}

// Functions are first-class values
let func = add;
let result = func(1, 2);
```

## Core Built-in Functions

### Type and Information
- `type(value)`: Returns type as string ("null", "boolean", "number", "string", "array", "object", "function", "resource")
- `length(value)`: Returns length of string, array, or object
- `exists(obj, key)`: Check if key exists in object

### I/O Functions
- `print(...args)`: Output to stdout
- `warn(...args)`: Output to stderr
- `printf(format, ...args)`: Formatted output to stdout
- `sprintf(format, ...args)`: Return formatted string

### Array Functions
- `push(arr, ...items)`: Add items to end
- `pop(arr)`: Remove and return last item
- `shift(arr)`: Remove and return first item
- `unshift(arr, ...items)`: Add items to beginning
- `slice(arr, start, end)`: Extract portion
- `splice(arr, start, deleteCount, ...items)`: Modify array
- `sort(arr, compareFn)`: Sort in place
- `reverse(arr)`: Reverse in place
- `join(arr, separator)`: Concatenate to string
- `index(arr, value)`: Find first occurrence
- `rindex(arr, value)`: Find last occurrence
- `uniq(arr)`: Remove duplicates
- `values(arr)`: Return array values (identity for arrays)

### Array Higher-Order Functions
- `map(arr, fn)`: Transform each element
- `filter(arr, fn)`: Filter elements
- `reduce(arr, fn, initial)`: Reduce to single value

### Object Functions
- `keys(obj)`: Return array of keys
- `values(obj)`: Return array of values
- `delete obj.key` or `delete(obj, key)`: Remove property

### String Functions
- `substr(str, start, length)`: Extract substring
- `split(str, separator, limit)`: Split into array
- `join(arr, separator)`: Join array into string
- `trim(str)`: Remove whitespace from both ends
- `ltrim(str)`: Remove leading whitespace
- `rtrim(str)`: Remove trailing whitespace
- `lc(str)`: Convert to lowercase
- `uc(str)`: Convert to uppercase
- `index(str, needle)`: Find substring position
- `rindex(str, needle)`: Find last occurrence
- `replace(str, search, replace, flags)`: Replace occurrences
- `match(str, regex)`: Match against regex
- `ord(str)`: Get character code
- `chr(code)`: Get character from code

### Number Functions
- `int(value)`: Convert to integer
- `min(...values)`: Return minimum
- `max(...values)`: Return maximum
- `abs(value)`: Absolute value
- `round(value)`: Round to nearest integer
- `floor(value)`: Round down
- `ceil(value)`: Round up

### JSON Functions
- `json(jsonString)`: Parse JSON string
- `jsonstr(value)`: Serialize to JSON (compact)

### Regular Expression
- `match(str, pattern)`: Match string against regex
- `replace(str, pattern, replacement, flags)`: Replace with regex

### System Functions
- `gc()`: Trigger garbage collection
- `require(moduleName)`: Load module
- `include(filePath)`: Include and execute file
- `sourcepath()`: Get current source file path

## Arrays (Detailed)

### Key Characteristics
- True contiguous memory arrays
- Support negative indexing (`arr[-1]` for last element)
- Can be sparse (gaps allocate memory)
- Mixed types allowed

### Creation and Manipulation
```ucode
// Creating arrays
let empty = [];
let numbers = [1, 2, 3, 4, 5];
let mixed = [1, "two", true, null, { key: "value" }];

// Accessing elements
let first = arr[0];
let last = arr[-1];

// Modifying
arr[0] = "new value";
arr[length(arr)] = "append";  // Add to end

// Checking existence
if (index in arr) {
    // index exists
}

// Iteration
for (item in arr) {
    print(item);
}

// With index
for (let i = 0; i < length(arr); i++) {
    print(i, ": ", arr[i]);
}
```

## Objects/Dictionaries (Detailed)

### Key Characteristics
- Ordered hash tables (preserves insertion order)
- O(1) average lookup time
- Keys must be strings (auto-conversion)
- Reference semantics

### Creation and Manipulation
```ucode
// Creating objects
let empty = {};
let person = {
    name: "Alice",
    age: 30,
    "special-key": "value"
};

// Accessing properties
let name = person.name;
let name2 = person["name"];
let special = person["special-key"];

// Setting properties
person.email = "alice@example.com";
person["city"] = "New York";

// Checking existence
if ("name" in person) {
    // property exists
}
if (exists(person, "name")) {
    // alternative check
}

// Deleting properties
delete person.age;

// Iteration
for (key in person) {
    print(key, ": ", person[key]);
}

// Destructuring iteration
for (key, value in person) {
    printf("%s = %J\n", key, value);
}
```

## Memory Management

### Reference Counting
- Automatic for primitives
- Arrays and objects use reference counting
- Variables going out of scope decrement count
- Memory freed when count reaches zero

### Potential Issues
```ucode
// Cyclic reference - causes memory leak
let obj = {};
obj.self = obj;  // Circular reference

// Array self-reference
let arr = [];
arr[0] = arr;  // Circular reference
```

### Solutions
1. Use `-g` flag to enable mark-and-sweep GC
2. Call `gc()` manually when needed
3. Break circular references explicitly

## Module System

### fs Module
```ucode
import { readfile, writefile, stat, mkdir } from 'fs';
import * as fs from 'fs';

// File operations
let content = fs.readfile('/path/to/file');
fs.writefile('/path/to/file', 'content');
fs.unlink('/path/to/file');  // Delete
fs.rename('old', 'new');

// Directory operations
fs.mkdir('/path/to/dir');
fs.rmdir('/path/to/dir');
let files = fs.lsdir('/path/to/dir');
fs.chdir('/new/working/dir');

// File information
let info = fs.stat('/path/to/file');
let isReadable = fs.access('/path/to/file', 'r');
fs.chmod('/path/to/file', 0o755);
fs.chown('/path/to/file', uid, gid);

// Special operations
fs.symlink('target', 'link');
let target = fs.readlink('link');
let handle = fs.open('file', 'r');
let pipe = fs.pipe();
let proc = fs.popen('command', 'r');
```

### uci Module (OpenWrt Configuration)
```ucode
import { cursor } from 'uci';

// Create UCI context
let ctx = cursor();

// Read configuration
let value = ctx.get('config', 'section', 'option');
let firstValue = ctx.get_first('config', 'type', 'option');
let allValues = ctx.get_all('config', 'section');

// Write configuration
ctx.set('config', 'section', 'option', 'value');
ctx.add('config', 'type');  // Add new section
ctx.delete('config', 'section', 'option');

// Commit changes
ctx.save('config');
ctx.commit('config');

// Error handling
if (!ctx.set('invalid', 'test', '1')) {
    print(ctx.error());
}
```

### uloop Module (Event Loop)
```ucode
import * as uloop from 'uloop';

// Initialize event loop
uloop.init();

// Timers
let timer = uloop.timer(1000, function() {
    print("Timer fired!");
    return 1000;  // Repeat after 1000ms
});

// Intervals
let interval = uloop.interval(500, function() {
    print("Every 500ms");
});

// Process handling
let proc = uloop.process("/bin/ls", ["-l"], null, function(code) {
    printf("Process exited: %d\n", code);
});

// Signal handling
let sig = uloop.signal("SIGINT", function() {
    print("SIGINT received");
    uloop.end();
});

// File descriptor monitoring
let handle = uloop.handle(fd, function(events) {
    if (events & uloop.ULOOP_READ) {
        // Handle readable
    }
}, uloop.ULOOP_READ);

// Run event loop
uloop.run();

// Cleanup
timer.cancel();
interval.cancel();
handle.delete();
```

## Template Mode

When using `-T` flag, ucode processes files as templates with Jinja-like syntax:

```ucode
{# This is a comment #}

{% for item in items %}
  {{ item.name }}: {{ item.value }}
{% endfor %}

{% if condition %}
  {{ variable }}
{% else %}
  Default value
{% endif %}

{%+ include "other_template.uc" %}
```

## Best Practices

1. **Variable Scoping**: Always use `let` for local variables to avoid polluting global scope
2. **Error Handling**: Check return values and use error functions
3. **Memory Management**: Be aware of circular references, use GC when needed
4. **Type Checking**: Use `type()` function to validate inputs
5. **String Formatting**: Use `sprintf()` or `printf()` for complex formatting
6. **Arrays vs Objects**: Use arrays for ordered collections, objects for key-value mappings
7. **Module Loading**: Use `import` for modules, `include()` for scripts
8. **Performance**: Cache object property access in loops
9. **Template Processing**: Use template mode for generating configuration files

## Common Patterns

### Safe Property Access
```ucode
function getProp(obj, path, defaultValue) {
    let parts = split(path, '.');
    let current = obj;
    
    for (part in parts) {
        if (type(current) != "object" || !(part in current)) {
            return defaultValue;
        }
        current = current[part];
    }
    
    return current;
}
```

### Deep Clone
```ucode
function deepClone(obj) {
    if (type(obj) != "object" && type(obj) != "array") {
        return obj;
    }
    
    let clone = type(obj) == "array" ? [] : {};
    
    for (key, value in obj) {
        clone[key] = deepClone(value);
    }
    
    return clone;
}
```

### Array Intersection
```ucode
function intersect(...arrays) {
    if (!length(arrays)) return [];
    
    let result = arrays[0];
    for (let i = 1; i < length(arrays); i++) {
        result = filter(result, item => item in arrays[i]);
    }
    
    return uniq(result);
}
```

### Object Merge
```ucode
function merge(...objects) {
    let result = {};
    
    for (obj in objects) {
        for (key, value in obj) {
            result[key] = value;
        }
    }
    
    return result;
}
```

## Notes
- Documentation source: https://ucode.mein.io
- Primary use case: OpenWrt system scripting and configuration
- Language inspiration: ECMAScript syntax with Perl-like built-ins
- No object-oriented features (no classes, prototypes, or this keyword)
- Synchronous execution only (no async/await or promises)