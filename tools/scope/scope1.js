const dgram = require('dgram');
const inputs = 9;

var client  = dgram.createSocket('udp4');

const chan = [
	{ color  : "#ffff00",
	  shaded : "#808000" },
	{ color  : "#00ffff",
	  shaded : "#008080" },
	{ color  : "#ff00ff",
	  shaded : "#800080" },
	{ color  : "#ffffff",
	  shaded : "#808080" },
	{ color  : "#0000ff",
	  shaded : "#000080" },
	  ];

window.addEventListener("load", function() {

	function send (cmd, data, channel, edge) {
		var buffer = Buffer.alloc(3);
		var host = "kit";
		var port = 57001;

		if (typeof port === "undefined")
			port = 57001;
	
		buffer[1] = parseInt(data);
		
		if (typeof edge !== "undefined")
			if (edge != 0) 
				channel = parseInt(channel) + 128;
		buffer[2] = parseInt(channel);

		console.log("channel : ", channel, "command : ", cmd);
		switch(cmd) {
		case "unit":
			buffer[0] = 0;
			break;
		case "offset":
			buffer[0] = 1;
			break;
		case "level":
			buffer[0] = 2;
			break;
		case "time":
			buffer[0] = 3;
			break;
		}
		client.send(buffer, port, host , function(err, bytes) {
			if (err) throw err;
			console.log('UDP message sent to ' + host +':'+ "57001");
		});
	}

	function mouseWheelCb (e) {
		this.value = parseInt(this.value) + parseInt(((e.deltaY > 0) ? 1 : -1));
	}

	function chanSelect (ev) {
		for(i=0 ; i < inputs; i++) {
			var idTrigger = "chan" + i + "-trigger";
			var idScale   = "chan" + i + "-scale";

			if (this.id === idTrigger)
				for (j=0; j < inputs; j++) {
					idTrigger = "chan" + j + "-trigger";
					if (this.id === idTrigger) {
						this.style.color = chan[j % chan.length ].color;
						document.getElementById("chan" + j + "-slope").onchange(ev);
					} else
						document.getElementById(idTrigger).style.color =  chan[j % chan.length ].shaded;
				}
			else if (this.id === idScale)
				for (j=0; j < inputs; j++) {
					idScale = "chan" + j + "-scale";
					if (this.id === idScale) {
						this.style.color = chan[j % chan.length ].color;
						document.getElementById("chan" + j + "-offset").onchange(ev);
					} else
						document.getElementById(idScale).style.color = chan[j % chan.length ].shaded;
				}
		}
	}
	body = document.getElementsByTagName("body");

	'<div id="hola" style="margin:1pt;display:inline-block;text-align:left">';
	for (i = 0; i < inputs; i++) {
		.innerHTML = vtChannelHTML (i, color[i]);
	}
	pp = pp + '</div>';
	body[0].innerHTML = pp;

	for (i=0; i < inputs; i++) {
		document.getElementById("chan" + i + "-unit").onchange = function(ev) {
			send ("unit", (parseInt(this.value)+16)%16, this.id.match(/\d+/)[0]);
		}

		document.getElementById("chan" + i + "-offset").onchange = function(ev) {
			send ("offset", (parseInt(this.value)+256)%256, this.id.match(/\d+/)[0] );
			document.getElementById("chan" + this.id.match(/\d+/)[0] + "-unit").onchange(ev);
		}

		document.getElementById("chan" + i + "-level").onchange = function(ev) {
			send ("level", (parseInt(this.value)+256)%256, this.id.match(/\d+/)[0], document.getElementById("chan" + this.id.match(/\d+/)[0] + "-slope").value);
		}

		document.getElementById("chan" + i + "-slope").onchange = function(ev) {
			document.getElementById("chan" + this.id.match(/\d+/)[0] + "-level").onchange(ev);
		}

	}

	document.getElementById("time").addEventListener("wheel",
		function (e) { 
			this.value = parseInt(this.value) + parseInt(((e.deltaY > 0) ? 1 : -1)); 
			this.onchange(e);
		},
		false);
	document.getElementById("time").onchange = function(ev) {
		console.log("pase por aca");
		send("time", parseInt(this.value));
	}



});
