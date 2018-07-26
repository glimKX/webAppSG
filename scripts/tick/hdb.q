//////////////////////////////////////////////////////////////////////////////////////////////////////////
//	HDB INIT SCRIPT 										//
//////////////////////////////////////////////////////////////////////////////////////////////////////////

/q tick/hdb.q [host]:port[:usr:pwd] [host]:port[:usr:pwd] 
/2008.09.09 .k ->.q


if[not "w"=first string .z.o;system "sleep 1"];
//init with config port
system "p ",getenv`HDB_PORT;

/ load logging capability
system "l ",getenv[`SCRIPTS_DIR],"/log.q";

/ cd to HDB location
system "cd ",getenv `HDB

/ load hdb
\l .
