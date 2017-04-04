var socketID;

chrome.sockets.udp.create({}, function(si) {
	socketID = si.socketId;
	chrome.sockets.udp.bind(socketID, "0.0.0.0", 0, function(si) {
	});
});

window.addEventListener("load", function() {
	var connect = document.getElementById("connect");
	var address = document.getElementById("address");

	connect.onclick = function() {
		var buffer = new ArrayBuffer(3);
		var bufvie = new Uint8Array(buffer);
		var host = address.value.split(":")[0];
		var port = (address.value.split(":")[1] || 7) | 0;
		console.log(host);
		console.log(port);

		if (typeof port === "undefined")
			port = 57001;
	
		for (i = 0; i < 3; i++) {
			bufvie[i] = 3*16+i;
		}

		chrome.sockets.udp.send(
			socketID,
			buffer,
			host,
			port,
			function(si) {
				console.log(si.resultCode);
				console.log(si.byteSent);
		});
		console.log("onclick " + socketID);
	};

	address.onkeydown = function(ev) {
		console.log("onkeydown");
	};

});
