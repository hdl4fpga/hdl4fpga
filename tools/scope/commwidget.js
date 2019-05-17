commWidget.prototype.uartOnChange =  function (e) {
	let uart     = this.uart.options[this.uart.selectedIndex].text;
	let baudrate = this.baudrate.options[this.baudrate.selectedIndex].text;

	createUART( uart, { baudRate : parseInt(baudrate) });
}

function commWidget(comm) {
	this.main = document.createElement("div");

	switch (comm) {
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
		o.type = "text";
		o.id   = "host";
		o.size = 16;
		this.main.appendChild(o);
		this.host = o;
		break; 
	}
}

commWidget.prototype.uartOnChange =  function (e) {
	let uart     = this.uart.options[this.uart.selectedIndex].text;
	let baudrate = this.baudrate.options[this.baudrate.selectedIndex].text;

	createUART( uart, { baudRate : parseInt(baudrate) });
}
