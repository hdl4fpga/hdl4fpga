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

const i18n = {
	'horizontal' : { en : 'Horizontal', es : 'Horizontal' },
	'level'      : { en : 'Level',      es : 'Nivel'      },
	'offset'     : { en : 'Offset',     es : 'Posición'   },
	'scale'      : { en : 'Scale',      es : 'Escala'     },
	'trigger'    : { en : 'Trigger',    es : 'Disparo'    },
	'vertical'   : { en : 'Vertical',   es : 'Vertical'   } };

const lang = 'en';

function hzControl (parent, color) {

	this.wrapper = {};
	this.inputControl = {};

	t = document.createElement("div");
	t.style['text-align']       = 'center'
	t.style['margin']           = '3pt';
	t.style['padding']          = '0pt';
	t.style['background-color'] = '#080808';
	t.style['display']          = 'inline-block';
	t.style['vertical-align']   = 'top';
	t.style['border']           = 'solid #888888 1pt';
	t.style['color']            = '#ffffff';
	parent.appendChild(t);

	p = document.createElement("div");
	p.style['padding']          = '1pt';
	p.style['display']          = 'inline-block';
	p.style['vertical-align']   = 'top';
	t.appendChild(p);
	t = p;

	p = document.createElement("div");
	p.style['display']          = 'inline-block';
	p.style['padding']          = '1pt';
	p.style['vertical-align']   = 'top';
	t.appendChild(p);

	i           = document.createElement("input");
	i.id        = "time";
	i.type      = "range"
	i.className = "vertical";
	i.value     = 0;
	i.min       = 0;
	i.max       = 15;
	p.appendChild(i);
	this.inputControl['time'] = i;

	i = document.createElement("label");
	i.style['display'] = 'block';
	i.appendChild(document.createTextNode(i18n.scale[lang]));
	p.appendChild(i);

	p = document.createElement("div");
	p.style['display']          = 'inline-block';
	p.style['padding']          = '1pt';
	p.style['vertical-align']   = 'top';
	t.appendChild(p);

	i           = document.createElement("input");
	i.id        = "time";
	i.type      = "range"
	i.className = "vertical";
	i.value     = 0;
	i.min       = 0;
	i.max       = 15;
	p.appendChild(i);
	this.inputControl['offset'] = i;

	i = document.createElement("label");
	i.style['display'] = 'block';
	i.appendChild(document.createTextNode(i18n.offset[lang]));
	p.appendChild(i);

	p = document.createElement("label");
	p.style['display'] = 'block';
	p.appendChild(document.createTextNode(i18n.horizontal[lang]));
	t.appendChild(p);
}

hzControl.prototype.mousewheel = function (number, callback) {
	this.inputControl['time'].addEventListener("wheel", callback, false);
	this.inputControl['offset'].addEventListener("wheel", callback, false);
}

function vtControl (parent, number, color) {
	this.wrapper = {};
	this.inputControl = {};

	t = document.createElement("div");
	t.style['text-align']       = 'center';
	t.style['padding']          = '0pt';
	t.style['margin']           = '1pt';
	t.style['background-color'] = '#444444';
	t.style['display']          = 'inline-block';
	t.style['vertical-align']   = 'top'; 
	t.style['color']            =  color;
	t.style['border']           = 'solid #404040 1pt'
	parent.appendChild(t);

	// Scale
	// -----
	
	p = document.createElement("div");
	p.id = number+'scale',
	p.style['background-color'] = '#080808';
	p.style['padding']          = '2pt';
	p.style['margin']           = '0pt';
	p.style['display']          = 'inline-block';
	p.style['border']           = 'solid #888888 1pt';
	p.style['display']          = 'inline-block';
	p.style['vertical-align']   = 'top';
	t.appendChild(p);
	this.wrapper['scale'] = p;
	
	c = document.createElement("div");
	c.style['display']        = 'inline-block';
	c.style['vertical-align'] = 'top';
	p.appendChild(c);

	chanInput = document.createElement("input");
	chanInput['id']        = number+':gain';
	chanInput['type']      = 'range';
	chanInput['className'] = 'vertical';
	chanInput['value']     = 0;
	chanInput['min']       = 0;
	chanInput['max']       = 15;
	c.appendChild(chanInput);
	this.inputControl['gain'] = chanInput;
	
	labelUnit = document.createElement("label");
	labelUnit.style['display'] = 'block';
	labelUnit.appendChild(document.createTextNode(i18n.scale[lang]));
	c.appendChild(labelUnit);

	c = document.createElement("div");
	c.style['display']        = 'inline-block';
	c.style['vertical-align'] = 'top';
	p.appendChild(c);

	chanInput = document.createElement("input");
	chanInput['id']        =  number+':offset';
	chanInput['type']      = 'range';
	chanInput['className'] = 'vertical';
	chanInput['value']     = 0;
	chanInput['min']       = -128;
	chanInput['max']       =  128;
	c.appendChild(chanInput);
	this.inputControl['offset'] = chanInput;

	labelUnit = document.createElement("label");
	labelUnit.style['display'] = 'block';
	labelUnit.appendChild(document.createTextNode(i18n.offset[lang]));
	c.appendChild(labelUnit);

	labelScale = document.createElement("label");
	labelScale.style['display']='block';
	labelScale.appendChild(document.createTextNode(i18n.vertical[lang]));
	p.appendChild(labelScale);

	// Trigger
	// ------

	p = document.createElement("div");
	p.id = number+':trigger',
	p.style['background-color'] = '#080808';
	p.style['padding']          = '2pt';
	p.style['margin']           = '0pt';
	p.style['display']          = 'inline-block';
	p.style['border']           = 'solid #888888 1pt';
	p.style['display']          = 'inline-block';
	p.style['vertical-align']   = 'top';
	t.appendChild(p);
	this.wrapper['trigger'] = p;
	
	c = document.createElement("div");
	c.style['display']        = 'inline-block';
	c.style['vertical-align'] = 'top';
	p.appendChild(c);

	chanInput = document.createElement("input");
	chanInput['id']        = number:'level';
	chanInput['type']      = 'range';
	chanInput['className'] = 'vertical';
	chanInput['value']     = 0;
	chanInput['min']       = 0;
	chanInput['max']       = 15;
	c.appendChild(chanInput);
	this.inputControl['level'] = chanInput;
	
	labelUnit = document.createElement("label");
	labelUnit.style['display'] = 'block';
	labelUnit.appendChild(document.createTextNode(i18n.level[lang]));
	c.appendChild(labelUnit);

	c = document.createElement("div");
	c.style['display']        = 'inline-block';
	c.style['vertical-align'] = 'top';
	p.appendChild(c);

	chanInput = document.createElement("input");
	chanInput['id']        = number:'slope';
	chanInput['type']      = 'range';
	chanInput['className'] = 'vertical';
	chanInput['value']     = 0;
	chanInput['min']       = 0;
	chanInput['max']       =  1;
	c.appendChild(chanInput);
	this.inputControl['slope'] = chanInput;

	labelUnit = document.createElement("label");
	labelUnit.style['display'] = 'block';
	labelUnit.appendChild(document.createTextNode(i18n.offset[lang]));
	c.appendChild(labelUnit);

	labelScale = document.createElement("label");
	labelScale.style['display']='block';
	labelScale.appendChild(document.createTextNode(i18n.trigger[lang]));
	p.appendChild(labelScale);

}

vtControl.prototype.onclick = function (callback = function(ev) { console.log(this.parentElement.parentElement); this.parentElement.parentElement.onclick(ev); }) {
	this.wrapper['scale'].onclick   = callback;
	this.wrapper['trigger'].onclick = callback;
	this.wrapper['scale'].addEventListener("wheel", chanSelect, false);
	this.wrapper['trigger'].addEventListener("wheel", chanSelect, false);
}

vtControl.prototype.onfocus = function (callback = function(ev) { console.log(this.parentElement.parentElement); this.parentElement.parentElement.onclick(ev); }) {
	this.inputControl['gain'].onfocus   = callback;
	this.inputControl['offset'].onfocus = callback;
	this.inputControl['level'].onfocus  = callback;
	this.inputControl['slope'].onfocus  = callback;
}

vtControl.prototype.mousewheel = function (number, callback) {
	this.inputControl['gain'].addEventListener("wheel", callback, false);
	this.inputControl['offset'].addEventListener("wheel", callback, false);
	this.inputControl['level'].addEventListener("wheel", callback, false);
	this.inputControl['slope'].addEventListener("wheel", callback, false);
}

function mouseWheel (e) {
	this.value = parseInt(this.value) + parseInt(((e.deltaY > 0) ? 1 : -1));
}
