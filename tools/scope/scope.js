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


function mouseWheel (e) {
	if (typeof this.value !== 'undefined') {
		console.log(typeof this.value);
		this.value = parseInt(this.value) + parseInt(((e.deltaY > 0) ? 1 : -1));
	}
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
		console.log(this.id);
		console.log(this.value);
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
			enable : 0,
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
		sendRegister(registers.hzaxis, { 
			scale  : this.hscale.value,
			offset : this.hoffset.value });
		break;
	case 'label' :

		this.colors.value  = parseInt(this.colors.value) + parseInt(((e.deltaY > 0) ? 1 : -1));
		this.colors.value += colorTab.length;
		this.colors.value %= colorTab.length;

		console.log(this.colors.value);
		var pid = param[2];
		switch(param[1]) {
		case 'channel' :
			pid += Object.keys(objects).length;
			this.colors.vtaxis.style['border']  = 'solid ' + colorTab[this.colors.value];
			break;
		case 'hzaxis' :
			pid = objects.horizontalfg.pid; 
			this.colors.hzaxis.style['border']  = 'solid ' + colorTab[this.colors.value];
			break;
		}
		sendRegister(registers.palette, { 
			opacityena  : 1,
			colorena    : 1,
			opacity     : 1,
			pid         : pid,
			color       : this.colors.value });
		console.log(param);
		break;
	case 'color' :

		var pid = objects[param[1]]['pid'];
		this.colors.value  = parseInt(this.colors.value) + parseInt(((e.deltaY > 0) ? 1 : -1));
		this.colors.value += colorTab.length;
		this.colors.value %= colorTab.length;

		console.log(this.colors.value);
		this.colors.color.style['background-color']  = colorTab[this.colors.value];
		sendRegister(registers.palette, { 
			opacityena  : 1,
			colorena    : 1,
			opacity     : 1,
			pid         : pid,
			color       : this.colors.value });
		console.log(param);
		break;
	}

	console.log(param[0]);
}

var commParam;
var langSel;
var inputNum;
var hz;
var vt = [];

function onChangeInputs () {
	let e;

	e  = document.getElementById("hzcontrol");
	e.innerHTML = '';
	hz = new hzControl(e);
	hz.mousewheel(mouseWheel);
	hz.onclick(onClick);
	hz.onchange(onClick);
	e  = document.getElementById("vtcontrol");
	e.innerHTML = '';
	for (i=0; i < parseInt(inputNum.value); i++) {
		if (i == 4)
			e.appendChild(document.createElement("BR"));
		vt = new vtControl(e, i, '#ffffff');
		vt.mousewheel(mouseWheel);
		vt.onclick(onClick);
		vt.onchange(onClick);
	}

}

function onchangeComm () {
	var commOption = (this.options[this.selectedIndex].text);
	setCommOption(commOption);
	commParam  = new commWidget (commOption);
	e = document.getElementById("comm-param");
	e.innerHTML = "";
	e.appendChild(commParam.main);
}

function onChangeLangSel () {
	var lang = (this.options[this.selectedIndex].text);
	setLang(lang);
	generate();
}

function generate ()
{
	var lang = getLang();

	inputNumLbl = document.getElementById("inputnumlbl");
	inputNumLbl.innerHTML = i18n.inputs[lang]; 

	onChangeInputs();

	e  = document.getElementById("palette");
	e.innerHTML = '';
	console.log(objects);
	Object.keys(objects).forEach(function(key) {
		palette = new paletteControl(e, key, objects[key]['defcolor']);
		palette.mousewheel(mouseWheel);
		palette.onclick(onClick);
	});

}

window.addEventListener("load", function() {
	let e;

	e = document.getElementById("comm-select");
	e.onchange = onchangeComm;
	e.onchange();

	inputNum = document.getElementById("inputnum");
	inputNum.onchange  = onChangeInputs;

	langSel = document.getElementById("lang-select");
	langSel.onchange  = onChangeLangSel;

	generate();

});
