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

var ws = io();

function rpcScopeIO(eventName, arg)
{
	const timeoutMs = 10000;
	return new Promise((resolve, reject) => {
		if (!ws.connected) {
			reject(new Error('Socket is not connected'));
			return;
		}

		let settled = false;
		const cleanup = () => {
			clearTimeout(timer);
			ws.off('disconnect', onDisconnect);
			ws.off('connect_error', onConnectError);
		};
		const settle = (fn, value) => {
			if (settled) return;
			settled = true;
			cleanup();
			fn(value);
		};
		const onDisconnect = (reason) => settle(reject, new Error('Socket disconnected: ' + reason));
		const onConnectError = (error) => settle(reject, error instanceof Error ? error : new Error(String(error)));
		const timer = setTimeout(() => settle(reject, new Error(eventName + ' timed out')), timeoutMs);

		ws.once('disconnect', onDisconnect);
		ws.once('connect_error', onConnectError);
		ws.emit(eventName, arg, (response) => {
			if (!response || response.ok !== true) {
				const message = response && response.error ? response.error : 'Invalid RPC acknowledgement';
				settle(reject, new Error(message));
				return;
			}
			settle(resolve, response.value);
		});
	});
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
