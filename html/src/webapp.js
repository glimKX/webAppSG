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
$(".dropdown-menu li a").click(function(){
  $("#dropdownMenuButton").text($(this).text());
//  $(this).parents(".dropdown").find('.btn').val($(this).data('value'));
});
//T
