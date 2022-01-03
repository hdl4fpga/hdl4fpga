#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include "siolib.h"
#include "lfsr.h"

__int128 lfsr;
size_t lfsr_size = 32;

void test_init ()
{
	lfsr = lfsr_mask(lfsr_size);
}

void test_fill (char *buffer, int length)
{
	for (int i = 0; i < length; i += lfsr_size/8) {
		memcpy(buffer+i, &lfsr, lfsr_size/8);
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
	while ((c = getopt (argc, argv, "d:loh:")) != -1) {
		switch (c) {
		case 'l':
			loglevel = 8|4|2|1;
			break;
		case 'd' :
			sscanf (optarg, "%ld", &lfsr_size);
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

	char buffer[2048];
	char siobuf[2048];
	char rawbuf[2048];
	char datbuf[2048];
	char *sioptr;
	int  mem_address;
	int  mem_length;
	int  byte_length;


	byte_length = 1024;
	mem_length  = byte_length/WORD_PER_BYTE;
	test_init();
	for(int pass = 1;;pass++) {
		for (mem_address = 0; mem_address < MAX_WORDS; mem_address += mem_length) {

			test_fill(buffer, byte_length);
			sioptr =  siobuf;
			sioptr += raw2sio(sioptr, 0x18, buffer, byte_length);
			sioptr += set_trans(sioptr, mem_address, mem_length);
			delete_queue(sio_request(siobuf, sioptr-siobuf));

			sioptr =  siobuf;
			sioptr += set_trans(sioptr, 0x80000000 | mem_address, mem_length);
			int rawbuf_len = sizeof(rawbuf);
			delete_queue(rgtr2raw(rawbuf, &rawbuf_len, sio_request(siobuf, sioptr-siobuf)));
			int length = sio2raw(datbuf, 0xff, rawbuf, rawbuf_len);

			for(int i = 0; i < length/WORD_PER_BYTE; i++) {
				int data;

				data = ((int unsigned *) datbuf)[i];
				if (((int unsigned *) buffer)[i]!=data) {
					fprintf(stderr, "Check failed : ");
					fprintf(stderr, "word address : 0x%08x", mem_address);
					fprintf(stderr, " : data : 0x%08x\n", data);
					exit(-1);
				}
			}

			fprintf(stderr, "Pass %d, Block@0x%08x\n", pass, mem_address);
		}
	}

	return 0;
}
