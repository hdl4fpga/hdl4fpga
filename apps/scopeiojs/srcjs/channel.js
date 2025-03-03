// Copyright (c) 2015 Miguel Angel Sagreras                                       //
//                                                                                //
// Permission is hereby granted, free of charge, to any person obtaining a copy   //
// of this software and associated documentation files (the "Software"), to deal  //
// in the Software without restriction, including without limitation the rights   //
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      //
// copies of the Software, and to permit persons to whom the Software is          //
// furnished to do so, subject to the following conditions:                       //
//                                                                                //
// The above copyright notice and this permission notice shall be included in all //
// copies or substantial portions of the Software.                                //
//                                                                                //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     //
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       //
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    //
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         //
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  //
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  //
// SOFTWARE.                                                                      //
//                                                                                //

function hzControl (parent) {

	this.inputControl = {};
	this.wrapper      = {};

	var t = document.createElement("div");
	t.style['text-align']       = 'center'
	t.style['margin']           = '1pt';
	t.style['padding']          = '1pt';
	t.style['background-color'] = '#080808';
	t.style['display']          = 'inline-block';
	t.style['vertical-align']   = 'top';
	t.style['border']           = 'solid #888888 2pt';
	t.style['color']            = '#ffffff';
	parent.appendChild(t);

	time = document.createElement("div");
	time.id                      = 'time';
	time.style['padding']        = '2pt';
	time.style['display']        = 'inline-block';
	time.style['vertical-align'] = 'top';
	t.appendChild(time);
	this.wrapper['time'] = time;

	p = document.createElement("div");
	p.style['display']        = 'inline-block';
	p.style['padding']        = '1pt';
	p.style['vertical-align'] = 'top';
	time.appendChild(p);

	w = document.createElement("div");
	w.className = "vertical";
	hscale           = document.createElement("input");
	hscale.id        = "hscale";
	hscale.type      = "range"
	hscale.className = "vertical";
	hscale.value     = 0;
	hscale.min       = 0;
	hscale.max       = 15;
	w.appendChild(hscale);
	p.appendChild(w);
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
	time.appendChild(p);

	w = document.createElement("div");
	w.className = "vertical";
	hoffset           = document.createElement("input");
	hoffset.id        = "hoffset";
	hoffset.type      = "range"
	hoffset.className = "vertical";
	hoffset.value     = 0;
	hoffset.min       = -(1 << 13);
	hoffset.max       = (1 << 13)-1;
	this.inputControl['hoffset'] = hoffset;
	w.appendChild(hoffset);
	p.appendChild(w);

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
	time.appendChild(hlabel);

//	slabel.colors = { scale : slabel, offset : olabel, hzaxis : hlabel };
	slabel.colors = { hzaxis : t , value : 0 };
	olabel.colors = slabel.colors;
	hlabel.colors = slabel.colors;

}

hzControl.prototype.onchange = function (callback) {
	var wrapper = this.wrapper;
	Object.keys(wrapper).forEach (function(key) {
		wrapper[key].onchange = callback;
	});
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

	var t = document.createElement("div");
	t.style['text-align']       = 'center';
	t.style['padding']          = '0pt';
	t.style['margin']           = '1pt';
	t.style['background-color'] = '#444444';
	t.style['display']          = 'inline-block';
	t.style['vertical-align']   = 'top'; 
	t.style['color']            =  color;
	t.style['border']           = 'solid #404040 2pt'
	parent.appendChild(t);

	// Scale
	// -----
	
	vtaxis = document.createElement("div");
	vtaxis.id = 'vtaxis:'+number,
	vtaxis.style['background-color'] = '#080808';
	vtaxis.style['padding']          = '4pt';
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

	w = document.createElement("div");
	w.className = "vertical";
	gain = document.createElement("input");
	gain['id']        = 'gain:'+number;
	gain['type']      = 'range';
	gain['className'] = 'vertical';
	gain['value']     = 0;
	gain['min']       = 0;
	gain['max']       = 15;
	w.appendChild(gain);
	c.appendChild(w);
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

	w = document.createElement("div");
	w.className = "vertical";
	offset = document.createElement("input");
	offset['id']        =  'offset:'+number;
	offset['type']      = 'range';
	offset['className'] = 'vertical';
	offset['value']     = 0;
	offset['min']       = -128;
	offset['max']       =  128;
	w.appendChild(offset);
	c.appendChild(w);
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
	trigger.style['padding']          = '4pt';
	trigger.style['margin']           = '0pt';
	trigger.style['display']          = 'inline-block';
	trigger.style['border']           = 'solid #888888 1pt';
	trigger.style['display']          = 'inline-block';
	trigger.style['vertical-align']   = 'top';
	t.appendChild(trigger);
	
	c = document.createElement("div");
	c.style['display']        = 'inline-block';
	c.style['vertical-align'] = 'top';
	trigger.appendChild(c);

	w = document.createElement("div");
	w.className = "vertical";
	level = document.createElement("input");
	level['id']        = 'level:'+number;
	level['type']      = 'range';
	level['className'] = 'vertical';
	level['value']     = 0;
	level['min']       = -256;
	level['max']       = 255;
	w.appendChild(level);
	c.appendChild(w);
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
	c.style['padding']  = '4pt';
	c.style['text-align']     = 'left';
	trigger.appendChild(c);

	d = document.createElement("div");
	d.style['display']        = 'inline-block';
	d.style['width']          = '100%';
	d.style['padding']        = '2pt';
	d.style['border-width']   = '1px';
	d.style['border-style']   = 'solid';
	d.style['border-color']   = 'gray';
	d.style['vertical-align'] = 'top';
	d.style['text-align']     = 'left';

	slabel = document.createElement("label");
	slabel.id                  = "label:channel:"+number;
	slabel.style['display']    = 'block';
	slabel.style['margin-top'] = '4px';
	slabel.style['text-align'] = 'center';
	slabel.appendChild(document.createTextNode(i18n.slope[lang]));
	this.inputControl['slabel'] = slabel;
	d.appendChild(slabel);

	slope = {};
	['positive', 'negative'].forEach(item => {
		slope[item] = document.createElement("label");
		slope[item].style.display = 'block';
		slope[item].style.align   = 'left';
		slope[item].style['margin-top'] = '4px';
		slope[item].input         = document.createElement("input");
		slope[item].input.id      = item + ':' + number;
		slope[item].input.type    = 'radio';
		slope[item].input.name    = 'slope';
		slope[item].input.value   = item;
		slope[item].input.trigger = trigger;
		slope[item].appendChild(slope[item].input);
		slope[item].appendChild(document.createTextNode(i18n[item][lang]));
		d.appendChild(slope[item]);
		this.wrapper[item] = slope[item].input;
	});

	c.appendChild(d);

	d = document.createElement("div");
	d.style['width']          = '100%';
	d.style['width']          = '100%';
	d.style['padding']        = '2pt';
	d.style['border-width']   = '1px';
	d.style['border-style']   = 'solid';
	d.style['border-color']   = 'gray';
	d.style['display']        = 'block';
	d.style['margin-top']     = '4px';
	d.style['vertical-align'] = 'top';
	d.style['text-align']     = 'left';

	slabel = document.createElement("label");
	slabel.id               = "label:channel:"+number;
	slabel.style['display'] = 'block';
	slabel.style['text-align'] = 'center';
	slabel.appendChild(document.createTextNode(i18n.mode[lang]));
	this.inputControl['slabel'] = slabel;
	d.appendChild(slabel);

	mode = {};
	['normal+free', 'normal', 'one shot', 'freeze'].forEach(item => {
		mode[item] = document.createElement("label");
		mode[item].style.display = 'block';
		mode[item].style.align   = 'left';
		mode[item].style['margin-top'] = '4px';
		mode[item].input         = document.createElement("input");
		mode[item].input.id      = item + ':' + number;
		mode[item].input.type    = 'radio';
		mode[item].input.name    = 'mode';
		mode[item].input.value   = item;
		mode[item].input.trigger = trigger;
		mode[item].appendChild(mode[item].input);
		mode[item].appendChild(document.createTextNode(i18n[item][lang]));
		d.appendChild(mode[item]);
		this.wrapper[item] = mode[item].input;
	});

	c.appendChild(d);
	level.trigger = trigger;
	level.level   = level;
	level.slope   = slope;
	level.mode    = mode;

	trigger.trigger = trigger;
	trigger.level   = level;
	trigger.slope   = slope;
	trigger.mode    = mode;

	tlabel = document.createElement("label");
	tlabel.id                   = "label:channel:"+number;
	tlabel.style['display']     = 'block';
	tlabel.appendChild(document.createTextNode(i18n.trigger[lang]));
	this.inputControl['tlabel'] = tlabel;

//	vglabel.colors = { gain : vglabel, offset : volabel, vtaxis : vtlabel, level : llabel, slope : slabel, trigger : tlabel };
//	vglabel.colors = { vtaxis : vtlabel, trigger : tlabel };
	vglabel.colors = { vtaxis : t, value : 0  };
	volabel.colors = vglabel.colors;
	vtlabel.colors = vglabel.colors;

	llabel.colors = vglabel.colors;
	slabel.colors = vglabel.colors;
	tlabel.colors = vglabel.colors;

	trigger.appendChild(tlabel);

}

vtControl.prototype.onchange = function (callback) {
	var wrapper = this.wrapper;
//	Object.keys(wrapper).forEach (function(key) {
//		wrapper[key].onchange = callback;
//	});
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
