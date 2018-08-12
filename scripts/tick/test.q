//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Test.q template													//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/q tick/test.q [host]:port[:usr:pwd]  

if[not "w"=first string .z.o;system "sleep 1"];

/ load logging capability
system "l ",getenv[`SCRIPTS_DIR],"/log.q";

/test functions

\d .test

backendHandle:@[
	{h:hopen `$":",":" sv ("localhost";x;getenv[`ADMIN_USER];getenv[`ADMIN_PASS]);
		.log.out "Handle to backend established ",.Q.s h;
		h};
	getenv `BACKEND_PORT;
	{.log.err "Failed to establish handle to ",.Q.s (x;y);0}getenv`BACKEND_PORT
 ];


//if backendHandle = 0; try to reconnect on a timer

//test case ingestion


\d .

