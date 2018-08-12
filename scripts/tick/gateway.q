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

/ open handle to HDB and RDB
/hdbHandle:hopen "J"$getenv `HDB_PORT;
backEndHandle:hopen `$"::",getenv[`BACKEND_PORT],":",getenv[`ADMIN_USER],":",getenv[`ADMIN_PASS];

/define .z.ws for websocket
.z.ws:{neg[.z.w] .debug.x:x;$[99h=type x:.j.k x;
	[x[`func]:`$x[`func];.j.j @[{.log.out .Q.s1 x;x[`func] @ x[`args]};x;{.log.err .Q.s1[x],.Q.s1[y];`func`output!(`error;"failed to process ",x," due to ",y)}.Q.s1 x]];
	[.j.j @[{.log.out .Q.s1 x;value x};x;{.log.err .Q.s1[x],.Q.s1[y];`func`output!(`error;"failed to process ",x," due to ",y)}.Q.s1 x]]]}

uploadCSV:{testCase:update "J"$id, "J"$iteration, "Z"$timer from x;`func`output!(`uploadCSB;backEndHandle(set;`.test.TestCase;testCase))}

/sourceForSym
/sourceForSym:{output:(rdbHandle "raze value flip 11#key desc select count i by sym from trade")except `$"BRK-A";
/	`func`output!(`sourceForSym;" " sv string raze output)
/ }

/selectFromTrade
/selectFromTrade:{output:rdbHandle "select from trade where sym = ",x;
/	`func`output!(`selectFromTrade;output)
/ }
