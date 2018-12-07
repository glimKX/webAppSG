//////////////////////////////////////////////////////////////////////////////////////////////////////////
//	 GATEWAY INIT SCRIPT 										//
//////////////////////////////////////////////////////////////////////////////////////////////////////////

if[not "w"=first string .z.o;system "sleep 1"];
//init with config port
/system "p ",getenv`GATEWAY_PORT;

/ load logging capability
system "l ",getenv[`SCRIPTS_DIR],"/log.q";

/ load permissioning capability
system "l ",getenv[`SCRIPTS_DIR],"/perm.q";

/define .z.ws for websocket
/TO-DO, put requests into a list so that gateway can be free while waiting for answer
/Async queries to wait for answer with callback to update answers
.z.ws:{.debug.x:x;x:@[{.j.k x};x;{x}x];
	$[99h=type x;
	[x[`func]:`$x[`func];neg[.z.w] .j.j @[{.log.out .Q.s1 x;x[`func] @ x[`args]};x;{.log.err .Q.s1[x],.Q.s1[y];`func`output!(`error;"failed to process ",x," due to ",y)}.Q.s1 x]];
	[neg[.z.w] .j.j {.log.out "Submission: ",.Q.s1 x;.gateway.newJob[x;.z.u;.z.w]}x]]}

/namespace for management/debugging
\d .gateway

/ open handle to backend
backEndHandle:hopen `$"::",getenv[`BACKEND_PORT],":",getenv[`ADMIN_USER],":",getenv[`ADMIN_PASS];

uploadCSV:{testCase:update "J"$id, "J"$iteration, "Z"$timer from x;`func`output!(`.gateway.uploadCSV;.gateway.backEndHandle(`.backend.uploadTestCase;`.test.TestCase;testCase))}

changeSchema:{.log.out "In .gateway.changeSchema -- Received new schema change request ",.Q.s1 x;
	colName:`$x`colName;
	ty:x`type;
	`func`output!(`.gateway.changeSchema;.gateway.backEndHandle(`.backend.changeTestCaseSchema;colName;ty))
 }

jobs:`jobID xkey flip `jobID`handle`status!"JJS"$\:();

//init running jobID with function to extract it
jobID:1;
getJobID:{jobID:.gateway.jobID;.gateway.jobID+:1;jobID};

newJob:{[func;user;handle]
	.debug.arg:`func`user`handle!(func;user;handle);
	.log.out "In .gateway.newJob -- Received new job " , .Q.s1 `jobID`func`handle!(jobID:.gateway.getJobID[];func;handle);
	`.gateway.jobs upsert `jobID`handle`status!(jobID;handle;`received);
	.log.out "Pushing to backend";
	@[.gateway.backEndHandle;(`.backend.val;func;user;handle;jobID);{.log.err .Q.s1[x],.Q.s1[y];`func`output!(`error;"failed to process ",x," due to ",y)}.Q.s1 (`.backend.val;func;user;handle;jobID)]
 };

queue:{[ID]
	.log.out "In .gateway.queue -- Received queue status for jobID " , .Q.s1 ID;
	h:neg first exec handle from .gateway.jobs where jobID=ID;
	.log.out "Sending to handle ",.Q.s[h]," that job is queuing for free process";
	h .j.j "Your job is currently queued, please remain connected to receive outcome";
 };
	

pushToKDB:{
	.log.out "Pushing to backend: ",.Q.s1 x;
	res:@[.gateway.backEndHandle;(set;`$x`holder;x`item);{.log.err "Unable to set ",.Q.s1[x], "due to ",.Q.s1[y];y}(set;`$x`holder;x`item)];
	`func`output!(`.gateway.pushToKDB;res)
 };

pullFromKDB:{
	.log.out "Pulling from backend: ",x;
	res:.gateway.backEndHandle x;
	if[x like ".backend.leaderBoard";refresh[];:"Refresh Applied"];
	`func`output`arg!(`.gateway.pullFromKDB;res;x)
 };

//init with global to prevent release of results
release:0b;

releaseNow:{.gateway.release:1b};

refresh:{
	.log.out "Entered Refresh to clients";
	h:select user,handle from .log.connections where host<>`localhost,connection =`opened;
	if[count[h] and .gateway.release;neg[h`handle]@\: .j.j `func`output`arg!(`.gateway.pullFromKDB;.gateway.backEndHandle ".backend.leaderBoard";".backend.leaderBoard");:""];
	workingLeaderBoard:.gateway.backEndHandle ".backend.leaderBoard";
	{[dict;workingLeaderBoard]
		res:update function:count[i]#enlist "Not Released Yet" from workingLeaderBoard where user<>dict`user;
		neg[dict`handle] .j.j `func`output`arg!(`.gateway.pullFromKDB;res;".backend.leaderBoard")
	}[;workingLeaderBoard] each h
 };

// function to send back result to client
sendResult:{[res;ID] .log.out "In .gateway.sendResult -- sending result back to client for jobID ",.Q.s[ID];
	.debug.jobID:ID;
	h:neg first exec handle from .gateway.jobs where jobID=ID;
	.log.out "Sending to handle ",.Q.s[h];
	h .j.j `func`output!(`.gateway.sendResult;res);
 };

//Chat Functionality
//Chat history retrieval on login
pullChat:{
	.log.out "In .gateway.pullChat -- Retrieving messages from .backend.chat...";
	res:.gateway.backEndHandle(`.backend.chat);
	img:`user xcol .gateway.backEndHandle(`.backend.imgTable);
	res:res lj img;
	.log.out "Retrieved messages. Sending to front end...";
	neg[.z.w] .j.j `func`output!(`.gateway.chatHistory;res);	
 };

//Backend message storage function
chatStore:{[msg]
        .log.out "In .gateway.chatStore -- Received chat message ", .Q.s1 `user`message!(.z.u;msg);
        .log.out "Sending message to .backend.chat";
	msgTime:string .z.Z;
	img:.gateway.backEndHandle"exec img from .backend.imgTable where username = `",string .z.u;
        neg[.gateway.backEndHandle](`.backend.chatHistory;msgTime;.z.u;msg);
	
	//Sending chat message to connected clients
	.log.out "Refreshing chat to connected clients";
	h:exec handle from .log.connections where host<>`localhost,connection=`opened;
	res:`user`msgTime`msg`img!(.z.u;msgTime;msg;img);
	if[count h;neg[h]@\: .j.j `func`output!(`.gateway.chatRefresh;res)];
 };

//getCountryOrigin API
getOrigin:{
	h:.z.w;
	//expect string ip
	ip:exec first ipAddress from .log.connections where handle = h, connection = `opened; 
	.log.out "In .gateway.getOrigin -- Received ip: ", ip;
	apiLink:(,/)("http://api.ipstack.com/";ip;"?access_key=449c6201e6517a4e1a3ebc448143d249");
	`func`output!(`.gateway.getOrigin;(.j.k .Q.hg hsym `$apiLink)`city)
 };

//store Image
storeImage:{
 	.log.out "In .gateway.storeImage -- Received args ", .Q.s1 x;
	.gateway.backEndHandle(`.backend.storeImage;x)
 };

//retrieve Image
retrieveImage:{
	.log.out "In .gateway.retrieveImage -- Received args ", .Q.s1 x;
	res:.gateway.backEndHandle"exec img from .backend.imgTable where username =`",x;
	if[count res;:`func`output!(`.gateway.retrieveImage;res)];
	"User does not have a profile picture in the backend"
 };

retrieveAllUsers:{
	res:.gateway.backEndHandle".backend.imgTable";
	if[count res;:`func`output!(`.gateway.retrieveAllUsers;res)];
	"No stored images in backend"
 };

\d .

/ force backend to open handle back at gateway
neg[.gateway.backEndHandle](`.backend.forceConnect;`);

