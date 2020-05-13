#include <stdlib.h>
#include <stdio.h>

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
	char c;

	setbuf(stdin, NULL);
	setbuf(stdout, NULL);

	char unsigned len;
	char unsigned rid;

	fwrite("\000", sizeof(char), 2, stdout);
	const int n = 20;
	for(int i = 0; fread(&rid, sizeof(char), 1, stdin) > 0; i++) {
		if (fread(&len, sizeof(char), 1,   stdin) > 0) {
			int cond = 1; // ((i/3)==n || (i/3)==(n-1));
//			int cond = (i==(3*20+1));
			if (cond) 
				stream(rid);
			if (cond) 
				stream(len);
			for (int j = 0; j <= len; j++) {
				if (fread(&c, sizeof(char), 1, stdin) > 0) {
					if (cond) 
						stream(c);
				} else
					exit(-1);
			}
			if (cond) 
				fwrite("\000", sizeof(char), 2, stdout);
		} else
			exit(-1);
	}

	return 0;
}
