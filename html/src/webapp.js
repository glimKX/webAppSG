//Functions
function going(){
	$("[href='index.html']").remove();
	$("section[id*='tabs']" ).removeClass("d-none");
	$("div[class*='mbr-arrow']").removeClass("d-none");
 }

function pushToKDB(x,text){
	if (ws == null){
		alert('Websocket handle is not found');
	} else {
		var msg=JSON.stringify({func:".gateway.pushToKDB",args:{holder:x,item:text}});
		ws.send(msg);
	}
 }

function pullFromKDB(x){
	if (ws == null){
		alert('Websocket handle is not found');
	} else {
		var msg=JSON.stringify({func:".gateway.pullFromKDB",args:x});
		ws.send(msg);
	}
 }

function changeSchema(colName,type){
	if (ws == null){
		alert('Websocket handle is not found');
	} else {
			var msg=JSON.stringify({func:".gateway.changeSchema",args:{colName:colName,type:type}});
			ws.send(msg);
	}
 }

//might not need this functionliaty, pullFromKDB .backend.chat
//when received message, run appendNewMsg
//we can also set command in ws.received such that whenever this message comes, (1 or more) run appendNewMsg
function pullChatHistory(){
	if (ws == null){
		alert('Websocket handle is not found');
	} else {
		var msg=JSON.stringify({func:".gateway.pullChat",args:""});
		ws.send(msg);
	}
}

function pullOrigin(){
	var msg = JSON.stringify({func:".gateway.getOrigin",args:""});
	ws.send(msg);
}

function scrollBtm(x){
	//take x as element id
	//keeps scroll at the bottom
	var msgList = document.getElementById(x);
	msgList.scrollTop = msgList.scrollHeight;
}

function appendNewMsg(x){
	//take in x which is a dictionary
	//for loop, parse dictionary, append user details
	if (x['user'] == username){
		var msg = "<div class=\"balon1 p-2 m-0 position-relative\" data-is=\""+"You - "+x['msgTime']+"\">"+"<a class=\"float-right\">"+x['msg']+"</a></div>";
	} else {
		var msg = "<div class=\"balon2 p-2 m-0 position-relative\" data-is=\""+x['user']+" - "+x['msgTime']+"\">"+"<a class=\"float-left sohbet2\">"+x['msg']+"</a></div>";	
	}
	msg = $.parseHTML(msg);
	$("#sohbet").append(msg);
	scrollBtm("sohbet");	
}

function updateMsgTable(x){
	//take in x which is an array of dictionaries
	//for loop, parse each dictionary, append user details
	var msgNumber = x.length;
	for (i=0;i<msgNumber;i++){
		appendNewMsg(x[i]);
	}
}

function readImage(x){
	console.log(x);
	if (x.files && x.files[0]) {
		var fileName = x.files[0];
		var fr = new FileReader();
		fr.onload = function(e) {
			$("#profileImg").attr('src',e.target.result);
			storeImage(e.target.result);
		}
		fr.readAsDataURL(fileName);
	}
}

function storeImage(x){
	//Take in encoded image and sends string to kdb database
	var msg=JSON.stringify({func:".gateway.storeImage",args:{"username":username,"img":x}});
        ws.send(msg);
}

function retrieveImage(x){
	//Sends username to backend and retrieve
	var msg=JSON.stringify({func:".gateway.retrieveImage",args:username});
	ws.send(msg);
}
//Event
$("#joinBtn").click(function(){going()});
$("#changeBtn").click(function(){$("[class='form-group']").toggle()});
$("#uploadBtn").click(function(){$("#dvImportSegments").toggle()});
$("#changeSchemaBtn").click(function(){$("[class='form-group my-1']").toggle()});
$("[aria-labelledby='changeArgSchema'] > a").click(function(){var type=$(this).attr("value");changeSchema("testCase",type)});
$("[aria-labelledby='changeAnsSchema'] > a").click(function(){var type=$(this).attr("value");changeSchema("answer",type)});
$(".dropdown-menu li a").click(function(){
  $("#dropdownMenuButton").text($(this).text());
//  $(this).parents(".dropdown").find('.btn').val($(this).data('value'));
});
$("button:contains('Submit Changes')").click(function(){
  //Parse text area
  var textBox=$("#exampleFormControlTextarea1").val().replace(/(\r\n|\n|\r)/gm, "<br />");
  //Store into KDB
  pushToKDB(".backend.funQStory",textBox);
  //Reflect it on page, replace
  $("#funQStoryBoard").empty();
  $("#funQStoryBoard").append($.parseHTML(textBox));
});
$(document).ready(function(){
  //When document loads, extract data from KDB
});

//Enable sending of message using enter key
$("#msgInput").submit(function(event){
	$("#msgBtn").click()
	event.preventDefault();
});

//Sending of message using submit button
$("#msgBtn").click(function(){
	var msg=$("#text").val();
	ws.send(JSON.stringify({func:".gateway.chatStore",args:msg}));
	$("#msgInput").trigger("reset");
});
//Add input event for change of avatar
$("#profileImg").click(function (){
	$("#imgInput").trigger('click');
});
$("#imgInput").on("change",function(){readImage(this);});
//Main
