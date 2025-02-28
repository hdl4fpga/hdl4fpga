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

function mouseWheel (e) {
	if (typeof this.value !== 'undefined') {
		this.value = parseInt(this.value) + parseInt(((e.deltaY > 0) ? 1 : -1));
	}
	sendCommand.call(this, e);
}

function onClick(e) {
	console.log("onclick");
	sendCommand.call(this, e);
}

const gains = [1, 2, 4, 5, 10, 20, 40, 50, 100, 200, 400, 5000, 1000, 2000, 4000, 5000];
var gainid_tab = [];
function sendCommand(e) {
	var param = this.id.split(':');

	switch(param[0]) {
	case 'gain':
		sendRegister(registers.gain, {
			gain   : this.value,
			chanid : param[1] } );
		gainid_tab[param[1]] = this.value;
		break;
	case 'offset':
		sendRegister(registers.vtaxis, {
			offset : this.value,
			chanid : param[1] } );
		break;
	case 'normal+free' :
	case 'normal' :
	case 'one shot' :
	case 'freeze' :
		if (typeof gainid_tab[param[1]] === 'undefined') {
			gainid_tab[param[1]] = 0;
		}
		this.trigger.mode.value = param[0];
		sendRegister(registers.trigger, { 
			level   : this.trigger.level.value * gains[gainid_tab[param[1]]],
			slope   : (this.trigger.slope.value === "negative") ? 1 : 0,
			freeze  : (this.trigger.mode.value  === "one shot" || this.trigger.mode.value === "freeze") ? 1 : 0,
			oneshot : (this.trigger.mode.value  === "one shot" || this.trigger.mode.value === "normal") ? 1 : 0,
			chanid  : param[1] });
		break;
	case 'positive':
	case 'negative':
		if (typeof gainid_tab[param[1]] === 'undefined') {
			gainid_tab[param[1]] = 0;
		}
		this.trigger.slope.value = param[0];
		sendRegister(registers.trigger, { 
			level   : this.trigger.level.value * gains[gainid_tab[param[1]]],
			slope   : (this.trigger.slope.value === "negative") ? 1 : 0,
			freeze  : (this.trigger.mode.value  === "one shot" || this.trigger.mode.value === "freeze") ? 1 : 0,
			oneshot : (this.trigger.mode.value  === "one shot" || this.trigger.mode.value === "normal") ? 1 : 0,
			chanid  : param[1] });
		break;
	case 'level':
		if (typeof gainid_tab[param[1]] === 'undefined') {
			gainid_tab[param[1]] = 0;
		}
		sendRegister(registers.trigger, { 
			level   : this.trigger.level.value * gains[gainid_tab[param[1]]],
			slope   : (this.trigger.slope.value === "negative") ? 1 : 0,
			freeze  : (this.trigger.mode.value  === "one shot" || this.trigger.mode.value === "freeze") ? 1 : 0,
			oneshot : (this.trigger.mode.value  === "one shot" || this.trigger.mode.value === "normal") ? 1 : 0,
			chanid  : param[1] });
		break;
	case 'vtaxis' :
		sendRegister(registers.vtaxis, { 
			offset : this.vtaxis.value,
			chanid : param[1] });
		break;
	case 'hscale':
	case 'hoffset':
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

		var pid = Number(param[2]);
		switch(param[1]) {
		case 'channel' :
			pid += Object.keys(objects).length;
			this.colors.vtaxis.style['border']  = 'solid #' + colorTab[this.colors.value];
			break;
		case 'hzaxis' :
			pid = objects.horizontalfg.pid; 
			this.colors.hzaxis.style['border']  = 'solid #' + colorTab[this.colors.value];
			break;
		}
		// console.log("hola " + this.colors.value);
		sendRegister(registers.palette, { 
			opacityena  : 0,
			colorena    : 1,
			opacity     : 1,
			pid         : pid,
			color       : parseInt("0x" + colorTab[this.colors.value]) });
		break;
	case 'color' :

		var pid = Number(objects[param[1]]['pid']);
		this.colors.value  = parseInt(this.colors.value) + parseInt(((e.deltaY > 0) ? 1 : -1));
		this.colors.value += colorTab.length;
		this.colors.value %= colorTab.length;
		console.log("color : " + this.colors.value + " : " + parseInt("0x" + colorTab[this.colors.value]));

		this.colors.color.style['background-color']  = colorTab[this.colors.value];
		sendRegister(registers.palette, { 
			opacityena  : 0,
			colorena    : 1,
			opacity     : 1,
			pid         : pid,
			color       : parseInt("0x" + colorTab[this.colors.value]) });
			// color       : this.colors.value });
		break;
	default :
		console.log("Invalid : " + param[0]);
	}

	console.log("Param [0] : " + param[0]);
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
	if (typeof ws === 'undefined')  {
		if (typeof SerialPort ==='undefined')
			document.getElementById("UART").remove();
	}

	var commOption = (this.options[this.selectedIndex].text);
	console.log(commOption);
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

