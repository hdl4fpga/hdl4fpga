const dgram = require('dgram');

var client  = dgram.createSocket('udp4');
var channel = 0;
window.addEventListener("load", function() {

	function send (id, data) {
		var buffer = Buffer.alloc(3);
		var host = "kit";
		var port = 57001;

		if (typeof port === "undefined")
			port = 57001;
	
		buffer[1] = parseInt(data);
		buffer[2] = parseInt(channel);
		console.log(channel);
		switch(id) {
		case "amp":
			buffer[0] = 0;
			break;
		case "offset":
			buffer[0] = 1;
			break;
		case "trigger":
			buffer[0] = 2;
			break;
		case "time":
			buffer[0] = 3;
			break;
		}
		console.log(data);
		client.send(buffer, port, host , function(err, bytes) {
			if (err) throw err;
			console.log('UDP message sent to ' + host +':'+ "57001");
		});
	}

	function mouseWheelCb (e) {
		this.value = parseInt(this.value) + parseInt(((e.deltaY > 0) ? 1 : -1));
		send (this.id, this.value);
	}

	document.getElementById( "unit"    ).addEventListener("wheel", mouseWheelCb, false);
	document.getElementById( "offset"  ).addEventListener("wheel", mouseWheelCb, false);
	document.getElementById( "trigger" ).addEventListener("wheel", mouseWheelCb, false);
	document.getElementById( "time"    ).addEventListener("wheel", mouseWheelCb, false);

	document.getElementById("unit").onchange = function(ev) {
		send (this.id, (parseInt(this.value)+16)%16);
	}

	document.getElementById("offset").onchange = function(ev) {
		send (this.id, (parseInt(this.value)+256)%256);
	}

	document.getElementById("trigger").onchange = function(ev) {
		send (this.id, (parseInt(this.value)+256)%256);
	}

	document.getElementById("time").onchange = function(ev) {
		send (this.id, parseInt(this.value));
	}

	document.getElementById("ch1").onclick = function(ev) {
		channel = 0;
		console.log("Pase por aca 1");
	}

	document.getElementById("ch2").onclick = function(ev) {
		channel = 1;
		console.log("Pase por aca 2");
	}

	document.getElementById("neg").onclick = function(ev) {
	}

	document.getElementById("pos").onclick = function(ev) {
	}

});
