#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef WINDOWS
#include <ws2tcpip.h>
#include <wininet.h>
#define htobe64(x) \
	((((unsigned long long)(x) & (unsigned long long)0x00000000000000ffULL) << 56) |\
	 (((unsigned long long)(x) & (unsigned long long)0x000000000000ff00ULL) << 40) |\
	 (((unsigned long long)(x) & (unsigned long long)0x0000000000ff0000ULL) << 24) |\
	 (((unsigned long long)(x) & (unsigned long long)0x00000000ff000000ULL) <<  8) |\
	 (((unsigned long long)(x) & (unsigned long long)0x000000ff00000000ULL) >>  8) |\
	 (((unsigned long long)(x) & (unsigned long long)0x0000ff0000000000ULL) >> 24) |\
	 (((unsigned long long)(x) & (unsigned long long)0x00ff000000000000ULL) >> 40) |\
	 (((unsigned long long)(x) & (unsigned long long)0xff00000000000000ULL) >> 56))
#else
#include <arpa/inet.h>
#endif
  
int main (int argc, char *argv[])
{
	long long unsigned int lfsr = 0;
	long long unsigned int mask = ~0;
	long long unsigned int datum;
	long long unsigned int check;

	int size = 32;

	if (argc > 1) 
		sscanf (argv[1], "%d", &size);

	if (size != 64) 
		mask = ((1LL << size)-1);

	const long long unsigned int p = (size==64) ? 0x5800000000000000 : 0x23000000;
	
	int i;
	for(i = 0; scanf("%llx", &datum) > 0; i++) {
		int k;

		// datum  = (size==64) ? htobe64(datum) : htonl(datum);
		datum &= mask;
		if (!lfsr)
			lfsr = mask;
					        
		check = lfsr;
		check = (size==64) ? htobe64(check) : htonl(check);

		if (check != (datum)){
			fprintf(stderr, "Failed %d : ", i+1);
			switch(size) {
			case 32:
				fprintf(stderr,"0x%08lx 0x%08lx 0x%08lx\n", (long unsigned int) (datum), (long unsigned int) check, (long unsigned int) (datum^check));
				break;
			case 64:
				fprintf(stderr,"0x%016llx 0x%016llx 0x%016llx\n", (datum), check, (datum)^check);
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
