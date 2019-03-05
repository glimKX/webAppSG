//////////////////////////////////////////////////////////////////////////////////////////////////
//	slack.q script which loads up with all tick templates											//
//	q script will define functions in .slack namespace						//
//////////////////////////////////////////////////////////////////////////////////////////////////

\c 1000 1000
//This is required becoz .Q.s is used to format the system string
//implement a bot version such that people can choose to subscribe - TODO
//implement a starting flag command such that symbol is place on init

/init webHook URL
.slack.hookURL:getenv`SLACK_URL;

.slack.wrapper:{" " sv ("curl -X POST -H \"Content-type: application/json\" --data";-1_.Q.s x;.slack.hookURL;
	"> /dev/null 2>&1")}

.slack.sendMsg:{[dict]
	if[not `text in key dict;'"Text is missing"];
	res:@[system;.slack.wrapper .j.j dict;{-2"Unable to run .slack.sendMsg due to: ".Q.s1 x}];
	if[not raze[res] like "ok";'res];
	//indicate that msg was successful
	:1b
	}

.slack.bold:{
	//appends * to string
	:raze ("*";x;"*")
	}

//external APIs

.openweather.hookURL:";" vs getenv`WEATHER_URL;

.openweather.wrapper:{"" sv ("curl \"";x sv .openweather.hookURL;enlist "\"";" > /dev/null 2>&1")}

.openweather.checkWeather:{[country]
	//for now we just want to extract the weather for the country mentioned, this returns a huge payload
	//will not use all of the information but there can be greater potential
	res:@[{.j.k raze system x};.openweather.wrapper country;{-2"unable to run .openweather.checkWeather due to: ".Q.s1 x;'x}];
	//hardcoded to json structure
	res[`weather;`main]
	}

.alphavantage.hookURL:";" vs getenv`STOCK_URL;

.alphavantage.wrapper:{raze ("curl \"";x sv .alphavantage.hookURL;enlist "\"";" > /dev/null 2>&1")}

.alphavantage.checkPrice:{[dict]
	//all args to be sent as a symbol
	if[not `symbol in key dict;'"Missing symbol"];
	if[not `interval in key dict;dict[`interval]:`5min];
	//build string from dictionary for wrapper
	query:"&" sv raze each string ((`$"="),/:flip (key[dict];value[dict]))[;1 0 2];
	res:@[{.j.k raze system x};.alphavantage.wrapper query;{-2"unable to run .alphavantage.checkPrice due to: ".Q.s1 x;'x}];
	//Just need the current price dictionary
	.debug.res:res;
	dataKey:key[res]1;
	`stockName`date`data!dict[`symbol],{first each (key x;x)} res[dataKey]
	}

//utils function
.utils.stringRes:{
	//most of the results will have various typing and we want a generic utility function to handle
	//.Q.s can be used but it will have weird formatting if applied to string
	typeCheck:type x;
	if[0h=typeCheck;:(raze/) x];
	if[10h=typeCheck;:x];
	:.Q.s x
	}
	
//main
//send message to slack
.weather.report:{.slack.sendMsg enlist[`text]!enlist .utils.stringRes "Weather in Singapore is currently: ",.slack.bold .openweather.checkWeather["Singapore"]}

//alphavantage message is a bit more complicated, currently hardcoded, to implement utility/api function
.alphavantage.sendToSlack:{[dict]
	stockName:string dict`stockName;
	fields:.alphavantage.buildFields[`open`high`low`close`volume!value dict`data];
	//build internal dictionary
	msg:`fallback`color`pretext`author_name`title`fields`footer!("Stock Notice";
		"#36a64f";"Stock Notice of ",stockName;"qBot";"Price of stock as at ",string 0.5452+"Z"$string dict`date;
		fields;"Slack API");
	msg:`text`attachments!("qBot Data";enlist msg);
	res:@[system;.slack.wrapper .j.j msg;{-2"Unable to run .alphavantage.sentToSlack due to: ".Q.s1 x;'x}];
        if[not raze[res] like "ok";'res];
        //indicate that msg was successful
        :1b	
	}

.alphavantage.buildFields:{
	//.j.j will convert the table into a format that is recognised in json
	flip `title`value!(key[x];value[x])
	//flip `title`value`short!(key[x];value[x];count[x]#0b)
	}

.main.dbs:{.alphavantage.sendToSlack .alphavantage.checkPrice enlist[`symbol]!enlist`D05.SI};
//to include a table/configuration to compare against time to send prices
.z.ts:{if[(.z.T within (09:00:00;19:00:00)) and not (.z.D mod 7) in 0 1;.main.dbs`]}
\t 600000

