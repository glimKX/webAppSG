
//load generic scripts

/ load logging capability
system "l ",getenv[`SCRIPTS_DIR],"/log.q";

/ load cron as it is a dependency for heartbeat
system "l ",getenv[`SCRIPTS_DIR],"/cron.q";


//////////////////////////////////
////   Client Play Function   ////
/////////////////////////////////

playHand:{[cards;usr] 
	$[.backend.checkTurn[];.backend.turnMsg[usr];
	//First hand validations
		0=count .backend.turnTable;
			$[.backend.check3D[cards];.backend.firstHand3DMsg[usr];
			.backend.checkPass[cards];.backend.firstPassMsg[usr];
			.backend.passInHand[cards];.backend.passInHandMsg[usr];
			.backend.checkInHand[cards];.backend.notInHandMsg[usr];
			.backend.roundPlay[cards];.backend.invalidRoundMsg[usr];
			//Play first hand after passing validations
				[.backend.broadcastPlay[cards];
				.backend.turnTableUpdate[a;cards;(.backend.rankCalc a:.backend.roundDict?count .backend.cardDeck?cards)[cards]];
				.backend.removeCard[cards];
				.backend.broadcastCardNo'[exec user from .backend.connections;count each .backend.hand];
				.backend.sendHand[];
				.backend.nextTurn[]
				]
			];	
		
		//Round hand validations - Run if not first hand
		0<sum -3#exec rankVal from .backend.turnTable;
			//Check if the card is a pass
			$[(1=count .backend.cardDeck?cards)&(max 0=.backend.cardDeck?cards);
				//Playing a pass
				[.backend.broadcastPlay[cards];
				.backend.turnTableUpdate[first -1#exec round from .backend.turnTable;cards;0];
				.backend.broadcastCardNo'[exec user from .backend.connections;count each .backend.hand];
				.backend.sendHand[];
				.backend.nextTurn[]
				];
				//Validations if it's a normal hand
				$[.backend.passInHand[cards];.backend.passInHandMsg[usr];
					.backend.checkInHand[cards];.backend.notInHandMsg[usr];
					.backend.roundPlay[cards];.backend.invalidRoundMsg[usr];
					(.backend.rankValCheck .backend.roundDict?count .backend.cardDeck?cards)[cards];.backend.invalidRankValMsg[];
				//Play hand after passing validations
					[.backend.broadcastPlay[cards];
					.backend.turnTableUpdate[a;cards;(.backend.rankCalc a:.backend.roundDict?count .backend.cardDeck?cards)[cards]];
					.backend.removeCard[cards];
					$[.backend.endGame[];
						.backend.sendMessage[string first exec user from .backend.connections where i=(first where 0=count each .backend.hand)," is the winner!";exec user from .backend.connections];
						[.backend.broadcastCardNo'[exec user from .backend.connections;count each .backend.hand];
						.backend.sendHand[];
						.backend.nextTurn[]
						]
					]
					]
				]
			];	

		//New round validations - run if not new hand and if 3 passes were played
		$[.backend.passInHand[cards];.backend.passInHandMsg[usr];
			.backend.checkInHand[cards];.backend.notInHandMsg[usr];
			.backend.roundPlay[cards];.backend.invalidRoundMsg[usr];
			//Play new round after passing validations
			[.backend.broadcastPlay[cards];
			.backend.turnTableUpdate[a;cards;(.backend.rankCalc a:.backend.roundDict?count .backend.cardDeck?cards)[cards]];
			.backend.removeCard[cards];
			$[.backend.endGame[];
				.backend.sendMessage[string first exec user from .backend.connections where i=(first where 0=count each .backend.hand)," is the winner!";exec user from .backend.connections];
				[.backend.broadcastCardNo'[exec user from .backend.connections;count each .backend.hand];
				.backend.sendHand[];
				.backend.nextTurn[]
				]
			]
			]
		]
	]};

\d .backend

//////////////////////////////
//// Comms functions	//////
//////////////////////////////

sendMessage:{[msg;usr] neg[backendHandle](`.daidi.backendMessage;msg;usr)}

backendHandle:@[
        {h:hopen `$":",":" sv ("localhost";x;getenv[`ADMIN_USER];getenv[`ADMIN_PASS]);
                .log.out "Handle to backend established ",.Q.s h;
                h};
        getenv `BACKEND_PORT;
        {.log.err "Failed to establish handle to ",.Q.s (x;y);0}getenv`BACKEND_PORT
 ];

//////////////////////////////
////   Connection logic   ////
/////////////////////////////

connections:flip `user`turn!"SB"$\:();

join:{[usr] $[4>=usrCount:1+exec count i from connections;
	[`.backend.connections insert usr,0b;
	.log.out"Connection Established by ",string usr];
	sendMessage["Lobby is full";usr]];
	
	if[1=usrCount:count connections;
        sendMessage["Please wait for 3 more players to connect before the game commences";usr]];
        
    if[(4>usrCount)&1<usrCount;
	sendMessage["Player ",(string count connections)," connection";exec user from connection where user not in usr];
        $[1=waitingFor:4-usrCount;
            neg[key .z.W]@\:(0N!;raze"Please wait for ",(string waitingFor)," more player to connect before the game commences");
            neg[key .z.W]@\:(0N!;raze"Please wait for ",(string waitingFor)," more players to connect before the game commences")];
        ]
    
    if[4=usrCount;
        sendMessage["All players have connected, the game is commencing...";exec user from connection];
	deal[];
	startTurn[];
        ]
    };
	
leave:{[usr] delete from `.backend.connections where user = usr;.log.out(string usr)," has left the Lobby"};

//***   Start game functions   ***//
cardDeck:til[53]!(enlist"pass"),((string 3+til[8]),enlist each"JQKA2")cross"DCHS";

shuffle:{system"S ",string`long$.z.t;
	flip(0N;4)#1+0N?52
	};

deal:{h::exec usr from connections;
	sendMessage .'[.backend.cardDeck hand::asc each shuffle[];h];
	.backend.turnTableInit[]
	};

startTurn:{update turn:max each 1=hand from `.backend.connections;
	sendMessage["Its your turn";first exec user from connections where turn=1b]
	};

//Turn table - reinitialised every game and updated when a valid hand is played
turnTableInit:{turnTable::flip `player`round`play`rankVal!"SS*J"$\:()};
hand:0;

////////////////////
////  Ranking   ////
///////////////////

//***   Card ranking   ***//
suitRank:til[4]!"DCHS";
valueRank:til[13]!(string 3+til[8]),enlist each"JQKA2";
fiveCardRank:(53*1+til[6])!`straight`flush`fullHouse`quads`straightFlush`royalFlush;

//***   Rank calculation   ***//
/Calculating the value of the played hand
singleCalc:{[cards] .backend.cardDeck?cards};
doublesCalc:{[cards] sum(.backend.cardDeck?cards),.backend.suitRank?last each cards};
fiveCardCalc:{[cards] if[any raze(`fullHouse;`quads)=\:(value .backend.fiveCardRank)where .backend.fiveCardVal;
	cards:cards where a=(distinct a)[$[any(3 4)=\:sum(first distinct a)=a:raze -1_'cards;0;1]]
	];
	(max .backend.cardDeck?cards)*last(key .backend.fiveCardRank)where .backend.fiveCardVal
	};

rankCalc:`single`double`fiveCard!(.backend.singleCalc;.backend.doublesCalc;.backend.fiveCardCalc);

/////////////////////////
////   Validations  /////
////////////////////////

//***   General validation   ***//
checkTurn:{[usr] not first 1=exec turn from connections where user=usr};
checkInHand:{[cards;usr] not min(.backend.cardDeck?cards)in .backend.hand[first exec i from connections where user=usr]};
passInHand:{[cards] (1<count cards)&(any 0=.backend.cardDeck?cards)};

//***   First hand validation   ***//
check3D:{[cards] not max 1=.backend.cardDeck?cards};
checkPass:{[cards] (52=count raze .backend.hand)&(any 0=.backend.cardDeck?cards)};

//***   Round type validations   ***//
singlePlay:{1b};
doublesPlay:{[cards] min(a 0)=a:.backend.valueRank?-1_'cards};
/Global fiveCardVal is used in .backend.rankVal calculations
fiveCardPlay:{[cards] max fiveCardVal::(.backend.straightCheck;
		.backend.flushCheck;
		.backend.fullHouseCheck;
		.backend.quadsCheck;
		.backend.straightFlushCheck;
		.backend.royalCheck)@\:cards
		};

roundDict:`single`double`fiveCard!1 2 5;
roundCheck:`single`double`fiveCard!(.backend.singlePlay;.backend.doublesPlay;.backend.fiveCardPlay);

roundPlay:{[cards] $[(0=count .backend.turnTable)|0=sum -3#exec rankVal from .backend.turnTable;
	$[(a:count .backend.cardDeck?cards) in value .backend.roundDict;
		not(.backend.roundCheck .backend.roundDict?count .backend.cardDeck?cards)[cards];
		1b]; 
	$[(count .backend.cardDeck?cards)=.backend.roundDict a:first -1#exec round from .backend.turnTable;
		not(.backend.roundCheck a)[cards];
		1b]
	]
	};

//***   Five card validations   ***//
straightCheck:{[cards] min 1=1_deltas .backend.valueRank?-1_'cards};
flushCheck:{[cards] min(first a)=a:last each cards};
straightFlushCheck:{[cards] .backend.straightCheck[cards]&.backend.flushCheck[cards]};
royalCheck:{[cards] .backend.straightCheck[cards]&.backend.flushCheck[cards]&50=sum .backend.valueRank?-1_'cards};
fullHouseCheck:{[cards] $[2=count distinct a:.backend.valueRank?-1_'cards;
	any(min=[(sum=[a]@)each distinct a]@)each(3 2;2 3);
	0b
	]
	};
quadsCheck:{[cards] $[2=count distinct a:.backend.valueRank?-1_'cards;
	any(min=[(sum=[a]@)each distinct a]@)each(4 1;1 4);
	0b
	]
	};

//***  Value validation   ***// 
/Ensure that played card value is greater than the previous play
singleRankCheck:{[cards] .backend.singleCalc[cards]<last exec rankVal from .backend.turnTable where rankVal>0};
doublesRankCheck:{[cards] .backend.doublesCalc[cards]<last exec rankVal from .backend.turnTable where rankVal>0};
fiveCardRankCheck:{[cards] .backend.fiveCardCalc[cards]<last exec rankVal from .backend.turnTable where rankVal>0};

rankValCheck:`single`double`fiveCard!(.backend.singleRankCheck;.backend.doublesRankCheck;.backend.fiveCardRankCheck);

//////////////////////////////
///   Validation Messages  ///
/////////////////////////////

invalidNumberMsg:{[usr] sendMessage["Invalid number of cards!";usr]};
turnMsg:{[usr] sendMessage["It is not your turn!";usr]};
notInHandMsg:{[usr] sendMessage["Invalid cards!";usr]};
firstPassMsg:{[usr] sendMessage["You cannot pass this turn!";usr]};
passInHandMsg:{[usr] sendMessage["Pass can only be played by itself!";usr]};
firstHand3DMsg:{[usr]sendMessage["First hand needs to have 3D!";usr]};
invalidDoublesMsg:{[usr] sendMessage["Invalid doubles pair!";usr]};
invalidFiveCardMsg:{[usr] sendMessage["Invalid 5 card combo!";usr]};
invalidRoundMsg:{[usr] sendMessage["Invalid play! The current round type is ",string first -1#exec round from .backend.turnTable;usr]};
invalidRankValMsg:{[usr] sendMessage["Hand value is lower than previously played hand!";usr]};

/////////////////////////////////////
////   Post-validation actions   ////
////////////////////////////////////

broadcastPlay:{[cards;usr] sendMessage[raze(string usr)," played ",cards;exec user from connections]};
turnTableUpdate:{[round;cards;rankVal;usr] `.backend.turnTable upsert (usr;round;enlist cards;rankVal)};
//***NOTE: Only run next turn after running remove card function***//
removeCard:{[cards] 
	@[`.backend.hand;
	a;
	{_/[x;y]};
	raze desc(where=[.backend.hand a:first exec i from .backend.connections where turn=1]@)each .backend.cardDeck?cards
	]};
broadcastCardNo:{sendMessage[raze (string x)," has ",(string y)," cards left!";exec user from connection]};
nextTurn:{update turn:-1 rotate turn from `.backend.connections;
	sendMessage[raze"It is ",string .z.u,"'s turn";exec usr from connection where turn=0];
	sendMessage["It is your turn";first exec usr from connection where turn=1];
	if[0=sum -3#exec rankVal from .backend.turnTable;
		sendMessage["3 players played pass. You can start a new round!";first exec usr from connections where turn=1]]
		};
sendHand:{sendMessage .'[.backend.cardDeck hand;exec usr from connections]};
endGame:{any 0=count each .backend.hand};

\d .
