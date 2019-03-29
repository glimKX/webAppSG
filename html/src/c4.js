var ws, cmd = "";
var output=$("#txtOutput");
var gridBox=$("#grid");
var fakeChild=document.createElement("fakeChild");
fakeChild.setAttribute('id', "GridChild");
gridBox.append(fakeChild);
var lastClicked;
var currentLobby;
var replayList=[];
var replayIndex;

function callTab(){
        ws.send(JSON.stringify({func:".c4.callTab",args:currentLobby}))
    }

function callGrid(){
        ws.send(JSON.stringify({func:".c4.grid",args:"`"}))
    }


function resetGame(){
	ws.send(JSON.stringify({func:".c4.runJob",args:{arg:"Y",lobby:currentLobby}}));
	$("#resetBtn").toggle();
	$("#backBtn").toggle();
        $("#forwardBtn").toggle();
	replayList=[];
    }

function resetGameP2(){
	//server has to let P2 know that game has been reset.
	//TO-DO
	$("#resetBtn").toggle();
        $("#backBtn").toggle();
        $("#forwardBtn").toggle();
        replayList=[];
    }

function endGame(){
	$("#resetBtn").toggle();
	$("#backBtn").toggle();
	$("#forwardBtn").toggle();
	//take note of the list length in replayList and assume user is in the last grid
	replayIndex=replayList.length - 1;
    }

function createGrid(x){
	var grid = clickableGrid(x,function(el,row,col,i){
		console.log("Sending run job as:",x[row][0].split(">")[1][0]+col)
		ws.send(JSON.stringify({func:".c4.runJob",args:{arg:x[row][0].split(">")[1][0]+col,lobby:currentLobby}}));
		//el.className='clicked';
		//if (lastClicked) lastClicked.className='';
		//lastClicked = el;
	});

	grid.setAttribute('id', "GridChild");
	gridBox.append(grid);

    }

function removeGrid() {
	// Removes an element from the document
	var element = document.getElementById("GridChild");
	element.parentNode.removeChild(element);
    }

function newGrid(x){
	console.log("In newGrid Function")
	removeGrid()
	x=JSON.parse(x);
	replayList.push(x);
	createGrid(x.grid)
	iconiseBoard()
    }

function replayBack(){
	replayIndex -= 1;
	if (replayIndex < 0){alert("In Starting Grid, unable to replay backwards");replayIndex = 0;}
	else {
		removeGrid()
		createGrid(replayList[replayIndex].grid)
		iconiseBoard()
	}
    }

function replayForward(){
	replayIndex += 1;
	if (replayIndex > replayList.length -1 ){alert("In Last Grid, unable to replay forward");replayIndex = replayList.length -1;}
	else {
		removeGrid()
		createGrid(replayList[replayIndex].grid)
		iconiseBoard()
	}
    }

function callMusic(){
	ws.send(JSON.stringify({func:".c4.retrieveMusic",arg:""}))
    }	

function clickableGrid(x, callback ){
	var rows=x.length;
	var cols=x[0].length;
	var i=0;
	var grid = document.createElement('table');
	grid.className = 'grid';
	for (var r=0;r<rows;++r){
        	var tr = grid.appendChild(document.createElement('tr'));
        	for (var c=0;c<cols;++c){
            		var cell = tr.appendChild(document.createElement('td'));
			if (x[r][c] == "0"){
			cell.innerHTML = " ";
			}
			else cell.innerHTML = x[r][c];
            		if (c > 0 && r != rows-1){
            		cell.addEventListener('click',(function(el,r,c,i){
                		return function(){
                    			callback(el,r,c,i);
                		}
            		})(cell,r,c,i),false);
            		}
        	}
    	}
   	 return grid;
    }

function changeChannel(channel){
        if (ws == null){
                alert('Websocket handle is not found');
        } else {
		if (currentLobby != null){
			var msg=JSON.stringify({func:".c4.leaveLobby",args:channel});
			$("#channelID").text("You have left channel "+currentLobby);
			ws.send(msg);
		}
                var msg=JSON.stringify({func:".c4.joinLobby",args:channel});
		currentLobby=channel;
		$("#channelID").text("You have joined channel "+currentLobby);
                ws.send(msg);
        }
 }

function c4Generic(obj){
	var x=obj.output
	switch(obj.func){
		case ".c4.gatewaySendGrid":newGrid(x);
			break;
		case ".c4.gatewayMessage":$("[class='card-text']").text(x);
			break;
		case ".c4.retrieveMusic":$("source").attr("src",x);
			break;
		case ".c4.lastMove":lastMove(x);
			break;
		case ".c4.leaderBoard":parseTable(x);
			break;
		case ".c4.pullCmd":captureDyn(obj);
			break;
		default:console.log(x);
		}
 }

function iconiseBoard(){
	$( "td:contains('%')" ).addClass("rdot");
	$( "td:contains('#')" ).addClass("bdot");
	$( "td:contains('%')" ).text("")
	$( "td:contains('#')" ).text("")
 }

function lastMove(coord){
	var alphabet=coord[0];
	var index=coord[1]-1;
	var checker=$( "p:contains('Game Over!')" );
	if (checker.length == 1){endGame()};
	$("td:has(b:contains('"+alphabet+"')) ~ td:eq("+index+")").addClass("clicked")
 }

function c4Init(){
	//Pull leaderboard
	var msg=JSON.stringify({func:".c4.pullCmd",args:".c4.leaderBoard"});
	//Pull music
	ws.send(msg)
 }

function captureDyn(obj){
	var x = obj.output
 	switch(obj.args){
		case ".c4.leaderBoard":parseTable(x);
			break;
		default:console.log(x);
		}
 }
//add listenr to dropdown
$("[aria-labelledby='changeChannel'] > a").click(function(){var channel=$(this).attr("value");changeChannel(channel)});
