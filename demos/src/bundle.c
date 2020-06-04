#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main (int argc, char *argv[])
{
	char   c;
	unsigned char  len;
	unsigned char  rid;
	unsigned char  buffer[1500];
	unsigned char  *bufptr;
	unsigned int   tlen;
	unsigned int   bsize;
	unsigned int   addr;
	unsigned int   baddr;
	unsigned short pktsz;

	baddr = 0;
	while ((c = getopt (argc, argv, "b:")) != -1) {
		switch (c) {
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

	fprintf (stderr, "Memory base address 0x%08x\n", baddr);

	bsize  = 0;
	bufptr = buffer;
	for(int i = 0; fread(&rid, sizeof(char), 1, stdin) > 0; i++) {
		*bufptr++ = rid;
		if (fread(&len, sizeof(char), 1, stdin) > 0) {
			*bufptr++ = len;

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
					fprintf(stderr, "Buffer length   : 0x%08x | ", bsize);
					fprintf(stderr, "Transfer length : 0x%08x\n", tlen);

					pktsz = bufptr-buffer;
					fwrite (&pktsz, sizeof(unsigned short), 1, stdout);
					fwrite (buffer, sizeof(unsigned char), bufptr-buffer, stdout);

					bsize  = 0;
					bufptr = buffer;

					break;

				case 0x16:
					addr = 0;
					for(int j = 0; j <= len; j++) {
						addr <<= 8;
						addr |=  (bufptr-len-1)[j];
					}
					addr += baddr;

					fprintf(stderr, "Memory address : 0x%08x | ", addr);
					for(int j = len; j >=0; j--) {
						(bufptr-len-1)[j] = (addr & 0xff);
						addr >>= 8;
					}
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
