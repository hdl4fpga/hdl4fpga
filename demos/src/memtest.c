#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include "siolib.h"
#include "lfsr.h"

#define BYTE_SIZE 8

typedef int unsigned lfsr_word;

__int128 lfsr;
const size_t lfsr_size = BYTE_SIZE*sizeof(lfsr_word);

void test_init ()
{
	lfsr = lfsr_mask(lfsr_size);
}

void test_fill (char *buffer, int length)
{
	for (int i = 0; i < length; i += sizeof(lfsr_word)) {
		memcpy(buffer+i, &lfsr, sizeof(lfsr_word));
		lfsr = lfsr_next(lfsr, lfsr_size);
	}
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

#define MAX_ADDRESS    (32*1024*1024)

int main (int argc, char *argv[])
{
	int nooutput;

	loglevel = 0;
	opterr   = 0;
	nooutput = 0;

	setvbuf(stderr, NULL, _IONBF, 0);
	setvbuf(stdout, NULL, _IONBF, 0);

	int c;
	while ((c = getopt (argc, argv, "loh:")) != -1) {
		switch (c) {
		case 'l':
			loglevel = 8|4|2|1;
			break;
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

	char buffer[8*1024];
	char siobuf[8*1024];
	char rawbuf[8*1024];
	char datbuf[8*1024];
	char *sioptr;
	int  mem_address;
	int  mem_length;

	mem_length  = 1024;
	test_init();
	for(int pass = 1;;pass++) {
		for (mem_address = 0; mem_address < MAX_ADDRESS; mem_address += mem_length) {

			test_fill(buffer, mem_length);
			sioptr =  siobuf;
			sioptr += raw2sio(sioptr, 0x18, buffer, mem_length);
			sioptr += set_trans(sioptr, mem_address, mem_length);
			delete_queue(sio_request(siobuf, sioptr-siobuf));

			sioptr =  siobuf;
			sioptr += set_trans(sioptr, 0x80000000 | mem_address, mem_length);
			int rawbuf_len = sizeof(rawbuf);
			delete_queue(rgtr2raw(rawbuf, &rawbuf_len, sio_request(siobuf, sioptr-siobuf)));
			int length = sio2raw(datbuf, 0xff, rawbuf, rawbuf_len);

			for(int i = 0; i < length; i += sizeof(lfsr_word)) {
				lfsr_word data_rd;
				lfsr_word data_wt;

				data_rd = *(lfsr_word *) (datbuf+i);
				data_wt = *(lfsr_word *) (buffer+i);
				if (data_wt!=data_rd) {
					fprintf(stderr, "Check failed : ");
					fprintf(stderr, "word address : 0x%08x", mem_address+i);
					fprintf(stderr, " : data read : 0x%08x", data_rd);
					fprintf(stderr, " : data written : 0x%08x\n", data_wt);
					exit(-1);
				} else {
//					fprintf(stderr, "word address : 0x%08x", mem_address+i);
//					fprintf(stderr, " : data read : 0x%08x", data_rd);
//					fprintf(stderr, " : data written : 0x%08x\n", data_wt);
				}
			}

			fprintf(stderr, "Pass %d, Block@0x%08x\n", pass, mem_address);
		}
	}

	return 0;
}
