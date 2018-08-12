//////////////////////////////////////////////////////////////////////////////////////////////////
//	log.q script which loads up with all tick templates											//
//	q script will define functions in .z.po .z.pc and some .log functions						//
//////////////////////////////////////////////////////////////////////////////////////////////////

/init connection schema
.log.connections:flip `dateTime`user`host`ipAddress`connection`handle`duration!"ZSS*SIV"$\:();

/when connection is opened, collect from handle the following information
/datetime username hostname ipaddress connection duration
/collect data from .z.po
.z.po:{[w] `.log.connections insert .z.Z,.z.u,(.Q.host .z.a;"." sv string "h"$0x0 vs .z.a),`opened,w,0Nv;.log.out .log.co w};

/when connection is closed, update connection to closed
.z.pc:{[w] update connection:`closed,duration:"v"$80000*.z.Z-dateTime from `.log.connections where handle = w;.log.out .log.cc w};

/need unique name for each log file
.log.AllProcessName:{x:"=" vs' x;(!) . reverse flip @'[@'[@'[x;1;"J"$];0;-5_];0;"S"$]} system "grep -v \"#\" ", getenv[`CONFIG_DIR],"/port.config | awk '{print $2}'";
/.log.AllProcessName:(5010;5011;5013;5020;5012)!`tickerPlant`RDB1`RDB2`FeedHandler`HDB;
.log.processName:.log.AllProcessName system"p";
.log.file:hopen `$":",getenv[`LOG_DIR],"/",string[.log.processName],".log";

.log.string:{string[.log.processName]," ## ",string[.z.P]," ## ",x," \n"};
/capture initalised time
.log.time:.z.T;
/declare log output function
.log.out:{.log.file "INFO: ",.log.string x};
.log.err:{.log.file "ERROR: ",.log.string x};
 
\c 200 200

.log.cc:{[w] "Connection closed: ",.Q.s1 exec from .log.connections where handle = w};
.log.co:{[w] "Connection opened: ",.Q.s1 exec from .log.connections where handle = w}; 

.log.value:{@[{.log.out "User: ",string[.z.u]," ## Memory Usage: ",.Q.s1 .Q.w[];value x};x;{.log.err -1_.Q.s x;x}]};

/adding logging message in evaluating ipc
.z.pg:{$[10h=type x;.log.value x;first[x] like "*upd";value x;.log.value x]};
.z.ps:{$[10h=type x;.log.value x;first[x] like "*upd";value x;.log.value x]};

/shutdown function
.log.shutdown:{.log.out "Shutdown Trigger from mainScript";exit 0};
