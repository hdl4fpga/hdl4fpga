// Copyright (c) 2015 Miguel Angel Sagreras                                       //
//                                                                                //
// Permission is hereby granted, free of charge, to any person obtaining a copy   //
// of this software and associated documentation files (the "Software"), to deal  //
// in the Software without restriction, including without limitation the rights   //
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      //
// copies of the Software, and to permit persons to whom the Software is          //
// furnished to do so, subject to the following conditions:                       //
//                                                                                //
// The above copyright notice and this permission notice shall be included in all //
// copies or substantial portions of the Software.                                //
//                                                                                //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     //
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       //
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    //
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         //
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  //
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  //
// SOFTWARE.                                                                      //
//                                                                                //

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>
#if __MINGW32__
#include <winsock2.h>
#else
#include <arpa/inet.h>
#endif

#include <libusb-1.0/libusb.h>

#include "siolib.h"
#include "lfsr.h"

#define BYTE_SIZE 8

typedef int unsigned lfsr_word;

__int128 seq;
const size_t lfsr_size = BYTE_SIZE*sizeof(lfsr_word);

void lfsr_init ()
{
	seq = lfsr_mask(lfsr_size);
}

void lfsr_fill (char *buffer, int length)
{
	for (int i = 0; i < length; i += sizeof(lfsr_word)) {
		memcpy(buffer+i, &seq, sizeof(lfsr_word));
		seq = lfsr_next(seq, lfsr_size);
	}
}

static char p = 0;
void arith_init ()
{
	seq = 0;
}

void arith_fill (char *buffer, int length)
{
	for (int i = 0; i < length; i += sizeof(char)) {
		memcpy(buffer+i, &seq, sizeof(seq));
		*(char *)&seq += 1;
	}
}

int sio_memtrans(char *siobuf, size_t mem_address, size_t mem_length)
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

int sio_memread(size_t address, char *buffer, size_t length)
{
	static char siobuf[8*1024];
	static char rawbuf[8*1024];
	int rawbuf_len;
	char *sioptr;

	assert(length < sizeof(siobuf));

	rawbuf_len = sizeof(rawbuf);
	sioptr = siobuf;
	sioptr += sio_memtrans(sioptr, 0x80000000 | address, length);
	delete_queue(rgtr2raw(rawbuf, &rawbuf_len, sio_request(siobuf, sioptr-siobuf)));
	return sio2raw(buffer, 0x18, rawbuf, rawbuf_len);
}

int sio_memwrite(size_t address, const char *buffer, size_t length)
{
	const int prefix_length = 2+(2+4)+(2+3);
	static char siobuf[8*1024];
	char *sioptr;

	assert(length < sizeof(siobuf)-sizeof(char)*prefix_length);

	sioptr =  siobuf;
	sioptr += raw2sio(sioptr, 0x18, buffer, length);
	sioptr += sio_memtrans(sioptr, address, length);
	delete_queue(sio_request(siobuf, sioptr-siobuf));
	return sioptr-siobuf;
}

// #define MAX_ADDRESS    (32*1024*1024)
// #define MAX_ADDRESS    (256*1024*1024)
#define MAX_ADDRESS    (1024*1024*1024)
// #define MAX_ADDRESS    (16*1024*1024)

static void (*seq_init) ();
static void (*seq_fill) (char *buffer, int length);

static short vendor;
static short product;
static char  endp;
static char  colon;
static char  dot;

static struct timeval start_time;
static struct timeval end_time;

int main (int argc, char *argv[])
{
	libusb_device_handle *dev_handle;
	libusb_context *ctx = NULL;

	int nooutput;

	opterr   = 0;

	setvbuf(stderr, NULL, _IONBF, 0);
	setvbuf(stdout, NULL, _IONBF, 0);

	bool h;
	bool u;
	bool s;

	s = false;
	h = false;
	u = false;
	for (int c = getopt (argc, argv, "lh:u:d"); c != -1; c = getopt (argc, argv, "lh:u:")) {
		switch (c) {
		case 'l':
			sio_setloglevel(8|4|2|1);
			break;
		case 'h':
			if (optarg) {
				init_socket(optarg);
				h = true;
			}
			break;
		case'u':
			if (optarg) {
				sscanf(optarg,  "%hx%c%hx%c%hhx", &vendor, &colon, &product, &dot, &endp);
				u = true;
			}
			break;
		case 'd':
			s = true;
			break;
		case '?':
			exit(1);
		default:
			fprintf (stderr, "usage : memtest [ -l ] [ -o ] [ -p ] [ -h hostname ] [ -u vendor:product ] \n");
			abort();
		}
	}

	if (!(h || u)) {
		init_comms();
	} else if (!h) {
		fprintf(stderr, "0x%04hx%c0x%04hx%c0x%02hhx\n", vendor, colon, product, dot, endp);
		init_usb (vendor, product, endp);
	}

#define LSR
#ifdef LSR
	seq_init = lfsr_init;
	seq_fill = lfsr_fill;
#else
	seq_init = arith_init;
	seq_fill = arith_fill;
#endif

	char wr_buffer[8*1024];
	char rd_buffer[8*1024];
	int  address;
	int  length;

	seq_init();
	length  = 1*1024;
	// length  = 1*96;
	// length  = 1*32;
	// length  = 1*48;
	gettimeofday(&start_time, NULL);
	for(int pass = 1; pass < 2 || 0; pass++) {
		for (address = 0; address < MAX_ADDRESS; address += length) {

			fprintf(stderr, "Pass %d, Block@0x%08x, 0x%08llx ", pass, address, (unsigned long long int) seq);
			seq_fill(wr_buffer, length);
			sio_memwrite(address, wr_buffer, length);
			sio_memread (address, rd_buffer, length);
			if (s) getchar();

			for(int i = 0; i < length; i += sizeof(lfsr_word)) {
				lfsr_word data_rd;
				lfsr_word data_wt;

				data_rd = *(lfsr_word *) (rd_buffer+i);
				data_wt = *(lfsr_word *) (wr_buffer+i);
				if (data_wt!=data_rd) {
					fputc('\n', stderr); 
					fprintf(stderr, "Check failed : ");
					fprintf(stderr, "block address : 0x%08x ", address);
					fprintf(stderr, "word address : 0x%08x", address+i);
					fprintf(stderr, " : missed : 0x%08x", data_rd ^ data_wt);
					fprintf(stderr, " : data read : 0x%08x", data_rd);
					fprintf(stderr, " : data written : 0x%08x\n", data_wt);
					for (int  j=0; j < length; j += 16) {
						if (j <= i &&  i < j+16) {
							fprintf(stderr, "*\n");
						}

						for(int l=0; l < 16; l++) {
							fprintf(stderr, "%02x", ((unsigned char *) wr_buffer)[j+l]);
							fprintf(stderr, " ");
						}
						fprintf(stderr, "\n");
						for(int l=0; l < 16; l++) {
							fprintf(stderr, "%02x", ((unsigned char *) rd_buffer)[j+l]);
							fprintf(stderr, " ");
						}
						fprintf(stderr, "\n");
						fprintf(stderr, "\n");
					}
					exit(-1);
				} else {
//					fprintf(stderr, "word address : 0x%08x", mem_address+i);
//					fprintf(stderr, " : data read : 0x%08x", data_rd);
//					fprintf(stderr, " : data written : 0x%08x\n", data_wt);
				}
			}

			fprintf(stderr, "OK\n");
			// fprintf(stderr, "Pass %d, Block@0x%08x\n", pass, address);
		}
	}
	gettimeofday(&end_time, NULL);
	fprintf(stderr, "Transfer time %fsec\n",
		(double) (end_time.tv_sec  - start_time.tv_sec) +
		(double) (end_time.tv_usec - start_time.tv_usec)  / 1.0e6);

	fprintf(stderr, "finished\n");
	return 0;
}




