//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//      c4.q template                                                                                                   //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/ load logging capability
system "l ",getenv[`SCRIPTS_DIR],"/log.q";

/ load cron as it is a dependency for heartbeat
system "l ",getenv[`SCRIPTS_DIR],"/cron.q";


\d .c4 

//Table initialisation
tab:1!flip `user`player`lobby`lastQuery`turn`started`yourSym!"SJJ*BB*"$\:();

//TODO - Variable grid depending on user choice
//Wrapper to reinitialise the grid
createGrid:{((19#.Q.A)," "),'flip (20 19#0),'1+til 20};

//lobby Logic
grid:()!();

//bolding @hm
// .j.j enlist[`grid]!enlist .[string grid;((::;0);(19;::));{"<b>",x,"</b>"}]
// .[string grid;(::;0);{"<b>",x,"</b>"}]

//////
//functions that client will call to server, assumes all function just sends back raw msg {neg[.z.w] .Q.s x} 
//showTab:{tab;}
//showGrid:{neg[.z.w] wrapGrid`;}
//run:{runJob {(first x;"J"$1_ x)}x}
//////


//wrapperLogic to bring grid to front end
wrapGrid:{[lby] .j.j enlist[`grid]!enlist ./[string grid[lby];((::;0);(19;::));{"<b>",x,"</b>"}]};

//Message Dictionary Init
msgDict:()!();

msgDict[`welcome]:{[usr] "Welcome to CONNECT 4, You have Joined Lobby ",(string exec lobby from tab where user=usr),"\n\nYou are Player", string exec player from tab where user=usr};
msgDict[`waiting]:"Currently waiting for another player to join";
msgDict[`spectate]:{[usr] (raze/) "Welcome to CONNECT 4, You have Joined Lobby",(string exec lobby from tab where user=usr), "\n\nYou are in spectate mode"};
///Validation Messages///
msgDict[`tryAgain]:"Invalid Input, Please try again";
msgDict[`invalidMove]:"Invalid Move, bottom row not filled";
msgDict[`positionUsed]:"Position is already used, Please try again";
msgDict[`playersTurn]:{raze ("\n\n"; raze "It is now Player ",(string exec user from tab where lobby=x,turn=1),"'s turn to move")};
msgDict[`wrongTurn]:"Not your turn";
msgDict[`endGame]:"Game has ended, please enter Y if you would like to restart";
msgDict[`gamePlayer1]:{raze("Welcome to CONNECT 4, You are Player 1"; "\n\n"; "There are 2 players, the game will now commence"; "\n\n"; "Instructions"; "\n\n"; "To begin, enter your coordinates"; " starting with your alphabet, followed by your number Eg S11"; "\n\n";raze "User ",(string exec user from tab where lobby=x,player=1), " has been randomly chosen to start first")};
msgDict[`gamePlayer2]:{raze("Welcome to CONNECT 4, You are Player 2"; "\n\n"; "There are 2 players, the game will now commence"; "\n\n"; "Instructions"; "\n\n"; "To begin, enter your coordinates"; " starting with your alphabet, followed by your number Eg S11"; "\n\n";raze "User ",(string exec user from tab where lobby=x,player=1), " has been randomly chosen to start first")};
msgDict[`newGameCreated]:{raze raze ("A new game is created!"; "\n\n"; "User ",(string exec user from tab where lobby=x,player=1), " has been randomly selected to start first!")};
msgDict[`gameOver]:{raze raze("Game Over! User ",string x, " has won! Would you like to restart? Y/N")};
msgDict[`sameLobby]:{(raze/)("The game has already started";"\n\n";raze "User ",(string exec user from tab where lobby=x,player=1), "turn!")};
msgDict[`playerQuit]:{(raze/)("User ",string x," has quit";"\n\n";"The game has reset now";"\n\n";"Please rejoin the channel to start a new game")};

//Game initialisation logic
//Runs function when new upsert to .c4.tab, this will trigger a check to see if game can be started
joinLobby:{.debug.x:x;
	`.c4.tab upsert x;
	update started:(exec any started from .c4.tab where lobby=x[`lobby]) from `.c4.tab;
	$[2=lobCount:exec count i from tab where lobby=x[`lobby],not started;
		//start the lobby game
		startGame x[`lobby];
		1=lobCount;
			sendMessage[msgDict[`waiting];x[`user]];
			x[`user] in exec user from tab where lobby=x[`lobby],null player;
				[sendMessage[msgDict[`spectate]x[`user];x`user];sendGrid[wrapGrid[x`lobby];x`user]];
				sendMessage[msgDict[`sameLobby] x[`lobby];x[`user]]
	]
 }

//Requires a leave lobby logic such that if a player leaves half way, the game ends and he is removed from tab
leaveLobby:{[usr]
	//just need to know that user left
	args:exec from tab where user=usr;
	lobbyStatus:select from tab where lobby=args[`lobby];
	//TODO to include a functionality for spectator to takeover
	
	//for now send message to everyone that game ended if user is the one playing
	if[any (exec player from lobbyStatus where user=usr) in (1 2);	
		sendMessage[msgDict[`playerQuit] usr;exec user from lobbyStatus];
		delete from `.c4.tab where lobby=args[`lobby]
	];
	delete from `.c4.tab where user = usr;
 }

//Take string message and list of users to send and passing it to gateway to return to clients
sendMessage:{[msg;usr] neg[backendHandle](`.c4.backendMessage;msg;usr)}

//Takes Grid string and list of users to send and passing it to gateway to return to clients
sendGrid:{[grid;usr] neg[backendHandle](`.c4.backendSendGrid;grid;usr)}

//Take last clicked and send to users to highlight it
sendLastClicked:{[coord;usr] neg[backendHandle](`.c4.backendLastClicked;coord;usr)}

//Call tab from user
callTab:{[usr;lby] msg:.Q.s select user, player, lobby, lastQuery from tab where lobby=lby;
	sendMessage[msg;usr];
 }

//LeaderBoard Logic
/table init
leaderBoard:`user xkey flip `ranking`user`wins`loss`winRate!"JSJJF"$\:();
//instead of checking if new user, to init the table with all users and zeroize everything from user database, this is the long term solution 
//TO-DO
updLdr:{[usr;win] 
	//sometimes usr is enlisted
	usr:first usr;
	usrWinInfo:exec from leaderBoard where user=usr;
	if[newUser:usrWinInfo[`user]=`;`.c4.leaderBoard upsert `wins`loss`winRate`user!(`long$win;`long$not win;(`long$win)%1;usr)];
	if[not newUser;
		$[win;
			update wins:1+wins, winRate:(usrWinInfo[`wins]+1)%@[+/;1,usrWinInfo`wins`loss] from `.c4.leaderBoard where user=usr;
			update loss:1+loss, winRate:(usrWinInfo[`wins])%@[+/;1,usrWinInfo`wins`loss] from `.c4.leaderBoard where user=usr
		];
	];
	update ranking:(1+i) from `wins`winRate xdesc `.c4.leaderBoard;
 }

sendLeaderBoard:{neg[backendHandle] (`.c4.backendSendLeaderBoard;leaderBoard;exec user from tab)}

//cron function to take snapshot of leaderBoard
snapshot:{.log.out "Performing snapshot of leaderBoard";
	(hsym `$getenv `C4_LEADERBOARD) set .c4.leaderBoard;
	.log.out "Finished snapshot of leaderBoard"}

//Every time a player joins a lobby, this will be ran
startGame:{[lby] 
		update player:(1 2), lastQuery:(::),turn:0b,started:1b,yourSym:"#%" from `.c4.tab where lobby=lby;
            	update turn:-2?10b from `.c4.tab where lobby=lby;
		//creates a new grid for the lobby;
		grid[lby]:createGrid`;
		//player1 message
		sendMessage[msgDict[`gamePlayer1] lby;exec user from tab where lobby=lby,player=1];
		//player2 message
		sendMessage[msgDict[`gamePlayer2] lby;exec user from tab where lobby=lby,player=2];
		//sendGrid to start Game
		sendGrid[wrapGrid[lby];exec user from tab where lobby=lby];
 }   

//due to multiple lobby logic, and username tagging, runJob needs a couple of args
runJob:{[x;lby;usr] 
		x:(first x;"J"$1 _ x);
		$[(all 1=exec turn from tab where lobby=lby) & not "Y"=first[x];
			[
			sendGrid[wrapGrid lby;usr];
			:sendMessage[msgDict[`endGame];usr];
			];
	
		(all 1=exec turn from tab) & "Y"=first[x];
			[
			grid[lby]:createGrid`;
			update turn:-2?10b from `.c4.tab where lobby=lby, (player=1) or player=2;
			sendMessage[msgDict[`newGameCreated] lby;users:exec user from tab where lobby=lby];
			:sendGrid[wrapGrid lby;users];
			];
		];
		//usr is enlisted and this will error out in validation analytics
		.[`.c4.validation;(x;lby;first usr)]
 }
			
validation:{[x;lby;usr] .log.out "Running .c4.validation";
			.debug.x:`x`lby`usr!(x;lby;usr);
			users:exec user from tab where lobby=lby;
			$[first exec turn from tab where user=usr;
            [
			sendGrid[wrapGrid lby;usr];
           		if[(not x[0] in 19#.Q.A) or not x[1] in 1+til[20];
                		:sendMessage[msgDict[`tryAgain];usr]
              		];
              
            		if["S" <> x 0;
                		if[0 in grid[lby] . (1 + where x[0] in/:grid[lby]), x 1;
				   :sendMessage[msgDict[`invalidMove];usr]
                   		];
              		];
            
            		if[not 0 in grid[lby] . (where x[0] in/:grid[lby]), x 1;
				:sendMessage[msgDict[`positionUsed];usr]
              		];
			  
            		grid[lby]:.[grid[lby]; (where x[0] in/:grid[lby]), x 1;: ;first exec yourSym from tab where user=usr];
			if[.[`.c4.valCheck;(x;lby)];
				.log.out "Validation Check identified that the game has ended";
				winner:exec user from tab where lobby=lby, turn=1;
				loser:exec user from tab where lobby=lby, turn=0, not null player;
				updLdr[winner;1b];
				updLdr[loser;0b];
				update turn:1b from `.c4.tab where lobby=lby;
				sendGrid[wrapGrid lby;users];
				sendLeaderBoard[];
				sendMessage[msgDict[`gameOver] winner;users];
				:sendLastClicked[x;users];
				];
            		update lastQuery:enlist[x] from `.c4.tab where user=usr;
			update not turn from `.c4.tab where not null player, lobby=lby;
	 	        sendMessage[msgDict[`playersTurn] lby;users];
			sendGrid[wrapGrid lby;users];
			sendLastClicked[x;users];
            ];

            :sendMessage[msgDict[`wrongTurn];usr]
        ]}

//Square created of selected points, 0-8 where 4 will be point selected
// 0 1 2 
// 3 4 5
// 6 7 8

//Square check//
valCheck:{[x;lby] .log.out "Running .c4.valCheck";
		.debug.valCheck:`x`lby!(x;lby);
		coord: raze (where x[0] in/:grid[lby]; x 1);
		sq: {raze first[x] ,/:\: last[x]} {flip (x-1; x; x+1)} coord;
		sym:string exec yourSym from tab where lobby=lby, turn=1;
		ind: where (raze/) sym in/: string grid[lby] ./:sq;
		
		.log.out "Checking Coordinates";
		yAxisUp:$[0 < coord 0; 1b; 0b];
		yAxis2Up:$[1 < coord 0; 1b; 0b];
		yAxisDown:$[18 > coord 0; 1b; 0b];
		yAxis2Down:$[17 > coord 0; 1b; 0b];
		xAxisLeft:$[1 < coord 1; 1b; 0b];
		xAxis2Left:$[2 < coord 1; 1b; 0b];
		xAxisRight:$[20 > coord 1; 1b; 0b];
		xAxis2Right:$[19 > coord 1; 1b; 0b];
		
		// Validation checks based on where index are same as 4 (selected point)
		if[(0 in ind) & not 8 in ind;
			if[yAxis2Up & xAxis2Left;
				if[all (raze/) sym in/: string grid[lby] ./: {(-3+x; -2+x)} coord;
					:1b]]];

		if[all 0 8 in ind;
			if[(yAxisUp & xAxisLeft) or (yAxisDown & xAxisRight);
				if[any (raze/) sym in/: string grid[lby] ./: {(-2+x;2+x)} coord;
					:1b]]];

		if[(8 in ind) & not 0 in ind;
			if[yAxis2Down & xAxis2Right;
				if[all (raze/) sym in/: string grid[lby] ./: {(2+x;3+x)} coord;
					:1b]]];
	
		if[(1 in ind) & not 7 in ind;
			if[yAxisUp & yAxis2Up;
				if[all (raze/) sym in/: string grid[lby] ./: @\[coord; 0; -; 2 1];
					:1b]]];

		if[all 1 7 in ind;
			if[yAxisUp or yAxisDown;
				if[any (raze/) sym in/: string grid[lby] ./: @\[coord; 0; -; 2 -4];
					:1b]]];
			
		if[(7 in ind) & not 1 in ind;
			if[yAxisDown & yAxis2Down;
				if[all (raze/) sym in/: string grid[lby] ./: @\[coord; 0; +; 2 1];
					:1b]]];
			
		if[(2 in ind) & not 6 in ind;
			if[yAxis2Up & xAxis2Right;
				if[all (raze/) sym in/: string grid[lby] ./: 2_{(-1+x 0; 1+x 1)}\[3;coord];
					:1b]]];
			
		if[all 2 6 in ind;
			if[(yAxisUp & xAxisRight) or (yAxisDown & xAxisLeft);
				if[any (raze/) sym in/: string grid[lby] ./: {x[;0],'reverse x[;1]} ({(x-2; x+2)}coord);
					:1b]]];
			
		if[(6 in ind) & not 2 in ind;
			if[yAxis2Down & xAxis2Left;
				if[all (raze/) sym in/: string grid[lby] ./: 2_{(1+x 0; -1+x 1)}\[3;coord];
					:1b]]];
			
		if[(3 in ind) & not 5 in ind;
			if[xAxisLeft & xAxis2Left;
				if[all (raze/) sym in/: string grid[lby] ./: @\[coord; 1; -; 2 1];
					:1b]]];
			
		if[all 3 5 in ind;
			if[xAxisLeft or xAxisRight;
				if[any (raze/) sym in/: string grid[lby] ./: @\[coord; 1; -; 2 -4];
					:1b]]];
			
		if[(5 in ind) & not 3 in ind;
			if[xAxisRight & xAxis2Right;
				if[all (raze/) sym in/: string grid[lby] ./: @\[coord; 1; +; 2 1];
					:1b]]];
					
		:0b

		};
		

backendHandle:@[
        {h:hopen `$":",":" sv ("localhost";x;getenv[`ADMIN_USER];getenv[`ADMIN_PASS]);
                .log.out "Handle to backend established ",.Q.s h;
                h};
        getenv `BACKEND_PORT;
        {.log.err "Failed to establish handle to ",.Q.s (x;y);0}getenv`BACKEND_PORT
 ];		
	
\d .

//init and check for snapshots
if[not ()~ key hsym `$getenv `C4_LEADERBOARD;
	.log.out "LeaderBoard Snapshot found, recalling on disk leaderBoard";
	.c4.leaderBoard:get hsym `$getenv `C4_LEADERBOARD];

//cron jobs
.cron.addJob[`.c4.snapshot;1%24;::;-0wz;0wz;1b];
