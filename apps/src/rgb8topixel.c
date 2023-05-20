#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#define SIZE (256)

static char pixels[SIZE];
static char rgb8[3*SIZE];
static int (*topixels)(char *, const char *, int) = 0;
static char c;

int torgb565 (char *pixels, const char *rgb8, int n)
{
	unsigned m;
	unsigned i;

	m = 0;
	for (i=0; i < n/3; i++) {
		unsigned pixel;

		pixel   = 0;
		pixel   |= ((rgb8[3*i+0] >> 3) & 0x1f);
		pixel <<= 6;
		pixel   |= ((rgb8[3*i+1] >> 2) & 0x3f);
		pixel <<= 5;
		pixel   |= ((rgb8[3*i+2] >> 3) & 0x1f);

		pixels[2*i+0] = ((pixel >> 8) & 0xff);
		m++;
		pixels[2*i+1] = ((pixel >> 0) & 0xff);
		m++;
	}
	return m;
}

int torgb24 (char *pixels, const char *rgb8, int n)
{

	unsigned m;
	unsigned i;

	m = 0;
	for (i=0; i < n/3; i++) {
		unsigned pixel;

		pixel = 0;
		for (int j = 0; j < 3; j++) {
			pixel <<= 8;
			pixel |= ((rgb8[3*i+j]) & 0xff);
		}

		for (int j = 0; j < 2; j++) {
			pixels[3*i+2-j] = (pixel & 0xff);
			pixel >>= 8;
			m++;
		}
	}
	return m;
}

int torgb32 (char *pixels, const char *rgb8, int n)
{

	unsigned m;
	unsigned i;

	m = 0;
	for (i=0; i < n/3; i++) {
		unsigned pixel;

		pixel   = 0;
		pixel   |= ((rgb8[3*i+0]) & 0xff);
		pixel <<= 8;
		pixel   |= ((rgb8[3*i+1]) & 0xff);
		pixel <<= 8;
		pixel   |= ((rgb8[3*i+2]) & 0xff);
		pixel <<= 8;

		for (unsigned j = 0; j < 4; j++) {
			pixels[4*i+3-j] = (pixel & 0xff);
			pixel >>= 8;
			m++;
		}
	}
	return m;
}

int main (int argc, char *argv[])
{

	int n, m;

	while ((c = getopt (argc, argv, "f:")) != -1) {
		switch (c) {
		case 'f':
			if (optarg) {
				if (strcmp("rgb32", optarg) == 0) {
					topixels = torgb32;
				} else if (strcmp("rgb24", optarg) == 0) {
					topixels = torgb24;		
				} else if (strcmp("rgb565", optarg) == 0) {
					topixels = torgb565;
				}
			}
			break;
		case '?':
		default:
			fprintf (stderr, "usage :  rgb8tofmt -f [rgb32|rgb24|rgb565]\n");
			exit(-1);
		}
	}

	if (!topixels) {
		fprintf (stderr, "usage :  rgb8tofmt -f [rgb32|rgb565]\n");
		exit(-1);
	}

	setbuf(stdin, NULL);
	setbuf(stdout, NULL);
	while((n = fread(rgb8, sizeof(char), sizeof(rgb8), stdin)) > 0) {
		m = topixels(pixels, rgb8, n);
		fwrite(pixels, sizeof(char), m, stdout);
	}

	return 0;
}
