//////////////////////////////////////////////////////////////////////////////////////////////////
//	Modify r.q template to accept tables for subscription										//
//	Input of table format must be string, this can be handled in the bash script that init this	//
//////////////////////////////////////////////////////////////////////////////////////////////////


if[not "w"=first string .z.o;system "sleep 1"];

/ load logging capability
system "l ",getenv[`SCRIPTS_DIR],"/log.q";
/ load permissioning capability
system "l ",getenv[`SCRIPTS_DIR],"/perm.q";

/ subscrption table for backend process
\d .backend

connections:([processName:`$()] handle:"J"$();status:`$());

connect:{[w] `.backend.connections upsert con:(w".log.processName";w;`free);.log.out "Connection established ",.Q.s1 con};

funQStory:();
\d .

.z.po:{.backend.connect[x]};
