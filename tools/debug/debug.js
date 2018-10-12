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
		data.push(3-1);

		var value;

		value = 0;
		e = document.getElementById("axis");
		value |= ((parseInt(e.value) & 0x1) << 2);
		e = document.getElementById("scale");
		value |= (parseInt(e.value) & 0x3);
		data.push(value & 0xff);

		value = 0;
		e = document.getElementById("offset");
		value |= (parseInt(e.value) >> 8);
		data.push(value & 0xff);

		value = 0;
		e = document.getElementById("offset");
		value |= parseInt(e.value);
		data.push(value & 0xff);

		send(data);
	}

	var e;
	
	e = document.getElementById("axis");
	e.addEventListener("wheel", mouseWheelCb, false);

	e = document.getElementById("scale");
	e.addEventListener("wheel", mouseWheelCb, false);

	e = document.getElementById("offset");
	e.addEventListener("wheel", mouseWheelCb, false);

});
