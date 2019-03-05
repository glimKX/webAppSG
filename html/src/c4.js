var ws, cmd = "";
var output=$("#txtOutput");
var gridBox=$("#grid");
var fakeChild=document.createElement("fakeChild");
fakeChild.setAttribute('id', "GridChild");
gridBox.append(fakeChild);
var lastClicked;
var currentLobby;

function callTab(){
        ws.send(JSON.stringify({func:".c4.callTab",args:currentLobby}))
    }

function callGrid(){
        ws.send(JSON.stringify({func:".c4.grid",args:"`"}))
    }


function resetGame(){
	ws.send(JSON.stringify({func:".c4.runJob",args:{arg:"Y",lobby:currentLobby}}));
    }

function endGame(){
	var x = $("#resetBtn");
	if (txtOutput.innerText.includes("restart")) {
	x.style.display = "block";
	} else {
	x.style.display = "none";
	}
    }

function createGrid(x){
	var grid = clickableGrid(x,function(el,row,col,i){
		console.log("Sending run job as:",x[row][0].split(">")[1][0]+col)
		ws.send(JSON.stringify({func:".c4.runJob",args:{arg:x[row][0].split(">")[1][0]+col,lobby:currentLobby}}));
		el.className='clicked';
		if (lastClicked) lastClicked.className='';
		lastClicked = el;
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
	createGrid(x.grid)
	iconiseBoard()
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
		default:console.log(x);
		}
 }

function iconiseBoard(){
	$( "td:contains('%')" ).addClass("rdot");
	$( "td:contains('#')" ).addClass("bdot");
	$( "td:contains('%')" ).text("")
	$( "td:contains('#')" ).text("")
 }


//add listenr to dropdown
$("[aria-labelledby='changeChannel'] > a").click(function(){var channel=$(this).attr("value");changeChannel(channel)});