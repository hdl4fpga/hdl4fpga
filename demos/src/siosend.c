#include <stdlib.h>
#include <stdio.h>
#include "siolib.h"

int main (int argc, char *argv[])
{

	int pktmd;
	int nooutput;
	pktmd    = 0;
	loglevel = 0;
	opterr   = 0;
	nooutput = 0;

	setvbuf(stderr, NULL, _IONBF, 0);

	int c;
	while ((c = getopt (argc, argv, "loph:")) != -1) {
		switch (c) {
		case 'l':
			loglevel = 8|4|2|1;
			break;
		case 'o':
			nooutput = 1;
			break;
		case 'p':
			pktmd = 1;
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

	if (nooutput) {
		fout = NULL;
	}

	// Reset ack //
	// --------- //

	struct rgtr_node *queue_in = NULL;
	if (LOG0) {
		fprintf (stderr, ">>> SETTING ACK <<<\n");
	}
	while(sio_init(0x08));
	queue_in = delete_queue(queue_in);
	if (LOG0) {
		fprintf (stderr, ">>> ACKNOWLEGE SET <<<\n");
	}

	// Processing data //
	// --------------- //

	if (!pktmd)
		if (LOG1) {
			fprintf (stderr, "\tNo-packet-size mode\n");
		}

	for(;;) {
		int n;
		short unsigned length = MAXLEN;
		char  unsigned buffer[MAXLEN];

		if (LOG0) {
			fprintf (stderr, ">>> READING PACKET <<<\n");
		}
		if (pktmd) {
			if (fread(&length, sizeof(unsigned short), 1, stdin) > 0) {
				if (LOG1) {
					fprintf (stderr, "Packet length %d\n", length);
				}
			} else break;
		}

		if ((n = fread(buffer, sizeof(unsigned char), length, stdin)) > 0) {
			if (LOG1) {
				fprintf (stderr, "Packet read length %d\n", n);
			}

			length = n;
			if (length > MAXLEN) {
				if (LOG1) {
					fprintf (stderr, "Packet length %d greater than %d\n", length, MAXLEN);
				}
				abort();
			}

			queue_in = sio_request(buffer, length);
			sio_dump (queue_in);
		} else {
			if(LOG0) fprintf(stderr, "eof %d\n", feof(stdin));
			break;
		}

	}

	return 0;
}
