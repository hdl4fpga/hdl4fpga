#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#define htonll(x) \
	((((unsigned long long)(x) & (unsigned long long)0x00000000000000ffULL) << 56) |\
	 (((unsigned long long)(x) & (unsigned long long)0x000000000000ff00ULL) << 40) |\
	 (((unsigned long long)(x) & (unsigned long long)0x0000000000ff0000ULL) << 24) |\
	 (((unsigned long long)(x) & (unsigned long long)0x00000000ff000000ULL) <<  8) |\
	 (((unsigned long long)(x) & (unsigned long long)0x000000ff00000000ULL) >>  8) |\
	 (((unsigned long long)(x) & (unsigned long long)0x0000ff0000000000ULL) >> 24) |\
	 (((unsigned long long)(x) & (unsigned long long)0x00ff000000000000ULL) >> 40) |\
	 (((unsigned long long)(x) & (unsigned long long)0xff00000000000000ULL) >> 56))

typedef unsigned int lfsr_t;

main (int argc, char *argv[])
{
	lfsr_t lfsr = 0;
	long long unsigned int datum;
	int i;
	int size;

	if (!(argc > 1)) {
		fprintf (stderr, "no argument %d", argc);
		abort();
	}
	sscanf(argv[1],"%d", &size);

	for(i = 0; scanf("%llx", &datum) > 0; i++) {
		lfsr_t p = (size!=32) ? 0x38 : 0x22800000;
		unsigned long long check;
		int k;

		if (!lfsr) lfsr = 
			(size!=32) 
				? (0xff & htobe64(datum))
				: (0x000000ff & ~ htobe64(datum)) |	(0x0000ff00 &   htobe64(datum)) |
			      (0x00ff0000 & ~(htobe64(datum) >> 16)) |(0xff000000 &  (htobe64(datum) >> 16));
					        
		check = 
			(size!=32)
			 ? (((((((((unsigned long long)lfsr<<8)&0xff00) | (~(unsigned long long)lfsr<<0)&0x00ff) << 16) & 0xffff0000) |
			    (((~((unsigned long long)lfsr<<8)&0xff00  | ( (unsigned long long)lfsr<<0)) & 0xffff))) << 32) & 0xffffffff00000000) |
			   (((((((unsigned long long)lfsr<<8)&0xff00) | (~(unsigned long long)lfsr<<0)&0x00ff) << 16) & 0xffff0000) |
			    (((~((unsigned long long)lfsr<<8)&0xff00  | ( (unsigned long long)lfsr<<0)) & 0xffff)))

			  : (((~(unsigned long long)lfsr&0xff000000) | ( (unsigned long long)lfsr&0x00ff0000)) << 32) |
			  ((( (unsigned long long)lfsr&0xff000000) | (~(unsigned long long)lfsr&0x00ff0000)) << 16) |
			  (((~(unsigned long long)lfsr&0x0000ff00) | ( (unsigned long long)lfsr&0x000000ff)) << 16) |
			  ((( (unsigned long long)lfsr&0x0000ff00) | (~(unsigned long long)lfsr&0x000000ff)) <<  0);

		printf("0x%016llx 0x%016llx\n", htonll(datum), check);
		if (check != htobe64(datum)){
			fprintf(stderr, "Failed %d\n", i);
			fprintf(stderr,"0x%016llx 0x%016llx 0x%016llx\n", htonll(datum)^check, htonll(datum), check);
			abort();
			return -1;
		}

		lfsr = ((lfsr>>1)|((lfsr&1)<<(size-1))) ^ (((lfsr&1) ? ~0 : 0) & p);
	}

	return 0;
}
