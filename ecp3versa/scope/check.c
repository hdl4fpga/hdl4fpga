#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef WINDOWS
#include <ws2tcpip.h>
#include <wininet.h>
#else
#include <arpa/inet.h>
#endif
  
unsigned __int128 htobe128 (unsigned __int128 num)
{
	unsigned __int128 a;

	a   = ~0;
	a <<= 64;
	a   = ~a;
	a = htobe64(num & a);
	a <<= 64;
	a |= htobe64(num >> 64);
	return a;
}

int main (int argc, char *argv[])
{
	unsigned __int128 lfsr = 0;
	unsigned __int128 mask = ~0;
	unsigned __int128 datum;
	unsigned __int128 check;
	unsigned __int128 diff;

	int size = 32;

	if (argc > 1) 
		sscanf (argv[1], "%d", &size);

	if (size != 128) { 
		mask = 1;
		mask <<= size;
		mask -= 1;
	}

	unsigned __int128 p = (size==128) ? (__int128) 0xE100000000000000 << 64 : (size==64)  ? 0xD800000000000000 : 0xA3000000;
	p ^= (((__int128) 1) << (size-1));

	int i;
	for(i = 0;; i++) {
		int k;

		if (!(scanf("%10x", (unsigned int *) &datum) > 0))
			return 0;
		if (size > 32) {
			*(((unsigned int *) &datum)+1) = *(unsigned int *) &datum;
			if (!(scanf("%8x", ((unsigned int *) &datum))) > 0)
				return 0;

			if (size > 64) {
				*((long long unsigned int *) &datum+1) = *(long long unsigned int *) &datum;
				if (!(scanf("%16llx", (long long unsigned int *) &datum) > 0))
					return 0;
			}
		}

		datum &= mask;
		if (!lfsr)
			lfsr = mask;
					        
		check = lfsr;
		check = (size==128) ? check : (size==64) ? check : check;

		if (check != (datum)){
			fprintf(stderr, "Failed %d : ", i+1);
			switch(size) {
			case 32:
				fprintf(stderr,"0x%08lx 0x%08lx 0x%08lx\n", (long unsigned int) (datum), (long unsigned int) check, (long unsigned int) (datum^check));
				break;
			case 64:
				fprintf(stderr,"0x%016llx 0x%016llx 0x%016llx\n", (long long unsigned int)(datum), (long long unsigned int)check, (long long unsigned int)((datum)^check));
				break;
			case 128:
				diff = (datum)^check;
				fprintf(stderr,"0x%016llx%016llx 0x%016llx%016llx 0x%016llx%016llx\n",
					*(((long long unsigned int *)&datum)+1),
					*(((long long unsigned int *)&datum)+0),
					*(((long long unsigned int *)&check)+1),
					*(((long long unsigned int *)&check)+0),
					*(((long long unsigned int *)&diff)+1),
					*(((long long unsigned int *)&diff)+0));
				break;
			default:
				fprintf(stderr,"invalid size\n");
				return -1;
			}
		}

		lfsr = ((lfsr>>1)|((lfsr&1)<<(size-1))) ^ (((lfsr&1) ? mask : 0) & p);
	}

	return 0;
}
