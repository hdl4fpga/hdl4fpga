#include <stdlib.h>
#include <stdio.h>
#include <netinet/in.h>

#ifdef _WIN32
	_setmode(_fileno(stdin), _O_BINARY);
#endif

#define CHAR_WIDTH    8
#define CHANNELS      8
#define SAMPLE_WIDTH 13

char buff[256];

const double vt_step = 3.3/(1<<(SAMPLE_WIDTH-1));
const double freq = 1.024e6/4;
const double unit = 1.0e-6;
// pulseview -I csv:column_formats=t,8a data.csv 
int main (int argc, char *argv[])
{
	int acc  = 0;
	int data = 0;
	int j    = 0;
	int n    = 0;

	unsigned int sample;
	unsigned int length;
	int c; 

	printf("Time[us], GN14 (analog), GP14 (analog), GN15 (analog), GP15 (analog), GN16 (analog), GP16 (analog), GN17 (analog), GP17 (analog)\n");

	while((c = getchar()) >= 0) {
		if ((int)(length = getchar()) < 0) ;
		switch(c) {
		case 0x18:
			for (int i = 0; i <= length; i++) {
				data <<= CHAR_WIDTH;
				c = getchar();
				data |= c;
				acc += CHAR_WIDTH;
				data &= ((1 << (SAMPLE_WIDTH+CHAR_WIDTH-1))-1);
				if (acc >= SAMPLE_WIDTH) {
					acc %= SAMPLE_WIDTH;
					sample = data;
					sample >>= acc;
					sample &= (1 << SAMPLE_WIDTH)-1;
					if (!j) printf("%f, ",(8+n++)/freq);
					printf("%4f", vt_step*sample);
					j = ++j % CHANNELS;
					if (j) {
						printf(", ");
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
	while(j) {
		printf("%d", j);
		j = (++j) % CHANNELS;
		if (j) {
			printf(", ");
		}
	}

	return 0;
}
