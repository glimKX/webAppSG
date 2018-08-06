//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Modify r.q template to become a cep template																		//
//	Input specialFunction such that it is load a particular cep, this can be handled in the bash script that init this	//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/q tick/cep.q [host]:port[:usr:pwd] [host]:port[:usr:pwd] -func specialFunction 

if[not "w"=first string .z.o;system "sleep 1"];


/ get the ticker plant ports, defaults are 5010
.u.x:.z.x,(count .z.x)_enlist ":5010";

if[not count .Q.opt[.u.x]`func;
	-2"ERROR: CEP cannot initalise due to missing func";
	exit 1
 ];

/ tables to subscribe to and defining AggregFunction
if["vwap" in .Q.opt[.u.x]`func;
	.u.tSub:"`trade`quote";
	cep:{if[0=type x;
		x:x 1;
 		aggreg:(select maxPrice:max price,minPrice:min price,tradedVol:sum size by sym from trade where sym in x) lj select maxBid:max bidPrice,minAsk:min askPrice by sym from quote where sym in x;
		:(`aggreg;value flip 0!aggreg)
		] 	
	}
 ];	
 
/example of how we can customise this template such that the func will initialise a different cep
if["aggregration" in .Q.opt[.u.x]`func;
	.u.tSub:"`trade`quote";
	cep:{$[0=type x;
		x:x 1;
		x:distinct x `sym];
 		aggreg:(select maxPrice:max price,minPrice:min price,tradedVol:sum size by sym from trade where sym in x) lj select maxBid:max bidPrice,minAsk:min askPrice by sym from quote where sym in x;
		(`aggreg;value flip 0!aggreg)
	}
 ];	

/error trap to capture specialFunction that cannot be initalised
@[value;`cep;{0N! "func not in list of template";exit 1}];
 

/ end of day: save, clear, hdb reload
.u.end:{t:tables`.;t@:where `g=attr each t@\:`sym;.Q.hdpf[`$":",.u.x 1;`:.;x;`sym];@[;`sym;`g#] each t;};

/modified upd such that it takes in the data from .u.tSub and apply cep function to it
/cep function is supposed to return the table manipulated and the data to insert to the tickerplant
/note that cep function can change accordingly to func
upd:{[t;x] .debug.glim:`t`x!(t;x);if[t in value .u.tSub;t insert x;h(`.u.upd,cep[x])]};


/ init schema and sync up from log file;cd to hdb(so client save can run)
.u.rep:{if[any 2<>count each x;x:enlist x];(.[;();:;].)each x;if[null first y;:()];-11!y;system "cd ",1_-10_string first reverse y};
/ HARDCODE \cd if other than logdir/db

/ connect to ticker plant for (schema;(logcount;log))


/ this changes such that the rdb is able to choose what it subscribes to
.u.rep .(h:hopen `$":",.u.x 0)"(.u.sub[;`] each ",.u.tSub,";`.u `i`L)";

