#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#define MAXSIZE (256)

static unsigned char buffer[(2+MAXSIZE)+(2+3)+(2+3)];
static unsigned char *bufptr;
static unsigned char *memdata;
static unsigned char *memaddr;
static unsigned char *memlen;
static unsigned wsize = 0;
static unsigned bsize = 0;

static unsigned n = 0;
static char c;

void help ()
{
	fprintf (stderr, "usage :  format -b buffer_size -s word_size\n");
}

int main (int argc, char *argv[])
{
	while ((c = getopt (argc, argv, "b:w:")) != -1) {
		switch (c) {
		case 'w':
			if (optarg){
				sscanf (optarg, "%d", &wsize);
			}
			wsize /= 8;
			break;
		case 'b':
			if (optarg){
				sscanf (optarg, "%d", &bsize);
				if (bsize > 256) {
					fprintf (stderr, "Maximun buffer_size is 256\n");
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

	if (!wsize) {
		help();
		exit(-1);
	} else
		fprintf (stderr, "word size is %d\n", wsize);

	if (!bsize) {
		help();
		exit(-1);
	} else
		fprintf (stderr, "buffer size is %d\n", bsize);


	setbuf(stdin, NULL);
	setbuf(stdout, NULL);
	for(unsigned addr = 0; ; addr += (n/wsize)) {

		bufptr = buffer;

		memlen    = bufptr;
		memlen[0] = 0x17;
		memlen[1] = 0x02;

		bufptr += (2 + bufptr[1] + 1);

		memdata    = bufptr;
		memdata[0] = 0x18;

		if (!(n = fread(memdata+2, sizeof(char), bsize, stdin)) > 0)
			break;
		memdata[1] = n-1;

		bufptr += (2 + bufptr[1] + 1);

		memaddr    = bufptr;
		memaddr[0] = 0x16;
		memaddr[1] = 0x02;

		memlen[2]  = 0xff & ((n/wsize-1) >> 16);
		memlen[3]  = 0xff & ((n/wsize-1) >>  8);
		memlen[4]  = 0xff & ((n/wsize-1) >>  0);

		memaddr[2] = 0xff & (addr >> 16);
		memaddr[3] = 0xff & (addr >>  8);
		memaddr[4] = 0xff & (addr >>  0);

		fwrite(buffer, sizeof(char), sizeof(buffer)-(MAXSIZE-n), stdout);

	}

	return 0;
}
