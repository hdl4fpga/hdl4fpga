#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef WINDOWS
#define htobe64(x) \
	((((unsigned long long)(x) & (unsigned long long)0x00000000000000ffULL) << 56) |\
	 (((unsigned long long)(x) & (unsigned long long)0x000000000000ff00ULL) << 40) |\
	 (((unsigned long long)(x) & (unsigned long long)0x0000000000ff0000ULL) << 24) |\
	 (((unsigned long long)(x) & (unsigned long long)0x00000000ff000000ULL) <<  8) |\
	 (((unsigned long long)(x) & (unsigned long long)0x000000ff00000000ULL) >>  8) |\
	 (((unsigned long long)(x) & (unsigned long long)0x0000ff0000000000ULL) >> 24) |\
	 (((unsigned long long)(x) & (unsigned long long)0x00ff000000000000ULL) >> 40) |\
	 (((unsigned long long)(x) & (unsigned long long)0xff00000000000000ULL) >> 56))
#endif

  
typedef long long unsigned int lfsr_t;

int main (int argc, char *argv[])
{
	lfsr_t lfsr = 0;
	long long unsigned int datum;
	int i;


	for(i = 0; scanf("%llx", &datum) > 0; i++) {
		lfsr_t p = 0x5800000000000000;
		unsigned long long check;
		int k;

		datum = htobe64(datum);
		if (!lfsr) lfsr = (0xffffffffffffffff & (datum));
					        
		check = lfsr;

		if (check != (datum)){
			fprintf(stderr, "Failed %d : ", i+1);
			fprintf(stderr,"0x%016llx 0x%016llx 0x%016llx\n", (datum), check, (datum)^check);
			//return -1;
		} else {
			//printf("0x%016llx 0x%016llx\n", (datum), check);
		}

		lfsr = ((lfsr>>1)|((lfsr&1)<<(64-1))) ^ (((lfsr&1) ? ~0 : 0) & p);
	}

	return 0;
}
