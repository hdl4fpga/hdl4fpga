// Asynchronous communication
//

const SerialPort = require('serialport')
const Readline   = require('@serialport/parser-readline'); 
const parser     = new Readline();


var  uart;

function streamout (buffer) {

	function logwrite (buffer) {
		const buf = Buffer.alloc(1,buffer);
		console.log(buf);
		uart.write(buf);
	}


	const esc = Buffer.alloc(1,0x5c);	// ASCII code for "\"
	const eos = Buffer.alloc(1,0x00);	// ASCII code for NUL

	for (i = 0; i < buffer.length; i++) {
		if (buffer[i] == esc[0] || buffer[i] == eos[0]) {
			logwrite(esc);
		}
		logwrite(buffer[i]);
	}
	logwrite(eos);
}

// TCP/IP communication
//

const dgram = require('dgram');
var udpsckt = dgram.createSocket('udp4');


window.addEventListener("load", function() {

	function send (data) {
		console.log(data);

		var e = document.getElementById("link-select");
		switch (parseInt(e.value)) {
		case 0:
			var buffer = Buffer.from(data);
			streamout(buffer);
			break;
		case 1:
			const ipport = 57001;
			h = document.getElementById("host");
			console.log(h.value);
			var buffer = Buffer.alloc(data.length+2);
			for (i=0; i < data.length; i++)
				buffer[i] = data[i];

			buffer[i++] = 0xff;
			buffer[i++] = 0xff;
			udpsckt.send(buffer, ipport, h.value, function(err, bytes) {
				if (err) throw err;
				console.log('UDP message has been sent');
			});
			break;
		}

	}

	function uartOnChange(e) {
		if (typeof uart !== 'undefined') {
			uart.close();
		}
		var u = document.getElementById("uart");
		console.log(u.options[u.selectedIndex].text);
		var b = document.getElementById("baudRate");
		console.log(b.options[b.selectedIndex].text);
		uart = new SerialPort(
			u.options[u.selectedIndex].text,
			{ baudRate : parseInt(b.options[b.selectedIndex].text) });
	}

	function createLinkDiv(link) {
		if (typeof uart !== 'undefined') {
			uart.close();
		}

		var e = document.getElementById("link-param");
		e.innerHTML = "";

		switch (parseInt(link.value)) {
		case 0: // UART
			let u = document.createElement("select");
			u.onchange = uartOnChange;
			u.id = "uart";
			e.appendChild(u);

			let b = document.createElement("select");
			b.onchange = uartOnChange;
			b.id = "baudRate";
			e.appendChild(b);

			for (i=0; i < baudRates.length; i++) {
				let o;
				o = document.createElement("option");
				o.text = baudRates[i];
				b.add(o, i);
			}

			SerialPort.list().then(function (ports) {
				var o;

				for (i=0; i < ports.length; i++) {
					o = document.createElement("option");
					o.text = ports[i].comName;
					u.add(o, i);
				}

				console.log(u.options[u.selectedIndex].text);
				console.log(b.options[b.selectedIndex].text);

				uart = new SerialPort(
					u.options[u.selectedIndex].text, 
					{ baudRate : parseInt(b.options[b.selectedIndex].text) });
			});
		break;
		case 1: // TCPIP
			let o;

			o = document.createTextNode("HOST ");
			e.appendChild(o);
			o = document.createElement("input");
			o.type = "text";
			o.id = "host";
			o.size = 16;
			e.appendChild(o);
			break; 
		}
	}

	function linkOnChange(e) {
		createLinkDiv(this);
	}
	

	function mouseWheelCb (e) {

		console.log("mouseWheel");
		if (typeof this.length === 'undefined') {
			this.value = parseInt(this.value) + parseInt(((e.deltaY > 0) ? -1 : 1));
		} else {
			var value = parseInt(this.value);
			value += parseInt(((e.deltaY > 0) ? 1 : (this.length-1)));
			value %= this.length;
			this.value = value;
		}
		this.onchange(e);
	}

	function axisOnChange (e) {

		var data = [];
		var	e;

		var value;

		e = document.getElementById("axis");

		switch(parseInt(e.value)) {
		case 0:
			data.push(0x10);
			data.push(3-1);

			value = 0;
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

			break;
		case 1:
			data.push(0x14);
			data.push(2-1);

			value = 0;
			e = document.getElementById("scale");
			value |= ((parseInt(e.value) & 0xf) << 5);

			e = document.getElementById("offset");
			value |= (parseInt(e.value) >> 8 ) & ((1 << 5)-1);
			data.push(value & 0xff);

			value = 0;
			value |= parseInt(e.value);
			data.push(value & 0xff);

			break;
		}

		send(data);
	}

	function paletteOnChange (e) {

		var data = [];
		var	e;

		data.push(17);
		data.push(1-1);

		var value;

		value = 0;
		e = document.getElementById("palette_color");
		value |= ((parseInt(e.value) & ((1<<3)-1)) << 4);

		e = document.getElementById("palette_id");
		value |= ((parseInt(e.value) & ((1<<4)-1)) << 0);

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
		data.push(2-1);

		var value;

		value = 0;
		e = document.getElementById("trigger");
		value |= ((parseInt(e.value) & ((1 << 9)-1)) << 2);
		console.log(value);

		e = document.getElementById("trigger_enable");
		value |= ((parseInt(e.value) & ((1 << 1)-1)) << 0);

		e = document.getElementById("trigger_slope");
		value |= ((parseInt(e.value) & ((1 << 1)-1)) << 1);

		data.push((value >> 8) & 0xff);
		data.push((value >> 0) & 0xff);

		send(data);
	}

	var e;

	e = document.getElementById("link-select");
	createLinkDiv(e);
	e.onchange = linkOnChange;
	e.addEventListener("wheel", mouseWheelCb, false);
	
	e = document.getElementById("trigger");
	e.onchange = triggerOnChange;
	e.addEventListener("wheel", mouseWheelCb, false);
	
	e = document.getElementById("trigger_slope");
	e.onchange = triggerOnChange;
	e.addEventListener("wheel", mouseWheelCb, false);
	
	e = document.getElementById("trigger_enable");
	e.onchange = triggerOnChange;
	e.addEventListener("wheel", mouseWheelCb, false);
	
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
	e.addEventListener("wheel", mouseWheelCb, false);

	e = document.getElementById("palette_color");
	e.onchange = paletteOnChange;
	e.addEventListener("wheel", mouseWheelCb, false);
});
