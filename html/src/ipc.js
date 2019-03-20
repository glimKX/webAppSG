var username=localStorage.getItem('user');
var password=localStorage.getItem('pass');
var wsTmp, wsJsonObj,globalTable,qOutput;
var editor = new Quill('#exampleFormControlTextarea1', {
  modules: {
    toolbar: [[{ header: [1, 2, false] }],
     ['bold', 'italic', 'underline'],
     ['image', 'code-block']]
  },
  placeholder: 'Change Story',
  theme: 'snow' 
});
var storyBoard = new Quill('#funQStoryBoard', {
  modules: {
    toolbar: false
  },
  readOnly:true,
  theme: 'snow'
});
//ipc functions
function connect(username,password)
{if ("WebSocket" in window)
 {var l = window.location;ws = new WebSocket("ws://" + username + ":" +  password + "@" + (l.hostname ? l.hostname : "localhost") + ":" + (l.port ? l.port : "5030") + "/"); 
  ws.onopen=function(e){console.log("connected");$(".username").text(username);pullOrigin();pullFromKDB(".backend.funQStory");pullFromKDB(".backend.leaderBoard");pullChatHistory();retrieveImage(username);c4Init();callMusic()}
  ws.onmessage=function(e){
	  wsTmp=e.data;
	  try {
	  	wsJsonObj=JSON.parse(wsTmp);
	      } catch(ex) {
		console.log(wsTmp);
		$("[class='card-text']").text(wsTmp);
		return null;
	      }

	  if (wsJsonObj.func == ".gateway.pullFromKDB"){parseResult(wsJsonObj);}
	  else if (wsJsonObj.func == ".gateway.pushToKDB"){displayPushStatus(wsJsonObj.output);}
	  else if (wsJsonObj.func == ".gateway.changeSchema"){changeSchemaStatus(wsJsonObj.output);}
	  else if (wsJsonObj.func == ".gateway.uploadCSV"){if(wsJsonObj.output==null){alert("Uploaded new CSV to Backend")};}
	  else if (wsJsonObj.func == ".gateway.sendResult"){qPushToClient(wsJsonObj.output);}
	  else if (wsJsonObj.func == ".gateway.chatStore"){appendNewMsg(wsJsonObj.output);}
  	  else if (wsJsonObj.func == ".gateway.chatRefresh"){appendNewMsg(wsJsonObj.output);}
	  else if (wsJsonObj.func == ".gateway.chatHistory"){updateMsgTable(wsJsonObj.output);}
	  else if (wsJsonObj.func == ".gateway.getOrigin"){$("small:first").text(wsJsonObj.output);}
	  else if (wsJsonObj.func == ".gateway.retrieveImage"){$("#profileImg").attr('src',wsJsonObj.output);}
	  else if (wsJsonObj.func.match(/.c4./g)){c4Generic(wsJsonObj);}
  	  }
  
  ws.onerror=function(e){console.log(e.data);}
  ws.onclose=function(e){alert("Web Socket Connection Closed, please refresh");$(".fa-check").addClass("fa-times");$(".fa-check").removeClass("fa-check")}
 }else alert("WebSockets not supported on your browser.");
}

function parseAnswers()
{
	var parsedAnswers, answers=$("[aria-selected='true']");
	for (i = 0;i<answers.length;i++){
		//create dictionary to store answers
	}
}

function parseResult(data){
	if (data.arg==".backend.funQStory"){
	  storyBoard.setContents(data.output);
	  if (username == "Administrator"){editor.setContents(data.output)}
	} else if (data.arg==".backend.leaderBoard"){
	  parseTable(data.output); 
	}
};

function parseTable(data){
	if (data.length == 0){return;}
	if (globalTable != null){globalTable.destroy();$("#dataTable").empty()}
	var colNames = [];
	var dataNames = [];
	var singleRow=data[0];
	for (var i=0;i<Object.keys(singleRow).length;i++) {var k =Object.keys(singleRow)[i]; colNames.push({"title":k,"targets":i}); dataNames.push({"data":k})};
	globalTable=$("#dataTable").DataTable({
		"data": data,
		"columns": dataNames,
		"columnDefs":colNames
	});
	var d = new Date();
        $("#ldrboardUpd").text("Updated: "+String(d));
}

function displayPushStatus(data){
	console.log(data);
}

function changeSchemaStatus(data){
	if (data == null){alert("Schema Changed")}
	else {alert("Error: "+data)}
}

function qPushToClient(data){
	//recv result from gateway when job has been completed
	//sends both success or failures
	//$("[class='card-text']").text(wsTmp)
	console.log(data);
	if (qOutput != null){qOutput.destroy();$("#qOutput").empty()}
	var colNames = [];
        var dataNames = [];
        var singleRow=data[0];
        for (var i=0;i<Object.keys(singleRow).length;i++) {var k =Object.keys(singleRow)[i]; colNames.push({"title":k,"targets":i}); dataNames.push({"data":k})};
        qOutput=$("#qOutput").DataTable({
                "data": data,
                "columns": dataNames,
                "columnDefs":colNames
        });
}

//Events
//send query from box to q console
$("#sendBtn").click(function(){ws.send($("[aria-label='q-console']").val())});

//main
$(document).ready(function(){
  //When document loads, make connections and work
  connect(username,password);
  if(username != "Administrator"){$("#AdminBox").remove()};
});

