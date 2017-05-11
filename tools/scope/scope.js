var socketID;

chrome.sockets.udp.create({}, function(si) {
	socketID = si.socketId;
	chrome.sockets.udp.bind(socketID, "0.0.0.0", 0, function(si) {
	});
});

window.addEventListener("load", function() {
	for (i = 1; i < 17; i++) {
		var opt = document.createElement("option");
		var mod = i % 3;
		var quo = ((i-mod) / 3) - 3;
		var aux;
		switch(mod) {
		case 0:
			aux = Math.pow(10.0, quo)*1.0;
			break;
		case 1:
			aux = Math.pow(10.0, quo)*2.0;
			break;
		case 2:
			aux = Math.pow(10.0, quo)*5.0;
			break;
		}
		if (aux < 1)
			aux = 1000*aux + 'm';
		opt.innerHTML = aux;
		document.getElementById("amp").appendChild(opt);
	}
});

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
