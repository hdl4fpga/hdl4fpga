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
#include <libusb-1.0/libusb.h>

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

static char p = 0;
void seq_init ()
{
	p = 0;
}

void seq_fill (char *buffer, int length)
{
	for (int i = 0; i < length; i += sizeof(p)) {
		memcpy(buffer+i, &p, sizeof(p));
		p += 1;
	}
}

static libusb_device_handle *usbdev;
static libusb_context *usbctx = NULL;

static const unsigned short vendorID  = 0x1234;
static const unsigned short productID = 0xabcd;
static const unsigned char  endp      = 0x01;

static unsigned char buffer[64];
static int transferred;

#define SEND 0
#define RECV 1
#define TEST 2

static char *cmmd[] = { 
	"send", 
	"recv",
	"test"};

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

	for (int i = 0; i < sizeof(cmmd)/sizeof(cmmd[0]); i++) {
		for (int j = 0; j < argc && j < 2; j++) {
			if (!strcmp(argv[j], cmmd[i])) {
				unsigned char pipe;
				int result;

				pipe = endp;
				switch(i) {
				case SEND: 
					unsigned char *data;
					int length;
					pipe &= ~0x80;
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
					result = libusb_bulk_transfer(usbdev, pipe, data, length, &transferred, 0);
					if (result == 0) {
						fprintf(stderr, "Bulk transfer completed. Bytes transferred: %d\n", transferred);
					} else {
						fprintf(stderr, "Error in bulk transfer. Error code: %d\n", result);
					}
					break;
				case RECV:
					pipe |=  0x80;
					result = libusb_bulk_transfer(usbdev, pipe, buffer, sizeof(buffer), &transferred, 0);
					if (result == 0) {
						fprintf(stderr, "Bulk transfer completed. Bytes transferred: %d\n", transferred);
						for (int i = 0; i < transferred; i++) {
							// printf("0x%02x\n", buffer[i]);
							putchar(buffer[i]);
						}
						putchar('\n');
					} else {
						fprintf(stderr, "Error in bulk transfer. Error code: %d\n", result);
					}
					break;
				case TEST:
					int wr_transferred;
					int rd_transferred;
					unsigned char wr_buffer[64];
					unsigned char rd_buffer[sizeof(wr_buffer)];
					int k;

					// test_init();
					seq_init();
					for (k = 0; 1 || k < 10240; k++) {

						// test_fill(wr_buffer, sizeof(wr_buffer));
						seq_fill(wr_buffer, sizeof(wr_buffer));
						fprintf(stderr, "Pass %5d, %ld bytes lfsr block 0x%08llx", k, sizeof(wr_buffer), (unsigned long long int) lfsr);
						pipe &= ~0x80;
						result = libusb_bulk_transfer(usbdev, pipe, wr_buffer, sizeof(wr_buffer), &wr_transferred, 0);
						if (result) {
							fprintf(stderr, "Error in write bulk transfer. Error code: %d\n", result);
						}

						pipe |=  0x80;
						result = libusb_bulk_transfer(usbdev, pipe, rd_buffer, sizeof(rd_buffer), &rd_transferred, 0);
						if (result) {
							fprintf(stderr, "Error in read bulk transfer. Error code: %d\n", result);
						}
						if (memcmp(wr_buffer, rd_buffer, sizeof(wr_buffer)) || wr_transferred!=rd_transferred) {
							fprintf(stderr, "\nPass %d doesn't match write transfered %d read transfered %d\n", k, wr_transferred, rd_transferred);
							goto exit;
						}
						fputs(" OK\n", stderr);
						// getchar();
					}
					fprintf(stderr, "%ld bytes of data checked successfully\n", sizeof(wr_buffer)*k);
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