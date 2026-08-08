let obj = { key: 1, other: 2 };
let val = obj.key;
let opt = obj?.key;
let deep = obj.key.nested;
let spread = [...list, 1];
let res = compute(1, 2);

function named(a, b) {
	return a + b;
}

print(obj, val, opt, deep, spread, res, named(1, 2));
