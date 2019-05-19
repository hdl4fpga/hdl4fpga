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

function hzControl (parent) {

	this.inputControl = {};
	this.wrapper      = {};

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

	time = document.createElement("div");
	time.id                      = 'time';
	time.style['padding']        = '1pt';
	time.style['display']        = 'inline-block';
	time.style['vertical-align'] = 'top';
	t.appendChild(time);
	this.wrapper['time'] = time;
	t = time;

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

	slabel = document.createElement("label");
	slabel.id               = "label:hzaxis";
	slabel.style['display'] = 'block';
	slabel.appendChild(document.createTextNode(i18n.scale[lang]));
	this.inputControl['slabel'] = slabel;
	p.appendChild(slabel);

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
	this.inputControl['hoffset'] = hoffset;
	p.appendChild(hoffset);

	hscale.hoffset  = hoffset;
	hscale.hscale   = hscale;
	hoffset.hoffset = hoffset;
	hoffset.hscale  = hscale;
	time.hoffset    = hoffset;
	time.hscale     = hscale;

	olabel = document.createElement("label");
	olabel.id               = "label:hzaxis";
	olabel.style['display'] = 'block';
	olabel.appendChild(document.createTextNode(i18n.offset[lang]));
	this.inputControl['olabel'] = olabel;
	p.appendChild(olabel);

	hlabel = document.createElement("label");
	hlabel.id               = "label:hzaxis";
	hlabel.style['display'] = 'block';
	hlabel.appendChild(document.createTextNode(i18n.horizontal[lang]));
	this.inputControl['hlabel'] = hlabel;
	t.appendChild(hlabel);

	slabel.colors = { scale : slabel, offset : olabel, hzaxis : hlabel };
	olabel.colors = slabel.colors;
	hlabel.colors = slabel.colors;

}

hzControl.prototype.onclick = function (callback) {
	var wrapper = this.wrapper;
	Object.keys(wrapper).forEach (function(key) {
		wrapper[key].onclick = callback;
	});
}

hzControl.prototype.onfocus = function (callback) {
	var inputControl = this.inputControl;
	Object.keys(inputControl).forEach (function(key) {
		inputControl[key].onfocus = callback;
	});
}

hzControl.prototype.mousewheel = function (callback) {
	var inputControl = this.inputControl;
	Object.keys(inputControl).forEach (function(key) {
		inputControl[key].addEventListener("wheel", callback, false);
	});
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
	
	vtaxis = document.createElement("div");
	vtaxis.id = 'vtaxis:'+number,
	vtaxis.style['background-color'] = '#080808';
	vtaxis.style['padding']          = '2pt';
	vtaxis.style['margin']           = '0pt';
	vtaxis.style['display']          = 'inline-block';
	vtaxis.style['border']           = 'solid #888888 1pt';
	vtaxis.style['display']          = 'inline-block';
	vtaxis.style['vertical-align']   = 'top';
	t.appendChild(vtaxis);
	this.wrapper['vtaxis'] = vtaxis;
	
	c = document.createElement("div");
	c.style['display']        = 'inline-block';
	c.style['vertical-align'] = 'top';
	vtaxis.appendChild(c);

	gain = document.createElement("input");
	gain['id']        = 'gain:'+number;
	gain['type']      = 'range';
	gain['className'] = 'vertical';
	gain['value']     = 0;
	gain['min']       = 0;
	gain['max']       = 15;
	c.appendChild(gain);
	this.inputControl['gain'] = gain;
	
	vglabel = document.createElement("label");
	vglabel.id = "label:channel:"+number;
	vglabel.style['display'] = 'block';
	vglabel.appendChild(document.createTextNode(i18n.vtaxis[lang]));
	c.appendChild(vglabel);
	this.inputControl['vglabel'] = vglabel;

	c = document.createElement("div");
	c.style['display']        = 'inline-block';
	c.style['vertical-align'] = 'top';
	vtaxis.appendChild(c);

	offset = document.createElement("input");
	offset['id']        =  'offset:'+number;
	offset['type']      = 'range';
	offset['className'] = 'vertical';
	offset['value']     = 0;
	offset['min']       = -128;
	offset['max']       =  128;
	c.appendChild(offset);
	this.inputControl['offset'] = offset;

	volabel = document.createElement("label");
	volabel.id = "label:channel:"+number;
	volabel.style['display'] = 'block';
	volabel.appendChild(document.createTextNode(i18n.offset[lang]));
	this.inputControl['volabel'] = volabel;
	c.appendChild(volabel);

	vtlabel = document.createElement("label");
	vtlabel.id              = "label:channel:"+number;
	vtlabel.style['display']='block';
	vtlabel.appendChild(document.createTextNode(i18n.vertical[lang]));
	this.inputControl['vtlabel'] = vtlabel;
	vtaxis.appendChild(vtlabel);

	vtaxis.vtaxis = vtaxis;
	vtaxis.offset = offset;
	vtaxis.gain   = gain;

	// Trigger
	// ------

	trigger = document.createElement("div");
	trigger.id = 'trigger:'+number,
	trigger.style['background-color'] = '#080808';
	trigger.style['padding']          = '2pt';
	trigger.style['margin']           = '0pt';
	trigger.style['display']          = 'inline-block';
	trigger.style['border']           = 'solid #888888 1pt';
	trigger.style['display']          = 'inline-block';
	trigger.style['vertical-align']   = 'top';
	t.appendChild(trigger);
	this.wrapper['trigger'] = trigger;
	
	c = document.createElement("div");
	c.style['display']        = 'inline-block';
	c.style['vertical-align'] = 'top';
	trigger.appendChild(c);

	level = document.createElement("input");
	level['id']        = 'level:'+number;
	level['type']      = 'range';
	level['className'] = 'vertical';
	level['value']     = 0;
	level['min']       = -128;
	level['max']       = 128;
	c.appendChild(level);
	this.inputControl['level'] = level;
	
	llabel = document.createElement("label");
	llabel.id = "label:channel:"+number;
	llabel.style['display'] = 'block';
	llabel.appendChild(document.createTextNode(i18n.level[lang]));
	this.inputControl['llabel'] = llabel;
	c.appendChild(llabel);

	c = document.createElement("div");
	c.style['display']        = 'inline-block';
	c.style['vertical-align'] = 'top';
	trigger.appendChild(c);

	slope = document.createElement("input");
	slope['id']        = 'slope:'+number;
	slope['type']      = 'range';
	slope['className'] = 'vertical';
	slope['value']     = 0;
	slope['min']       = 0;
	slope['max']       = 1;
	c.appendChild(slope);
	this.inputControl['slope'] = slope;

	level.level = level;
	level.slope = slope;
	slope.level = level;
	slope.slope = slope;

	trigger.trigger =  trigger;
	trigger.level = level;
	trigger.slope = slope;

	slabel = document.createElement("label");
	slabel.id               = "label:channel:"+number;
	slabel.style['display'] = 'block';
	slabel.appendChild(document.createTextNode(i18n.slope[lang]));
	this.inputControl['slabel'] = slabel;
	c.appendChild(slabel);

	tlabel = document.createElement("label");
	tlabel.id               = "label:channel:"+number;
	tlabel.style['display']='block';
	tlabel.appendChild(document.createTextNode(i18n.trigger[lang]));
	this.inputControl['tlabel'] = tlabel;

	vglabel.colors = { gain : vglabel, offset : volabel, vtaxis : vtlabel, level : llabel, slope : slabel, trigger : tlabel };
	volabel.colors = vglabel.colors;
	vtlabel.colors = vglabel.colors;

	llabel.colors = vglabel.colors;
	slabel.colors = vglabel.colors;
	tlabel.colors = vglabel.colors;

	trigger.appendChild(tlabel);

}

vtControl.prototype.onclick = function (callback) {
	var wrapper = this.wrapper;
	Object.keys(wrapper).forEach (function(key) {
		wrapper[key].onclick = callback;
	});
}

vtControl.prototype.onfocus = function (callback) {
	var inputControl = this.inputControl;
	Object.keys(inputControl).forEach (function(key) {
		inputControl[key].onfocus = callback;
	});
}

vtControl.prototype.mousewheel = function (callback) {
	var inputControl = this.inputControl;
	Object.keys(inputControl).forEach (function(key) {
		inputControl[key].addEventListener("wheel", callback, false);
	});
}

