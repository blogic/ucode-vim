// Every line below is JavaScript that ucode rejects. This fixture is
// deliberately NOT valid ucode; it exists to prove the error rules fire.
let a = undefined;
let b = new Object();
class Foo extends Bar {}
do { work(); } while (0);
try { work(); } finally { cleanup(); }
throw "boom";
let t = typeof(x);
async function fetcher() { await ready(); }
let [first, second] = arr;
let {alpha, beta} = obj;
if (a) { work(); } elseif (b) { other(); }
let sep = 1_000;
# this is not a comment in ucode
