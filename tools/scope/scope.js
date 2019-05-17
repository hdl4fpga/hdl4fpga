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

const inputs = 9;

var commParam;

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
	hz = new hzControl(body[0], 1, '#ffffff');
	hz.mousewheel(1, mouseWheel);
	for (i=0; i < 2; i++) {
		vt = new vtControl(body[0], 1, '#ffffff');
		vt.mousewheel(1, mouseWheel);
		vt.onfocus();
	}

	function onchangeComm () {
		commOption = (this.options[this.selectedIndex].text);
		commParam  = new commWidget (commOption);
		e = document.getElementById("comm-param");
		e.innerHTML = "";
		e.appendChild(commParam.main);
	}

	e = document.getElementById("comm-select");
//	e.addEventListener("wheel", mouseWheelCb, false);
	e.onchange = onchangeComm;
	w = new commWidget(e.options[e.selectedIndex].text);
	e = document.getElementById("comm-param");
	e.innerHTML = "";
	e.appendChild(w.main);

});
