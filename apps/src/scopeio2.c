#include <stdlib.h>
#include <stdio.h>
#include <netinet/in.h>

#ifdef _WIN32
	_setmode(_fileno(stdin), _O_BINARY);
#endif

#define BYTEWIDTH
char buff[256];
int main (int argc, char *argv[])
{
	int c; 
	unsigned int sample;
	int acc;
	int length;
	int data;
	data = 0;
	acc  = 0;
	int j = 0;
	int n = 0;
	while((c = getchar()) >= 0) {
		length = getchar();
		switch(c) {
		case 0x18:
			for (int i =0; i <= length; i++) {
				data <<= 8;
				c = getchar();
				data |= c;
				acc += 8;
				data &= ((1 << (13+8-1))-1);
				if (acc >= 13) {
					acc %= 13;
					sample = data;
					sample >>= acc;
					sample &= (1 << 13)-1;
					if (!j) printf("%5d ",n++);
					printf("%4d", sample);
					j = ++j % 8;
					if (j) {
						printf(" ");
					} else {
						printf("\n");
					}
				}
			}
			break;
		default:
			for (int i = 0; i <= length; i++) {
				getchar();
			}
		}
	}
	return 0;
}
