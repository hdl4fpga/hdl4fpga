#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

typedef unsigned int lfsr_t;

int main (int argc, char *argv[])
{
	lfsr_t lfsr = 0;
	long long unsigned int datum;
	int i;


	for(i = 0; scanf("%llx", &datum) > 0; i++) {
		lfsr_t p = 0x22800000;
		unsigned long long check;
		int k;

		if (!lfsr) lfsr = (0xffffffff & (datum));
					        
		check = ((unsigned long long)lfsr) |  (((unsigned long long)lfsr) << 32);

		if (check != (datum)){
			fprintf(stderr, "Failed %d : ", i+1);
			fprintf(stderr,"0x%016llx 0x%016llx 0x%016llx\n", (datum), check, (datum)^check);
			//return -1;
		} else {
			//printf("0x%016llx 0x%016llx\n", (datum), check);
		}

		lfsr = ((lfsr>>1)|((lfsr&1)<<(32-1))) ^ (((lfsr&1) ? ~0 : 0) & p);
	}

	return 0;
}
