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

	return 0;
}
