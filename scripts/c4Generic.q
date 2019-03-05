//////////////////////////////////////////////////////////////////////////////////////////////////
//	c4Generic.q script which loads up with all c4 analytic cross templates			//
//	q script will define functions for backend and gateway					//
//////////////////////////////////////////////////////////////////////////////////////////////////

.log.out "Loading c4Generic analytics";
\d .c4
/Gateway Only

usrLeft:{[w]
	//takes handle which usr quit and send to c4 process to run leaveLobby
	usr:exec user from .log.connections where handle = w, connection=`opened;
	.log.out .Q.s[usr]," has left the C4 application";
	runCommand["C4*";(`.c4.leaveLobby;first usr)]
 };

runCommand:{[proc;args] 
	//generic function to run all c4 command through this function.
	.log.out "Running C4 Command --- ",.Q.s1 `proc`args!(proc;args);
	sendTo:.gateway.backEndHandle"first exec handle from .backend.connections where processName like \"",proc,"\"";
	neg[.gateway.backEndHandle](sendTo;args);
 };

callTab:{[lby]
	usr:exec user from .log.connections where handle = .z.w, connection=`opened;
        .log.out .Q.s[usr]," has attempt to join C4 game in lobby ",.Q.s[lby];
        runCommand["C4*";(`.c4.callTab;usr;"J"$lby)]
 };

joinLobby:{[lby]
	//build instructions before sending to run internally
	usr:exec user from .log.connections where handle = .z.w, connection=`opened;
	.log.out .Q.s[usr]," has attempt to join C4 game in lobby ",.Q.s[lby];
	runCommand["C4*";(`.c4.joinLobby;first each `user`lobby!(usr;"J"$lby))]
 };

leaveLobby:{[lby]
	//similar to joinLobby
	usr:exec user from .log.connections where handle = .z.w, connection=`opened;
	.log.out .Q.s[usr]," left C4 game lobby ",.Q.s[lby];
	runCommand["C4*";(`.c4.leaveLobby;first usr)]
 };

runJob:{[x]
	.debug.x:x;
	lby:x[`lobby];
	arg:x[`arg];
	usr:exec user from .log.connections where handle = .z.w, connection=`opened;
	.log.out .Q.s[usr]," sent instruction to run job at ",.Q.s[x];
	runCommand["C4*";(`.c4.runJob;arg;"J"$lby;usr)];
 };

retreiveMusic:{
        res:read0 `:/home/webapp/webAppSG/html/qPortal/audio/battle.txt;
	.log.out "Sending battle music to handles ",.Q.s usrHandles;
        usrHandles@\:.j.j `func`output!(`.c4.retreiveMusic;res);
 };

gatewaySendGrid:{[grid;usr]
	usrHandles:neg exec handle from .log.connections where user in usr,connection = `opened;
	.log.out "Sending grid to handles ",.Q.s usrHandles;
	usrHandles@\:.j.j `func`output!(`.c4.gatewaySendGrid;grid)
 };

gatewayMessage:{[msg;usr]
	usrHandles:neg exec handle from .log.connections where user in usr,connection = `opened;
	.log.out "Sending messages to handles ",.Q.s usrHandles;
	usrHandles@\:.j.j `func`output!(`.c4.gatewayMessage;msg)
 };

/Backend Only
backendSendGrid:{[grid;usr]
	.log.out "Sending grid to ",.Q.s1 usr;
	neg[.backend.gatewayHandle](`.c4.gatewaySendGrid;grid;usr);
 };

backendMessage:{[msg;usr]
	.log.out "Sending Message to ",.Q.s1 usr;
	neg[.backend.gatewayHandle](`.c4.gatewayMessage;msg;usr);
 };

\d .

if[.log.processName = `GATEWAY;
	.log.out "Redefining websocket close function";
	.c4.wc:.z.wc;
	.z.wc:{[w] .c4.usrLeft[w];.c4.wc[w]};];
.log.out "Finishing loading c4Generic analytics";
