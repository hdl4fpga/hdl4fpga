#include <stdlib.h>
#include <stdio.h>

int main (int argc, char *argv[])
{
	char rgb565[256];
	char rgb8[3*sizeof(rgb565)/2];

	setbuf(stdin, NULL);
	setbuf(stdout, NULL);
	while(fread(rgb8, sizeof(char), sizeof(rgb8), stdin) > 0) {

		for (unsigned i=0; i < sizeof(rgb8)/3; i++) {
			unsigned pixel;

			pixel   = 0;
			pixel   |= ((rgb8[3*i+0] >> 3) & 0x1f);
			pixel <<= 5;
			pixel   |= ((rgb8[3*i+1] >> 3) & 0x1f);
			pixel <<= 5;
			pixel   |= ((rgb8[3*i+2] >> 3) & 0x1f);

			rgb565[2*i+0] = ((pixel >> 8) & 0xff);
			rgb565[2*i+1] = ((pixel >> 0) & 0xff);
		}
		fwrite(rgb565, sizeof(char), sizeof(rgb565), stdout);

	}

	return 0;
}
