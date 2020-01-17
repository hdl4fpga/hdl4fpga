const SerialPort = require('serialport')
const Readline   = require('@serialport/parser-readline'); 
const com = new SerialPort("/dev/ttyUSB0", { baudRate : 115200 } )
const parser = new Readline();
var buffer = Buffer.alloc(1);
for (i = 0; i < 256; i++) {
buffer[0] = i;
com.write(buffer);
}
//com.write(String.fromCharCode(0xc1));
