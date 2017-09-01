const dgram = require('dgram');

var client  = dgram.createSocket('udp4');
var trigger_edge = 0;
var trigger_channel = 0;
window.addEventListener("load", function() {

	function send (id, data, channel) {
		var buffer = Buffer.alloc(3);
		var host = "kit";
		var port = 57001;

		if (typeof port === "undefined")
			port = 57001;
	
		buffer[1] = parseInt(data);
		buffer[2] = parseInt(channel + trigger_edge);
		console.log(channel);
		switch(id) {
		case "green-unit":
		case "red-unit":
			buffer[0] = 0;
			break;
		case "green-offset":
		case "red-offset":
			buffer[0] = 1;
			break;
		case "trigger":
			buffer[0] = 2;
			break;
		case "time":
			buffer[0] = 3;
			break;
		}
//		console.log(data);
		client.send(buffer, port, host , function(err, bytes) {
			if (err) throw err;
			console.log('UDP message sent to ' + host +':'+ "57001");
		});
	}

	function mouseWheelCb (e) {
		this.value = parseInt(this.value) + parseInt(((e.deltaY > 0) ? 1 : -1));
		document.getElementById(this.id).onchange(e);
	}

	document.getElementById( "green-unit"  ).addEventListener("wheel", mouseWheelCb, false);
	document.getElementById( "green-offset").addEventListener("wheel", mouseWheelCb, false);
	document.getElementById( "red-unit"    ).addEventListener("wheel", mouseWheelCb, false);
	document.getElementById( "red-offset"  ).addEventListener("wheel", mouseWheelCb, false);
	document.getElementById( "trigger"     ).addEventListener("wheel", mouseWheelCb, false);
	document.getElementById( "time"        ).addEventListener("wheel", mouseWheelCb, false);

	document.getElementById("green-unit").onchange = function(ev) {
		send (this.id, (parseInt(this.value)+16)%16, 1);
	}

	document.getElementById("green-offset").onchange = function(ev) {
		send (this.id, (parseInt(this.value)+256)%256, 1);
	}

	document.getElementById("red-unit").onchange = function(ev) {
		send (this.id, (parseInt(this.value)+16)%16, 0);
	}

	document.getElementById("red-offset").onchange = function(ev) {
		send (this.id, (parseInt(this.value)+256)%256, 0);
	}

	document.getElementById("trigger").onchange = function(ev) {
		send (this.id, (parseInt(this.value)+256)%256, trigger_channel);
	}

	document.getElementById("time").onchange = function(ev) {
		send (this.id, parseInt(this.value), trigger_channel);
	}

	document.getElementById("neg").onclick = function(ev) {
		trigger_edge = 0x00;
	}

	document.getElementById("pos").onclick = function(ev) {
		trigger_edge = 0x80;
	}

	document.getElementById("green").onclick = function(ev) {
		trigger_channel = 0;
	}

	document.getElementById("red").onclick = function(ev) {
		trigger_channel = 1;
	}

});
