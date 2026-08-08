// Every reserved word from reserved_words[] in lexer.c, in a position the
// compiler accepts. This fixture is valid ucode: ucode -c must be happy with it.

function demo(list, obj) {
	let total = 0;
	const limit = 10;

	for (let item in list) {
		if (item == null)
			continue;
		if (item > limit)
			break;
		total += item;
	}

	while (total > 0)
		total--;

	switch (total) {
	case 1:
		return true;
	default:
		return false;
	}
}

function alt(x) {
	if (x == 1):
		print("one");
	elif (x == 2):
		print("two");
	else
		print("other");
	endif;

	for (let i = 0; i < 2; i++):
		print(i);
	endfor;

	while (0):
		print(1);
	endwhile;
}

function altfn(): print("alt"); endfunction;

let obj = { key: 1 };

try {
	delete obj.key;
} catch (e) {
	warn(e);
}

print(demo([1], obj), alt(1), altfn());
