// Copyright (c) <2015> <Miguel Angel Sagreras>                                    //
//                                                                                 //
// Permission is hereby granted, free of charge, to any person obtaining a copy of //
// this software and associated documentation files (the "Software"), to deal in   //
// the Software without restriction, including without limitation the rights to    //
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   //
// of the Software, and to permit persons to whom the Software is furnished to do  //
// so, subject to the following conditions:                                        //
//                                                                                 //
// The above copyright notice and this permission notice shall be included in all  //
// copies or substantial portions of the Software.                                 //
//                                                                                 //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    //
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        //
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     //
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          //
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   //
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   //
// SOFTWARE.                                                                       //
//                                                                                 //

var ws = io();

function rpcScopeIO(eventName, arg)
{
	var promise = new Promise((resolve, reject) => { ws.once(eventName, function(data) { resolve(data) }); });
	ws.emit(eventName, arg);
	return promise;
}

function createUART(uartName, options)
{
	return rpcScopeIO("createUART", { uartName : uartName, options : options });
}

function send(data)
{
//	setHost(hostName);
	return rpcScopeIO("send", { data : data } );
}

function listUART ()
{
	return rpcScopeIO( "listUART", { } );
}

function setHost(name)
{
	return rpcScopeIO("setHost", { name : name } );
}

function getHost()
{
	return rpcScopeIO("getHost", { } );
}

function setCommOption(option)
{
	return rpcScopeIO( "setCommOption", { option : option } );
}

