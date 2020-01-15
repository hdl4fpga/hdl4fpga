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

var SerialPort;
var Readline;
var parser;

try {
	SerialPort = require('serialport')
	Readline   = require('@serialport/parser-readline'); 
	parser     = new Readline();
}
catch(e) {
	console.log("SerialPort was not loaded");
}

var http    = require('http').createServer(handler);
var fs      = require('fs');
var io      = require('socket.io')(http)
var commjs  = require('../scope/comm.js');

commjs.listUART();
http.listen(8080);

function handler (req, res) { //create server
	function fsCallback(err, data) { 
		if (err) {
			console.log("*****" + err);
			  res.writeHead(404, {'Content-Type': 'text/html'});
			  return res.end("404 Not Found");
		}
		res.writeHead(200, {'Content-Type': 'text/html'});
		res.write(data);
		return res.end();
	}

	switch(req.url) {
	case '/' :
		fs.readFile(__dirname + '/../scope/main.html', fsCallback);
		break;
	case '/comm.js' :
		console.log(req.url);
		fs.readFile(__dirname + '/comm.js', fsCallback);
		break;
	default :
		fs.readFile(__dirname + '/../scope' + req.url, fsCallback);
		break;
	}
}

io.sockets.on('connection', function (socket) {
	socket.on('listUART', function(data) { 
		console.log(commjs);
		commjs.listUART().then((ports) => {
			socket.emit('listUART', ports);
			console.log(ports);
		});
	});

	socket.on('createUART', function(data) { 
		commjs.createUART(data.uartName, data.options);
	});

	socket.on('send', function(data) { 
		commjs.send(data.data);
	});

});
