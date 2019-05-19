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

