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

function reverse (value, size) {
	var reval;

	revval = 0;
	for (i = 0; i < size; i++) {
		reval <<= 1;
		if (value & 0x1)
			reval += 1;
		value >>= 1;
	}
	return reval;
}

function alignValues (reg, data) {
	const byteSize = 8;
	var   buffer   = [];
	var   byteNum  = 0;
	var   bitOffs  = 0;

	Object.keys(reg).forEach (function(key) {
		switch(key) {
		case 'rid':
		case 'size':
			break;
		default:
			console.log(key+ " : " + reg[key]  + " : " + data[key]);
			for (var i = 0; i < reg[key]; i++) {
				if (bitOffs == byteSize) {
					buffer[byteNum+1] = buffer[byteNum];
					byteNum++;
					bitOffs %= byteSize;
				}
				if (bitOffs == 0)
					buffer[byteNum] = 0;
				buffer[byteNum] |= (data[key] & (1 << (reg[key]-i-1))) ? (1 << (byteSize-1-bitOffs)) : 0;
				bitOffs         += 1;
				if (bitOffs == byteSize)
					console.log("bytenum : " + byteNum);
			}
			console.log("--------------> " + buffer);
		};
	});
	bitOffs %= byteSize;
	if (bitOffs) {
		for (var i = 0; i < buffer.length; i++) {
			var octet = buffer[i];
			buffer[i] >>= (byteSize - bitOffs);
			octet 
		}
	}
	console.log("Sali" + bitOffs);
	return [ reg.rid, reg.size-1, ...buffer ];
}

function sendRegister(reg, values) {
	send(alignValues(reg, values));
}