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
	var buffer   = new ArrayBuffer(reg.size+2);
	var dataView = new Uint8Array(buffer);

	Object.keys(reg).forEach (function(key) {

		switch(key) {
		case 'rid':
			dataView[0] = reg.rid;
			break;
		case 'size':
			dataView[1] = reg.size-1;
			break;
		default:
			var i;
			var shtcnt = parseInt(reg[key] % byteSize);
			var mask   = (1 << shtcnt) -1;
			var offset = parseInt(reg[key]/byteSize);

			data[key] = reverse(data[key], reg[key]);
			if (shtcnt > 0) {
				for(i = 0; i < reg.size-1; i++) {
					dataView[i+2] <<=  shtcnt;
					dataView[i+2]  |= (dataView[i+2+1] >> (byteSize - shtcnt)) & mask;
				}
				dataView[i+2] <<= shtcnt;
				dataView[i+2]  |= reverse(data[key], shtcnt);
				data[key]   >>= shtcnt;
			}

			if (offset) for(i = offset; i < reg.size; i++) 
				dataView[i+2-offset] = dataView[i+2];

			for(i = reg.size-offset; i < reg.size; i++) {
				dataView[i+2] = reverse(data[key], byteSize);
				data[key] >>= byteSize;
			}
		};
	});
	return dataView;
}

function sendRegister(reg, values) {
	var buffer = alignValues(reg, values);
	send(buffer);
}
