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

var ws = io();

function rpcScopeIO(eventName, arg) {
	console.log(eventName);
	ws.emit(eventName, arg);

	let retval;

	ws.once(eventName, function(data) { retval = data } );

	return retval;
}

function createUART(uartName, options) {
	return rpcScopeIO("createUART", [ uartName, options ]);
}

function send(data) {
	return rpcScopeIO("send", [ data ] );
}

function listUART () {
	return rpcScopeIO( "listUART", [ ] );
}

function setHost(name) {
	return rpcScopeIO("setHost", [ name ] );
}

function setCommOption(option) {
	return rpcScopeIO( "setCommOption", [ option ] );
}

