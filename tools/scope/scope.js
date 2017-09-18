const dgram = require('dgram');

var client  = dgram.createSocket('udp4');

const chan = [
	{ color  : "#ffff00",
	  shaded : "#808000" },
	{ color  : "#00ffff",
	  shaded : "#008080" } ];

window.addEventListener("load", function() {

	function send (id, data, channel, edge) {
		var buffer = Buffer.alloc(3);
		var host = "kit";
		var port = 57001;

		if (typeof port === "undefined")
			port = 57001;
	
		buffer[1] = parseInt(data);
		
		if (typeof edge !== "undefined")
			if (edge != 0) 
				channel += 128;
		buffer[2] = parseInt(channel);

		console.log(channel);
		switch(id) {
		case "chan0-unit":
		case "chan1-unit":
			buffer[0] = 0;
			break;
		case "chan0-offset":
		case "chan1-offset":
			buffer[0] = 1;
			break;
		case "chan0-level":
		case "chan1-level":
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

	function pru() {
		console.log("hola");
	}

	function mouseWheelCb (e) {
		this.value = parseInt(this.value) + parseInt(((e.deltaY > 0) ? 1 : -1));
		document.getElementById(this.id).onchange(e);
	}

	function chanSelect (ev) {
		for(i=0 ; i < 2; i++) {
			var idTrigger = "chan" + i + "-trigger";
			var idScale   = "chan" + i + "-scale";

			if (this.id === idTrigger)
				for (j=0; j < 2; j++) {
					idTrigger = "chan" + j + "-trigger";
					if (this.id === idTrigger) {
						this.style.color = chan[j].color;
					} else
						document.getElementById(idTrigger).style.color =  chan[j].shaded;
				}
			else if (this.id === idScale)
				for (j=0; j < 2; j++) {
					idScale = "chan" + j + "-scale";
					if (this.id === idScale)
						this.style.color = chan[j].color;
					else
						document.getElementById(idScale).style.color = chan[j].shaded;
				}
		}
	}
	document.getElementById("time").onchange = function(ev) {
		send(this.id, parseInt(this.value));
	}

	document.getElementById("chan0-scale").onclick   = chanSelect;
	document.getElementById("chan1-scale").onclick   = chanSelect;
	document.getElementById("chan0-trigger").onclick = chanSelect;
	document.getElementById("chan1-trigger").onclick = chanSelect;

	document.getElementById("chan0-unit"   ).addEventListener("wheel", mouseWheelCb, false);
	document.getElementById("chan0-offset" ).addEventListener("wheel", mouseWheelCb, false);
	document.getElementById("chan0-level"  ).addEventListener("wheel", mouseWheelCb, false);
	document.getElementById("chan0-slope"  ).addEventListener("wheel", mouseWheelCb, false);
	document.getElementById("chan0-scale"  ).addEventListener("wheel", chanSelect, false);
	document.getElementById("chan0-trigger").addEventListener("wheel", chanSelect, false);
	document.getElementById("chan1-unit"   ).addEventListener("wheel", mouseWheelCb, false);
	document.getElementById("chan1-offset" ).addEventListener("wheel", mouseWheelCb, false);
	document.getElementById("chan1-level"  ).addEventListener("wheel", mouseWheelCb, false);
	document.getElementById("chan1-slope"  ).addEventListener("wheel", mouseWheelCb, false);
	document.getElementById("chan1-trigger").addEventListener("wheel", chanSelect, false);
	document.getElementById("chan1-scale"  ).addEventListener("wheel", chanSelect, false);
	document.getElementById("time"         ).addEventListener("wheel", mouseWheelCb, false);

	document.getElementById("chan0-unit").onchange = function(ev) {
		send (this.id, (parseInt(this.value)+16)%16, 0);
	}

	document.getElementById("chan0-offset").onchange = function(ev) {
		send (this.id, (parseInt(this.value)+256)%256, 0);
		document.getElementById("chan0-unit").onchange(ev);
	}

	document.getElementById("chan0-level").onchange = function(ev) {
		send (this.id, (parseInt(this.value)+256)%256, 0, document.getElementById("chan0-slope").value);
	}

	document.getElementById("chan0-slope").onchange = function(ev) {
		document.getElementById("chan0-level").onchange(ev);
	}

	document.getElementById("chan1-unit").onchange = function(ev) {
		send (this.id, (parseInt(this.value)+16)%16, 1);
	}

	document.getElementById("chan1-offset").onchange = function(ev) {
		send (this.id, (parseInt(this.value)+256)%256, 1);
		document.getElementById("chan1-unit").onchange(ev);
	}

	document.getElementById("chan1-level").onchange = function(ev) {
		send (this.id, (parseInt(this.value)+256)%256, 1, document.getElementById("chan1-slope").value);
	}

	document.getElementById("chan1-slope").onchange = function(ev) {
		document.getElementById("chan1-level").onchange(ev);
	}

});
