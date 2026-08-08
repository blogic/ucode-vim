let dq = "double \"quoted\" with a \n escape";
let sq = 'single \'quoted\' with a \t escape';
let apostrophe = 'it\'s fine';
let escapes = "hex \x41 octal \101 unicode ä bell \a";
let slashes = "a // is not a comment here";
let block = "a /* is not a comment either */";
let tmpl = `template ${name} and ${obj.prop} done`;
print(dq, sq, apostrophe, escapes, slashes, block, tmpl);
