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

schema:([colName:`testCase`answer] ty:("*";"*"));

testFunction:{[user;f;handle;jobID] if[not count .test.TestCase;'No test case];
	//given that func is "{x+1}"
	.log.out "Submission: ",.Q.s1(.z.u;f;handle);
	.test.func:value f;
	.log.out "Adapting Schema to testCase";
	testCase:@[{![.test.TestCase;();0b;x]};schemaCols!{($;first value schema x;x)}each schemaCols:(0!.test.schema)`colName;{.log.err "Fail to adapt schema", .Q.s[x];x}];
	//assumes function takes one arg/one dictionary
	//TO-DO Exception handling for @' since this can fail
	.log.out "Declared test function ",.Q.s .test.func;
	.log.out "Declared test args ",.Q.s .test.args:exec testCase from testCase;
	output:@[{.test.func @' x};.test.args;.test.logErrReset["Evaluation in output";handle;jobID]];
	.log.out "Output is: ",.Q.s1 output;
	if[0 = count output;:()];
	correct:output=testCase`answer;
	.log.out "Correct boolean is ",.Q.s1 correct;
	$[all correct;timeTaken:system "t:10000 .test.func@' .test.args";timeTaken:-1];
	.log.out "Time Taken: ",.Q.s1 timeTaken;
	neg[.test.backendHandle](`.backend.upd;`.backend.leaderBoard;`user`function`funcLength`overallSpeed!(user;f;count f;timeTaken));
	neg[.test.backendHandle]"update status:`free from `.backend.connections where handle=",string handle;
	neg[.test.backendHandle](`upd;`.backend.jobs;`jobID`status`msg!(jobID;`completed;.Q.s correct));
	//send output in a table to user so that he knows his result -TODO
	res:`testCase`answer`output`correct!(.test.args;testCase`answer;output;correct);
	.log.out "Compiled output for client ",.Q.s1 res;
	neg[.test.backendHandle](`.backend.sendResult;res;jobID);
	//sends reminder to gateway to refresh leadership board to all connections - TODO
 };

logErrReset:{[msg;handle;jobID;err] .log.err msg," --- due to: ",.Q.s[err];
	neg[.test.backendHandle]"update status:`free from `.backend.connections where handle=",string handle;
	neg[.test.backendHandle](`upd;`.backend.jobs;`jobID`status`msg!(jobID;`failed;.Q.s[err]));
	:()
 };

//To Add logging function in upd for system resilience
upd:{[t;x] t upsert x}

//if backendHandle = 0; try to reconnect on a timer


\d .

