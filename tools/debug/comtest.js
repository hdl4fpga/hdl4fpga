const SerialPort = require('serialport')
const Readline   = require('@serialport/parser-readline'); 
const com = new SerialPort("/dev/ttyUSB0", { baudRate: 115200 })
const parser = new Readline();
com.write('A');
