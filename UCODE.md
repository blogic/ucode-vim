# ucode Language Reference

ucode is a JavaScript-like scripting language closely related to ECMAScript/JavaScript but with a different set of core functions and modules. ucode files have the `.uc` extension and typically start with a shebang line: `#!/usr/bin/env ucode`.

## CLI Execution Options

```bash
# Run a script
ucode script.uc

# Execute inline code
ucode -e "print('Hello World\n')"

# Print expression result
ucode -p "1 + 2"

# Template mode (Jinja-like)
ucode -T template.uc

# Enable garbage collection (mark-and-sweep)
ucode -g script.uc

# Strict mode
ucode -S script.uc
```

## Template Mode

When using the `-T` flag, ucode processes files as templates with Jinja-like syntax for generating text output:

```ucode
{# This is a template comment (not included in output) #}

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

**Template Syntax:**
- `{{ expression }}` - Output expression result
- `{% statement %}` - Control flow statement (if, for, etc.)
- `{# comment #}` - Template comment (not output)
- `{%+ ... %}` - Statement with whitespace control

**Use case**: Generating configuration files, HTML, or any text-based output from data.

## Basic Syntax

### Comments
```ucode
// Single line comment
/* Multi-line comment */
```

### Variables and Constants
```ucode
let variable_name = value;
const CONSTANT_NAME = value;
```

**⚠️ CRITICAL: NO DESTRUCTURING ASSIGNMENT ⚠️**

ucode does NOT support destructuring assignment. You must extract array/object values manually:

```ucode
// ❌ ERROR - Array destructuring NOT supported
let [foo] = fn();
let [first, second] = array;
let [a, b, ...rest] = items;

// ❌ ERROR - Object destructuring NOT supported
let {x, y} = object;
let {name, age} = person;

// ✅ CORRECT - Manual extraction for arrays
let result = fn();
let foo = result[0];

let first = array[0];
let second = array[1];

// ✅ CORRECT - Manual extraction for objects
let x = object.x;
let y = object.y;

let name = person.name;
let age = person.age;
```

**Style Note:** Don't explicitly initialize variables to their default values when the default (null) is acceptable:
```ucode
// ✅ CORRECT
let need_sort;  // null is default in ucode

// ❌ WRONG
let need_sort = false;
```

### Function Declaration

**⚠️ No Hoisting - Textual Order Matters**: Functions and variables must be TEXTUALLY defined in the source code before ANY reference to them (including references inside other function bodies). Declarations are NOT hoisted to the top of their scope.

```ucode
// ❌ Error - function used before declaration
let result = my_function(42);
function my_function(x) { return x * 2; }

// ❌ Error - function referenced before declaration (even inside another function)
function helper() {
    return my_function(42);  // References my_function
}
function my_function(x) { return x * 2; }

// ✅ Correct - function declared before any reference
function my_function(x) { return x * 2; }
let result = my_function(42);

// ✅ Correct - define functions in textual order before use
function my_function(x) { return x * 2; }
function helper() {
    return my_function(42);  // Now my_function is already defined
}

// Arrow functions
const arrow_func = (param) => expression;
```

**Best Practice**: Define all functions at the top of your file/scope before any code that uses them. Read the code top-to-bottom - nothing is hoisted.

### Conditionals
```ucode
if (condition) {
    // code
} else if (other_condition) {
    // code
} else {
    // code
}

// Braces can be omitted for single statements
if (condition)
    single_statement();
else if (other_condition)
    another_statement();
else
    final_statement();
```

**Style Note:** Use `else if` directly instead of nesting `if` inside `else`:
```ucode
// ✅ CORRECT
else if (condition) { ... }

// ❌ WRONG
else { if (condition) { ... } }
```

### Loops
```ucode
// for loop
for (let i = 0; i < length; i++) {
    // code
}

// for-in loops
for (let key in object) {
    // code - iterates over object keys
}

for (let key, value in object) {
    // code - iterates over object key-value pairs
}

for (let value in array) {
    // code - iterates over array values
}

// while loop
while (condition) {
    // code
}

// Braces can be omitted for single statements
for (let i = 0; i < length; i++)
    single_statement();

for (let key in object)
    process(key);

while (condition)
    single_action();
```

### Objects and Arrays
```ucode
// Object literal
let obj = {
    key: 'value',
    method: function() { return 'result'; }
};

// Shorthand property syntax (variable name becomes key)
let name = "Alice";
let age = 30;
let person = { name, age };  // Equivalent to { name: name, age: age }

// Array literal
let arr = [1, 2, 3, 'string'];
```

### String Literals
```ucode
'single quotes'
"double quotes"
`template literal with ${expression}`
```

### String Escape Sequences

Escape sequences in string literals:

- `\n`, `\r`, `\t` - Standard control characters
- `\xHH` - Hexadecimal byte value (00-FF), produces a single byte
- `\0OOO` - Octal byte value (000-377), produces a single byte
- `\uHHHH` - Unicode escape (if supported)
- `\\`, `\'`, `\"` - Literal backslash and quotes

Note that `\xHH` and `\0OOO` produce raw byte values, not UTF-8 encoded sequences. Use `uchr()` for UTF-8 encoding.

```ucode
let hex_byte = "\x41";     // Single byte: 0x41 ('A')
let octal_byte = "\0101";  // Single byte: 0101 octal = 65 ('A')
let utf8_char = uchr(0x41); // UTF-8 encoded character
```

## Module System

### Import/Export

> **⚠️⚠️⚠️ CRITICAL SYNTAX RULE ⚠️⚠️⚠️**
>
> **EXPORT FUNCTION DECLARATIONS REQUIRE A SEMICOLON**
>
> This is THE most common syntax error in ucode!
> Regular functions do NOT need semicolons, but export functions DO.
>
> ✓ CORRECT:   `export function foo() { ... };`
> ✗ WRONG:     `export function foo() { ... }`
>
> Missing the semicolon will cause a syntax error.
> **⚠️⚠️⚠️ ALWAYS ADD THE SEMICOLON ⚠️⚠️⚠️**

**Export Function Semicolon Requirement:**

When using `export function`, a semicolon is **MANDATORY** after the closing brace. This is a syntax requirement unique to ucode and differs from:
- Regular function declarations (which do NOT require a semicolon)
- JavaScript export syntax (which does NOT require a semicolon)

```ucode
// ✓ CORRECT - Export function WITH semicolon
export function myFunction() {
    return 'value';
};  // <-- SEMICOLON REQUIRED

// ✗ WRONG - Missing semicolon will cause syntax error
export function myFunction() {
    return 'value';
}  // <-- SYNTAX ERROR: Missing semicolon

// ✓ CORRECT - Export default function WITH semicolon
export default function() {
    return 'value';
};  // <-- SEMICOLON REQUIRED

// ✓ CORRECT - Regular function WITHOUT semicolon (for comparison)
function regularFunction() {
    return 'value';
}  // <-- No semicolon needed for non-exported functions
```

**Other export forms:**

```ucode
// Named imports
import { func1, func2 } from 'module';
import { func as alias } from 'module';

// Namespace import
import * as namespace from 'module';

// Default import
import default_export from 'module';

// Export named bindings (no semicolon issues)
export { func1, func2 };

// Export const (semicolon at end as normal)
export const MY_CONSTANT = 42;
```

**Remember**: Regular function declarations do NOT require a trailing semicolon, but `export function` declarations DO require one. This is a common source of syntax errors.

### Module Resolution

Module paths are resolved in the following order:

1. **Relative paths**: Resolved from current source file's directory
   ```ucode
   import { utils } from './utils.uc';
   import { helper } from '../lib/helper.uc';
   ```

2. **Absolute paths**: Use full filesystem path
   ```ucode
   import { config } from '/usr/share/myapp/config.uc';
   ```

3. **Module search paths**: Searched in directories specified by `REQUIRE_SEARCH_PATH` array
   ```ucode
   // Add custom search paths
   push(REQUIRE_SEARCH_PATH, '/usr/share/ucentral/*.uc');

   // Import from search path
   import { myModule } from 'libs.mymodule';  // Finds /usr/share/ucentral/libs/mymodule.uc
   ```

4. **Built-in modules**: Core modules like `'fs'`, `'uci'`, `'ubus'`, `'log'`, etc.

**Note**: Unlike Node.js, there is no automatic searching up the directory tree for modules. Path changes require manually updating all import statements.

**⚠️ CRITICAL: Path Resolution is Relative to CWD**

Unlike JavaScript (which resolves relative to the importing file), ucode resolves ALL paths relative to the **current working directory**.

```ucode
// File: lib/utils.uc
export function load_config() {
    // ❌ WRONG - This looks for "config.json" relative to CWD, NOT relative to utils.uc
    let data = fs.readfile("config.json");
}

// File: tests/test_utils.uc
import { load_config } from '../lib/utils.uc';

// When running from project root:
// $ ucode tests/test_utils.uc
// load_config() will look for ./config.json (relative to project root)

// When running from tests/ directory:
// $ cd tests && ucode test_utils.uc
// load_config() will look for tests/config.json (relative to tests/)
```

**Solutions:**
1. Use absolute paths
2. Use `sourcepath()` to get module's directory
3. Pass paths as parameters instead of hardcoding

```ucode
import { dirname } from 'fs';

export function load_config() {
    let my_dir = dirname(sourcepath());
    let config_path = my_dir + "/config.json";
    return fs.readfile(config_path);
}
```

### require() vs import

Both module loading syntaxes are supported:

- **`import` (recommended)**: Loads modules at compile time, supports selective importing and tree-shaking, better static analysis
  ```ucode
  import * as fs from 'fs';           // Built-in module
  import { utils } from './utils';    // Custom module
  ```

- **`require()` (legacy)**: Loads modules at runtime, compatible with older code
  ```ucode
  let fs = require("fs");        // Built-in module
  let utils = require("./utils"); // Custom module
  ```

Use `import` for new code for better performance and error detection.

### Modules vs Scripts

**Critical Distinction:**
- **Modules**: Files containing `export` statements - CANNOT be executed, run, or syntax-checked directly
- **Scripts**: Files without exports - CAN be executed with `ucode script.uc`

```ucode
// my_module.uc - This is a MODULE
export function process_data() {
    return 42;
};

// main.uc - This is a SCRIPT (no exports)
import { process_data } from './my_module.uc';
print(process_data());
```

**⚠️ Common Errors:**
```bash
# ❌ CANNOT compile modules with -c (syntax checking)
ucode -c my_module.uc
# Error: "Exports may only appear at top level of a module"

# ❌ CANNOT execute modules directly
ucode my_module.uc
# Error: "Exports may only appear at top level of a module"

# ✅ CORRECT - Create a script that imports the module
ucode main.uc
```

**Important:** The `-c` flag (compile to bytecode) ONLY works for standalone scripts. You cannot use it to syntax-check modules. To test a module, create a separate test script that imports it.

**Testing Modules:**
Always create a separate test script to import and test modules:
```ucode
// test_my_module.uc
import { process_data } from './my_module.uc';
assert(process_data() == 42);
print("Tests passed\n");
```

### Import Scope Restrictions

**⚠️ CRITICAL: Imports must be at top level**

Import statements can ONLY appear at the top level of a file, never inside functions or blocks.

```ucode
// ✅ CORRECT - Import at file scope
import * as fs from 'fs';

function process_file(path) {
    let file = fs.open(path, 'r');  // Use imported module
    // ...
}

// ❌ ERROR - Cannot import inside function
function process_file(path) {
    import * as fs from 'fs';  // Syntax error: Imports may only appear at top level
    let file = fs.open(path, 'r');
}

// ❌ ERROR - Cannot import conditionally
if (need_filesystem) {
    import * as fs from 'fs';  // Syntax error
}
```

**Solution:** Always import at file scope, even if only used in specific functions.

### Strict Mode
```ucode
'use strict';
```

## Core Built-in Functions

### String Manipulation Functions

- `chr(...numbers)` → `string` - Converts numeric values to bytes and returns resulting string
- `lc(string)` → `string` - Converts string to lowercase
- `uc(string)` → `string` - Converts string to uppercase
- `uchr(...numbers)` → `string` - Converts numeric values to UTF-8 multibyte sequences
- `trim(string, [chars])` → `string` - Trims specified characters from start and end of string
- `ltrim(string, [chars])` → `string` - Trims specified characters from start of string only
- `rtrim(string, [chars])` → `string` - Trims specified characters from end of string only
- `substr(string, offset, [length])` → `string` - Extracts substring starting at offset
- `split(string, separator, [limit])` → `Array` - Splits string using separator into array
- `sprintf(format, ...args)` → `string` - Formats arguments according to format string (use "%.J" for pretty-printed JSON, "%s" converts arrays/objects to compact JSON)
- `replace(string, pattern, replacement, [global])` → `string` - Replaces occurrences of pattern in string. Pattern can be a plain string or a regex
- `match(string, pattern, [global])` → `Array|Object` - Matches string against regular expression pattern. The pattern must be a regex literal (`/pattern/`) or a `regexp()` call -- plain strings do NOT work as patterns

### Array/Object Manipulation Functions

- `length(array|object|string)` → `number` - Returns length of array, object key count, or string byte count
- `keys(object)` → `Array` - Returns array of all key names in object
- `values(object)` → `Array` - Returns array of all values in object
- `push(array, ...values)` → `*` - Adds values to end of array
- `pop(array)` → `*` - Removes and returns last element from array
- `shift(array)` → `*` - Removes and returns first element from array
- `unshift(array, ...values)` → `*` - Adds values to beginning of array
- `splice(array, offset, length, ...replacements)` → `Array` - Removes elements and optionally inserts replacements
- `slice(array, start, [end])` → `Array` - Returns new array containing elements from start index up to (not including) end index
- `reverse(array|string)` → `Array|string` - Reverses order of array elements or string characters
- `sort(array, [compareFunction])` → `Array` - Sorts array using optional comparison function
- `join(separator, array)` → `string` - Joins array elements into string using separator
- `filter(array, function)` → `Array` - Filters array by invoking function for each element
- `map(array, function)` → `Array` - Transforms array by invoking function for each element
- `uniq(array)` → `Array` - Returns new array containing all unique values from input

### Search Functions

- `index(array|string, needle)` → `number` - Finds first occurrence of value in array or string (-1 if not found)
- `rindex(array|string, needle)` → `number` - Finds last occurrence of value in array or string (-1 if not found)
- `exists(object, key)` → `boolean` - Checks if key exists in object

**IMPORTANT:** The `in` operator works differently in ucode than in JavaScript:

```ucode
// For OBJECTS - checks if KEY exists (same as JavaScript)
let obj = { a: 1, b: 2 };
if ('a' in obj) { /* true - RECOMMENDED usage */ }
if ('c' in obj) { /* false */ }

// For ARRAYS - AVOID using 'in' operator (behaves differently than JavaScript!)
// JavaScript: 'in' checks if INDEX exists (0 in [10,20,30] → true)
// ucode: 'in' checks if VALUE exists (0 in [10,20,30] → false, 20 in [10,20,30] → true)

// ✅ RECOMMENDED - Use index() for array value checks
let arr = [10, 20, 30];
if (index(arr, 20) >= 0) { /* value exists */ }
if (index(arr, 99) < 0) { /* value does not exist */ }

// ✅ RECOMMENDED - Filter array excluding certain values
let filtered = filter(array, item => index(exclusion_list, item) < 0);

// ❌ DISCOURAGED - Don't use 'in' with arrays (confusing due to JS difference)
if (20 in arr) { /* works but confusing for JS developers */ }
```

### Type Conversion Functions

- `int(value, [base])` → `number` - Converts value to integer using optional base (default 10)
- `hex(hexstring)` → `number` - Converts hexadecimal string to number
- `ord(string, [offset])` → `number` - Returns byte value of character at offset (default 0)
- `type(value)` → `string` - Returns type of value as string

### I/O Functions

- `print(...values)` → `number` - Prints values to stdout with JSON representation for objects/arrays (use this for compact JSON output)
- `printf(format, ...args)` → `number` - Formats and prints arguments to stdout
- `warn(...values)` → `number` - Prints values to stderr

### System Functions

- `system(command, [timeout])` → `number` - Executes command and waits for completion
- `getenv([name])` → `string|Object` - Returns environment variable value or all environment variables
- `sleep(milliseconds)` → `null` - Suspends execution for specified milliseconds
- `signal(signal, [handler])` → `Function|string` - Sets or queries signal handler

### Module/Script Loading Functions

- `require(path)` → `*` - Loads and evaluates ucode scripts or shared library extensions
- `include(path, [scope])` → `*` - Includes and evaluates ucode script in current or specified scope
- `loadstring(string, [filename])` → `Function` - Compiles string as ucode source and returns entry function
- `loadfile(path)` → `Function` - Compiles file as ucode source and returns entry function
- `render(template, [variables])` → `string` - Renders template string with optional variables

### Utility Functions

- `die(message)` → `void` - Raises exception with message and aborts execution
- `exit([code])` → `void` - Terminates interpreter with exit code (default 0)
- `time()` → `number` - Returns current UNIX epoch timestamp
- `clock([monotonic])` → `Array` - Returns [seconds, nanoseconds] time array
- `assert(expression, [message])` → `null` - Asserts expression is truthy, throws error if not
- `trace([level])` → `Array` - Returns call stack trace information
- `gc()` → `number` - Triggers garbage collection
- `sourcepath()` → `string` - Returns path of currently executing source file

### Regular Expression Functions

- `regexp(pattern, [flags])` → `RegExp` - Compiles regular expression with optional flags. Non-capturing groups `(?:...)` are NOT supported -- use regular capturing groups `(...)` instead
- `wildcard(subject, pattern, [nocase])` → `boolean` - Matches subject against wildcard (file glob) pattern

### Encoding/Decoding Functions

- `b64enc(string)` → `string` - Encodes string to base64
- `b64dec(string)` → `string` - Decodes base64 string
- `hexenc(string)` → `string` - Encodes byte string to hexadecimal digits
- `hexdec(hexstring, [skipchars])` → `string` - Decodes hexadecimal string to bytes

### Network Functions

- `iptoarr(ipstring)` → `Array` - Converts IP address string to byte array (IPv4/IPv6)
- `arrtoip(bytearray)` → `string` - Converts byte array to IP address string

### Date/Time Functions

- `localtime(timestamp, [utc])` → `Object` - Converts timestamp to broken-down time in local timezone
- `gmtime(timestamp)` → `Object` - Converts timestamp to broken-down time in UTC
- `timelocal(timeobj)` → `number` - Converts broken-down time object to timestamp
- `timegm(timeobj)` → `number` - Converts broken-down UTC time object to timestamp

### Advanced Functions

- `json(value)` → `*` - Parses JSON string into ucode values (parsing only, NOT for generating JSON). **Throws an exception on invalid input.**
- `proto(value, [prototype])` → `*` - Gets or sets prototype of array/object value
- `call(function, [scope], ...args)` → `*` - Calls function with modified environment/scope
- `min(...values)` → `number` - Returns minimum value from arguments
- `max(...values)` → `number` - Returns maximum value from arguments

### Global Variables
- `ARGV` - Command line arguments array

**⚠️ Important:** `ARGV` starts at the first command line argument, NOT the script name.

```ucode
// Command: ucode script.uc arg1 arg2 arg3
// ARGV[0] = "arg1"  (first argument)
// ARGV[1] = "arg2"
// ARGV[2] = "arg3"
// length(ARGV) = 3
```

This differs from C, Python, and many other languages where `argv[0]` contains the program/script name itself.

## Memory Management

ucode uses reference counting for automatic memory management, with optional mark-and-sweep garbage collection.

### Reference Counting
- **Automatic for primitives**: Numbers, strings, booleans automatically managed
- **Arrays and objects**: Use reference counting - memory freed when reference count reaches zero
- **Scoping**: Variables going out of scope automatically decrement reference count

### Circular Reference Problem

Circular references can cause memory leaks with reference counting alone:

```ucode
// ⚠️ Circular reference - causes memory leak without GC
let obj = {};
obj.self = obj;  // Object references itself

// ⚠️ Array self-reference
let arr = [];
arr[0] = arr;  // Array contains itself
```

### Solutions for Circular References

1. **Enable mark-and-sweep GC**: Use `-g` flag when running ucode
   ```bash
   ucode -g script.uc
   ```

2. **Manual garbage collection**: Call `gc()` periodically
   ```ucode
   // Perform operations that might create circular references
   // ...
   gc();  // Manually trigger garbage collection
   ```

3. **Break circular references explicitly**: Set references to `null` when done
   ```ucode
   obj.self = null;  // Break the circular reference
   ```

## Core Modules

### digest - Cryptographic Hash Functions
**Purpose:** Cryptographic hash functions (MD5, SHA-1, SHA-256, etc.) for computing message digests from strings and files.

**See:** `ucode-modules/digest.md` for complete documentation with examples.

### fs - Filesystem Operations
**Purpose:** Complete filesystem manipulation including file I/O, directory management, permissions, symbolic links, and pattern matching.

**See:** `ucode-modules/fs.md` for complete documentation with examples.

### math - Mathematical Functions
**Purpose:** Mathematical, trigonometric, exponential, logarithmic, and random number functions.

**See:** `ucode-modules/math.md` for complete documentation with examples.

### socket - Network Socket Operations
**Purpose:** Network socket programming for TCP, UDP, UNIX domain sockets, and packet sockets. Supports DNS resolution, socket polling, file descriptor passing, and ancillary data.

**See:** `ucode-modules/socket.md` for complete documentation with examples.

### struct - Binary Data Packing/Unpacking
**Purpose:** Pack and unpack binary data using format strings for network protocols, file formats, and low-level data manipulation. Supports integer types, endianness control, hex/base64 encoding, and streaming operations.

**See:** `ucode-modules/struct.md` for complete documentation with format specifiers, buffer operations, and examples.

### ubus - OpenWrt IPC System
**Purpose:** Interface to OpenWrt's ubus inter-process communication system for method calls, object publication, and event handling.

**See:** `ucode-modules/ubus.md` for complete documentation with examples.

### uci - OpenWrt Configuration Interface
**Purpose:** Interface to OpenWrt's Unified Configuration Interface for reading, modifying, and managing system configuration files in `/etc/config/`.

**See:** `ucode-modules/uci.md` for complete documentation with examples.

### uloop - OpenWrt Event Loop
**Purpose:** Asynchronous event loop for timers, file descriptor monitoring, process execution, background tasks, and signal handling. Essential for building event-driven system services.

**See:** `ucode-modules/uloop.md` for complete documentation with examples.

### log - System Logging
**Purpose:** Interface to system logging facilities including syslog and ulog for writing structured log messages to system services.

**See:** `ucode-modules/log.md` for complete documentation with examples.

### resolv - DNS Resolution
**Purpose:** DNS resolution for A, AAAA, MX, TXT, SRV, PTR, NS, and SOA records with configurable nameservers, timeouts, and retry logic.

**See:** `ucode-modules/resolv.md` for complete documentation with examples.

### zlib - Compression and Decompression
**Purpose:** Zlib compression and decompression using DEFLATE algorithm. Supports single-call operations and streaming compression/decompression for large files.

**See:** `ucode-modules/zlib.md` for complete documentation with examples.

### debug - Runtime Debugging
**Purpose:** Runtime debugging and introspection including stack traces, call frame information, and memory dumps.

**See:** `ucode-modules/debug.md` for complete documentation with examples.

### nl80211 - 802.11 Netlink Interface
**Purpose:** Interface to Linux nl80211 netlink for WiFi operations including device configuration, station management, scanning, and event monitoring.

**See:** `ucode-modules/nl80211.md` for complete documentation with examples.

### rtnl - Routing Netlink Interface
**Purpose:** Interface to Linux routing netlink for network interface, address, route, and neighbor configuration and monitoring.

**See:** `ucode-modules/rtnl.md` for complete documentation with examples.

### udebug - Debug Ring Buffer Interface
**Purpose:** Interface to udebug ring buffer system for efficient logging, tracing, packet capture, and kernel tracepoint integration.

**See:** `ucode-modules/udebug.md` for complete documentation with examples.

## Module Import Patterns

All modules support multiple import patterns:

```ucode
// Named imports
import { function1, function2 } from 'module';

// Namespace imports
import * as module from 'module';

// CLI flag imports
// ucode -lmodule script.uc
```

## Error Handling

Most modules provide an `error()` function that returns the last error message:

```ucode
import { open, error as fserror } from 'fs';

let file = open('/nonexistent', 'r');
if (!file) {
    print('Error:', fserror());
}
```

Standard try/catch for exceptions:
```ucode
try {
    // risky code
} catch (e) {
    warn(`Exception: ${e}\n${e.stacktrace[0].context}`);
}
```

### Enhanced Exception Handling

Access to stack trace information:
```ucode
try {
    // code that might throw
} catch(e) {
    // Access exception details
    warn(`Exception: ${e}\n${e.stacktrace[0].context}`);
}
```

Properties available on exception objects:
- `e.stacktrace[0].context` - Context of first stack frame
- `e.stacktrace` - Full stack trace array

## Advanced Language Features

### Optional Chaining
```ucode
let value = object?.property?.nested_property;
let result = func?.();
// Advanced chaining with array access and computed properties
let brvlan = rtevent.msg.af_spec?.bridge?.bridge_vlan_info?.[0]?.vid;
```

### Nullish Coalescing
```ucode
let value = potentially_null ?? default_value;
// Combined with property assignment
config ??= {};
config.prefix = model.udebug_prefix;
```

### Binary Literals and Bitwise Operations
```ucode
// Binary literal syntax
let flags = 0b10000000;
let mask = 0b01000000;

// Bitwise operations
if (he_capa & (1 << 1))
    push(widths, 40);
```

### Negative Array Indexing
```ucode
// Access elements from end of array
let last_item = array[-1];
let second_last = array[-2];

// Useful for dynamic array manipulation
push(devices, new_device);
devices[-1].status = 'active';  // Access just-added element
```

### Spread Operator
```ucode
let new_array = [...existing_array, new_item];
let combined = { ...obj1, ...obj2 };
```

### Template Literals
```ucode
let message = `Hello ${name}, you have ${count} items`;
```

### The `this` Keyword

ucode supports the `this` keyword in function contexts. Functions called as object methods have access to `this`:

```ucode
let obj = {
    value: 42,
    getValue: function() {
        return this.value;
    }
};

print(obj.getValue());  // 42
```

Use `call(function, scope, ...args)` for explicit context binding to set the `this` value.

### Capturing `this` in Closures - CRITICAL

**⚠️ CRITICAL: `this` does NOT work in closures created within methods ⚠️**

When creating closures (functions that will be called later) inside a method, `this` will NOT refer to what you expect. You MUST explicitly capture it in a variable:

```ucode
// ❌ ERROR - `this` lost in closure
const MyObject = {
    value: 42,
    setup_callback: function() {
        uloop.timer(1000, function() {
            print(this.value);  // `this` here does NOT refer to MyObject!
        });
    }
};

// ✅ CORRECT - Capture `this` in a variable before creating closure
const MyObject = {
    value: 42,
    setup_callback: function() {
        let self = this;  // Capture context FIRST
        uloop.timer(1000, function() {
            print(self.value);  // Works correctly
        });
    }
};

// ❌ ERROR - Arrow functions also do NOT capture `this`
const MyObject = {
    value: 42,
    setup_callback: function() {
        uloop.timer(1000, () => {
            print(this.value);  // DOES NOT WORK - arrow functions don't inherit `this`
        });
    }
};
```

**Common scenarios where this matters:**
- Event loop callbacks (`uloop.timer`, `uloop.fd`, `uloop.process`, etc.)
- Socket event handlers
- Array iteration with closures (`map`, `filter`)
- Any callback passed to another function

**Rule of thumb:** When writing a method that creates closures/callbacks, ALWAYS add `let self = this;` at the start of the method, then use `self` in all closures instead of `this`.

## Key Differences from JavaScript

### Not Supported
- **No hoisting**: Functions and variables are not hoisted - must be TEXTUALLY declared before ANY reference (even inside function bodies)
- **No destructuring**: Cannot use `let [a, b] = array` or `let {x, y} = object` - must manually extract values with `let a = array[0]; let b = array[1];` or `let x = object.x; let y = object.y;`
- **No `class` keyword**: No ES6 class syntax
- **No `new` operator**: Cannot use constructor functions with `new`
- **No async/await**: All execution is synchronous
- **No Promise**: No Promise constructor or async patterns
- **No `do...while` loops**: Only `while` and `for` available
- **No `throw` and no `finally`**: Neither is a reserved word; both are syntax errors. Raise errors with `die()`, which `try`/`catch` catches, and put cleanup after the `try`/`catch`
- **No `typeof` operator**: Use the `type()` builtin
- **No default parameters**: Cannot use `function(x = 10)` syntax - use `if (x == null) x = 10;`
- **No `undefined` keyword**: JavaScript's `undefined` keyword is not supported - use `null` to represent missing/empty values
- **No Symbol type**: JavaScript Symbol primitives not available
- **No BigInt type**: Use regular 64-bit integers
- **No `console` object**: Use `print()`, `warn()`, or `printf()` instead
- **No `Array.prototype` methods**: Use global functions - `push(arr, item)` not `arr.push(item)`
- **No `Object.keys()`**: Use `keys(obj)` function
- **No `JSON.parse()`/`JSON.stringify()`**: Use `json()` and `sprintf("%J", obj)`

### Supported (with differences)
- **`this` keyword**: Works in regular functions when called as methods
- **Arrow functions**: Fully supported with `=>` syntax
- **Spread operator**: Fully supported for arrays (`[...arr]`) and objects (`{...obj}`)
- **Optional chaining**: `?.` operator supported (e.g., `obj?.prop?.nested`)
- **Nullish coalescing**: `??` operator supported (e.g., `value ?? default`)
- **Template literals**: Backtick strings with `${expression}` interpolation
- **Closures**: Functions can capture outer scope and return functions
- **`in` operator**: For objects checks KEYS (same as JS), for arrays checks VALUES (different - see warning above)
- **Unary `+` operator**: Converts values to numbers, same as JavaScript (e.g., `+"42"` yields `42`, `+true` yields `1`)
- **Block scoping**: `let`/`const` are block-scoped
- **Prototypes**: `proto(obj, prototype)` function for basic prototype support

### Known Quirks
- **No hoisting**: Functions and variables must be textually declared before ANY reference, including references inside function bodies (JavaScript hoists function declarations)
- **Loop closures**: `let` in `for` loops shares variable across iterations, not per-iteration scope like ES6
- **String indexing**: `string[0]` doesn't work, use `substr(string, 0, 1)`
- **Negative array indices**: `array[-1]` gets last element (Python-style)
- **Integer division truncates**: `1/1024` is `0`, not `0.0009765625` - force a float with `1.0/1024` (see "Integer Division Truncates" below)
- **`proto` is a global function**: importing any module as `proto` shadows the builtin used for prototypes (see "Prototype System" below)
- **Object literals reject numeric keys**: `{ 1: 'a' }` is a syntax error ("Expecting label") - quote the key as `{ '1': 'a' }` or use an array

## Prototype System

ucode supports prototype-based inheritance using the `proto(instance, prototype)` function.

**⚠️ CRITICAL: Never import a module as `proto` ⚠️**

`proto()` is a global builtin, and it is the only way to attach a prototype. An
import that binds the name `proto` shadows it for the whole file, so any later
`proto(obj, Methods)` call tries to invoke the module namespace object instead.
The failure is confusing because the import itself succeeds.

```ucode
// ❌ BROKEN - the import shadows the builtin
import * as proto from 'myapp.proto';

function make() {
    return proto({ x: 1 }, Methods);  // calls the MODULE, not the builtin
}

// ✅ CORRECT - alias the module to anything else
import * as protocol from 'myapp.proto';

function make() {
    return proto({ x: 1 }, Methods);  // builtin is still reachable
}
```

The same care applies to any other global you might shadow with an import alias
or a local variable, such as `length`, `type`, `push` or `index`.

### Basic Usage

```ucode
const BaseObject = {
    method: function() { return 'base'; }
};

const instance = proto({ property: 'value' }, BaseObject);
// instance can access both its own properties and BaseObject methods
```

### Object-Oriented Pattern

The recommended pattern for OOP is to define a const prototype object with methods that access instance data via `this`:

```ucode
// Define prototype with methods
const Person = {
    greet: function() {
        return sprintf("Hello, I'm %s", this.name);
    },

    get_age: function() {
        return this.age;
    },

    set_age: function(new_age) {
        this.age = new_age;
    }
};

// Factory function to create instances
function create_person(name, age) {
    return proto({
        name: name,
        age: age
    }, Person);
}

// Usage
let person = create_person("Alice", 30);
print(person.greet());        // "Hello, I'm Alice"
print(person.get_age());      // 30
person.set_age(31);
print(person.get_age());      // 31
```

### How `this` Works

In prototype methods:
- `this` refers to the instance object (not the prototype)
- Methods can access instance properties via `this.property_name`
- Instance properties are stored on the instance, not the prototype
- All instances share the same prototype methods (memory efficient)

### Complete Example

```ucode
// Prototype definition
const Counter = {
    increment: function() {
        this.value++;
    },

    decrement: function() {
        this.value--;
    },

    get: function() {
        return this.value;
    },

    reset: function() {
        this.value = 0;
    }
};

// Factory function
function create_counter(initial_value) {
    return proto({
        value: initial_value ?? 0
    }, Counter);
}

// Create multiple instances
let counter1 = create_counter(10);
let counter2 = create_counter(20);

counter1.increment();
counter2.decrement();

print(counter1.get());  // 11
print(counter2.get());  // 19
```

### Best Practices

1. **Use const for prototypes**: Prevents accidental modification of shared methods
2. **Factory functions**: Wrap instance creation in a function for cleaner API
3. **Instance data in proto() call**: Pass instance-specific data as first argument
4. **Methods in prototype**: Define all methods in the prototype object
5. **Access via this**: Methods access instance data via `this.property`

### Limitations

- No built-in constructor functions
- No `new` keyword
- No automatic `super()` mechanism for inheritance chains
- Methods are not bound - `this` context depends on how method is called

## Format Specifiers (struct module)

### Basic Types
- `b`, `B` - signed/unsigned 8-bit integer
- `h`, `H` - signed/unsigned 16-bit integer
- `i`, `I` - signed/unsigned 32-bit integer
- `l`, `L` - signed/unsigned 64-bit integer

### Endianness
- `!` or `>` - big endian
- `<` - little endian
- `=` - native endian

### Arrays and Padding
- `*` - repeat until end of data
- `[n]` - repeat n times
- `x` - padding byte

## Common Usage Patterns

### File Operations
```ucode
import { open } from 'fs';

let file = open('/etc/config/system', 'r');
if (file) {
    let content = file.read();
    file.close();
    print(content);
}
```

### Network Configuration via ubus
```ucode
import * as ubus from 'ubus';

let interfaces = ubus.call('network.interface', 'dump', {});
print(json(interfaces));
```

### System Configuration via uci
```ucode
import * as uci from 'uci';

let cursor = uci.cursor();
cursor.load('wireless');
cursor.set('wireless', 'radio0', 'channel', '6');
cursor.commit('wireless');
```

### Event Loop Programming
```ucode
import * as uloop from 'uloop';

uloop.init();
uloop.timer(5000, function() {
    print('5 seconds elapsed');
});
uloop.run();
```

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

// Usage
let value = getProp(config, 'network.interfaces.wan', 'dhcp');
```

### Deep Clone

Creates a deep copy of objects and arrays. **Note**: Does not handle circular references (will throw "Too much recursion" error).

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

// Usage
let original = { name: "test", nested: { x: 10, y: 20 }, list: [1, 2, 3] };
let copy = deepClone(original);
// Modifications to original won't affect copy
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

// Usage
let config = merge(defaults, userSettings, overrides);
```

## Common Gotchas and Limitations

### No Destructuring Assignment

**⚠️ CRITICAL: ucode does NOT support destructuring assignment ⚠️**

This is one of the most common mistakes when writing ucode. You cannot extract array or object values using ES6 destructuring syntax.

```ucode
// ❌ ERROR - Array destructuring not supported
let [foo] = get_results();
let [first, second] = array;
let [x, y] = coordinates;
let [head, ...tail] = items;

// ❌ ERROR - Object destructuring not supported
let {name, age} = person;
let {x, y} = point;
let {status, data} = response;

// ❌ ERROR - Nested destructuring not supported
let {user: {name}} = data;
let [[a, b], [c, d]] = matrix;

// ❌ ERROR - Function parameter destructuring not supported
function process({name, age}) { }
function handle([first, second]) { }

// ✅ CORRECT - Extract array values manually
let results = get_results();
let foo = results[0];

let first = array[0];
let second = array[1];

let x = coordinates[0];
let y = coordinates[1];

// ✅ CORRECT - Extract object values manually
let name = person.name;
let age = person.age;

let x = point.x;
let y = point.y;

let status = response.status;
let data = response.data;

// ✅ CORRECT - Handle function returns
let result = api_call();
if (result.error) {
    warn("Error: ", result.error, "\n");
} else {
    let data = result.data;
    process_data(data);
}
```

**Common scenarios requiring manual extraction:**
- Function returns: `let result = fn(); let value = result[0];`
- API responses: `let response = api_call(); let status = response.status;`
- Coordinates: `let point = get_location(); let x = point.x; let y = point.y;`
- Multiple return values (via arrays): `let results = calc(); let sum = results[0]; let avg = results[1];`

### No `undefined` Keyword - Use `null` Instead

**⚠️ ucode does not support the `undefined` keyword ⚠️**

Unlike JavaScript which has both `null` and `undefined`, ucode only has `null` to represent missing or empty values.

```ucode
// ❌ ERROR - undefined keyword not supported
let value = undefined;
if (value === undefined) { /* ... */ }

// ✅ CORRECT - Use null instead
let value = null;
if (value === null) { /* ... */ }

// ✅ Check for missing object properties
let obj = { a: 1 };
if (!('b' in obj)) {
    // Property 'b' does not exist
}

// ✅ Check for missing function parameters
function process(required, optional) {
    if (optional == null) {
        optional = "default";
    }
    // ...
}

// ✅ Use type() to distinguish null from other types
if (type(value) == "null") {
    // value is null
}
```

**Key points:**
- Missing object properties: Use `in` operator to check existence, not comparison to `undefined`
- Uninitialized variables: Use `null` explicitly or check with `type(value) == "null"`
- Function parameters: Check for `null` with `param == null` pattern
- Return values: Return `null` to indicate absence of a value

### No Hoisting - Declare Before Use

**⚠️ Functions and variables must be TEXTUALLY declared before ANY reference ⚠️**

Unlike JavaScript, ucode does not hoist declarations. This means you must define functions and variables in the source code BEFORE any reference to them, including references that appear inside function bodies.

**Functions:**

```ucode
// ❌ ERROR - Cannot call function before declaration
calculate_total(items);

function calculate_total(items) {
    return length(items) * 10;
}

// ✅ CORRECT - Declare function first
function calculate_total(items) {
    return length(items) * 10;
}

calculate_total(items);
```

**Variables:**

```ucode
// ❌ ERROR - Cannot use variable before declaration
print(my_var);
let my_var = 42;

// ❌ ERROR - Cannot reference variable in function before declaration
function get_value() {
    return my_var;  // References my_var
}
let my_var = 42;

// ✅ CORRECT - Declare variable first
let my_var = 42;
print(my_var);

// ✅ CORRECT - Define variable before any referencing function
let my_var = 42;
function get_value() {
    return my_var;
}
```

**Mutual Recursion:**

This also applies to mutual recursion - textual order matters:

```ucode
// ❌ ERROR - is_odd not yet defined when is_even references it
function is_even(n) {
    return n == 0 || is_odd(n - 1);  // Reference happens here
}

function is_odd(n) {
    return n != 0 && is_even(n - 1);
}

// ✅ WORKAROUND - Use forward declaration pattern
let is_odd;  // Declare variable first

function is_even(n) {
    return n == 0 || is_odd(n - 1);
}

is_odd = function(n) {  // Assign function to variable
    return n != 0 && is_even(n - 1);
};
```

**Best Practice**: Define all functions and variables at the top of your file/scope in dependency order. Think of ucode as a single-pass compiler reading top-to-bottom.

### Export Function Semicolon (Most Common Error!)

**⚠️ ALWAYS add semicolon after `export function` declarations ⚠️**

```ucode
// ✓ CORRECT
export function foo() { return 42; };

// ✗ SYNTAX ERROR - Missing semicolon
export function foo() { return 42; }
```

This is THE most common syntax error in ucode. See the Module System section above for full details.

### Loop Closure Issue

**Problem**: `let` in `for` loops does NOT create per-iteration scope. All closures share the same variable.

```ucode
// ❌ Does NOT work as expected
let funcs = [];
for (let i = 0; i < 3; i++) {
    push(funcs, function() { return i; });
}
// All three functions return 3 (the final value of i)
print(funcs[0]());  // 3 (not 0!)

// ✅ Workaround 1: Use IIFE
let funcs = [];
for (let i = 0; i < 3; i++) {
    push(funcs, (function(val) {
        return function() { return val; };
    })(i));
}

// ✅ Workaround 2: Use helper function
function makeClosure(val) {
    return function() { return val; };
}
let funcs = [];
for (let i = 0; i < 3; i++) {
    push(funcs, makeClosure(i));
}

// ✅ Workaround 3: Use arrow function IIFE
let funcs = [];
for (let i = 0; i < 3; i++) {
    push(funcs, ((val) => () => val)(i));
}
```

### String Indexing Not Supported

```ucode
// ❌ Error: left-hand side expression is not an array or object
let str = "hello";
let char = str[0];

// ✅ Use substr() instead
let char = substr(str, 0, 1);  // "h"

// ✅ Or convert to array
let chars = split(str, "");
let char = chars[0];  // "h"
```

### Integer Division Truncates

**⚠️ Dividing two integers yields an integer, unlike JavaScript ⚠️**

ucode keeps integers and doubles as distinct types. When both operands of `/`
are integers the result is truncated toward zero. This is silent: no warning,
no NaN, just a wrong number.

```ucode
// ❌ WRONG - both operands are integers
let scale = 1/1024;        // 0
let volts = 12288 * scale; // 0

// ✅ CORRECT - force one operand to a double
let scale = 1.0/1024;      // 0.0009765625
let volts = 12288 * scale; // 12.0 (a double, prints as 12.0 not 12)
```

Verify quickly from the shell:

```bash
ucode -p '1/1024'      # 0
ucode -p '1.0/1024'    # 0.0009765625
```

This is most dangerous in constant tables, where a ratio doubles as
documentation and reads as obviously correct:

```ucode
// ❌ Every decoded value silently becomes 0
const FIELDS = [
    { name: 'voltage', scale: 1/1024, unit: 'V' },   // 1/1024 V per LSB
    { name: 'current', scale: 1/16,   unit: 'A' },   // 1/16 A per LSB
];

// ✅ Same table, correct values
const FIELDS = [
    { name: 'voltage', scale: 1.0/1024, unit: 'V' },
    { name: 'current', scale: 1.0/16,   unit: 'A' },
];
```

**Promotion is per-operation, not per-expression.** A double elsewhere in the
expression does not rescue an integer division that happens first:

```ucode
(1/1024) * 1.0    // 0.0    - the division ran on two integers
1.0 * 1 / 1024    // 0.0009765625 - the left operand is already a double
1 * 1.0 / 1024    // 0.0009765625
```

The decimal point has to be on an operand of the division itself.

Related operator behaviour, each verified:

- `%` is **not** integer-only, unlike `/` it accepts doubles: `7.5 % 2` is `1.5`
- bitwise operators truncate their operands to integers: `7.9 & 3` is `3`
- `/` truncates toward zero, not toward negative infinity: `7/2` is `3`,
  `-7/2` is `-3` and `7/-2` is `-3` (a floor division would give `-4`)
- the remainder takes the sign of the dividend: `-7 % 2` is `-1`

---

### Numeric Keys in Object Literals

**⚠️ Object literal keys must be identifiers or quoted strings ⚠️**

A bare number as a key is a syntax error, `Syntax error: Expecting label`. This
differs from JavaScript, which coerces numeric keys to strings.

```ucode
// ❌ SYNTAX ERROR
const CHEMISTRY = {
    1: 'lead acid',
    2: 'nickel-cadmium',
};

// ✅ Quote the keys
const CHEMISTRY = {
    '1': 'lead acid',
    '2': 'nickel-cadmium',
};

// ✅ Or use an array when the keys are a small dense integer range
const CHEMISTRY = [
    null,               // 0 unassigned
    'lead acid',        // 1
    'nickel-cadmium',   // 2
];
```

Assignment with a computed numeric key is fine, only the literal form is
restricted: `obj[1] = 'a';` works and stores under the key `"1"`.

---

### Error Handling Without `throw` or `new Error()`

**⚠️ There is no `throw` keyword and no `finally` block ⚠️**

Neither `throw` nor `finally` appears in `reserved_words[]` in the ucode lexer,
so both are syntax errors, not merely unsupported idioms. `die()` is what
raises an error, and it is catchable: a surrounding `try`/`catch` receives the
value passed to `die()` as the exception.

```ucode
// ❌ No Error constructor
throw new Error("Something went wrong");

// ❌ SYNTAX ERROR - throw is not a ucode keyword
throw "Custom error message";

// ❌ SYNTAX ERROR - finally is not a ucode keyword
try { risky(); } catch (e) { handle(e); } finally { cleanup(); }

// ✅ die() raises the error, and try/catch catches it
try {
    if (bad_state)
        die("Custom error message");
} catch (e) {
    warn("Caught error: ", e, "\n");   // e is "Custom error message"
}

// ✅ Use die() for fatal errors when nothing catches it (terminates script)
die("Something went wrong");

// ✅ Return error objects for recoverable errors
function doSomething() {
    if (error_condition)
        return { error: "Something went wrong", code: 1 };
    return { success: true, data: result };
}

// ✅ No finally: put the cleanup after the try/catch, or in both branches
try {
    risky();
} catch (e) {
    warn("Caught error: ", e, "\n");
}
cleanup();
```

## Differences from JavaScript (Summary)

For a comprehensive list of language feature differences, see the "Key Differences from JavaScript" section in the Advanced Language Features area above.

**Key Differences:**
- **Module system**: ES6-style `import`/`export` with mandatory semicolons after `export function`
- **Built-in functions**: Global functions like `length()`, `push()`, `keys()` instead of prototype methods
- **System integration**: Deep OpenWrt/Linux integration via ubus, uci, netlink modules
- **File extension**: Uses `.uc` instead of `.js`
- **Runtime**: Optimized for embedded systems (~64KB footprint on ARM)
- **Memory**: Reference counting with optional mark-and-sweep GC via `gc()`
- **Error handling**: Module-specific `error()` functions plus try/catch
- **No destructuring**: Cannot use `let [a, b] = array` or `let {x, y} = obj` - must extract manually: `let a = array[0]; let x = obj.x;`
- **No `class`/`new`**: No ES6 classes or constructor pattern
- **Loop closures**: `let` in `for` loops doesn't create per-iteration scope

## Best Practices

1. **Function and variable ordering**: ALWAYS declare functions and variables at the top of your scope BEFORE any code that references them (no hoisting - ucode reads top-to-bottom like a single-pass compiler)
2. **Strict mode**: Use `'use strict';` for stricter error checking and better error messages
3. **Variable declarations**: Always use `let` for local variables to avoid polluting global scope; use `const` for constants
4. **Naming convention**: Use `snake_case` for variable and function names (following codebase convention)
5. **Error handling**: Check return values and use module `error()` functions; use try/catch for exceptions
6. **Type checking**: Use `type()` function to validate inputs before processing
7. **String formatting**: Use `sprintf()` or `printf()` for complex formatting rather than concatenation
8. **Array vs Objects**: Use arrays for ordered collections, objects for key-value mappings
9. **Module loading**: Use `import` for modules (compile-time), `include()` only for scripts
10. **Module imports**: Import only what you need from modules to reduce memory usage
11. **Safe property access**: Use optional chaining (`?.`) or helper functions for safe property access
12. **System integration**: Use appropriate modules (ubus, uci) rather than shell commands
13. **Event-driven code**: Use uloop for event-driven programming in system services
14. **Performance**: Cache object property access in loops to avoid repeated lookups
15. **Memory management**: Be aware of circular references; use `-g` flag or `gc()` when needed
16. **Array value checks**: Use `index(arr, value) >= 0` not `value in arr` to avoid confusion with JavaScript
17. **Indentation levels**: Keep nesting shallow (maximum 2-3 levels). Use early returns, guard clauses, continue/break, and function extraction. See "Reducing Indentation Levels" section below for patterns.
18. **Avoid trivial wrappers**: Don't create functions that just return a property or forward to another function. If direct access or calls are clearer, use them instead of creating unnecessary wrapper functions.

## Reducing Indentation Levels

**CRITICAL**: Deep nesting (4+ levels) makes code hard to read and maintain. Keep indentation to maximum 2-3 levels using these patterns:

### Early Returns and Guard Clauses

Validate preconditions at the start and return early. This avoids wrapping the entire function in conditionals.

```ucode
// ❌ BAD - Deeply nested (4 levels)
function process_data(data) {
    if (data) {
        if (data.valid) {
            if (data.items) {
                for (let item in data.items) {
                    if (item.active) {
                        result_process(item);
                    }
                }
            }
        }
    }
}

// ✅ GOOD - Guard clauses with early returns (2 levels)
function process_data(data) {
    if (!data)
        return;
    if (!data.valid)
        return;
    if (!data.items)
        return;

    for (let item in data.items) {
        if (!item.active)
            continue;
        result_process(item);
    }
}
```

### Continue to Skip Loop Iterations

Use `continue` to skip iterations that don't meet criteria instead of wrapping the loop body in conditions.

```ucode
// ❌ BAD - Nested conditions in loop (4 levels)
for (let file in files) {
    if (file.type == 'text') {
        if (file.size < max_size) {
            if (!file.error) {
                file_process(file);
            }
        }
    }
}

// ✅ GOOD - Continue for early skip (2 levels)
for (let file in files) {
    if (file.type != 'text')
        continue;
    if (file.size >= max_size)
        continue;
    if (file.error)
        continue;

    file_process(file);
}
```

### Break to Exit Loops Early

Exit loops immediately when the goal is achieved instead of using flag variables.

```ucode
// ❌ BAD - Flag variable with nested condition (3 levels)
let found = false;
for (let item in items) {
    if (!found) {
        if (item.id == target_id) {
            result = item;
            found = true;
        }
    }
}

// ✅ GOOD - Break immediately (2 levels)
for (let item in items) {
    if (item.id != target_id)
        continue;
    result = item;
    break;
}
```

### Extract Functions to Reduce Nesting

Move complex nested logic into separate helper functions. This improves readability and reusability.

```ucode
// ❌ BAD - Complex nested logic (5 levels)
function handle_event(event) {
    if (event.type == 'update') {
        for (let device in devices) {
            if (device.id == event.device_id) {
                if (device.status == 'active') {
                    for (let prop in event.properties) {
                        device.properties[prop] = event.properties[prop];
                    }
                    device.last_update = time();
                }
            }
        }
    }
}

// ✅ GOOD - Extract helper function (2 levels max)
function device_update(device, properties) {
    for (let prop in properties)
        device.properties[prop] = properties[prop];
    device.last_update = time();
}

function handle_event(event) {
    if (event.type != 'update')
        return;

    for (let device in devices) {
        if (device.id != event.device_id)
            continue;
        if (device.status != 'active')
            continue;

        device_update(device, event.properties);
        break;
    }
}
```

### Invert Conditions to Eliminate Else Blocks

Handle the exceptional case first with early return, eliminating the need for `else`.

```ucode
// ❌ BAD - Unnecessary else block
function apply_settings(config) {
    if (config) {
        settings_apply(config);
        return true;
    } else {
        return null;
    }
}

// ✅ GOOD - Early return, no else needed
function apply_settings(config) {
    if (!config)
        return null;

    settings_apply(config);
    return true;
}
```

### Combining Multiple Patterns

Real-world functions often benefit from combining several patterns:

```ucode
// ❌ BAD - Multiple levels of nesting (6 levels)
function process_network_update(msg) {
    if (msg) {
        if (msg.type == 'interface') {
            for (let iface in interfaces) {
                if (iface.name == msg.interface) {
                    if (msg.addresses) {
                        for (let addr in msg.addresses) {
                            if (addr.family == 'ipv4') {
                                address_add(iface, addr);
                            }
                        }
                    }
                }
            }
        }
    }
}

// ✅ GOOD - Guard clauses, continue, and extraction (2 levels max)
function interface_add_addresses(iface, addresses) {
    for (let addr in addresses) {
        if (addr.family != 'ipv4')
            continue;
        address_add(iface, addr);
    }
}

function process_network_update(msg) {
    if (!msg)
        return;
    if (msg.type != 'interface')
        return;
    if (!msg.addresses)
        return;

    for (let iface in interfaces) {
        if (iface.name != msg.interface)
            continue;

        interface_add_addresses(iface, msg.addresses);
        break;
    }
}
```

**Summary**: Shallow nesting makes code easier to read, debug, and maintain. Always prefer flatter structures over deeply nested ones.

## Debugging Common Errors

### "Exports may only appear at top level of a module"

**Cause:** Trying to execute or compile a module file directly.

**Solution:** Modules must be imported, not executed. Create a test script:
```bash
# Create test script
cat > test.uc << 'EOF'
import { my_function } from './my_module.uc';
print(my_function());
EOF

# Run the test script
ucode test.uc
```

---

### "Imports may only appear at top level"

**Cause:** Import statement inside a function or conditional block.

**Solution:** Move all imports to the top of the file before any function definitions.

---

### "No such file or directory" for Module Imports

**Cause:** Path resolved from CWD, not from importing file's location.

**Debug:**
```bash
# Check your current directory
pwd

# Verify the path exists from CWD
ls ./path/to/module.uc
```

**Solution:** Adjust path to be relative to CWD, or use absolute paths.
