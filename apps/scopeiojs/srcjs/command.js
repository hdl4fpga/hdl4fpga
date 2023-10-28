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
	var   bitOffs  = 0;

	Object.keys(reg).forEach (function(key) {
		switch(key) {
		case 'rid':
		case 'size':
			break;
		default:
			for (var i = 0; i < reg[key]; i++) {
				if (bitOffs == 0)
					buffer.unshift(0);
				buffer[0] |= ((data[key]) & (1 << (reg[key]-i-1))) ? (1 << (byteSize-1-bitOffs)) : 0;
				bitOffs   += 1;
				bitOffs   %= byteSize;
			}
		};
	});
	bitOffs %= byteSize;
	if (bitOffs) {
		var octet;
		for (var i = 0; i < buffer.length-1; i++) {
			octet       = buffer[i+1];
			octet     <<= bitOffs;
			octet      &= ((1<< byteSize)-1);
			buffer[i] >>= (byteSize - bitOffs);
			buffer[i]  |= octet;
		}
		buffer[buffer.length-1] >>= (byteSize - bitOffs);
	}
	return [ reg.rid, reg.size-1, ...buffer.slice().reverse() ];
}

function sendRegister(reg, values) {
	send(alignValues(reg, values));
}