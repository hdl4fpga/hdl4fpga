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
static unsigned char *const memdata = buffer;
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


	memdata[0] = 0x18;

	memlen  = memdata + (2+bsize);
	memlen[0]  = 0x17;
	memlen[1]  = 0x02;
	memlen[2]  = 0x00;
	memlen[3]  = 0x00;

	memaddr = memlen + 5;
	memaddr[0] = 0x16;
	memaddr[1] = 0x02;

	setbuf(stdin, NULL);
	setbuf(stdout, NULL);
	for(unsigned addr = 0; (n = fread(buffer+2, sizeof(char), bsize, stdin)) > 0; addr += (n/wsize)) {

		memdata[1] = n-1;

		memaddr[2] = (addr >> 16) & 0xff;
		memaddr[3] = (addr >>  8) & 0xff;
		memaddr[4] = (addr >>  0) & 0xff;

		memlen[4]  = n/wsize-1;

		fwrite(buffer, sizeof(char), sizeof(buffer)-(MAXSIZE-n), stdout);

	}

	return 0;
}
