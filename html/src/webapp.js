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
function retrieveLatestMsg(){
	if (ws == null){
		alert('Websocket handle is not found');
	} else {
		var msg=JSON.stringify({func:".gateway.retrieveLatestMsg",args:""});
		ws.send(msg);
	}
}

function appendNewMsg(x){
	//take in x which is a dictionary
	//for loop, parse dictionary, append user details
	if (x['user'] == username){
		var msg = "<div class=\"balon1 p-2 m-0 position-relative\" data-is=\""+"You - "+x['datetime']+"\">"+"<a class=\"float-right\">"+x['msg']+"</a></div>";
	} else {
		var msg = "<div class=\"balon2 p-2 m-0 position-relative\" data-is=\""+x['user']+" - "+x['datetime']+"\">"+"<a class=\"float-left sohbet2\">"+x['msg']+"</a></div>";	
	}
	msg = $.parseHTML(msg);
	$("#sohbet").append(msg);
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

//Main
