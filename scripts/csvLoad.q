//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Modify r.q template to become load csv and push to ticker plant							//
//	Script is similar to feedhandler but takes a csv file argument to push to tickerplant 				//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/q csv.q [host]:port[:usr:pwd] -csv pathToCSV 

/ bash script to feed in the right port number or not run script
/ get the ticker plant ports, defaults are 5010
.u.x:.z.x,(count .z.x)_enlist ":5010";

-1"INFO: Initialise script to load csv to push to tickerplant at ", first .u.x;

if[not count .csv.dir:.Q.opt[.u.x]`csv;
	-2"ERROR: csv script cannot initalise due to missing csv path";
	exit 1
 ];

.csv.dir:hsym`$first .csv.dir;
/ error check on csv directory 
if[()~key .csv.dir;
	-2"ERROR: csv input is missing";
	exit 1
 ]; 

/ analytics to ingest data 
.csv.ingestQuoteCSV:{(`.u.upd;`quote;1_'("NSJFJF";",")0:x)};

.csv.ingestTradeCSV:{(`.u.upd;`trade;1_'("NSJF";",")0:x)};

/ load schema table to ensure consistency in data with tickerplant
system "l ",getenv`SCHEMA

/ script checks header to decide function to apply, if errors out, exit immediately 
.csv.cols:@[{`$"," vs first read0 x};.csv.dir;{-2"ERROR: Unable to ingest data due to ",.Q.s x;exit 1}];
.csv.ingestedData:$[cols[trade] ~.csv.cols;.csv.ingestTradeCSV .csv.dir;cols[quote] ~.csv.cols;.csv.ingestQuoteCSV .csv.dir;[-1"WARN: Schema conflicts with tickerplant, not ingesting data";exit 0]]; 
-1"INFO: Pushing csv data to ticker plant";
@[{(h:hopen `$":",first .u.x) x};.csv.ingestedData;{-2"ERROR: Failed to push csv data to tickerplant due to ",.Q.s x;exit 1}];
-1"INFO: Done Pushing";
exit 0
