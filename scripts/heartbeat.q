//////////////////////////////////////////////////////////////////////////////////////////////////
//	heartbeat.q script which loads up with all tick templates											//
//	q script will define functions for heartbeats						//
//////////////////////////////////////////////////////////////////////////////////////////////////

\d .hb

//heartbeat script requires .log and .cron
if[not min(count key @)each (`.cron;`.log);'"Either cron or log script is missing"];

/init heartbeat schema
heartbeats:1!flip `processName`port`handle`counter`sensitivity!"SJJJJ"$\:();

/define analytic to add heartbeats to monitor
addHB:{[processName;handle;sensitivity]
	.log.out "In .hb.addHB --- adding ",.Q.s1[processName]," to monitor heartbeat";
	//check if able to query process
	if[`noReply~port:@[{x(system;"p")};handle;{`noReply}];.log.err "Unable to obtain a reply from process ",.Q.s1[processName];'"Unable to add heartbeat monitoring due to no reply"];
	.log.out "Monitoring heartbeats of ",.Q.s1 (processName;port;handle;0;sensitivity);
	`.hb.heartbeats upsert `processName`port`handle`counter`sensitivity!(processName;port;handle;0;sensitivity);
	.log.out "Finished adding process to monitor for heartbeat";
 }

/define analytics to send message for heartbeats, increase counter by 1
sendHBRequest:{[h]
	.log.out "In .hb.sendHBRequest --- sending heartbeat request to handle ",.Q.s1[h];
	neg[h](`.hb.sendHBReply;`);
	update counter:counter+1 from `.hb.heartbeats where handle=h;
 }

/define analytics to reply heartbeat request
sendHBReply:{
	.log.out "In .hb.sendHBReply --- sending heartbeat reply to requestor ",.Q.s1[.z.w];
	neg[.z.w](`.hb.reply;.log.processName);
 }

/define analytic to reduce counter upon receiving reply
reply:{[pName]
	.log.out "In .hb.reply --- received reply from ",.Q.s1 pName;
	update counter:0 from `.hb.heartbeats where processName=pName;
 }

/define analytic to find processes to send heartbeats to
findProcesses:{
	.log.out "In .hb.findProcesses --- looking for proceses to send heartbeats";
	processes:exec handle from .hb.heartbeats where counter <=sensitivity;
	if[count processes;
		{@[.hb.sendHBRequest;
			x;
			{.log.err "Unable to send HBRequest initialising restart process ",.Q.s[y];
			.hb.restartProcess {key[x]!first each value x}exec processName,port from .hb.heartbeats where handle=x}x
			]
		}each processes
	];
	.log.out "In .hb.findProcesses --- checking for processes which have not returned heart beats";
	failures:select processName,port from .hb.heartbeats where counter>sensitivity;
	if[count failures;
		.hb.restartProcess each failures;
	];
	.log.out "In .hb.findProcesses --- completed";
 }

killProcess:{
	.log.out "In .hb.killProcess --- ",.Q.s1 x;
	@[system;"ps -ef | grep ",string[x `port]," | grep -v grep | awk '{print $2}' | xargs kill -9";{.log.err "Unable to kill process due to ",.Q.s[x]}];	 
 }

startProcess:{
	.log.out "In .hb.startProcess --- ",.Q.s1 x;
	//hardcoded mapping, need better way to store this information
	startConfig:`TEST`GATEWAY`BACKEND!(("tick/test.q";"-w 200");("tick/gateway.q";"");("tick/backend.q";""));
	if[x[`processName] like "TEST*";x[`processName]:`$4#string x`processName];
	{[port;script;args]
		//script:getenv[`SCRIPTS_DIR],script;
		port:"-p ",string port;
		nohupEnd:"> /dev/null 2>&1 &";
		nohupStart:"nohup";
		command:" " sv (nohupStart;getenv[`Q];script;args;port;nohupEnd);
		
		@[{system x;.log.out "Successfully started process"};command;{.log.err "Unable to start process due to ",.Q.s[x]}];
	}[x`port]. startConfig x`processName
 }


restartProcess:{
	.log.out "In .hb.restartProcess --- ",.Q.s1 x;
	killProcess x;
	startProcess x;
 }

\d .

.cron.addJob[`.hb.findProcesses;1%24*60;::;-0wz;0wz;0b];
