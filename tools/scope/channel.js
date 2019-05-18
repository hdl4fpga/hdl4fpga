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
	p.style['padding']        = '1pt';
	p.style['display']        = 'inline-block';
	p.style['vertical-align'] = 'top';
	t.appendChild(p);
	t = p;

	p = document.createElement("div");
	p.style['display']        = 'inline-block';
	p.style['padding']        = '1pt';
	p.style['vertical-align'] = 'top';
	t.appendChild(p);

	hscale           = document.createElement("input");
	hscale.id        = "hscale";
	hscale.type      = "range"
	hscale.className = "vertical";
	hscale.value     = 0;
	hscale.min       = 0;
	hscale.max       = 15;
	p.appendChild(hscale);
	this.inputControl['hscale'] = hscale;

	i = document.createElement("label");
	i.style['display'] = 'block';
	i.appendChild(document.createTextNode(i18n.scale[lang]));
	p.appendChild(i);

	p = document.createElement("div");
	p.style['display']        = 'inline-block';
	p.style['padding']        = '1pt';
	p.style['vertical-align'] = 'top';
	t.appendChild(p);

	hoffset           = document.createElement("input");
	hoffset.id        = "hoffset";
	hoffset.type      = "range"
	hoffset.className = "vertical";
	hoffset.value     = 0;
	hoffset.min       = -(1 << 13);
	hoffset.max       = (1 << 13)-1;
	p.appendChild(hoffset);
	this.inputControl['hoffset'] = hoffset;

	hscale.hoffset  = hoffset;
	hscale.hscale   = hscale;
	hoffset.hoffset = hoffset;
	hoffset.hscale  = hscale;

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
	this.inputControl['hscale'].addEventListener("wheel", callback, false);
	this.inputControl['hoffset'].addEventListener("wheel", callback, false);
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

	gain = document.createElement("input");
	gain['id']        = 'gain:'+number;
	gain['type']      = 'range';
	gain['className'] = 'vertical';
	gain['value']     = 0;
	gain['min']       = 0;
	gain['max']       = 15;
	c.appendChild(gain);
	this.inputControl['gain'] = gain;
	
	labelUnit = document.createElement("label");
	labelUnit.style['display'] = 'block';
	labelUnit.appendChild(document.createTextNode(i18n.scale[lang]));
	c.appendChild(labelUnit);

	c = document.createElement("div");
	c.style['display']        = 'inline-block';
	c.style['vertical-align'] = 'top';
	p.appendChild(c);

	offset = document.createElement("input");
	offset['id']        =  'offset:'+number;
	offset['type']      = 'range';
	offset['className'] = 'vertical';
	offset['value']     = 0;
	offset['min']       = -128;
	offset['max']       =  128;
	c.appendChild(offset);
	this.inputControl['offset'] = offset;

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
	p.id = 'trigger:'+number,
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

	level = document.createElement("input");
	level['id']        = 'level:'+number;
	level['type']      = 'range';
	level['className'] = 'vertical';
	level['value']     = 0;
	level['min']       = -128;
	level['max']       = 128;
	c.appendChild(level);
	this.inputControl['level'] = level;
	
	labelUnit = document.createElement("label");
	labelUnit.style['display'] = 'block';
	labelUnit.appendChild(document.createTextNode(i18n.level[lang]));
	c.appendChild(labelUnit);

	c = document.createElement("div");
	c.style['display']        = 'inline-block';
	c.style['vertical-align'] = 'top';
	p.appendChild(c);

	slope = document.createElement("input");
	slope['id']        = 'slope:'+number;
	slope['type']      = 'range';
	slope['className'] = 'vertical';
	slope['value']     = 0;
	slope['min']       = 0;
	slope['max']       =  1;
	c.appendChild(slope);
	this.inputControl['slope'] = slope;

	level.level = level;
	level.slope = slope;
	slope.level = level;
	slope.slope = slope;

	labelUnit = document.createElement("label");
	labelUnit.style['display'] = 'block';
	labelUnit.appendChild(document.createTextNode(i18n.slope[lang]));
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

