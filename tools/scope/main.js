chrome.app.runtime.onLaunched.addListener(function() {
	chrome.app.window.create('main.html', {
		id: "scope",
			innerBounds : {
				width   : 680,
				height  : 480 } } );
	});
