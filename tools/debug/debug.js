const dgram = require('dgram');
var udpsckt  = dgram.createSocket('udp4');

var host = "kit";
var port = 57001;

window.addEventListener("load", function() {

	function send (data) {
		var buffer = Buffer.alloc(data.length+2);
		console.log(buffer.length);

		console.log(data);
		for (i=0; i < data.length; i++)
			buffer[i] = data[i];

		buffer[i++] = 0xff;
		buffer[i++] = 0xff;

		udpsckt.send(buffer, port, host, function(err, bytes) {
			if (err) throw err;
			console.log('UDP message has been sent');
		});
	}

	function mouseWheelCb (e) {
		this.value = parseInt(this.value) + parseInt(((e.deltaY > 0) ? 1 : -1));
	}

	var e;
	
	e = document.createElement("INPUT");

	e.setAttribute("type","number");
	e.setAttribute("value","0");
	e.style.textAlign = "right";

	e.addEventListener("wheel", mouseWheelCb, false);

	document.body.appendChild(e);

	var rgtrID = e;

	e = document.createElement("INPUT");
	e.setAttribute("type","button");
	e.setAttribute("value","hola");
	document.body.appendChild(e);

	e.onclick = function(ev) {
		var data = [];
		data.push(rgtrID.value);
		data.push(0);
		data.push(0);
		console.log("pase por aca");
		send(data);
	}
});
