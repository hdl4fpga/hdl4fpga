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

// Asynchronous communication
//

const chanid_size    = 6;
const max_inputs     = (1 << chanid_size);
const max_pixelsize  = 24;
const paletteid_size = 7;

const registers = {
	gain    : { rid : 0x13, size : 2, gain   : 4,             chanid : chanid_size },
	hzaxis  : { rid : 0x10, size : 3, scale  : 4,             offset : 16 },
	palette : { rid : 0x11, size : 4, color  : max_pixelsize, pid    : paletteid_size },
	trigger : { rid : 0x12, size : 2, level  : 9,             slope  : 1,             enable  : 1 },
	vtaxis  : { rid : 0x14, size : 3, chanid : chanid_size,   offset : 13 }};

const objects = {
	background   : '#000000',
	segmentbg    : '#00ffff',
	textbg       : '#000000',
	verticalbg   : '#0000ff',
	horizontalbg : '#0000ff',
	horizontalfg : '#ffffff',
	gridbg       : '#ff0000',
	gridfg       : '#000000' };
