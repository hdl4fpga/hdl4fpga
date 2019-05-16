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
	this.wrapper['scale'] = c;
	
	c = document.createElement("div");
	c.style['display']        = 'inline-block';
	c.style['vertical-align'] = 'top';
	p.appendChild(c);

	chanUnit = document.createElement("input");
	chanUnit['id']        = 'chan' + number + '-unit';
	chanUnit['type']      = 'range';
	chanUnit['className'] = 'vertical';
	chanUnit['value']     = 0;
	chanUnit['min']       = 0;
	chanUnit['max']       = 15;
	c.appendChild(chanUnit);
	this.inputControl['unit'] = c;
	
	labelUnit = document.createElement("label");
	labelUnit.style['display'] = 'block';
	labelUnit.appendChild(document.createTextNode("Escala"));
	c.appendChild(labelUnit);

	c = document.createElement("div");
	c.style['display']        = 'inline-block';
	c.style['vertical-align'] = 'top';
	p.appendChild(c);

	chanUnit = document.createElement("input");
	chanUnit['id']        = 'chan' + number + '-offset';
	chanUnit['type']      = 'range';
	chanUnit['className'] = 'vertical';
	chanUnit['value']     = 0;
	chanUnit['min']       = -128;
	chanUnit['max']       =  128;
	c.appendChild(chanUnit);
	this.inputControl['offset'] = c;

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
	this.wrapper['trigger'] = c;
	
	c = document.createElement("div");
	c.style['display']        = 'inline-block';
	c.style['vertical-align'] = 'top';
	p.appendChild(c);

	chanUnit = document.createElement("input");
	chanUnit['id']        = 'chan' + number + '-level';
	chanUnit['type']      = 'range';
	chanUnit['className'] = 'vertical';
	chanUnit['value']     = 0;
	chanUnit['min']       = 0;
	chanUnit['max']       = 15;
	c.appendChild(chanUnit);
	this.inputControl['level'] = c;
	
	labelUnit = document.createElement("label");
	labelUnit.style['display'] = 'block';
	labelUnit.appendChild(document.createTextNode("Nivel"));
	c.appendChild(labelUnit);

	c = document.createElement("div");
	c.style['display']        = 'inline-block';
	c.style['vertical-align'] = 'top';
	p.appendChild(c);

	chanUnit = document.createElement("input");
	chanUnit['id']        = 'chan' + number + '-slope';
	chanUnit['type']      = 'range';
	chanUnit['className'] = 'vertical';
	chanUnit['value']     = 0;
	chanUnit['min']       = -128;
	chanUnit['max']       =  128;
	c.appendChild(chanUnit);
	this.inputControl['slope'] = c;

	labelUnit = document.createElement("label");
	labelUnit.style['display'] = 'block';
	labelUnit.appendChild(document.createTextNode("Posticion"));
	c.appendChild(labelUnit);

	labelScale = document.createElement("label");
	labelScale.style['display']='block';
	labelScale.appendChild(document.createTextNode("Disparo"));
	p.appendChild(labelScale);

}

vtControl.onclick = function (callback = function(ev) { this.parentElement.parentElement.onclick(ev); }) {
	this.wrapper['scale'].onclick   = callback;
	this.wrapper['trigger'].onclick = callback;
}

vtControl.onfocus = function (number, callback) {
	this.inputControl['unit'].onfocus   = callback;
	this.inputControl['offset'].onfocus = callback;
	this.inputControl['level'].onfocus  = callback;
	this.inputControl['slope'].onfocus  = callback;
}

vtControl.mousewheel = function (number, callback) {
	this.inputControl['unit'].addEventListener("wheel", callback, false);
	this.inputControl['offset'].addEventListener("wheel", callback, false);
	this.inputControl['level'].addEventListener("wheel", callback, false);
	this.inputControl['slope'].addEventListener("wheel", callback, false);
}

window.addEventListener("load", function() {
	body = document.getElementsByTagName("body");
	vt = vtControl(body[0], 1, '#ffffff');
	vt.
});
