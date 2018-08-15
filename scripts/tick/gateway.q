//////////////////////////////////////////////////////////////////////////////////////////////////////////
//	 GATEWAY INIT SCRIPT 										//
//////////////////////////////////////////////////////////////////////////////////////////////////////////

if[not "w"=first string .z.o;system "sleep 1"];
//init with config port
/system "p ",getenv`GATEWAY_PORT;

/ load logging capability
system "l ",getenv[`SCRIPTS_DIR],"/log.q";

/ load permissioning capability
//system "l ",getenv[`SCRIPTS_DIR],"/perm.q";

/ open handle to backend 
backEndHandle:hopen `$"::",getenv[`BACKEND_PORT],":",getenv[`ADMIN_USER],":",getenv[`ADMIN_PASS];

/define .z.ws for websocket
/TO-DO, put requests into a list so that gateway can be free while waiting for answer
/Async queries to wait for answer with callback to update answers
.z.ws:{.debug.x:x;x:@[{.j.k x};x;{x}x];
	$[99h=type x;
	[x[`func]:`$x[`func];neg[.z.w] .j.j @[{.log.out .Q.s1 x;x[`func] @ x[`args]};x;{.log.err .Q.s1[x],.Q.s1[y];`func`output!(`error;"failed to process ",x," due to ",y)}.Q.s1 x]];
	[neg[.z.w] .j.j @[{.log.out .Q.s1 x;backEndHandle(`.backend.val;x)};x;{.log.err .Q.s1[x],.Q.s1[y];`func`output!(`error;"failed to process ",x," due to ",y)}.Q.s1 x]]]}

uploadCSV:{testCase:update "J"$id, "J"$testCase, "J"$answer, "J"$iteration, "Z"$timer from x;`func`output!(`uploadCSV;backEndHandle(`.backend.uploadTestCase;`.test.TestCase;testCase))}

