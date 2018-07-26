/q feed.q :5010 -p 5020 
/Mock feed handler

/open handle to tickerplant
h:hopen "J"$1_first .u.x:.z.x,count[.z.x]_enlist ":5010";
/mockFeedhandler, hence data is randomly generated;
/generate data base on dictionary schema
csvDir:getenv`CSV_DIR;
ticks:`$"," vs raze read0 `$":",csvDir,"/feed.csv";
rng:`sym`size`price!(ticks;50;(10.0 3000.0));
/load table schema;
\l tick/sym.q
\l tick/u.q

/tables (trade;quote;aggreg)
/generate random batch of data for quote
/note that ask price should be 
generateQuoteData:{
	i:first 5+1?30;
	value flip (@[quote;;:;] .) (`time`sym`bidSize`bidPrice`askSize`askPrice;
	(i#"n"$.z.P;i?rng`sym;rng[`size]*1+i?9;m+i?max[rng[`price]] - m:min rng`price;rng[`size]*1+i?9;m+i?max[rng[`price]] - m:min rng`price))
	};
/generate random batch of data for trade
generateTradeData:{
	i:first 5+1?20;
	value flip (@[trade;;:;] .) (`time`sym`size`price;(i#"n"$.z.P;i?rng`sym;rng[`size]*1+i?9;m+i?max[rng[`price]] - m:min rng`price))
	};

/Timer to control data generation
.z.ts:{h(`.u.upd;`trade;generateTradeData[]);h(`.u.upd;`quote;generateQuoteData[])};
