var socketID;

chrome.sockets.udp.create({}, function(si) {
	socketID = si.socketId;
	chrome.sockets.udp.bind(socketID, "0.0.0.0", 0, function(si) {
	});
});

window.addEventListener("load", function() {
		for (i=0; i <= 255; i++) {
				var e = document.createElement("option");
				e.innerHTML = i + ' ' + String.fromCharCode(i);
				document.getElementById("character").appendChild(e);
		}
});

window.addEventListener("load", function() {
	var connect = document.getElementById("connect");
	var address = document.getElementById("address");

	connect.onclick = function() {
		var buffer = new ArrayBuffer(3);
		var bufvie = new Uint8Array(buffer);
		var host = address.value.split(":")[0];
		var port = (address.value.split(":")[1] || 7) | 0;

		if (typeof port === "undefined")
			port = 57001;
	
		bufvie[0] = document.getElementById("character").selectedIndex;
		bufvie[1] = document.getElementById("column").value;
		bufvie[2] = document.getElementById("row").value*2;

		console.log(bufvie[1]);
		console.log(bufvie[2]);
		chrome.sockets.udp.send(
			socketID,
			buffer,
			host,
			port,
			function(si) {
		});
	};

	address.onkeydown = function(ev) {
		console.log("onkeydown");
	};

});
