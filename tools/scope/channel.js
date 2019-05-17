function hzControlHTML (color) {
	let html =
	'<div style="text-align:center;margin:3pt;padding:0pt;background-color:#080808;display:inline-block;vertical-align:top;border:solid #888888 1pt;color:' + color + '">' +
		'<div style="padding:1pt;display:inline-block;vertical-align:top;">' +
			'<div style="display:inline-block;vertical-align:top;padding:1pt">' +
				'<input id="time" type="range" class="vertical" value="0" min="0"    max="15"/>' +
				'<label style="display:block;">Escala</label>' +
			'</div>' +
			'<label style="display:block;">Horizontal</label>' +
		'</div>' +
	'</div>';
	return html;
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
	p.id = 'chan' + number + '-scale',
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
	chanInput['id']        = 'chan' + number + '-unit';
	chanInput['type']      = 'range';
	chanInput['className'] = 'vertical';
	chanInput['value']     = 0;
	chanInput['min']       = 0;
	chanInput['max']       = 15;
	c.appendChild(chanInput);
	this.inputControl['unit'] = chanInput;
	
	labelUnit = document.createElement("label");
	labelUnit.style['display'] = 'block';
	labelUnit.appendChild(document.createTextNode("Escala"));
	c.appendChild(labelUnit);

	c = document.createElement("div");
	c.style['display']        = 'inline-block';
	c.style['vertical-align'] = 'top';
	p.appendChild(c);

	chanInput = document.createElement("input");
	chanInput['id']        = 'chan' + number + '-offset';
	chanInput['type']      = 'range';
	chanInput['className'] = 'vertical';
	chanInput['value']     = 0;
	chanInput['min']       = -128;
	chanInput['max']       =  128;
	c.appendChild(chanInput);
	this.inputControl['offset'] = chanInput;

	labelUnit = document.createElement("label");
	labelUnit.style['display'] = 'block';
	labelUnit.appendChild(document.createTextNode("Posicion"));
	c.appendChild(labelUnit);

	labelScale = document.createElement("label");
	labelScale.style['display']='block';
	labelScale.appendChild(document.createTextNode("Vertical"));
	p.appendChild(labelScale);

	// Trigger
	// ------

	p = document.createElement("div");
	p.id = 'chan' + number + '-trigger',
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
	chanInput['id']        = 'chan' + number + '-level';
	chanInput['type']      = 'range';
	chanInput['className'] = 'vertical';
	chanInput['value']     = 0;
	chanInput['min']       = 0;
	chanInput['max']       = 15;
	c.appendChild(chanInput);
	this.inputControl['level'] = chanInput;
	
	labelUnit = document.createElement("label");
	labelUnit.style['display'] = 'block';
	labelUnit.appendChild(document.createTextNode("Nivel"));
	c.appendChild(labelUnit);

	c = document.createElement("div");
	c.style['display']        = 'inline-block';
	c.style['vertical-align'] = 'top';
	p.appendChild(c);

	chanInput = document.createElement("input");
	chanInput['id']        = 'chan' + number + '-slope';
	chanInput['type']      = 'range';
	chanInput['className'] = 'vertical';
	chanInput['value']     = 0;
	chanInput['min']       = 0;
	chanInput['max']       =  1;
	c.appendChild(chanInput);
	this.inputControl['slope'] = chanInput;

	labelUnit = document.createElement("label");
	labelUnit.style['display'] = 'block';
	labelUnit.appendChild(document.createTextNode("Posticion"));
	c.appendChild(labelUnit);

	labelScale = document.createElement("label");
	labelScale.style['display']='block';
	labelScale.appendChild(document.createTextNode("Disparo"));
	p.appendChild(labelScale);

}

vtControl.prototype.onclick = function (callback = function(ev) { console.log(this.parentElement.parentElement); this.parentElement.parentElement.onclick(ev); }) {
	this.wrapper['scale'].onclick   = callback;
	this.wrapper['trigger'].onclick = callback;
	this.wrapper['scale'].addEventListener("wheel", chanSelect, false);
	this.wrapper['trigger'].addEventListener("wheel", chanSelect, false);
}

vtControl.prototype.onfocus = function (callback = function(ev) { console.log(this.parentElement.parentElement); this.parentElement.parentElement.onclick(ev); }) {
	this.inputControl['unit'].onfocus   = callback;
	this.inputControl['offset'].onfocus = callback;
	this.inputControl['level'].onfocus  = callback;
	this.inputControl['slope'].onfocus  = callback;
}

vtControl.prototype.mousewheel = function (number, callback) {
	this.inputControl['unit'].addEventListener("wheel", callback, false);
	this.inputControl['offset'].addEventListener("wheel", callback, false);
	this.inputControl['level'].addEventListener("wheel", callback, false);
	this.inputControl['slope'].addEventListener("wheel", callback, false);
}

function mouseWheel (e) {
	this.value = parseInt(this.value) + parseInt(((e.deltaY > 0) ? 1 : -1));
}
