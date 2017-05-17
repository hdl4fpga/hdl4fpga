const dgram = require('dgram');

var client = dgram.createSocket('udp4');
window.addEventListener("load", function() {

	function send (cmd, data) {
		var buffer = Buffer.alloc(2);
		var host = "kit";
		var port = 57001;

		if (typeof port === "undefined")
			port = 57001;
	
		buffer[0] = cmd;
		buffer[1] = data;
		console.log(data);
	//	bufvie[2] = document.getElementById("row").value*2;

	//	console.log(bufvie[1]);
	//	console.log(bufvie[2]);
		client.send(buffer, port, host , function(err, bytes) {
			if (err) throw err;
			console.log('UDP message sent to ' + host +':'+ "57001");
		});
	}

	document.getElementById("amp").onchange = function(ev) {
		send (0, (parseInt(document.getElementById("amp").value)+16)%16);
	}

	document.getElementById("offset").onchange = function(ev) {
		send (1, document.getElementById("offset").value);
	}

	document.getElementById("trigger").onchange = function(ev) {
		send (2, document.getElementById("trigger").value);
	}

});
