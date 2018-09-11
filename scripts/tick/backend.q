//////////////////////////////////////////////////////////////////////////////////////////////////
//	Modify r.q template to accept tables for subscription										//
//	Input of table format must be string, this can be handled in the bash script that init this	//
//////////////////////////////////////////////////////////////////////////////////////////////////


if[not "w"=first string .z.o;system "sleep 1"];

/ load logging capability
system "l ",getenv[`SCRIPTS_DIR],"/log.q";

/ load permissioning capability
//system "l ",getenv[`SCRIPTS_DIR],"/perm.q";

/ subscrption table for backend process
\d .backend

connections:([processName:`$()] handle:"J"$();status:`$());

connect:{[w] `.backend.connections upsert con:(w".log.processName";w;`free);.log.out "Connection established ",.Q.s1 con};

forceConnect:{ .log.out "Force Connect to Gateway";
	@[{.backend.connect .backend.gatewayHandle:hopen `$x};":" sv (":localhost";getenv[`GATEWAY_PORT];getenv[`ADMIN_USER];getenv[`ADMIN_PASS]);{.log.err "Unable to open connnection to gatewayHandle ",.Q.s[x]}]};

funQStory:();

/table init
leaderBoard:`user xkey flip `rank`user`function`funcLength`overallSpeed!"JS*JJ"$\:();
jobs:`jobID xkey flip `jobID`user`handle`function`status`msg!"JSJ*S*"$\:();

uploadTestCase:{[tab;csvFile] .log.out "In .backend.uploadTestCase -- proceeding to upload test cases";
	h:exec handle from .backend.connections where processName like "*TEST*";
	neg[h]@\:(set;tab;csvFile);
 };

changeTestCaseSchema:{[column;ty] .log.out "In .backend.changeTestCaseSchema -- changing col: ",.Q.s[column]," schema: ",.Q.s[ty];
	h:exec handle from .backend.connections where processName like "*TEST*";
	neg[h]@\:({.log.out "Changing schema".Q.s1 x;.test.upd[`.test.schema;x]};`colName`ty!(column;first ty));
 };

upd:{[tab;x] if[0<=x`overallSpeed;tab upsert x]};

val:{[func;user;handle;jobID]
	.log.out "In .backend.val";
	h:exec first handle from .backend.connections where status=`free,processName like "*TEST*";
	.log.out "Pushing to handle ",.Q.s h;
	update status:`processing from `.backend.connections where handle=h;
	`.backend.jobs upsert `jobID`user`function`status`handle!(jobID;user;func;`sent;handle);
	.log.out "New Job received: ",.Q.s jobID;
	neg[h](`.test.testFunction;user;func;h;jobID);
	"Submitted test function please wait for results..."
 };

sendResult:{[res;jobID]
	.log.out "In .backend.sendResult ",.Q.s1 `res`jobID!(res;jobID);
	$[1=count res;res:enlist res;res:flip res];
	h:first exec handle from .backend.connections where processName like "GATEWAY";
	neg[h](`.gateway.sendResult;res;jobID);
 };

refresh:{
	.log.out "Forcing all connections to refresh leaderboard";
	neg[.backend.gatewayHandle](`.gateway.refresh;`);
 };

\d .

.z.po:{.backend.connect[x]};

/ replay logic for connections and leaderBoard is needed

//generic upd
upd:{[tab;x] tab upsert x};
