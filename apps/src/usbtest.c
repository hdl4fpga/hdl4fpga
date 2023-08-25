//                                                                            //
// Author(s):                                                                 //
//   Miguel Angel Sagreras                                                    //
//                                                                            //
// Copyright (C) 2015                                                         //
//    Miguel Angel Sagreras                                                   //
//                                                                            //
// This source file may be used and distributed without restriction provided  //
// that this copyright statement is not removed from the file and that any    //
// derivative work contains  the original copyright notice and the associated //
// disclaimer.                                                                //
//                                                                            //
// This source file is free software; you can redistribute it and/or modify   //
// it under the terms of the GNU General Public License as published by the   //
// Free Software Foundation, either version 3 of the License, or (at your     //
// option) any later version.                                                 //
//                                                                            //
// This source is distributed in the hope that it will be useful, but WITHOUT //
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      //
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   //
// more details at http://www.gnu.org/licenses/.                              //
//                                                                            //

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <ctype.h>
#include <time.h>
#include <libusb-1.0/libusb.h>

#include "lfsr.h"

#define DEBUG 0

typedef int unsigned lfsr_word;

const int byte_size = 8;
const size_t lfsr_size = byte_size*sizeof(lfsr_word);
__int128 seq;

static void lfsr_init ()
{
	seq = lfsr_mask(lfsr_size);
}

static void lfsr_fill (char *buffer, int length)
{
	for (int i = 0; i < length; i += sizeof(lfsr_word)) {
		memcpy(buffer+i, &seq, sizeof(lfsr_word));
		seq = lfsr_next(seq, lfsr_size);
	}
}

static void arith_init ()
{
	seq = 0;
}

static void arith_fill (char *buffer, int length)
{
	for (int i = 0; i < length; i += sizeof(char)) {
		memcpy(buffer+i, (char *) &seq, sizeof(char));
		*(char *)&seq += 1;
	}
}

static libusb_device_handle *usbdev;
static libusb_context *usbctx = NULL;

static const unsigned short vendorID  = 0x1234;
static const unsigned short productID = 0xabcd;
static const unsigned char  endp      = 0x01;
static const unsigned char  rd_endp = endp |  LIBUSB_ENDPOINT_IN;
static const unsigned char  wr_endp = endp & ~LIBUSB_ENDPOINT_IN;

static unsigned char buffer[64];
static int transferred;

#define SEND 0
#define RECV 1
#define TEST 2

static char *cmmd[] = { 
	"send", 
	"recv",
	"test"};

static int length;
static int wr_result;
static int rd_result;
static int wr_transferred;
static int rd_transferred;
static unsigned char *data;
static unsigned char wr_buffer[64];
static unsigned char rd_buffer[sizeof(wr_buffer)];
static char *format;
static void (*seq_init) ();
static void (*seq_fill) (char *buffer, int length);
static __int128 saved_seq;
static char retry = 0;
static struct timeval start_time;
static struct timeval end_time;

int main(int argc, char **argv) 
{
	if (libusb_init(&usbctx) != 0) {
		fprintf(stderr, "Error initializing libusb.\n");
		return 1;
	}

	usbdev = libusb_open_device_with_vid_pid(usbctx, vendorID, productID);
	if (usbdev == NULL) {
		fprintf(stderr, "unable to open the USB device.\n");
		libusb_exit(usbctx);
		return 1;
	}

	if (libusb_claim_interface(usbdev, 0) != 0) {
		fprintf(stderr, "unable to claim the interface of the USB device.\n");
		libusb_close(usbdev);
		libusb_exit(usbctx);
		return 1;
	}

	for (char c = getopt (argc, argv, "f:"); c != -1; c = getopt (argc, argv, "f:")) {
		switch (c) {
		case 'f':
			if (optarg) {
			} else {
				format = "%c";
			}
			format = "0x%x";
			break;
		case '?':
			exit(1);
		default:
			abort();
		}
	}

	setbuf(stdout, NULL);
	setbuf(stderr, NULL);
	for (int i = 0; i < sizeof(cmmd)/sizeof(cmmd[0]); i++) {
		for (int j = 0; j < argc && j < 2; j++) {
			if (!strcmp(argv[j], cmmd[i])) {
				int k;

				switch(i) {
				case SEND: 
					if (argc > (j+1)) {
						data   = argv[j+1];
						length = strlen(data);
					} else {
						if (!fgets(buffer, sizeof(buffer), stdin)) {
							fprintf(stderr, "Error reading stdin\n");
							return 1;
						}
						data   = buffer;
						length = strlen(data);
					}
					wr_result = libusb_bulk_transfer(usbdev,  wr_endp, data, length, &transferred, 0);
					if (wr_result == 0) {
						fprintf(stderr, "Bulk transfer completed. Bytes transferred: %d\n", transferred);
					} else {
						fprintf(stderr, "Error in bulk transfer. Error code: %d %s\n", wr_result, libusb_strerror(wr_result));
					}
					break;
				case RECV:
					if (argc > (j+1)) {
						format = argv[j+1];
					} else {
						format = "%c";
					}
					rd_result = libusb_bulk_transfer(usbdev, rd_endp, buffer, sizeof(buffer), &transferred, 0);
					if (rd_result == 0) {
						fprintf(stderr, "Bulk transfer completed. Bytes transferred: %d\n", transferred);
						for (int i = 0; i < transferred; i++) {
							printf(format, buffer[i]);
						}
						putchar('\n');

					} else {
						fprintf(stderr, "Error in bulk transfer. Error code: %d %s\n", rd_result, libusb_strerror(rd_result));
					}
					break;
				case TEST:

					if (argc > (j+1)) {
						if (!strcmp(argv[j+1],"arith")) {
							seq_init = arith_init;
							seq_fill = arith_fill;
						} else {
							if (strcmp(argv[j+1],"lfsr")) {
								fprintf(stderr, "%s is not a valid sequence. settting sequence to lfsr\n", argv[j+1]);
							}
							seq_init = lfsr_init;
							seq_fill = lfsr_fill;
						}
					} else {
						seq_init = lfsr_init;
						seq_fill = lfsr_fill;
					}
					saved_seq = seq;
					seq_init();
					while(libusb_bulk_transfer(usbdev, rd_endp, rd_buffer, sizeof(rd_buffer), &rd_transferred, 0) || rd_transferred);

					gettimeofday(&start_time, NULL);
					for (k = 0; k < 12e6/(sizeof(wr_buffer)*8*2)*100; k++) {

						printf("Pass %5d, %ld bytes sequence id 0x%08llx", k, sizeof(wr_buffer), (unsigned long long int) seq);
						seq_fill(wr_buffer, sizeof(wr_buffer));
						wr_result = libusb_bulk_transfer(usbdev, wr_endp, wr_buffer, sizeof(wr_buffer), &wr_transferred, 0);
						if (wr_result) {
							fprintf(stderr, "\nError in bulk write transfer: %s(%d)\n", libusb_strerror(wr_result), wr_result);
							if (wr_result == LIBUSB_ERROR_PIPE) {
								libusb_clear_halt(usbdev, wr_endp);
							}
							goto exit;
						}

						int result;
						do {
							result = libusb_bulk_transfer(usbdev, rd_endp, rd_buffer, sizeof(rd_buffer), &rd_transferred, 0);
							if (result) {
								rd_result = result;
								fprintf(stderr, "\nError in bulk read transfer: %s(%d)\n", libusb_strerror(rd_result), rd_result);
								goto exit;
							} 
							if (rd_result == LIBUSB_ERROR_PIPE) {
								libusb_clear_halt(usbdev, rd_endp);
							}
						} while(result || (rd_result && rd_transferred));

						if (!wr_result && !rd_result) {
							if (memcmp(wr_buffer, rd_buffer, rd_transferred) || !rd_transferred || rd_transferred != wr_transferred) {
								fprintf(stderr, "\nPass %d doesn't match write transferred %d read transferred %d\n", k, wr_transferred, rd_transferred);
								goto exit;
							}
							saved_seq = seq;
							fputs(" OK\n", stdout);
							if (DEBUG && retry) {
								getchar();
								retry = 0;
							}
						} else {
							seq = saved_seq;
							printf(" transfer error. Retrying\n");
							if (DEBUG) {
								retry = 1;
								getchar();
							}
						}
						rd_result = result;
					}
					gettimeofday(&end_time, NULL);
					fprintf(stderr, "%ld bytes of data checked successfully\nThroughput %f b/s\n",
						sizeof(wr_buffer)*k,
						(double) (sizeof(wr_buffer)*k*8*2)/(
						(double) (end_time.tv_sec  - start_time.tv_sec) +
						(double) (end_time.tv_usec - start_time.tv_usec)  / 1.0e6));
					break;
				default:
					break;
				};
				goto exit;
			}
		}
	}
	exit:

	libusb_release_interface(usbdev, 0);
	libusb_close(usbdev);
	libusb_exit(usbctx);

	return 0;
}
