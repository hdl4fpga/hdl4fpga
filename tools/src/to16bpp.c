#include <stdlib.h>
#include <stdio.h>
#include <math.h>

int main (int argc, char *argv[])
{
	int    addr;

	addr = 0;
	setbuf(stdin, NULL);
	setbuf(stdout, NULL);
	while(!feof(stdin)) {
		char buffer[2+(2+256)+(2+3)+(2+3)+2];
		char data[3*256/2];

		char *memaddr;
		char *memlen;
		char *memdata;

		buffer[0] = 0;
		buffer[1] = 0;
		buffer[sizeof(buffer)-2] = 0;
		buffer[sizeof(buffer)-1] = 0;

		memdata = buffer + 2;
		memdata[0] = 0x18;
		memdata[1] = 0xff;

		memaddr = memdata + (2+256);
		memaddr[0] = 0x16;
		memaddr[1] = 0x02;
		memaddr[2] = (addr >> 16) & 0xff;
		memaddr[3] = (addr >>  8) & 0xff;
		memaddr[4] = (addr >>  0) & 0xff;

		memlen = memaddr + 5;
		memlen[0] = 0x17;
		memlen[1] = 0x02;
		memlen[2] = 0x00;
		memlen[3] = 0xff;
		memlen[4] = 0xff;

		int n = fread(data, sizeof(char), sizeof(data), stdin);
		for (int i=0; i < sizeof(data)/3; i++) {
			unsigned pixel;

			pixel    = 0;
			pixel <<= 5;
			pixel   |= ((data[3*i+0] >> 5) & 0x1f);
			pixel <<= 5;
			pixel   |= ((data[3*i+1] >> 5) & 0x1f);
			pixel <<= 5;
			pixel   |= ((data[3*i+2] >> 5) & 0x1f);
			pixel = -1;

			memdata[2*i+0+2] = ((pixel >> 8) & 0xff);
			memdata[2*i+1+2] = ((pixel >> 0) & 0xff);
		}
		fwrite(buffer, sizeof(char), sizeof(buffer), stdout);

		addr += 0x40;
		return 0;

	}

	return 0;
}
