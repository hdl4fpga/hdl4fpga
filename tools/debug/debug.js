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

		this.value = parseInt(this.value) + parseInt(((e.deltaY > 0) ? -1 : 1));
		console.log("mouseWheel");

		var data = [];
		var	e;

		data.push(16);
		data.push(1);

		e = document.getElementById("scale");
		data.push((0x3 & parseInt(e.value)));

		e = document.getElementById("delay");
		data.push(parseInt(e.value));

		send(data);
	}

	var e;
	
	e = document.getElementById("delay");
	e.addEventListener("wheel", mouseWheelCb, false);

	e = document.getElementById("scale");
	e.addEventListener("wheel", mouseWheelCb, false);

	e = document.getElementById("offset");
	e.addEventListener("wheel", mouseWheelCb, false);

});
