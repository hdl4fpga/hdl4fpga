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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "lfsr.h"

__int128 unsigned lfsr_mask(int size)
{
	__int128 unsigned mask;

	mask = -1;
	mask >>= (128-size);

	return mask;
}

__int128 unsigned lfsr_p (int size)
{
	unsigned __int128 p;

	assert(size==128 || size==64 || size==32);
	switch(size) {
	case 128:
		p   = 0xE100000000000000;
		p <<= 64;
		break;
	case 64:
		p = 0xD800000000000000;
		break;
	case 32:
		p = 0xA3000000;
		break;
	}
	p ^= (((__int128) 1) << (size-1));
	return p;
}

__int128 unsigned lfsr_next(__int128 unsigned lfsr, int lfsr_size)
{
	return ((lfsr>>1)|((lfsr&1)<<(lfsr_size-1))) ^ (((lfsr&1) ? lfsr_mask(lfsr_size) : 0) & lfsr_p(lfsr_size));
}


void lfsr_print(__int128 lfsr, size_t lfsr_size)
{
	assert(lfsr_size==128 || lfsr_size==64 || lfsr_size==32);
	switch(lfsr_size) {
	case 32:
		fprintf(stderr,"0x%08lx\n", (long unsigned int) lfsr);
		break;
	case 64:
		fprintf(stderr,"0x%016llx\n", (long long unsigned int) lfsr);
		break;
	case 128:
		fprintf(stderr,"0x%016llx%016llx\n",
			(long long unsigned int ) (lfsr >> 64),
			(long long unsigned int ) (lfsr &  lfsr_mask(lfsr_size)));
		break;
	}
}
