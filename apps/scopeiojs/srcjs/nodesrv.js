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
		commjs.setHost(args.name);
	});

	socket.on('getHost', function(args) { 
		commjs.getHost();
	});

});




