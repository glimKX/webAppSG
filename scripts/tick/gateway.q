//////////////////////////////////////////////////////////////////////////////////////////////////////////
//	 GATEWAY INIT SCRIPT 										//
//////////////////////////////////////////////////////////////////////////////////////////////////////////

if[not "w"=first string .z.o;system "sleep 1"];
//init with config port
/system "p ",getenv`GATEWAY_PORT;

/ load logging capability
system "l ",getenv[`SCRIPTS_DIR],"/log.q";

/ open handle to HDB and RDB
/hdbHandle:hopen "J"$getenv `HDB_PORT;
backEndHandle:hopen "J"$getenv `BACKEND_PORT;

/define .z.ws for websocket
.z.ws:{neg[.z.w] .j.j @[{.log.out .Q.s1 x;value x};x;{.log.err .Q.s1[x],.Q.s1[y];`func`output!(`error;"failed to process ",x," due to ",y)}x]}

/sourceForSym
/sourceForSym:{output:(rdbHandle "raze value flip 11#key desc select count i by sym from trade")except `$"BRK-A";
/	`func`output!(`sourceForSym;" " sv string raze output)
/ }

/selectFromTrade
/selectFromTrade:{output:rdbHandle "select from trade where sym = ",x;
/	`func`output!(`selectFromTrade;output)
/ }
