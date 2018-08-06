var username=localStorage.getItem('user');
var password=localStorage.getItem('pass');
var wsTmp, wsJsonObj;

function connect(username,password)
{if ("WebSocket" in window)
 {var l = window.location;ws = new WebSocket("ws://" + username + ":" +  password + "@" + (l.hostname ? l.hostname : "localhost") + ":" + (l.port ? l.port : "5030") + "/"); 
  ws.onopen=function(e){console.log("connected");} 
  ws.onmessage=function(e){
	  wsTmp=e.data;
	  wsJsonObj=JSON.parse(wsTmp);
	  if (wsJsonObj.func == "sourceForSym"){parseForSym(wsJsonObj.output)}
	  else if (wsJsonObj.func == "selectFromTrade"){parseForQTable(wsJsonObj.output);}
	  else {console.log(wsTmp);}
  }
  ws.onerror=function(e){console.log(e.data);}
 }else alert("WebSockets not supported on your browser.");
}

connect(username,password);