///////////////////////////////////////////////////////////
// Tickerplant log reader 
// Starts a q session which attempts to read in the latest logFile or one specificed by the user
// q tplogIBM.q -tplogFile FilePath
///////////////////////////////////////////////////////////

//Runs in quiet mode
-1"INFO: Initialising tickerplant log reader to create new tplogFile";
\d .tpr
dir: @[.Q.opt;.z.x;""];
dir: $[count dir;first dir `tplogFile;string .z.D];
/to change to use env config for tplog dir, use key to check if it exists
dir: raze @[system;"find . -name \"",dir,"\"*";{-2"Cannot find tplogFile: ",.Q.s x;exit 1}];
dir: `$":",2_dir;
filter:{x:`func`table`data!x;.debug.x:x;x:@[x;`data;:;x[`data][;where `IBM=x[`data] 1]];if[sum count each x`data;.tpr.write enlist value x;]};
file:"/" vs string[dir];
file[1]:"IBM.",file[1];
write:` sv `$file;
if[(`$file[1]) in key `:tplog;-1"WARN: File ",(1_string ` sv `$.tpr.file)," exists, overwritting file"];
write set (); 
write: hopen write;
\d .

@[{.tpr.filter each get x};.tpr.dir;{-2"ERROR: Unable to create new logFile due to ",.Q.s x;exit 1}];

-1"INFO: Completed and created new logFile ",1_string ` sv `$.tpr.file;
exit 0;
