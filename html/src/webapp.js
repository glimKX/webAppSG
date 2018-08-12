//Functions
function going(){
	$("[href='index.html']").remove();
	$("section[id*='tabs']" ).removeClass("d-none");
	$("div[class*='mbr-arrow']").removeClass("d-none");
 }

//Event
$("#joinBtn").click(function(){going()});
$("#changeBtn").click(function(){$("form").toggle()});
$("#uploadBtn").click(function(){$("#dvImportSegments").toggle()});
//T
