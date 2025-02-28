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

function paletteControl (parent, objectName, paletteID) {

	this.inputControl = {};

	p = document.createElement("div");
	p.style['display']= "block";
	p.style['text-align'] = 'left';
	parent.appendChild(p);

	color = document.createElement("div");
	color.id                      = 'color:'+objectName;
	color.style['width']          = '100pt';
	color.style['height']         = '10pt';
	color.style['padding']        = '1pt';
	color.style['display']        = 'inline-block';
	color.style['background-color'] = paletteID;
	color.style['vertical-align'] = 'middle';
	color.style['text-align'] = 'left';
	color.value = 0;
	this.inputControl['color']    = color;
	p.appendChild(color);

	palette = document.createElement("div");
	palette.id                      = 'color:'+objectName;
	palette.style['padding']        = '1pt';
	palette.style['display']        = 'inline-block';
	palette.style['vertical-align'] = 'middle';
	palette.style['text-align'] = 'left';
	this.inputControl['palette']    = palette;
	p.appendChild(palette);

	label = document.createElement("label");
	label.style['text-align'] = 'left';
	label.style['display'] = 'inline-block';
	label.style['color'] = '#ffffff';
	label.style['vertical-align'] = 'middle';
	label.appendChild(document.createTextNode(i18n[objectName][lang]));
	palette.appendChild(label);

	color.colors = { color : color,  value : 0  };
	palette.colors = color.colors;
}

paletteControl.prototype.onclick = function (callback) {
	this.inputControl['palette'].onclick   = callback;
	this.inputControl['color'].onclick   = callback;
}

paletteControl.prototype.onfocus = function (callback) {
	this.inputControl['palette'].onfocus   = callback;
	this.inputControl['color'].onfocus   = callback;
}

paletteControl.prototype.mousewheel = function (callback) {
	this.inputControl['palette'].addEventListener("wheel", callback, false);
	this.inputControl['color'].addEventListener("wheel", callback, false);
}


