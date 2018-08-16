var debug;
$(document).ready(function() {

    // The event listener for the file upload
    document.getElementById('txtFileUpload').addEventListener('change', upload, false);

    // Method that checks that the browser supports the HTML5 File API
    function browserSupportFileUpload() {
        var isCompatible = false;
        if (window.File && window.FileReader && window.FileList && window.Blob) {
        isCompatible = true;
        }
        return isCompatible;
    }

    function sendCSV(data){
    	if (ws == null){
	  alert('Websocket handle is not found');
	} else {
	  ws.send(JSON.stringify({func:".gateway.uploadCSV",args:data}));
	}
    }

    // Method that reads and processes the selected file
    function upload(evt) {
    if (!browserSupportFileUpload()) {
        alert('The File APIs are not fully supported in this browser!');
        } else {
            var data = null;
            var file = evt.target.files[0];
            var reader = new FileReader();
            reader.readAsText(file);
            reader.onload = function(event) {
                var csvData = event.target.result;
		//should make data into dictionary, easy for KDB q
                data = $.csv.toObjects(csvData);
                if (data && data.length > 0) {
//		  debug=data;
		  sendCSV(data);
                  alert('Imported -' + data.length + '- rows successfully!');
                } else {
                    alert('No data to import!');
                }
            };
            reader.onerror = function() {
                alert('Unable to read ' + file.fileName);
            };
        }
    }
}
)
