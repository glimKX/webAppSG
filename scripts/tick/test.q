/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Test.q template													//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/q tick/test.q [host]:port[:usr:pwd]  

if[not "w"=first string .z.o;system "sleep 1"];

/ load logging capability
system "l ",getenv[`SCRIPTS_DIR],"/log.q";

/ load cron as it is a dependency for heartbeat
system "l ",getenv[`SCRIPTS_DIR],"/cron.q";

/ load heartbeat script to reply
system "l ",getenv[`SCRIPTS_DIR],"/heartbeat.q";

/test functions

\d .test

logFile:hsym`$getenv[`TESTLOG_DIR],"/TEST";


/backendHandle:@[
/	{h:hopen `$":",":" sv ("localhost";x;getenv[`ADMIN_USER];getenv[`ADMIN_PASS]);
/		.log.out "Handle to backend established ",.Q.s h;
/		h};
/	getenv `BACKEND_PORT;
/	{.log.err "Failed to establish handle to ",.Q.s (x;y);0}getenv`BACKEND_PORT
/ ];

schema:([colName:`testCase`answer] ty:("*";"*"));

testFunction:{[user;f;handle;jobID] if[not count .test.TestCase;'No test case];
	//given that func is "{x+1}"
	.log.out "Submission: ",.Q.s1(.z.u;f;handle);
	.test.func:value f;
	.log.out "Adapting Schema to testCase";
	testCase:@[{![.test.TestCase;();0b;x]};schemaCols!{(each;value;x)}each schemaCols:(exec colName from .test.schema where ty<>"*");{.log.err "Fail to adapt schema", .Q.s[x];x}];
	//assumes function takes one arg/one dictionary
	//TO-DO Exception handling for @' since this can fail
	.log.out "Declared test function ",.Q.s .test.func;
	.log.out "Declared test args ",.Q.s .test.args:exec testCase from testCase;
	output:@[{.test.func @' x};.test.args;.test.logErrReset["Evaluation in output";handle;jobID]];
	.log.out "Output is: ",.Q.s1 output;
	if[0 = count output;:()];
	$[1<count first ans:testCase`answer;
		correct:.[{x~'y};(output;ans);.test.logErrReset["Comparison in output";handle;jobID]];	
		correct:.[{x=y};(output;ans);.test.logErrReset["Comparison in output";handle;jobID]]
	 ];
	//prevent string from crashing system needs long term fix might not be needed with booleanTrap below
	//if[0h=type output;correct:raze correct];
	//logic is needed here to allow string comparison
	//logic is needed to throw type error back at user
	.log.out "Correct boolean is ",.Q.s1 correct;
	if[0 = count correct;:()];
	c:@[{all x};correct;{.test.logErrReset["All Correct Error";x;y;z];:()}[handle;jobID]];
	if[-1h<>type c;.test.logErrReset["All Correct Error";handle;jobID;`booleanErr];'booleanErr];
	$[c;timeTaken:system "t:10000 .test.func@' .test.args";timeTaken:-1];
	.log.out "Time Taken: ",.Q.s1 timeTaken;
	neg[.test.backendHandle](`.backend.upd;`.backend.leaderBoard;`user`function`funcLength`overallSpeed!(user;f;count f;timeTaken));
	neg[.test.backendHandle]"update status:`free from `.backend.connections where handle=",string handle;
	neg[.test.backendHandle](`upd;`.backend.jobs;`jobID`status`msg!(jobID;`completed;.Q.s correct));
	res:`testCase`answer`output`correct!(.test.args;testCase`answer;output;correct);
	.log.out "Compiled output for client ",.Q.s1 res;
	neg[.test.backendHandle](`.backend.sendResult;res;jobID);
	//sends reminder to gateway to refresh leadership board to all connections
	neg[.test.backendHandle](`.backend.refresh;`);
 };

logErrReset:{[msg;handle;jobID;err] .log.err msg," --- due to: ",.Q.s[err];
	neg[.test.backendHandle]"update status:`free from `.backend.connections where handle=",string handle;
	neg[.test.backendHandle](`upd;`.backend.jobs;`jobID`status`msg!(jobID;`failed;.Q.s[err]));
	neg[.test.backendHandle](`.backend.sendResult;enlist[`error]!enlist .Q.s err;jobID);
	//send error back to user
	:()
 };

//To Add logging function in upd for system resilience
upd:{[t;x] t upsert x}

//if backendHandle = 0; try to reconnect on a timer

@[{-11!x};logFile;{.log.err "Unable to replay logfile ",.Q.s x}];

backendHandle:@[
	{h:hopen `$":",":" sv ("localhost";x;getenv[`ADMIN_USER];getenv[`ADMIN_PASS]);
		.log.out "Handle to backend established ",.Q.s h;
		h};
	getenv `BACKEND_PORT;
	{.log.err "Failed to establish handle to ",.Q.s (x;y);0}getenv`BACKEND_PORT
 ];

\d .

