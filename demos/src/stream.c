#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <time.h>

void stream (char c)
{
	if (c == 0) 
		fwrite("\\", sizeof(char), 1, stdout);
	else if(c == '\\')
		fwrite("\\", sizeof(char), 1, stdout);

	fwrite(&c, sizeof(char), 1, stdout);
}

int main (int argc, char *argv[])
{
	int c;
	int pktmd;

	pktmd  = 0;
	opterr = 0;

	while ((c = getopt (argc, argv, "p")) != -1) {
		switch (c) {
		case 'p':
			pktmd = 1;
			break;
		case '?':
			fprintf (stderr, "usage : stream -p\n");
			exit(1);
		default:
			exit(1);
		}
	}

	setbuf(stdin, NULL);
	setbuf(stdout, NULL);

	char unsigned len;
	char unsigned rid;

	fwrite("\000", sizeof(char), 2, stdout);

	while (fread(&rid, sizeof(char), 1, stdin) > 0) {
		char c;

		if (fread(&len, sizeof(char), 1, stdin) > 0) {
			stream(rid);
			stream(len);
			for (int i = 0; i <= len; i++) {
				if (fread(&c, sizeof(char), 1, stdin) > 0) {
					stream(c);
				} else
					exit(-1);
			}
			fwrite("\000", sizeof(char), 2, stdout);
			nanosleep((const struct timespec[]){ {0, 2000000L } }, NULL);
		} else
			exit(-1);
	}

//	for(;;) {
//		if (pktmd) {
//			if ((fread(&size, sizeof(unsigned short), 1, stdin) > 0))
//				fprintf (stderr, "packet size %d\n", size);
//			else
//				return 0;
//		}
//
//			
//		if ((n = fread(buffer, sizeof(unsigned char), size, stdin)) > 0) {
//			if (size > MAXSIZE) {
//				fprintf (stderr, "packet size %d greater than %d\n", size, MAXSIZE);
//				exit(-1);
//			}
//
//			buffer[size++] = 0x00;
//			buffer[size++] = 0x00;
//			if (fwrite(buffer, sizeof(char), size, stdout) < 0) {
//				perror ("sending packet");
//				exit (-1);
//			}
//			fprintf (stderr, "packet length %d\n", n);
//			nanosleep((const struct timespec[]){ {0, 500000L } }, NULL);
//		} else if (n < 0) {
//			perror ("reading packet");
//			exit(-1);
//		}
//		else
//			break;
//	}

	return 0;
}
