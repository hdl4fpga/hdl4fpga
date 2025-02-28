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

const chanid_size    = 6;
const max_inputs     = (1 << chanid_size);
const max_pixelsize  = 24;
const paletteid_size = 5;

const registers = {
	ack     : { rid : 0x01, size : 1, value  : 8 },
	gain    : { rid : 0x13, size : 2, chanid : chanid_size,   gain   : 4 },
	hzaxis  : { rid : 0x10, size : 3, scale  : 4,             offset : 16 },
	palette : { rid : 0x11, size : 4, color  : max_pixelsize, pid    : paletteid_size, opacity : 1, colorena : 1, opacityena : 1 },
	trigger : { rid : 0x12, size : 4, chanid : chanid_size,   level  : 16, slope  : 1,  oneshot : 1, freeze : 1 },
	vtaxis  : { rid : 0x14, size : 3, chanid : chanid_size,   offset : 13 }};

const objects = {
	background   : { defcolor : '#000000', pid : 8 },
	segmentbg    : { defcolor : '#00ffff', pid : 7 },
	gridbg       : { defcolor : '#ff0000', pid : 6 },
	textbg       : { defcolor : '#000000', pid : 5 },
	textfg       : { defcolor : '#ffffff', pid : 9 },
	horizontalbg : { defcolor : '#0000ff', pid : 4 },
	horizontalfg : { defcolor : '#ffffff', pid : 3 },
	verticalbg   : { defcolor : '#0000ff', pid : 2 },
	verticalfg   : { defcolor : '#ffffff', pid : 1 },
	gridfg       : { defcolor : '#000000', pid : 0 } };

const colorTab = [
	'000000',
	'0000ff',
	'00ff00',
	'00ffff',
	'ff0000',
	'ff00ff',
	'ffff00',
	'ffffff' ];
