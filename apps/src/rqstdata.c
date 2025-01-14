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
#include <netinet/in.h>

#ifdef _WIN32
	_setmode(_fileno(stdin), _O_BINARY);
#endif

char buff[256];
int main (int argc, char *argv[])
{
	union {
		char byte[4];
		int word;
	} hton;
	char *ptr;

	setbuf(stdout, NULL);
	for(int i = 0; i < 16; i++) {
		ptr = buff+sizeof(short);
		hton.word = htonl((i << 10));
    	*ptr++ = 0x17;
    	*ptr++ = 0x02;
    	*ptr++ = 0x00;
    	*ptr++ = 0x03;
    	*ptr++ = 0xff;
    	*ptr++ = 0x16;
    	*ptr++ = 0x03;
    	*ptr++ = hton.byte[0] | 0x80;
    	*ptr++ = hton.byte[1];
    	*ptr++ = hton.byte[2];
    	*ptr++ = hton.byte[3];
		*(short *)buff = ptr-buff-sizeof(short);
		if (fwrite (buff, sizeof(char), ptr-buff, stdout) < 0) {
			perror("exit\n");
			exit(-1);
		}
		fprintf(stderr, "pase %d\n",i);
	}

	return 0;
}
