// Copyright (c) 2015 Miguel Angel Sagreras                                       //
//                                                                                //
// Permission is hereby granted, free of charge, to any person obtaining a copy   //
// of this software and associated documentation files (the "Software"), to deal  //
// in the Software without restriction, including without limitation the rights   //
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      //
// copies of the Software, and to permit persons to whom the Software is          //
// furnished to do so, subject to the following conditions:                       //
//                                                                                //
// The above copyright notice and this permission notice shall be included in all //
// copies or substantial portions of the Software.                                //
//                                                                                //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     //
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       //
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    //
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         //
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  //
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  //
// SOFTWARE.                                                                      //
//                                                                                //

commWidget.prototype.uartOnChange = function (e) {
	let uart     = this.uart.options[this.uart.selectedIndex].text;
	let baudrate = this.baudrate.options[this.baudrate.selectedIndex].text;

	createUART( { 
		path     : uart, 
		baudRate : parseInt(baudrate) });
}

commWidget.prototype.hostOnInput = function (e) {
//	console.log(this.value);
	setHost(this.value);
}


function commWidget(commOption) {
	this.main = document.createElement("div");

	switch (commOption) {
	case 'UART': // UART
		if (typeof io === 'undefined')
			if (typeof SerialPort === 'undefined')
				break;

		let baudRates  = [ 9600, 38400, 115200 ];

		delete this.host;

		let u = document.createElement("select");
		u.onchange = this.uartOnChange;
		u.id = "uart";
		this.main.appendChild(u);

		let b = document.createElement("select");
		b.onchange = this.uartOnChange;
		b.id = "baudRate";
		this.main.appendChild(b);

		for (i=0; i < baudRates.length; i++) {
			let o;
			o = document.createElement("option");
			o.text = baudRates[i];
			b.add(o, i);
		}
		b.value = 115200;

		u.uart     = u;
		u.baudrate = b;
		b.uart     = u;
		b.baudrate = b;
		listUART().then(function (ports) {
			let o;

			console.log(ports);
			for (i=0; i < ports.length; i++) {
				o = document.createElement("option");
				o.text = ports[i].path;
				u.add(o, i);
			}

			return createUART(
				{ path     : u.options[u.selectedIndex].text, 
				  baudRate : parseInt(b.options[b.selectedIndex].text) });
		});
		break;
	case 'TCPIP': // TCPIP

		delete this.uart;
		delete this.baudrate;

		let o;

		o = document.createTextNode("HOST ");
		this.main.appendChild(o);

		o = document.createElement("input");
		o.type    = "text";
		o.id      = "host";
		o.size    = 16;
		o.oninput = this.hostOnInput;
		this.main.appendChild(o);

		break; 
	case 'USB':
		console.log("***************");
		openUSB();
		break;
	}
	return commOption;
}

commWidget.prototype.uartOnChange =  function (e) {
	let uart     = this.uart.options[this.uart.selectedIndex].text;
	let baudrate = this.baudrate.options[this.baudrate.selectedIndex].text;

	createUART( { 
		path     : uart, 
		baudRate : parseInt(baudrate) });
}
