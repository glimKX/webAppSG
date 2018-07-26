//////////////////////////////////////////////////////////////////////////////////////////////////
//	Modify r.q template to accept tables for subscription										//
//	Input of table format must be string, this can be handled in the bash script that init this	//
//////////////////////////////////////////////////////////////////////////////////////////////////

/q tick/r.q [host]:port[:usr:pwd] [host]:port[:usr:pwd] -table "table1;table2;table3"
/2008.09.09 .k ->.q


if[not "w"=first string .z.o;system "sleep 1"];


/ get the ticker plant and history ports, defaults are 5010,5012
.u.x:.z.x,(count .z.x)_(":5010";":5012");
/ tables to subscribe to
.u.tSub:$["-table" in .u.x;raze "`",/:raze";" vs' .Q.opt[.u.x]`table;"`"];
/ end of day: save, clear, hdb reload
.u.end:{t:tables`.;
	/added to fix aggreg saving down
	t set' (0!value @) each t;
	t@:where `g=attr each t@\:`sym;
	.Q.hdpf[`$"::",getenv`HDB_PORT;`:.;x;`sym];@[;`sym;`g#] each t;};

/ load logging capability
system "l ",getenv[`SCRIPTS_DIR],"/log.q";

/ init schema and sync up from log file;cd to hdb(so client save can run)
//update upd such that if data is aggreg, it will manipulate it
//it might be faster to have many q scripts with customised/optimised upd for millisecond reductions
//convoluted upd to ensure that upsert maintains the latest data
/initialise aggreg keyed on sym so that upsert will always maintain the latest statistics
/error trapped so that it will not error out if rdb does not subscribes to aggreg table

upd:{[t;x] if[t in value .u.tSub;$[t=`aggreg;$[0=type x;t upsert `sym xkey `time`sym xcol flip (cols[t])!x;t upsert `sym xkey x];t insert x]]};
.u.rep:{if[any 2<>count each x;x:enlist x];(.[;();:;].)each x;if[null first y;:()];if[`aggreg in value .u.tSub;`sym xkey `aggreg];-11!y;system "cd ",getenv `HDB};
/cd in environmental variable, HDB location

/ connect to ticker plant for (schema;(logcount;log))
/ this changes such that the rdb is able to choose what it subscribes to

.u.rep .(hopen `$":",.u.x 0)"(.u.sub[;`] each ",.u.tSub,";`.u `i`L)";


