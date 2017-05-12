const dgram = require('dgram');

var client = dgram.createSocket('udp4');
window.addEventListener("load", function() {

	function send (cmd, data) {
		var buffer = new ArrayBuffer(2);
		var bufvie = new Uint8Array(buffer);
		var host = address.split(":")[0];
		var port = (address.split(":")[1] || 7) | 0;

		if (typeof port === "undefined")
			port = 57001;
	
		bufvie[0] = cmd;
		bufvie[1] = data;
	//	bufvie[2] = document.getElementById("row").value*2;

	//	console.log(bufvie[1]);
	//	console.log(bufvie[2]);
		client.send(buffer, 0, buffer.length, 57001, 'kit' , function(err, bytes) {
			if (err) throw err;
			console.log('UDP message sent to ' + HOST +':'+ PORT);
			client.close();
		});
	}

	document.getElementById("amp").onchange = function(ev) {
		send (0, document.getElementById("amp").selectedIndex);
	}

	document.getElementById("offset").onchange = function(ev) {
		send (1, document.getElementById("offset").value);
	}

	document.getElementById("trigger").onchange = function(ev) {
		send (2, document.getElementById("trigger").value);
	}

});
