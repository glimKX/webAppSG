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

funQStory:();

leaderBoard:`user xkey flip `rank`user`function`funcLength`overallSpeed!"JSCJZ"$\:();

uploadTestCase:{[tab;csvFile] .log.out "In .backend.uploadTestCase -- proceeding to upload test cases";
	h:exec handle from .backend.connections where processName like "*TEST*";
	neg[h]@\:(set;tab;csvFile);
 };


upd:{[tab;x] if[0>=x`timeTaken;tab upsert x]};

val:{.log.out "In .backend.val";
	h:exec first handle from .backend.connections where status=`free,processName like "*TEST*";
	.log.out "Pushing to handle ",.Q.s h;
	update status:`processing from `.backend.connections where handle=h;
	neg[h](`.test.testFunction;x;h);
	"Submitted test function please wait for results..."
 };

\d .

.z.po:{.backend.connect[x]};

/ replay logic for connections and leaderBoard is needed
