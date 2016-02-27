#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include <arpa/inet.h>
typedef unsigned int lfsr_t;

int main (int argc, char *argv[])
{
	lfsr_t lfsr = 0;
	long unsigned int datum;
	int i;


	for(i = 0; scanf("%lx", &datum) > 0; i++) {
		datum = htonl(datum);
		lfsr_t p = 0x22800000;
		unsigned long long check;
		int k;

		if (!lfsr) lfsr = (0xffffffff & (datum));
					        
		check = (unsigned long long)lfsr;

		if (check != (datum)){
			fprintf(stderr, "Failed %d : ", i+1);
			fprintf(stderr,"0x%08lx 0x%08lx 0x%08lx\n", (datum), check, (datum)^check);
			//return -1;
		} else {
			//printf("0x%016llx 0x%016llx\n", (datum), check);
		}

		lfsr = ((lfsr>>1)|((lfsr&1)<<(32-1))) ^ (((lfsr&1) ? ~0 : 0) & p);
	}

	return 0;
}
