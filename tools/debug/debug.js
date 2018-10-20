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

		console.log("mouseWheel");
		this.value = parseInt(this.value) + parseInt(((e.deltaY > 0) ? -1 : 1));
		console.log (this.value);
		this.onchange(e);
	}

	function axisOnChange (e) {

		var data = [];
		var	e;

		data.push(16);
		data.push(3-1);

		var value;

		value = 0;
		e = document.getElementById("axis");
		value |= ((parseInt(e.value) & 0x1) << 4);
		e = document.getElementById("scale");
		value |= (parseInt(e.value) & 0xf);
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

	function paletteOnChange (e) {

		var data = [];
		var	e;

		data.push(17);
		data.push(1-1);

		var value;

		value = 0;
		e = document.getElementById("palette_id");
		value |= (parseInt(e.value) & 0x7);
		e = document.getElementById("palette_color");
		value |= ((parseInt(e.value) & 0x7) << 3);
		data.push(value & 0xff);

		send(data);
	}

	function gainOnChange (e) {

		var data = [];
		var	e;

		data.push(19);
		data.push(1-1);

		var value;

		value = 0;
		e = document.getElementById("gain");
		value |= (parseInt(e.value) & 0xff);
		data.push(value & 0xff);

		send(data);
	}

	function triggerOnChange (e) {

		var data = [];
		var	e;

		data.push(18);
		data.push(1-1);

		var value;

		value = 0;
		e = document.getElementById("trigger");
		value |= (parseInt(e.value) & 0xff);
		data.push(value & 0xff);

		send(data);
	}

	var e;
	
	e = document.getElementById("gain");
	e.onchange = gainOnChange;
	e.addEventListener("wheel", mouseWheelCb, false);

	e = document.getElementById("axis");
	e.onchange = axisOnChange;
	e.addEventListener("wheel", mouseWheelCb, false);

	e = document.getElementById("scale");
	e.onchange = axisOnChange;
	e.addEventListener("wheel", mouseWheelCb, false);

	e = document.getElementById("offset");
	e.onchange = axisOnChange;
	e.addEventListener("wheel", mouseWheelCb, false);

	e = document.getElementById("palette_id");
	e.onchange = paletteOnChange;

	e = document.getElementById("palette_color");
	e.onchange = paletteOnChange;
	e.addEventListener("wheel", mouseWheelCb, false);
});
