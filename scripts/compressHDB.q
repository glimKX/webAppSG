//////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Q script which reads in sym to get schema before reading tplog					//
//	Input of tplog with trade and quote data with date						//
//////////////////////////////////////////////////////////////////////////////////////////////////////////

/q compressHDB.q -tplog tplogFile(dt)

-1"INFO: Initialising tickerplant log reader to create compressed HDB";
\d .tpr
dir: @[.Q.opt;.z.x;""];
dir: $[count dir;first dir `tplogFile;string .z.D];
//validate to ensure dt format
if[not dir like "????.??.??";-2"ERROR: tplogFile name does not conform to (YYYY.MM.DD) date format";exit 1];
dt:"D"$dir;

// save down table compressed, similar to EOD
end:{-1"INFO: Saving of tables as HDB";
	t:tables[`]except `aggreg;
	@[{.Q.dpft[hsym`$getenv`COMPRESSHDB_DIR;.tpr.dt;`sym;]each x};t;{-2"ERROR: Failed to save tables as HDB ",.Q.s x;exit 1}]
 };

// go into directory and compress each column with -19
compress:{-1"INFO: Start of Compression";
 	@[system;"cd /",2_string partitionDir;{-2"ERROR: HDB Partition was not saved, unable to proceed with compression ",.Q.s x;exit 1}]
	tradeColsToCompress:` sv' `:trade,/:key[`:trade] except `time`sym;
	quoteColsToCompress:` sv' `:quote,/:key[`:quote] except `time`sym;
	-1"INFO: Compressing Trade table";
	{-19!(x;x;16;0;0)} each tradeColsToCompress;
	-1"INFO: Compressing Quote table";
	{-19!(x;x;16;0;0)} each quoteColsToCompress;
	-1"INFO: Compression Complete";
 };

partitionDir:hsym`$getenv[`COMPRESSHDB_DIR],"/",.tpr.dir;
\d .

//declare upd to ignore aggreg
upd:{[t;x] $[t=`aggreg;:();t insert x]};

//load schema from sym.q
system "l ",getenv `SCHEMA;

//attempt to get tplog
if[()~key .tpr.tplog:getenv[`TPLOG_DIR],"/",.tpr.dir;-2"ERROR: tplogFile ",.tpr.dir,"is missing from tplog directory";exit 1];

//pass validation at tplog exists
-11!hsym `$.tpr.tplog;

//save down hdb
.tpr.end[];

//compress hdb partition
.tpr.compress[];

-1"INFO: Creation of compressed HDB for ",.tpr.dir," Completed!!";
exit 0
