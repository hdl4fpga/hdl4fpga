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

const gain    = { rid : 0x13, size : 1, value  :  4, chanid : 4 };
const hzAxis  = { rid : 0x10, size : 3, offset : 16, scale  : 4 };
const palette = { rid : 0x11, size : 2, pid    :  4, color  : 3 }; 
const trigger = { rid : 0x12, size : 2, enable :  1, slope  : 1, value : 9 };
const vtAxis  = { rid : 0x14, size : 2, offset : 13, chanid : 3 };


function prepareBuffer (reg, data) {
	const byteSize = 8;
	var buffer = new Buffer.alloc(reg.size+2);


	let n;
	let j;

	Object.keys(reg).forEach (function(key) {

		function max_mask (val) {
			return (1 << (val % byteSize)+1) - 1;
		}

		function max_shift (val) {
			if (val > 0)
				return (val % byteSize) + 1;
			else
				return byteSize-parseInt(val % byteSize);
		}

		switch(key) {
		case 'rid':
			buffer[0] = reg.rid;
			break;
		case 'size':
			buffer[1] = reg.size;
			break;
		default:
			for(n = 0; n < reg[key]; n += max_shift(reg[key])) {
				for(i = 0; i < reg.size; i++) {
					buffer[i+2] = buffer[i+2]    << max_shift(reg[key]-n);
					buffer[i+2] = (buffer[i+2+1] >> max_shift(-(reg[key]-n))) & max_mask(reg[key]-n);
				}

				buffer[reg.size-1] = data & max_mask(reg[key]-n);
				data = data >> max_shift(reg[key]-n);
			}

		};
	});
}

prepareBuffer(gain, [30, 25 ]);
