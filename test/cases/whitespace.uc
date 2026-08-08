// This fixture carries deliberate trailing whitespace. Do not strip it.
let code = 1;	
/* a block comment with a trailing tab	
   and a space before a tab: 	x
*/
let text = "a string with an inner tab	";
// a line comment with a trailing tab	
print(code, text);
