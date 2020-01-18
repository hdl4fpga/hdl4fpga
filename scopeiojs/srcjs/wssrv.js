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

var http    = require('http').createServer(handler);
var fs      = require('fs');
var io      = require('socket.io')(http)
var commjs  = require('./comm.js');

http.listen(8080);

function handler (req, res) { //create server
	function fsCallback(err, data) { 
		if (err) {
			  res.writeHead(404, {'Content-Type': 'text/html'});
			  return res.end("404 Not Found");
		}
		res.writeHead(200, {'Content-Type': 'text/html'});
		res.write(data);
		return res.end();
	}

	switch(req.url) {
	case '/' :
		fs.readFile(__dirname + '/../html/scopeio.html', fsCallback);
		break;
	case '/scopeio.css' :
		fs.readFile(__dirname + '/../html/scopeio.css', fsCallback);
		break;
	case '/srcjs/comm.js' :
		fs.readFile(__dirname + '/../srcjs/wscomm.js', fsCallback);
		break;
	default :
		fs.readFile(__dirname + '/../' + req.url, fsCallback);
		break;
	}
}

io.sockets.on('connection', function (socket) {
	socket.on('listUART', function(args) { 
		commjs.listUART().then((ports) => {
			socket.emit('listUART', ports);
		});
	});

	socket.on('createUART', function(args) { 
		commjs.createUART(args.uartName, args.options);
	});

	socket.on('setCommOption', function(args) { 
		commjs.setCommOption(args.option);
	});

	socket.on('send', function(args) { 
		commjs.send(args.data);
	});

	socket.on('setHost', function(args) { 
		commjs.setHost(args.uartName, args.name);
	});

	socket.on('getHost', function(args) { 
		commjs.getHost();
	});

});
