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

const program = require('commander');
const commjs  = require('./comm.js');

program
	.requiredOption('-r, --rid  <id>',   'register id')
	.requiredOption('-d, --data <name>', 'data')
	.parse(process.argv);

function hex(data) {
	var values = [];
	for (i = 0; i < data.length; i++) {
		let val;

		if (i % 2 == 0) {
			values.push(16*parseInt("0x" +  data[i]));
		} else {
			values.push(values.pop() + parseInt("0x" +  data[i]));
		}

	}
	return String.fromCharCode.apply(this, values);
}

var hexbuf = hex(program.data);
process.stdout.write(
	String.fromCharCode(parseInt("0x" + program.rid)) +
	String.fromCharCode(parseInt(hexbuf.length-1)) +
	hexbuf);
