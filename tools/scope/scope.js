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
		for (i = 0; i < 3; i++) {
			bufvie[i] = 3*16+i;
		}

		chrome.sockets.udp.send(
			socketID,
			buffer,
			"127.0.0.1",
			57001,
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
