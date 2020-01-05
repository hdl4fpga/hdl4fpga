//                                                                            //
// Author(s):                                                                 //
//   Miguel Angel Sagreras                                                    //
//                                                                            //
// Copyright (C) 2015                                                         //
//    Miguel Angel Sagreras                                                   //
//                                                                            //
// This source file may be used and distributed without restriction provided  //
// that this copyright statement is not removed from the file and that any    //
// derivative work contains  the original copyright notice and the associated //
// disclaimer.                                                                //
//                                                                            //
// This source file is free software; you can redistribute it and/or modify   //
// it under the terms of the GNU General Public License as published by the   //
// Free Software Foundation, either version 3 of the License, or (at your     //
// option) any later version.                                                 //
//                                                                            //
// This source is distributed in the hope that it will be useful, but WITHOUT //
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      //
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   //
// more details at http://www.gnu.org/licenses/.                              //
//                                                                            //

commWidget.prototype.uartOnChange = function (e) {
	let uart     = this.uart.options[this.uart.selectedIndex].text;
	let baudrate = this.baudrate.options[this.baudrate.selectedIndex].text;

	createUART( uart, { baudRate : parseInt(baudrate) });
}

commWidget.prototype.hostOnInput = function (e) {
//	console.log(this.value);
	setHost(this.value);
}


function commWidget(commOption) {
	this.main = document.createElement("div");

	switch (commOption) {
	case 'UART': // UART
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

			for (i=0; i < ports.length; i++) {
				o = document.createElement("option");
				o.text = ports[i].comName;
				u.add(o, i);
			}

			createUART(
				u.options[u.selectedIndex].text, 
				{ baudRate : parseInt(b.options[b.selectedIndex].text) });
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
	}
}

commWidget.prototype.uartOnChange =  function (e) {
	let uart     = this.uart.options[this.uart.selectedIndex].text;
	let baudrate = this.baudrate.options[this.baudrate.selectedIndex].text;

	createUART(uart, { baudRate : parseInt(baudrate) });
}
