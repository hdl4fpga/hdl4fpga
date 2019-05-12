// Asynchronous communication
//

const SerialPort = require('serialport')
const Readline   = require('@serialport/parser-readline'); 
const uart       = new SerialPort("/dev/ttyUSB0", { baudRate : 115200 } )
const parser     = new Readline();

const baudRates  = [ 9600, 38400, 115200 ];
// TCP/IP communication
//

const dgram = require('dgram');
var udpsckt = dgram.createSocket('udp4');

var host = "kit";
var port = 57001;

window.addEventListener("load", function() {

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

	function send (data) {
		var buffer = Buffer.alloc(data.length+2);
		console.log(buffer.length);

		console.log(data);
		for (i=0; i < data.length; i++)
			buffer[i] = data[i];

		buffer[i++] = 0xff;
		buffer[i++] = 0xff;

//		udpsckt.send(buffer, port, host, function(err, bytes) {
//			if (err) throw err;
//			console.log('UDP message has been sent');
//		});
		streamo(buffer);
	}

	function linkOnChange(e) {
		var e = document.getElementById("link-param");
		e.innerHTML = "";
		switch (parseInt(this.value)) {
		case 0: // UART
			console.log("pase");

			var u = document.createElement("select");
			u.id = "uart";
			e.appendChild(u);
			SerialPort.list(function (err, ports) {
				var o;

				for (i=0; i < ports.length; i++) {
					o = document.createElement("option");
					o.text = ports[i].comName;
					u.add(o, i);
			//		console.log(ports[i]);
				}
			});

			var o;
			s = document.createElement("select");
			s.id = "baudRate";
			e.appendChild(s);
			for (i=0; i < baudRates.length; i++) {
				o = document.createElement("option");
				o.text = baudRates[i];
				s.add(o, i);
			}
		break;
		case 1: // TCPIP
			var o;

			o = document.createTextNode("IP address");
			e.appendChild(o);
			o = document.createElement("input");
			o.id = "ipaddress";
			e.appendChild(o);
		break; }
	}
	

	function mouseWheelCb (e) {

		console.log("mouseWheel");
		if (this.length === undefined) {
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

	e = document.getElementById("link");
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
