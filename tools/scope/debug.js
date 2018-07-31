const dgram = require('dgram');
var client  = dgram.createSocket('udp4');

var host = "kit";
var port = 57001;

var msg = Buffer.from("Fabian no hagas marinadas", 'utf-8');
var pos = 240;
var i = 0;
var j = 0;

//for (j=0 ; j < msg.length; j++) {
	var buffer = Buffer.alloc(9);

	i=0;
	buffer[i++] = 1;
	buffer[i++] = 1;
	buffer[i++] = pos >> 8;
	buffer[i++] = pos &  0xff;

	buffer[i++] = 0;
	buffer[i++] = 0
	buffer[i++] = 0xf1;
	buffer[i++] = 0xff;
	buffer[i++] = 0xff;

	client.send(buffer, port, host , function(err, bytes) {
		if (err) throw err;
		console.log('UDP message has been sent');
	});

	pos++;
//}

