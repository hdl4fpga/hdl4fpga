#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#define SIZE (128)

static unsigned char buffer[(2+SIZE)+(2+3)+(2+3)];
static unsigned char *const memdata = buffer;;
static unsigned char *const memaddr = memdata + (2+SIZE);
static unsigned char *const memlen  = memaddr + 5;
static unsigned word_size = 0;
static unsigned n = 0;
static char c;

int main (int argc, char *argv[])
{
	while ((c = getopt (argc, argv, "s:")) != -1) {
		switch (c) {
		case 's':
			if (optarg){
				sscanf (optarg, "%d", &word_size);
			}
			word_size /= 8;
			break;
		case '?':
		default:
			fprintf (stderr, "usage :  format -s word_size\n");
			exit(-1);
			break;
		}
	}

	if (!word_size) {
		fprintf (stderr, "usage :  format -s word_size\n");
		exit(-1);
	}
	memdata[0] = 0x18;

	memaddr[0] = 0x16;
	memaddr[1] = 0x02;

	memlen[0]  = 0x17;
	memlen[1]  = 0x02;
	memlen[2]  = 0x00;
	memlen[3]  = 0x00;

	setbuf(stdin, NULL);
	setbuf(stdout, NULL);
	for(unsigned addr = 0; (n = fread(buffer+2, sizeof(char), SIZE, stdin)) > 0; addr += n) {

		memaddr[2] = (addr >> 16) & 0xff;
		memaddr[3] = (addr >>  8) & 0xff;
		memaddr[4] = (addr >>  0) & 0xff;

		memdata[1] = n-1;
		memlen[4]  = n/word_size-1;

		fwrite(buffer, sizeof(char), sizeof(buffer), stdout);

	}

	return 0;
}
