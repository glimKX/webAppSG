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

testFunction:{[f;handle] if[not count .test.TestCase;'No test case];
	//given that func is "{x+1}"
	.log.out "Submission: ",.Q.s1(.z.u;f;handle);
	.test.func:value f;
	//assumes function takes one arg/one dictionary
	//TO-DO Exception handling for @' since this can fail
	.log.out "Declared test function ",.Q.s .test.func;
	.log.out "Declared test args ",.Q.s .test.args:exec testCase from .test.TestCase;
	output:@[{.test.func @' x};.test.args;.test.logErrReset["Evaluation in output";handle]];
	.log.out "Output is: ",.Q.s1 output;
	if[0 = count output;:()];
	correct:output=.test.TestCase`answer;
	.log.out "Correct boolean is ",.Q.s1 correct;
	$[all correct;timeTaken:system "t:10000 .test.func@' .test.args";timeTaken:-1];
	.log.out "Time Taken: ",.Q.s1 timeTaken;
	neg[.test.backendHandle](`.backend.upd;`.backend.leaderBoard;`user`function`funcLength`overallSpeed!(.z.u;f;count f;timeTaken));
	neg[.test.backendHandle]"update status:`free from `.backend.connections where handle=",string handle;
 };

logErrReset:{.log.err x," --- due to: ",.Q.s[z];
	neg[.test.backendHandle]"update status:`free from `.backend.connections where handle=",string y;
	:()
 };

//if backendHandle = 0; try to reconnect on a timer


\d .

