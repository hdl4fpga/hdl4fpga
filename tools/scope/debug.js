const dgram = require('dgram');
var client  = dgram.createSocket('udp4');

var buffer = Buffer.alloc(7);
var host = "kit";
var port = 57001;

i=0;
buffer[i++] = 0;
buffer[i++] = 1;
buffer[i++] = 0;
buffer[i++] = 0;

buffer[i++] = 1;
buffer[i++] = 0
buffer[i++] = 0x41;

client.send(buffer, port, host , function(err, bytes) {
	if (err) throw err;
	console.log('UDP message sent to ' + host +':'+ "57001");
});

