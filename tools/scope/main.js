window.addEventListener("load", function() {
	var connect = document.getElementById("connect");
	var address = document.getElementById("address");

	connect.onclick = function(ev) {
		var socket = chrome.sockets.udp;
		console.log("onclick");
	};

	address.onkeydown = function(ev) {
		console.log("onkeydown");
	};

});
