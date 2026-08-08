// All 71 names from uc_stdlib_functions[] in lib.c, plus the global bindings
// installed by uc_vm_init_scope() in vm.c. Referencing a builtin without
// calling it is valid: they are ordinary function values.

let core = [
	arrtoip, assert, b64dec, b64enc, call, chr, clock, die,
	exists, exit, filter, gc, getenv, gmtime, hex, hexdec,
	hexenc, include, index, int, iptoarr, join, json, keys,
	lc, length, loadfile, loadstring, localtime, ltrim, map, match,
	max, min, ord, pop, print, printf, proto, push,
	regexp, render, replace, require, reverse, rindex, rtrim, shift,
	signal, sleep, slice, sort, sourcepath, split, splice, sprintf,
	substr, system, time, timegm, timelocal, trace, trim, type,
	uc, uchr, uniq, unshift, values, warn, wildcard
];

let globals = [ARGV, REQUIRE_SEARCH_PATH, modules, NaN, Infinity, global];

// Not builtins: these live in the math module, or nowhere at all.
let absent = [abs, round, floor, ceil, reduce, jsonstr];

print(length(core), length(globals), length(absent));
