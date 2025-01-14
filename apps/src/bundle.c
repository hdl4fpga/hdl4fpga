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

int main (int argc, char *argv[])
{
	char   c;
	unsigned char  len;
	unsigned char  rid;
	unsigned char  buffer[8*1024];
	unsigned char  *bufptr;
	unsigned int   tlen;
	unsigned int   bsize;
	unsigned int   addr;
	unsigned int   baddr;
	unsigned short pktsz;
	char pktmd;

	baddr  = 0;
	opterr = 0;
	pktmd  = 0;
	while ((c = getopt (argc, argv, "pb:")) != -1) {
		switch (c) {
		case 'p':
			pktmd = 1;
			break;
		case 'b':
			if (optarg)
				sscanf (optarg, "%x", &baddr);
			break;
		case '?':
			fprintf (stderr, "usage : bundle -b base_address\n");
			exit(1);
		default:
			exit(1);
		}
	}

#ifdef _WIN32
	_setmode(_fileno(stdin), _O_BINARY);
	_setmode(_fileno(stdout), _O_BINARY);
#endif

	setbuf(stdin, NULL);
	setbuf(stdout, NULL);

	fprintf (stderr, "Memory base address 0x%08x\n", baddr);

	bsize  = 0;
	bufptr = buffer;
	for(int i = 0; fread(&rid, sizeof(char), 1, stdin) > 0; i++) {
		*bufptr++ = rid;
		if (fread(&len, sizeof(char), 1, stdin) > 0) {
			*bufptr++ = len;

			if (buffer+sizeof(buffer) < bufptr+len+1) {
				fprintf (stderr, "buffer size required %ld, buffer size %ld\n", sizeof(buffer), bufptr-buffer+len+1);
				exit(-1);
			}
			if (fread(bufptr, sizeof(char), len+1, stdin) > 0) {
				bufptr += (len+1);
				switch (rid) {
				case 0x18:
					bsize += (len + 1);
					break;

				case 0x17:
					tlen = 0;
					for(int j = 0; j <= len; j++) {
						tlen <<= 8;
						tlen |=  (bufptr-len-1)[j];
					}

					break;

				case 0x16:
					addr = 0;
					for(int j = 0; j <= len; j++) {
						addr <<= 8;
						addr |=  (bufptr-len-1)[j];
					}
					addr += baddr;

					fprintf(stderr, "address : 0x%08x, ", addr);
					for(int j = len; j >=0; j--) {
						(bufptr-len-1)[j] = (addr & 0xff);
						addr >>= 8;
					}

					fprintf(stderr, "buffer : 0x%08x, ", bsize);
					fprintf(stderr, "transfer : 0x%08x\n", tlen);
					pktsz = bufptr-buffer;
					if (pktmd)
						fwrite (&pktsz, sizeof(unsigned short), 1, stdout);
					fwrite (buffer, sizeof(unsigned char), pktsz, stdout);

					bsize  = 0;
					bufptr = buffer;

					break;
				}
			} else {
				exit(-1);
			}
		} else {
			exit(-1);
		}
	}

	return 0;
}
