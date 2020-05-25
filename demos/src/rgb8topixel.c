#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#define SIZE (256)

static char pixels[SIZE];
static char rgb8[3*SIZE];
static void (*topixels)(char *, const char *) = 0;
static char c;

void torgb565 (char *pixels, const char *rgb8)
{
	unsigned addr;
	for (unsigned i=0; i < SIZE/2; i++) {
		unsigned pixel;

		pixel   = 0;
		pixel   |= ((rgb8[3*i+0] >> 3) & 0x1f);
		pixel <<= 6;
		pixel   |= ((rgb8[3*i+1] >> 2) & 0x3f);
		pixel <<= 5;
		pixel   |= ((rgb8[3*i+2] >> 3) & 0x1f);

//		switch((addr+1)%6) {
//		case 0:
//			pixel = 0;
//			break;
//		case 1:
//			pixel = -1;
//			break;
//		case 2:
//			pixel = 0;
//			break;
//		case 3:
//			pixel = 0xf800;
//			break;
//		case 4:
//			pixel = 0;
//			break;
//		case 5:
//			pixel = 0x07e0;
//			break;
//		};

		pixels[2*i+0] = ((pixel >> 8) & 0xff);
		pixels[2*i+1] = ((pixel >> 0) & 0xff);
		addr ++;
	}
}

void torgb32 (char *pixels, const char *rgb8)
{
	unsigned addr;

	for (unsigned i=0; i < SIZE/4; i++) {
		unsigned pixel;

		pixel   = 0;
		pixel   |= ((rgb8[3*i+0]) & 0xff);
		pixel <<= 8;
		pixel   |= ((rgb8[3*i+1]) & 0xff);
		pixel <<= 8;
		pixel   |= ((rgb8[3*i+2]) & 0xff);
		pixel <<= 8;

		for (unsigned j = 0; j < 3; j++) {
			pixels[4*i+3-j] = (pixel & 0xff);
			pixel >>= 8;
		}
		addr++;
	}
}

int main (int argc, char *argv[])
{

	while ((c = getopt (argc, argv, "s:")) != -1) {
		switch (c) {
		case 's':
			if (optarg) {
				if (strcmp("rgb8", optarg) == 0) {
					topixels = torgb32;
				} else if (strcmp("rgb565", optarg) == 0) {
					topixels = torgb565;
				} else {
					fprintf (stderr, "usage :  rgb8tofmt -f [rgb8|rgb565]\n");
					exit(-1);
				}
			}
			break;
		case '?':
		default:
			fprintf (stderr, "usage :  rgb8tofmt -f [rgb8|rgb565]\n");
			exit(-1);
		}
	}

	if (!topixels) {
		fprintf (stderr, "usage :  rgb8tofmt -f [rgb8|rgb565]\n");
		exit(-1);
	}

	setbuf(stdin, NULL);
	setbuf(stdout, NULL);
	while(fread(rgb8, sizeof(char), sizeof(rgb8), stdin) > 0) {
		topixels(pixels, rgb8);
		fwrite(pixels, sizeof(char), SIZE, stdout);
	}

	return 0;
}
