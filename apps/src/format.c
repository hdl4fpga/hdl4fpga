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
#include <unistd.h>
#include <fcntl.h>

#define BUF_SIZE  256
#define BUF_NUM   (8*1024/BUF_SIZE)

static unsigned char buffer[BUF_NUM*(2+BUF_SIZE)+(2+3)+(2+3)];
static unsigned char *bufptr;
static unsigned char *memdata;
static unsigned char *memaddr;
static unsigned char *memlen;
static unsigned wsize = 0;
static unsigned bsize = 0;
static unsigned addr  = 0;

static unsigned n = 0;
static char c;

void help ()
{
	fprintf (stderr, "usage :  format -b buffer_size\n");
}

int main (int argc, char *argv[])
{
	while ((c = getopt (argc, argv, "b:w:")) != -1) {
		switch (c) {
		case 'b':
			if (optarg){
				sscanf (optarg, "%d", &bsize);
				if (bsize > (BUF_NUM*BUF_SIZE)) {
					fprintf (stderr, "Maximun buffer_size is %d\n", BUF_NUM*BUF_SIZE);
					help();
					exit(-1);
				}
			}
			break;
		case '?':
		default:
			help();
			exit(-1);
			break;
		}
	}

	if (!bsize) {
		help();
		exit(-1);
	} else
		fprintf (stderr, "buffer size is %d\n", bsize);


#ifdef _WIN32
	_setmode(_fileno(stdin), _O_BINARY);
	_setmode(_fileno(stdout), _O_BINARY);
#endif

	setbuf(stdin, NULL);
	setbuf(stdout, NULL);
	addr = 0;
	int j = 0;
	do {

		bufptr = buffer;

		int i;
		for (i = 0; i < bsize; i += n) {

			memdata    = bufptr;
			memdata[0] = 0x18;

			if (!(n = fread(memdata+2, sizeof(char), ((bsize-i) < (BUF_SIZE)) ? (bsize-i) : (BUF_SIZE), stdin)) > 0) {
				if (n < 0 ) {
					perror ("Reading stdin\n");
					exit(-1);
				}
				if (!(i > 0)) {
					perror ("Reading stdin\n");
					exit(0);
				}

				break;
			}

			memdata[1] = n-1;

			bufptr += (2 + bufptr[1] + 1);
		}

		memlen    = bufptr;
		memlen[0] = 0x17;
		memlen[1] = 0x02;
		memlen[2] = 0xff & ((i-1) >> 16);
		memlen[3] = 0xff & ((i-1) >>  8);
		memlen[4] = 0xff & ((i-1) >>  0);

		bufptr += (2 + bufptr[1] + 1);

		memaddr    = bufptr;
		memaddr[0] = 0x16;
		memaddr[1] = 0x03;
		memaddr[2] = 0xff & (addr >> 24);
		memaddr[3] = 0xff & (addr >> 16);
		memaddr[4] = 0xff & (addr >>  8);
		memaddr[5] = 0xff & (addr >>  0);

		bufptr += (2 + bufptr[1] + 1);

		fwrite(buffer, sizeof(char), bufptr-buffer, stdout);

		addr += i;

	} while (n > 0);

	return 0;
}
