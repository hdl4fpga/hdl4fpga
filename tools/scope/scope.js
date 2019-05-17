const inputs = 9;

function mouseWheelCb (e) {

	console.log("mouseWheel");
	if (typeof this.length === 'undefined') {
		this.value = parseInt(this.value) + parseInt(((e.deltaY > 0) ? -1 : 1));
	} else {
		var value = parseInt(this.value);
		value += parseInt(((e.deltaY > 0) ? 1 : (this.length-1)));
		value %= this.length;
		this.value = value;
	}
	this.onchange(e);
}

window.addEventListener("load", function() {

	body = document.getElementsByTagName("body");
	vt = new vtControl(body[0], 1, '#ffffff');
	vt.mousewheel(1, mouseWheel);
	vt.onfocus();

	function onchangeComm () {
		w = new commWidget(this.options[this.selectedIndex].text);
		e = document.getElementById("comm-param");
		e.innerHTML = "";
		e.appendChild(w.main);
	}

	e = document.getElementById("comm-select");
//	e.addEventListener("wheel", mouseWheelCb, false);
	e.onchange = onchangeComm;
	w = new commWidget(e.options[e.selectedIndex].text);
	e = document.getElementById("comm-param");
	e.innerHTML = "";
	e.appendChild(w.main);

});
