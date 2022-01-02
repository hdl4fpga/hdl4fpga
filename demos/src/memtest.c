#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include "siolib.h"

__int128 unsigned lfsr_mask(int size)
{
	__int128 unsigned mask;

	mask = -1;
	mask >>= (128-size);

	return mask;
}

__int128 unsigned lfsr_p (int size)
{
	unsigned __int128 p;
	switch(size) {
	case 128:
		p   = 0xE100000000000000;
		p <<= 64;
		break;
	case 64:
		p = 0xD800000000000000;
		break;
	case 32:
		p = 0xA3000000;
		break;
	default:
		break;
	}
	p ^= (((__int128) 1) << (size-1));
	return p;
}

__int128 unsigned lfsr_next(__int128 unsigned lfsr, int lfsr_size)
{
	return ((lfsr>>1)|((lfsr&1)<<(lfsr_size-1))) ^ (((lfsr&1) ? lfsr_mask(lfsr_size) : 0) & lfsr_p(lfsr_size));
}

__int128 lfsr_fill (char *buffer, int size, __int128 lfsr, size_t lfsr_size)
{
	for (int i = 0; i < size; i += lfsr_size/8) {
		memcpy(buffer+i, &lfsr, lfsr_size/8);
		lfsr = lfsr_next(lfsr, lfsr_size);
	}
	return lfsr;
}

int set_trans(char *siobuf, int mem_address, int mem_length)
{
	char *sioptr;
	int nmem_address;
	int nmem_length;

	nmem_address = htonl(mem_address);
	nmem_length  = htonl(mem_length-1);
	nmem_length  >>= 8;

	sioptr  = siobuf;
	sioptr += raw2sio(sioptr, 0x17, (char *) &nmem_length,  3);
	sioptr += raw2sio(sioptr, 0x16, (char *) &nmem_address, 4);

	return sioptr-siobuf;
}

#define BYTE_SIZE      8
#define WORD_SIZE      32
#define WORD_PER_BYTE  (WORD_SIZE/BYTE_SIZE)
#define MAX_WORDS      (256*1024*1024/WORD_SIZE)
#define MAX_PAYLOAD    (1024/WORD_SIZE)

int main (int argc, char *argv[])
{
	int nooutput;

	loglevel = 0;
	opterr   = 0;
	nooutput = 0;

	setvbuf(stderr, NULL, _IONBF, 0);
	setvbuf(stdout, NULL, _IONBF, 0);

	int c;
	int lfsr_size = 32;
	while ((c = getopt (argc, argv, "d:loh:")) != -1) {
		switch (c) {
		case 'l':
			loglevel = 8|4|2|1;
			break;
		case 'd' :
			sscanf (optarg, "%d", &lfsr_size);
		case 'o':
			nooutput = 1;
			break;
		case 'h':
			if (optarg) {
				sscanf (optarg, "%64s", hostname);
			}
			break;
		case '?':
			exit(1);
		default:
			fprintf (stderr, "usage : sendbyudp [ -l ] [ -o ] [ -p ] [ -h hostname ]\n");
			abort();
		}
	}

	if (strlen(hostname) > 0) {
		init_socket();
		if (LOG1) {
			fprintf (stderr, "Socket has been initialized\n");
		}
	} else {
		init_comms();
		if (LOG1) {
			fprintf (stderr, "COMMS has been initialized\n");
		}
	}

	lfsr_size=32;
	__int128 lfsr;

	char buffer[2048];
	char siobuf[2048];
	char rawbuf[2048];
	char datbuf[2048];
	char *sioptr;
	int  mem_address;
	int  mem_length =1;

	lfsr = lfsr_mask(lfsr_size);

	mem_length = 1280/WORD_PER_BYTE;
	for (mem_address = 0; mem_address < MAX_WORDS; mem_address += mem_length) {
		int nmem_length;
		int nmem_address;
		int byte_length;

		byte_length    = mem_length*WORD_PER_BYTE;

		lfsr   =  lfsr_fill(buffer, byte_length, lfsr_mask(lfsr_size), lfsr_size);
		sioptr =  siobuf;
		sioptr += raw2sio(sioptr, 0x18, buffer, byte_length);
		sioptr += set_trans(sioptr, mem_address, mem_length);
		delete_queue(sio_request(siobuf, sioptr-siobuf));

		sioptr =  siobuf;
		sioptr += set_trans(sioptr, 0x80000000 | mem_address, mem_length);
		int rawbuf_len = sizeof(rawbuf);
		delete_queue(rgtr2raw(rawbuf, &rawbuf_len, sio_request(siobuf, sioptr-siobuf)));
		int length = sio2raw(datbuf, 0xff, rawbuf, rawbuf_len);
		for(int i = 0; i < length; i++) {
			if (datbuf[i]!=buffer[i]) {
				fprintf(stderr, "Salio mal %x\n", i);
				exit(0);
			}
		}
	fprintf(stderr, "%d\n", rawbuf_len);

	}



	for(long long unsigned i = 0; i < (long long unsigned) 1 << 32; i++) {
		switch(lfsr_size) {
		case 32:
			fprintf(stderr,"0x%08lx\n", (long unsigned int) lfsr);
			break;
		case 64:
			fprintf(stderr,"0x%016llx\n", (long long unsigned int) lfsr);
			break;
		case 128:
			fprintf(stderr,"0x%016llx%016llx\n",
				(long long unsigned int ) (lfsr >> 64),
				(long long unsigned int ) (lfsr &  lfsr_mask(lfsr_size)));
			break;
		default:
			fprintf(stderr,"invalid size\n");
			return -1;
		}
		lfsr = lfsr_next(lfsr, lfsr_size);
	}

	return 0;
}
