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

function mouseWheel (e) {
	this.value = parseInt(this.value) + parseInt(((e.deltaY > 0) ? 1 : -1));
	sendCommand.call(this, e);
}

function onClick(e) {
	sendCommand.call(this, e);
}

function sendCommand(e) {
	var param = this.id.split(':');
	var value = this.value;

	switch(param[0]) {
	case 'gain':
		sendRegister(registers.gain, {
			gain   : this.value,
			chanid : param[1] } );
		break;
	case 'offset':
		sendRegister(registers.vtaxis, {
			offset : this.value,
			chanid : param[1] } );
		break;
	case 'level':
	case 'slope':
		sendRegister(registers.trigger, { 
			level  : this.level.value,
			slope  : this.slope.value,
			enable : 1,
			chanid : param[1] });
		break;
	case 'vtaxis' :
		sendRegister(registers.vtaxis, { 
			offset : this.vtaxis.value,
			chanid : param[1] });
		break;
	case 'trigger' :
		sendRegister(registers.vtaxis, { 
			offset : this.trigger.value,
			chanid : param[1] });
		break;
	case 'hscale':
	case 'hoffset':
			console.log(this.hoffset.value);
		sendRegister(registers.hzaxis, { 
			scale  : this.hscale.value,
			offset : this.hoffset.value });
		break;
	case 'time' :
		sendRegister(registers.vtaxis, { 
			scale  : this.hscale.value,
			offset : this.hoffset.value });
		break;
	}

	console.log(param[0]);
}

function onchangeComm () {
	var commOption = (this.options[this.selectedIndex].text);
	setCommOption(commOption);
	commParam  = new commWidget (commOption);
	e = document.getElementById("comm-param");
	e.innerHTML = "";
	e.appendChild(commParam.main);

}

window.addEventListener("load", function() {

	body = document.getElementsByTagName("body");
	hz = new hzControl(body[0], 1, '#ffffff');
	hz.mousewheel(1, mouseWheel);
	hz.mousewheel(mouseWheel);
	hz.onclick(onClick);
	for (i=0; i < 2; i++) {
		vt = new vtControl(body[0], i, '#ffffff');
		vt.mousewheel(mouseWheel);
		vt.onclick(onClick);
	}

	e = document.getElementById("comm-select");
	e.onchange = onchangeComm;
	e.onchange();

});
