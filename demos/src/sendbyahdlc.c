#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <time.h>

#ifdef __MINGW32__
#include <ws2tcpip.h>
#include <wininet.h>
#include <fcntl.h>
#define	pipe(fds) _pipe(fds, 1024, O_BINARY)
#else
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <signal.h>
#include <netdb.h>
#endif

#include <math.h>
#include "ahdlc.h"

#define QUEUE   4
#define MAXSIZE (8*1024)

char ack_rcvd = 0;
long long addr_rcvd;

char rbuff[MAXSIZE];

struct rgtr {
	char unsigned id;
	char unsigned len;
	char unsigned *data;
	struct rgtr * next;
};

int next_free = -1;
int free_rgtr[256];
struct rgtr rgtrs[256];

struct rgtr *new_rgtr()
{
	struct rgtr *rgtr;

	if (next_free == -1) {
		for (int i = 0; i < 256-1; i++)
			free_rgtr[i] = i + 1;
		free_rgtr[256-1] = -1;
		next_free = 0;
	}
	rgtr = rgtrs+next_free;
	rgtr->data = NULL;
	next_free = free_rgtr[next_free];

	return rgtr;
}

struct rgtr *delete_rgtr(struct rgtr *rgtr)
{
	int e = rgtr-rgtrs; 
	free_rgtr[e] = next_free;
	next_free = e;

}

struct rgtr *sio_parse(char unsigned *data, int len)
{
	enum states { stt_id, stt_len, stt_data };
	enum states state;

	struct rgtr *rgtr;
	char unsigned *ptr;

	state = stt_id;
	ptr = data;
	while (data-ptr < len) {
		if (!rgtr) {
			rgtr = new_rgtr();
		else {
			rgtr->next = new_rgtr();
			rgtr = rgtr->next;
		}
		switch(state) {
		case stt_id:
			rgtr->id = *ptr++;
			state   = stt_len;
			break;
		case stt_len:
			rgtr->len = *ptr++;
			state    = stt_data;
			break;
		case stt_data:
			rgtr->data = ptr;
			ptr  += rgtr->len;
			rgtr->next = 0;
			state = stt_id;
			break;
		}
	}
}

#define RGTR0_ID       0x00
#define RGTRDMAADDR_ID 0x16

struct rgtr *get_rgtr (int rid)
{
	struct rgtr *rgtr;

	rgtr = rgtrs;
	while (rgtr->id != rid) {
		if (rgtrs-rgtr < next_free)
			rgtr++;
		else
			return NULL;
	}
}

void push_rgtr (struct rgtr rgtr)
{

}

struct rgtr0 {
	int dup:1;
	int ack:6;
};

struct rgtr0 *get_rgtr0(struct rgtr0 *rgtr0) {
	struct rgtr *rgtr = get_rgtr(RGTR0_ID);

	if (rgtr) {
		rgtr0->dup = (rgtr->data[0] & 0x80) ? 0 : 1;
		rgtr0->ack = (rgtr->data[0] & 0x3f);
		return rgtr0;
	}
	return NULL;
}

struct rgtr *new_rgtr0()
{
	struct rgtr *rgtr = new_rgtr();
	rgtr->id   = RGTR0_ID;
	rgtr->len  = 1;
	rgtr->data = alloc(1);

	return rgtr;
}

struct rgtr0 *set_rgtr0(struct rgtr0 *rgtr0, int ack, int dup) {
	rgtr0->dup = dup;
	rgtr0->ack = ack;
	return rgtr0;
}

struct rgtr *new_rgtr0(int ack, int dup)
{
	struct rgtr *rgtr = new_rgtr();
	struct rgtr0 rgtr0;

	set_rgtr0(&rgtr0, ack, dup);
	rgtr->id   = RGTR0_ID;
	rgtr->len  = 1;
	rgtr->data = alloc(1);

	rgtr->data[0]  = (rgtr0.dup) ? 0x80 : 0x00;
	rgtr->data[0] |= rgtr0.ack;

	return rgtr;
}

struct {
	struct rgtr *header;
	struct rgtr *tail;
} sendqueue;

void push_rgtr (struct rgtr *rgtr)
{
	if (sendqueue.sendtail)
		sendqueue.sendtail->next = rgtr0;
		sendqueue.sendtail = rgtr0;
	} else
		sendqueue.sendtail = rgtr0;
}

struct rgtr_dma {
	int dmalen_trdy:1;
	int dmaaddr_trdy:1;
	int dmaiolen_irdy:1;
	int dmaioaddr_irdy:1;
	int dmaioaddr:24;
};

void *get_rgtrdma(struct rgtr_dma *rgtr_dma) {

	struct rgtr *rgtr = get_rgtr(RGTRDMAADDR_ID);
	int data;

	if (rgtr) {
		data = 0;
		for (int i; i < rgtr->len; i++) {
			data <<= 8;
			data |= rgtr->data[i];
		}

		rgtr_dma->dmalen_trdy    = (data & 0x80000000) ? 0 : 1;
		rgtr_dma->dmaaddr_trdy   = (data & 0x40000000) ? 0 : 1;
		rgtr_dma->dmaiolen_irdy  = (data & 0x20000000) ? 0 : 1;
		rgtr_dma->dmaioaddr_irdy = (data & 0x10000000) ? 0 : 1;
		rgtr_dma->dmaioaddr      = (data & 0x00ffffff);
		return rgtr_dma;
	}

	return NULL;
}

void init_ahdlc ()
{
	setbuf(stdin, NULL);
	setbuf(stdout, NULL);
}

char sbuff[MAXSIZE];
char *sload = sbuff+5;
int  pkt_sent = 0;
int  ack      = 0x4a;

void print_pkt (void *pkt, int len)
{
	for(int i = 0; i < len; i++) {
		fprintf(stderr,"0x%02x ", ((char unsigned *) pkt)[i]);
	}
}

void send_char (char unsigned c)
{
	fwrite(&c, sizeof(char), 1, stdout);
//	fprintf(stderr,"0x%02x ", c);
}

void send_ahdlc (int psize)
{
	u16 fcs;

    fcs = ~reverse(pppfcs16(PPPINITFCS16, sbuff, psize), 16);
	memcpy(sbuff+psize+0, (char *) &fcs+1, sizeof(fcs)/2);
	memcpy(sbuff+psize+1, (char *) &fcs+0, sizeof(fcs)/2);
	psize += sizeof(fcs);
	send_char(0x7e);
	for (int i = 0; i < psize; i++) {
		if (sbuff[i] == 0x7e) {
			send_char(0x7d);
			sbuff[i] ^= 0x20;
		} else if(sbuff[i] == 0x7d) {
			send_char(0x7d);
			sbuff[i] ^= 0x20;
		}
		send_char(sbuff[i]);
	}
	send_char(0x7e);
}

void send_pkt(int psize)
{
	int len = 0;

	sbuff[len++] = 0x00;
	sbuff[len++] = 0x02;
	sbuff[len++] = 0x00;
	sbuff[len++] = 0x00;
	sbuff[len++] = (ack & 0x03f);
	len += psize;

	send_ahdlc(len);
	pkt_sent++;
}

int  pkt_lost = 0;

int rcvd_pkt()
{
	short unsigned fcs;
	fd_set rfds;
	struct timeval tv;
	int err;
	int len;

	pkt_lost++;
	for (len = 0; len < sizeof(rbuff); len++) {
		FD_ZERO(&rfds);
		FD_SET(fileno(stdout), &rfds);
		tv.tv_sec  = 0;
		tv.tv_usec = 1000;

		if ((err = select(fileno(stdout)+1, &rfds, NULL, NULL, &tv)) == -1) {
			perror ("select");
			exit (1);
		} else {
			if (err > 0) {
				if (fread(rbuff+len, sizeof(char), 1, stdout) > 0)
					if (rbuff[len] == 0x7e)
						break;
					else
						continue;
				perror("reading serial");
				exit(1);
			} else {
				fprintf(stderr, "reading time out\n");
				len--;
			}
		}
	}

	int i;
	int j;
	for (i = 0, j = 0; i < len; rbuff[j++] = rbuff[i++]) {
		if (rbuff[i] == 0x7d) {
			rbuff[++i] ^= 0x20;
		}
	}
	len += (j-i);
	fcs = pppfcs16(PPPINITFCS16, rbuff, len);
	if (fcs == PPPGOODFCS16) {
		len -= 2;
		print_pkt(rbuff, len);
		fprintf(stderr, "OK!!!!!!!! fcs 0x%04x\n", fcs);
		pkt_lost--;
		return len;
	}
	len -= 2;
	print_pkt(rbuff, len);
	fprintf(stderr, ">>> WRONG <<< fcs 0x%04x\n", fcs);

	return 0;
}

int debug;

int main (int argc, char *argv[])
{

#ifdef __MINGW32__
	WSADATA wsaData;
#endif

	int  c;
	char hostname[256] = "";

	unsigned char *bufptr;
	char pktmd;

	fd_set rfds;
	int n;
	int l;
	int ssize;
	int rlen;


#ifdef __MINGW32__
	if (WSAStartup(MAKEWORD(2,2), &wsaData))
		exit(-1);
#endif

	pktmd  = 0;
	opterr = 0;
	while ((c = getopt (argc, argv, "dph:")) != -1) {
		switch (c) {
		case 'p':
			pktmd = 1;
			break;
		case 'h':
			if (optarg)
				sscanf (optarg, "%64s", hostname);
			break;
		case '?':
			fprintf (stderr, "usage : sendbyudp -p -h hostname\n");
			exit(1);
		default:
			exit(1);
		}
	}

	init_ahdlc();

	// Reset ack //
	// --------- //

	if (debug) fprintf (stderr, ">>> SETTING ACK <<<\n");
	for(;;) {
		if (debug) fprintf (stderr, "Sending acknowlage\n");
		send_pkt(0);
		sio_parse(sbuff, sload-sbuff);

		if (debug) fprintf (stderr, "Waiting acknowlage\n");
		rlen = rcvd_pkt();
		if (debug) fprintf (stderr, "Acknowlage received\n");
		sio_parse(rbuff, rlen);

		if (((ack ^ ack_rcvd) & 0x3f) == 0 && rlen > 0)
			break;
	}
	if (debug) fprintf (stderr, ">>> ACKNOWLEGE SET <<<\n");

	if (!pktmd)
		if (debug) fprintf (stderr, "No-packet-size mode\n");

	for(;;) {
		int size = sizeof(sbuff)-(sload-sbuff);

		if (debug) fprintf (stderr, ">>> READING PACKET <<<\n");
		if (pktmd) {
			if ((fread(&size, sizeof(unsigned short), 1, stdin) > 0))
				if (debug) fprintf (stderr, "Packet size %d\n", size);
			else
				break;
		}

		if ((n = fread(sload, sizeof(unsigned char), size, stdin)) > 0) {
			if (debug) fprintf (stderr, "Packet read length %d\n", n);
			size = n;
			if (size > MAXSIZE) {
				if (debug) fprintf (stderr, "Packet size %d greater than %d\n", size, MAXSIZE);
				exit(1);
			}

			ack++;

			if (debug) fprintf (stderr, ">>> SENDING PACKET <<<\n");
			send_pkt(size);
			sio_parse(sbuff, sload-sbuff+size);  ack = ack_rcvd;
			if (debug) fprintf (stderr, ">>> CHECKING ACK <<<\n");
			for(;;) {
				if (debug) fprintf (stderr, "waiting for acknowlege\n", n); //exit(1);
				rlen = rcvd_pkt();
				if (rlen > 0) {
					if (debug) fprintf (stderr, "acknowlege received\n", n); //exit(1);
					sio_parse(rbuff, rlen); 
					if (((ack ^ ack_rcvd) & 0x3f) == 0)
						break;
					else {
						if (debug) fprintf (stderr, "acknowlege sent 0x%02x received 0x%02x\n", ack & 0xff, ack_rcvd & 0xff);
						continue;
					}
				}

				if (debug) fprintf (stderr, "waiting time out\n", n); //exit(1);
				if (debug) fprintf (stderr, "sending package again\n", n); //exit(1);
				send_pkt(size);
				sio_parse(sbuff, sload-sbuff+size);  ack = ack_rcvd;
			}

			if (debug) fprintf (stderr, "package acknowleged\n", n); //exit(1);

			if (debug) fprintf (stderr, ">>> CHECKING DMA STATUS <<<\n");
			for (;;) {
				if (!((addr_rcvd & 0xc0000000) ^ 0xc0000000)) 
					break;

				if (debug) fprintf (stderr, "dma not ready\n");
				ack++;
				if (debug) fprintf (stderr, "sending new acknowlege\n");
				send_pkt(0);
				sio_parse(sbuff, sload-sbuff);  ack = ack_rcvd;

				for (;;) {
					rlen = rcvd_pkt();
					if (rlen > 0) {
						sio_parse(rbuff, rlen); 
						if (rlen > 0)
							if (((ack ^ ack_rcvd) & 0x3f) == 0)
								break;
							else
								continue;
					}
					send_pkt(0);
					sio_parse(sbuff, sload-sbuff);  ack = ack_rcvd;
				}
			}
			if (debug) fprintf (stderr, "dma ready\n");
	//		if ((addr_rcvd & 0xfff) != ((addr_rcvd >> 12) & 0xfff))
	//			break;
		
//			for (int i = 1; i < 4; i++)
//				if ((addr_rcvd & 0xf) != ((addr_rcvd >> (4*i) & 0xf))) {
//					if (debug) fprintf(stderr,"marca -->\n");
//					break;
//				}


		} else if (n < 0) {
			perror ("reading packet");
			exit(1);
		} else
			break;

	}

	return 0;
}
