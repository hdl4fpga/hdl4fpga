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
	t = document.createElement("div");
	t.style = {
		"text-align"       : 'center',
		"padding"          : '0pt',
		"margin"           : '1pt',
		"background-color" : '#444444',
		"display"          : 'inline-block',
		"vertical-align"   : 'top', 
		"color"            :  color,
		"border"           : 'solid #404040 1pt;' };
	parent.appendChild(p);

	// Scale
	// -----
	
	p = document.createElement("div");
	p = {
		id : 'chan' + number + '-scale',
		style : {
			'background-color' : '#080808',
			'padding'          : '2pt',
			'margin'           : '0pt',
			'display'          : 'inline-block',
			'border'           : 'solid #888888 1pt',
			'display'          : 'inline-block',
			'vertical-align'   : 'top' } };
	t.appendChild(p);
	
	c = document.createElement("div");
	c.style = {
		'display'        : 'inline-block',
		'vertical-align' : 'top' };
	p.appendChild(c);

	chanUnit = document.createElement("input");
	chanUnit = { 
		'id'    : 'chan' + number + '-unit',
		'type'  : 'range',
		'class' : 'vertical',
		'value' : 0,
		'min'   : 0,
		'max'   : 15 };
	c.appendChild(chanUnit);

	labelUnit = document.createElement("label");
	labelUnit = {
		style : { display : 'block' } }
	labelUnit.createTextNode("Escala");
	c.appendChild(labelUnit);

	c = document.createElement("div");
	c.style = {
		'display'        : 'inline-block',
		'vertical-align' : 'top' },
	p.appendChild(c);

	chanUnit = document.createElement("input");
	chanUnit = { 
		'id'    : 'chan' + number + '-offset',
		'type'  : 'range',
		'class' : 'vertical',
		'value' : 0,
		'min'   : -128,
		'max'   :  128 };
	c.appendChild(chanUnit);

	labelUnit = document.createElement("label");
	labelUnit = {
		'style' : { display : 'block' } }
	labelUnit.createTextNode("Escala");
	c.appendChild(labelUnit);

	labelUnit = document.createElement("label");
	labelUnit = {
		style : { display : 'block' } }
	labelUnit.createTextNode("Position");
	c.appendChild(labelUnit);

	labelScale = document.createElement("label");
	labelScale = {
		style : { display : 'block' } }
	labelUnit.createTextNode("Vertical");
	p.appendChild(labelUnit);

	// Trigger
	// ------

	p = document.createElement("div");
	p = {
		id : 'chan' + number + '-trigger',
		style : {
			'background-color' : '#080808',
			'padding'          : '2pt',
			'margin'           : '0pt',
			'display'          : 'inline-block',
			'border'           : 'solid #888888 1pt',
			'display'          : 'inline-block',
			'vertical-align'   : 'top' } };
	t.appendChild(p);

	c = document.createElement("div");
	c.style = {
		'display'        : 'inline-block',
		'vertical-align' : 'top' };
	p.appendChild(c);

	chanUnit = document.createElement("input");
	chanUnit = { 
		'id'    : 'chan' + number + '-level',
		'type'  : 'range',
		'class' : 'vertical',
		'value' : 0,
		'min'   : 0,
		'max'   : 15 };
	c.appendChild(chanUnit);

	labelUnit = document.createElement("label");
	labelUnit = {
		style : { 'display' : 'block' } }
	labelUnit.createTextNode("Escala");
	c.appendChild(labelUnit);

	c = document.createElement("div");
	c.style = {
		'display'        : 'inline-block',
		'vertical-align' : 'top' };
	p.appendChild(c);

	chanUnit = document.createElement("input");
	chanUnit = { 
		'id'    : 'chan' + number + '-offset',
		'type'  : 'range',
		'class' : 'vertical',
		'value' : 0,
		'min'   : -128,
		'max'   :  128 };
	c.appendChild(chanUnit);

	labelUnit = document.createElement("label");
	labelUnit = {
		style : { display : 'block' } }
	labelUnit.createTextNode("Nivel");
	c.appendChild(labelUnit);

	labelUnit = document.createElement("label");
	labelUnit = {
		style : { display : 'block' } }
	labelUnit.createTextNode("Pendiente");
	c.appendChild(labelUnit);

	labelScale = document.createElement("label");
	labelScale = {
		style : { display : 'block' } }
	labelUnit.createTextNode("Disparo");
	p.appendChild(labelUnit);

}

vtControl.onclick = function (number, callback = function(ev) { this.parentElement.parentElement.onclick(ev); }) {
	document.getElementById("chan" + number + "-scale").onclick   = callback;
	document.getElementById("chan" + number + "-trigger").onclick = callback;
}

vtControl.onfocus = function (number, callback) {
	document.getElementById("chan" + number + "-unit").onfocus   = callback;
	document.getElementById("chan" + number + "-offset").onfocus = callback;
	document.getElementById("chan" + number + "-level").onfocus  = callback;
	document.getElementById("chan" + number + "-slope").onfocus  = callback;
}

vtControl.mousewheel = function (number, callback) {
	document.getElementById("chan" + number + "-unit").addEventListener("wheel", callback, false);
	document.getElementById("chan" + number + "-offset").addEventListener("wheel", callback, false);
	document.getElementById("chan" + number + "-level").addEventListener("wheel", callback, false);
	document.getElementById("chan" + number + "-slope").addEventListener("wheel", callback, false);
}

console.log(' <head> <title>Scope</title> <link rel="stylesheet" href="scope.css"> <meta charset="utf-8"> <script src="scope.js"></script> </head>');
console.log(vtControl(document, 1, '#ffffff') + hzControlHTML('#ffff00'));
