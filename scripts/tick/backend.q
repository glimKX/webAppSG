//////////////////////////////////////////////////////////////////////////////////////////////////
//	Modify r.q template to accept tables for subscription										//
//	Input of table format must be string, this can be handled in the bash script that init this	//
//////////////////////////////////////////////////////////////////////////////////////////////////


if[not "w"=first string .z.o;system "sleep 1"];

/ load logging capability
system "l ",getenv[`SCRIPTS_DIR],"/log.q";

/ load permissioning capability
//system "l ",getenv[`SCRIPTS_DIR],"/perm.q";

/ load cron capability
system "l ",getenv[`SCRIPTS_DIR],"/cron.q";

/ load heartbeat capability
system "l ",getenv[`SCRIPTS_DIR],"/heartbeat.q";

/ log file for test process to replay if it get restarted
/logFile:hsym`$getenv[`TESTLOG_DIR],"/TEST";
/logFile set ();
/l:hopen logFile;

/ subscrption table for backend process
\d .backend

/ log file for test process to replay if it get restarted
logFile:hsym`$getenv[`TESTLOG_DIR],"/TEST";
logFile set ();
l:hopen logFile;

connections:([processName:`$()] handle:"J"$();status:`$());

connect:{[w] 
	`.backend.connections upsert con:(w".log.processName";w;`free);
	.log.out "Connection established ",.Q.s1 con;
	if[(con 0) like "TEST*";
		.hb.addHB[con 0;w;1];
		.backend.failRequest con 0;
	]
 };

forceConnect:{ .log.out "Force Connect to Gateway";
	@[{.backend.connect .backend.gatewayHandle:hopen `$x};":" sv (":localhost";getenv[`GATEWAY_PORT];getenv[`ADMIN_USER];getenv[`ADMIN_PASS]);{.log.err "Unable to open connnection to gatewayHandle ",.Q.s[x]}]};

funQStory:();

/table init
leaderBoard:`user xkey flip `ranking`user`function`funcLength`overallSpeed!"JS*JJ"$\:();
jobs:`jobID xkey flip `jobID`processName`user`handle`function`status`msg!"JSSJ*S*"$\:();

uploadTestCase:{[tab;csvFile] .log.out "In .backend.uploadTestCase -- proceeding to upload test cases";
	h:exec handle from .backend.connections where processName like "*TEST*";
	.backend.l enlist (set;tab;csvFile);
	neg[h]@\:(set;tab;csvFile);
 };

changeTestCaseSchema:{[column;ty] .log.out "In .backend.changeTestCaseSchema -- changing col: ",.Q.s[column]," schema: ",.Q.s[ty];
	h:exec handle from .backend.connections where processName like "*TEST*";
	.backend.l enlist ({.test.upd[`.test.schema;x]};`colName`ty!(column;first ty));
	neg[h]@\:({.test.upd[`.test.schema;x]};`colName`ty!(column;first ty));
 };

upd:{[tab;x] if[0<=x`overallSpeed;tab upsert x;.backend.leaderBoard:update ranking:(1+i) from `overallSpeed xasc .backend.leaderBoard]};

val:{[func;user;handle;jobID]
	.log.out "In .backend.val";
	h:exec first handle from .backend.connections where status=`free,processName like "*TEST*";
	if[null h;
		.log.out "No free test process";
		`.backend.jobs upsert `jobID`user`function`status`handle!(jobID;user;func;`queued;handle);
		neg[.z.w](`.gateway.queue;jobID);
		:"Submitted test function, no free process currently. Please remain connected"
	];
	.log.out "Pushing to handle ",.Q.s h;
	update status:`processing from `.backend.connections where handle=h;
	processName:exec first processName from .backend.connections where handle=h;
	`.backend.jobs upsert `jobID`processName`user`function`status`handle!(jobID;processName;user;func;`sent;handle);
	.log.out "New Job received: ",.Q.s jobID;
	neg[h](`.test.testFunction;user;func;h;jobID);
	"Submitted test function please wait for results..."
 };

valReplay:{[dict]
	//[func;user;handle;jobID]
	jobID:dict`jobID;
	handle:dict`handle;
	func:dict`function;
	user:dict`user;
        .log.out "In .backend.valReplay --- ",.Q.s1 dict;
        h:exec first handle from .backend.connections where status=`free,processName like "*TEST*";
        if[null h;
                .log.out "No free test process";
                :()
        ];
	.log.out "Pushing to handle ",.Q.s h;
        update status:`processing from `.backend.connections where handle=h;
	pName:exec first processName from .backend.connections where handle=h;
        `.backend.jobs upsert `jobID`status`processName!(jobID;`sent;pName);
	neg[h](`.test.testFunction;user;func;h;jobID);
 };

replayQueue:{.log.out "Replaying queued jobs";
	replayJob:select function,user,handle,jobID from .backend.jobs where status=`queued;
	if[count replayJob;.backend.valReplay each replayJob];
 };

sendResult:{[res;jobID]
	.log.out "In .backend.sendResult ",.Q.s1 `res`jobID!(res;jobID);
	$[1=count res;res:enlist res;res:flip res];
	if[`testCase in cols res;
		if[1<count exec first testCase from res;res:update .Q.s1 each testCase from res];
	  ];
	h:first exec handle from .backend.connections where processName like "GATEWAY";
	neg[h](`.gateway.sendResult;res;jobID);
 };

refresh:{
	.log.out "Forcing all connections to refresh leaderboard";
	neg[.backend.gatewayHandle](`.gateway.refresh;`);
 };

failRequest:{[pName]
	.log.out "In .backend.failRequest --- failing sent request in ",.Q.s1 pName;
	update status:`free from `.backend.connections where processName=pName;
	res:enlist[`error]!enlist "Bad Request";
	jobID:first exec jobID from `.backend.jobs where processName=pName,status=`sent; 
	update status:`failed,msg:enlist "Bad Request" from `.backend.jobs where processName=pName,status=`sent;
	.backend.sendResult[res;jobID];
 };

//////////////////////////////////////////////////////
//@Chat Functionality/////////////////////////////////
//////////////////////////////////////////////////////

//Table init
chat:flip `time`user`msg!"*S*"$\:();

//Upsert function
chatHistory:{[time;user;msg]
	`.backend.chat insert (enlist time;user;enlist msg);
	if[(count .backend.chat)>=30;.backend.chat:-30#.backend.chat]
 };

\d .

prepo:.z.po;
.z.po:{prepo[x];.backend.connect[x]};
prepc:.z.pc;
.z.pc:{prepc[x];.hb.findProcesses[]};

/ replay logic for connections and leaderBoard is needed

//generic upd
upd:{[tab;x] tab upsert x};

//cron jobs
.cron.addJob[`.backend.replayQueue;1%24*60*30;::;-0wz;0wz;1b];
.cron.switchJob[`.hb.findProcesses];
