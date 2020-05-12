#include <stdlib.h>
#include <stdio.h>
#include <math.h>

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
	fwrite("\000", sizeof(char), 2, stdout);
	while(fread(&c, sizeof(char), 1, stdin) > 0) {
		stream(c);
	}
	fwrite("\000", sizeof(char), 2, stdout);

	return 0;
}
