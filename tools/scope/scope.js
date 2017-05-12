const dgram        = require('dgram');

var server = dgram.createSocket('udp4');

server.on(
	'listening',
   	function () {
		const address = server.address();
		console.log('listening -> ' + address.address + ":" + address.port);
	});

server.on(
	'message',
	function (data, remote) {
		msgRecv = 1;
		const msg = JSON.parse(data.toString());
		console.log('message -> ' + data.toString());
		sbEmitter.emit(msg.type, msg);
	});

server.bind(config.dcs.port, config.dcs.ip);

window.addEventListener("load", function() {
	var address = "kit";

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
		chrome.sockets.udp.send(
			socketID,
			buffer,
			host,
			port,
			function(si) {
		});
	};

	document.getElementById("amp").onchange = function(ev) {
		send (0, document.getElementById("amp").selectedIndex);
	}

	document.getElementById("offset").onchange = function(ev) {
		send (1, document.getElementById("offset").value);
	}

	document.getElementById("trigger").onchange = function(ev) {
		send (2, document.getElementById("trigger").value);
	}

	address.onkeydown = function(ev) {
		console.log("onkeydown");
	};

});
