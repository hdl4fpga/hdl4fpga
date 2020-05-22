#include <stdlib.h>
#include <stdio.h>

int main (int argc, char *argv[])
{
	int addr ;
	char rgb565[256];
	char rgb8[3*sizeof(rgb565)/2];

	setbuf(stdin, NULL);
	setbuf(stdout, NULL);
	addr = 0;
	while(fread(rgb8, sizeof(char), sizeof(rgb8), stdin) > 0) {

		for (unsigned i=0; i < sizeof(rgb8)/3; i++) {
			unsigned pixel;

			pixel   = 0;
			pixel   |= ((rgb8[3*i+0] >> 3) & 0x1f);
			pixel <<= 6;
			pixel   |= ((rgb8[3*i+1] >> 2) & 0x3f);
			pixel <<= 5;
			pixel   |= ((rgb8[3*i+2] >> 3) & 0x1f);

			switch((addr+1)%6) {
			case 0:
				pixel = 0;
				break;
			case 1:
				pixel = -1;
				break;
			case 2:
				pixel = 0;
				break;
			case 3:
				pixel = 0xf800;
				break;
			case 4:
				pixel = 0;
				break;
			case 5:
				pixel = 0x07e0;
				break;
			};

			rgb565[2*i+0] = ((pixel >> 8) & 0xff);
			rgb565[2*i+1] = ((pixel >> 0) & 0xff);
			addr ++;
		}
		fwrite(rgb565, sizeof(char), sizeof(rgb565), stdout);

	}

	return 0;
}
