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
#include <fcntl.h>
#include <stdbool.h>
#include "siolib.h"

static short vendor;
static short product;
static char  endp;
static char  colon;
static char  dot;

static long unsigned totaldata;
static struct timeval start_time;
static struct timeval end_time;

int main (int argc, char *argv[])
{

	int pktmd;
	int nooutput;
	pktmd    = 0;
	opterr   = 0;
	nooutput = 0;

	setvbuf(stderr, NULL, _IONBF, 0);
	setvbuf(stdout, NULL, _IONBF, 0);
	int c;
	bool log;
	bool h;
	bool u;

	log = false;
	h = false;
	u = false;
	while ((c = getopt (argc, argv, "lph:u:")) != -1) {
		switch (c) {
		case 'l':
			sio_setloglevel(8|4|2|1);
			log = true;
			break;
		case 'p':
			pktmd = 1;
			break;
		case 'h':
			if (optarg) {
				init_socket(optarg);
				h = true;
				fprintf (stderr, "Socket has been initialized\n");
			}
			break;
		case'u':
			if (optarg) {
				sscanf(optarg, "%hx%c%hx%c%hhx", &vendor, &colon, &product, &dot, &endp);
				u = true;
			}
			break;
		case '?':
			exit(1);
		default:
			fprintf (stderr, "usage : siosend [ -l ] [ -o ] [ -p ] [ -h hostname ]\n");
			exit(-1);
		}
	}

	if (!(h || u)) {
		init_comms();
		fprintf (stderr, "COMMS has been initialized\n");
	} else if (!h) {
		fprintf(stderr, "0x%04hx%c0x%04hx%c0x%02hhx\n", vendor, colon, product, dot, endp);
		init_usb (vendor, product, endp);
	}

	// Reset ack //
	// --------- //

	struct rgtr_node *queue_in = NULL;
	if (log) {
		fprintf (stderr, ">>> SETTING ACK <<<\n");
	}
	while(sio_init(0x08));
	queue_in = delete_queue(queue_in);
	if (log) {
		fprintf (stderr, ">>> ACKNOWLEGE SET <<<\n");
	}

	// Processing data //
	// --------------- //

	if (!pktmd)
		if (log) {
			fprintf (stderr, "\tNo-packet-size mode\n");
		}

	fcntl(fileno(stdin), F_SETFL, fcntl(fileno(stdin), F_GETFL) & ~O_NONBLOCK);
#ifdef _WIN32
	_setmode(_fileno(stdin), _O_BINARY);
#endif

	totaldata = 0;
	gettimeofday(&start_time, NULL);
	for(;;) {
		int n;
		short unsigned length = MAXLEN;
		char  unsigned buffer[MAXLEN];

		if (log) {
			fprintf (stderr, ">>> READING PACKET <<<\n");
		}
		if (pktmd) {
			if ((n = fread(&length, sizeof(unsigned short), 1, stdin)) > 0) {
				if (log) {
					fprintf (stderr, "Packet length %d\n", length);
				}
				totaldata += n;
			} else if (n < 0) {
				break;
			} else {
				break;
			}
		}

		if ((n = fread(buffer, sizeof(unsigned char), length, stdin)) > 0) {
			totaldata += n;
			if (log) {
				fprintf (stderr, "Packet read length %d\n", n);
				for (int i=0; i < n; i++) {
					fprintf (stderr, "%02x", buffer[i]);
				}
				fprintf (stderr, "\n", n);
			}

			length = n;
			if (length > MAXLEN) {
				if (log) {
					fprintf (stderr, "Packet length %d greater than %d\n", length, MAXLEN);
				}
				abort();
			}

			queue_in = sio_request(buffer, length);
			sio_dump (stdout, queue_in);
			delete_queue(queue_in);
		} else  {
			if(log) fprintf(stderr, "eof %d\n", feof(stdin));
			break;
		}
	}
	gettimeofday(&end_time, NULL);
	fprintf(stderr, "Transfer time %f sec\nThroughput %f Bytes/s\n",
		(double) (end_time.tv_sec  - start_time.tv_sec) +
		(double) (end_time.tv_usec - start_time.tv_usec)  / 1.0e6,
		(double) (totaldata)/(
		(double) (end_time.tv_sec  - start_time.tv_sec) +
		(double) (end_time.tv_usec - start_time.tv_usec)  / 1.0e6));

	return 0;
}





