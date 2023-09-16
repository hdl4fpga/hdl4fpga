#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include "siolib.h"

static short vendor;
static short product;
static char  endp;
static char  colon;
static char  dot;

int main (int argc, char *argv[])
{

	int pktmd;
	int nooutput;
	pktmd    = 0;
	opterr   = 0;
	nooutput = 0;

	setvbuf(stderr, NULL, _IONBF, 0);
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
				// product = 0xabcd;
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

#ifdef _WIN32
	_setmode(_fileno(stdin), _O_BINARY);
#endif

	for(;;) {
		int n;
		short unsigned length = MAXLEN;
		char  unsigned buffer[MAXLEN];

		if (log) {
			fprintf (stderr, ">>> READING PACKET <<<\n");
		}
		if (pktmd) {
			if (fread(&length, sizeof(unsigned short), 1, stdin) > 0) {
				if (log) {
					fprintf (stderr, "Packet length %d\n", length);
				}
			} else break;
		}

		if ((n = fread(buffer, sizeof(unsigned char), length, stdin)) > 0) {
			if (log) {
				fprintf (stderr, "Packet read length %d\n", n);
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
		} else {
			if(log) fprintf(stderr, "eof %d\n", feof(stdin));
			break;
		}
	}

	return 0;
}
