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
#define MAXLEN (8*1024)

int loglevel;
#define LOG0 (loglevel & (1 << 0))
#define LOG1 (loglevel & (1 << 1))

char ack_rcvd = 0;
long long addr_rcvd;

struct object_pool {
	int object_free;
	int free_objects[256];
};

int new_object(struct object_pool *pool)
{
	int object;

	if (pool->object_free == -1) {
		for (int i = 0; i < 256-1; i++)
			pool->free_objects[i] = i + 1;
		pool->free_objects[256-1] = -1;
		pool->object_free = 0;
	}
	object = pool->object_free;
	pool->object_free = pool->free_objects[pool->object_free];

	return object;
}

void delete_object(struct object_pool *pool, int object)
{
	pool->free_objects[object] = pool->object_free;
	pool->object_free = object;
}

struct rgtr_hdr {
	char unsigned id;
	char unsigned len;
};

struct rgtr {
	struct rgtr_hdr hdr;
	union {
		char unsigned data[sizeof(long)];
		char unsigned *ptr;
	} payload;
};

struct rgtr_pool {
	struct object_pool pool;
	struct rgtr objects[256];
} rgtr_pool;

struct rgtr *new_rgtr()
{
	struct rgtr *rgtr;

	int object = new_object(&rgtr_pool.pool);
	rgtr = rgtr_pool.objects+object;
	rgtr->payload.ptr = NULL;

	return rgtr;
}

void delete_rgtr(struct rgtr *rgtr)
{
	delete_object(&rgtr_pool.pool, rgtr-rgtr_pool.objects);
}

struct rgtr_node {
	struct rgtr *rgtr;
	struct rgtr_node *next;
};

struct rgtrnode_pool {
	struct object_pool pool;
	struct rgtr_node objects[256];
} node_pool;

struct rgtr_node *new_rgtrnode()

{
	struct rgtr_node *node;

	int object = new_object(&node_pool.pool);
	node = node_pool.objects+object;
	node->rgtr = new_rgtr();
	node->rgtr->payload.ptr = NULL;

	return node;
}

void delete_rgtrnode(struct rgtr_node *node)
{
	delete_object(&rgtr_pool.pool, node->rgtr-rgtr_pool.objects);
	delete_object(&node_pool.pool, node-node_pool.objects);
}

void delete_queue(struct rgtr_node *node)
{
	while (!node) {
		struct rgtr_node *next;
		next = node->next;
		delete_rgtrnode(node);
		node = next;
	}
}

struct rgtr_node *get_rgtrnode(int id, struct rgtr_node *node)
{
	while(!node) {
		if(node->rgtr->hdr.id == id)
			break;
		node = node->next;
	}
	return node;

}

char unsigned *rgtr2raw(char unsigned *data, int * len, struct rgtr_node *node)
{
	char unsigned *ptr;

	*len = 0;
	ptr = data;
	while(!node) {
		*ptr++ = node->rgtr->hdr.id;
		*ptr++ = node->rgtr->hdr.len;
		memcpy(ptr, node->rgtr->payload.data, node->rgtr->hdr.len+1);
		ptr  += (node->rgtr->hdr.len+1);
		*len += ((node->rgtr->hdr.len+1) + 2);
		node  = node->next;
	}
	return data;
}

struct rgtr_node *sio_parse(char unsigned *data, int len)
{
	enum states { stt_id, stt_len, stt_data };
	enum states state;

	struct rgtr_node *node;
	char unsigned *ptr;

	node = NULL;
	ptr = data;
	state = stt_id;
	while (ptr-data < len) {
		if (!node) {
			node = new_rgtrnode();
		} else {
			node->next = new_rgtrnode();
			node = node->next;
		}
		switch(state) {
		case stt_id:
			node->rgtr->hdr.id = *ptr++;
			state   = stt_len;
			break;
		case stt_len:
			node->rgtr->hdr.len = *ptr++;
			state    = stt_data;
			break;
		case stt_data:
			node->rgtr->payload.ptr = ptr;
			ptr  += node->rgtr->hdr.len;
			node->next = 0;
			state = stt_id;
			break;
		}
	}
}

#define RGTR0_ID       0x00
#define RGTRACK_ID     0x00
#define RGTRDMAADDR_ID 0x16


struct rgtr_node *new_acknode()
{
	struct rgtr_node *node = new_rgtrnode();
	node->rgtr->hdr.id   = RGTR0_ID;
	node->rgtr->hdr.len  = 1;
	node->rgtr->payload.ptr = NULL;

	return node;
}

void delete_acknode(struct rgtr_node *node)
{
	delete_object(&node_pool.pool, node-node_pool.objects);
}

struct rgtr_node *set_rgtr0node(struct rgtr_node *node, char unsigned *data, int len) {
	node->rgtr->hdr.id  = RGTR0_ID;
	node->rgtr->hdr.len = len-1;
	node->rgtr->payload.ptr  = data;
	return node;
}

struct rgtr_node *set_acknode(struct rgtr_node *node, int ack, int dup) {
	node->rgtr->payload.data[0]  = (dup) ? 0x80 : 0x00;
	node->rgtr->payload.data[0] |= (0x3f & ack);
	return node;
}

int get_rgtrdma(struct rgtr_node *node)
{
	int status;

	status = 0;
	if (node)
		for (int i; i < node->rgtr->hdr.len; i++) {
			status <<= 8;
			status |= node->rgtr->payload.ptr[i];
		}

	return status;
}

struct {
	struct rgtr_node *header;
	struct rgtr_node *tail;
} sendqueue;

void push_rgtr (struct rgtr_node *node)
{
	if (sendqueue.tail) {
		sendqueue.tail->next = node;
		sendqueue.tail = node;
	} else {
		sendqueue.header = node;
		sendqueue.tail   = node;
	}
}

void init_ahdlc ()
{
	setbuf(stdin, NULL);
	setbuf(stdout, NULL);
}

int  pkt_sent = 0;
int  ack      = 0x4a;

void ahdlc_send(char * data, int len)
{
	u16 fcs;

    fcs = ~reverse(pppfcs16(PPPINITFCS16, data, len), 16);
	memcpy(data+len+0, (char *) &fcs+1, sizeof(fcs)/2);
	memcpy(data+len+1, (char *) &fcs+0, sizeof(fcs)/2);
	len += sizeof(fcs);
	putchar(0x7e);
	for (int i = 0; i < len; i++) {
		if (data[i] == 0x7e) {
			putchar(0x7d);
			data[i] ^= 0x20;
		} else if(data[i] == 0x7d) {
			putchar(0x7d);
			data[i] ^= 0x20;
		}
		putchar(data[i]);
	}
	putchar(0x7e);
}

void ahdlc_sendrgtrrawdata(struct rgtr_node *node, char unsigned *data, int len)
{
	char unsigned buffer[MAXLEN];
	int len1 = sizeof(buffer);

	rgtr2raw(buffer, &len1, node);
	memcpy(buffer+len1, data, len);
	ahdlc_send(buffer, len);
}

void ahdlc_sendrgtr(struct rgtr_node *node)
{
	char unsigned buffer[MAXLEN];
	int len = sizeof(buffer);

	rgtr2raw(buffer, &len, node);
	ahdlc_send(buffer, len);
}

void send_rgtr(struct rgtr_node *node)
{
	ahdlc_sendrgtr(node);
}

void send_rgtrrawdata(struct rgtr_node *node, char unsigned *data, int len)
{
	ahdlc_sendrgtrrawdata(node, data, len);
}

int  pkt_lost = 0;

void print_pkt (void *pkt, int len)
{
	for(int i = 0; i < len; i++) {
		fprintf(stderr,"0x%02x ", ((char unsigned *) pkt)[i]);
	}
}

int ahdlc_rcvd(char unsigned *buffer, int maxlen)
{
	int len;

	short unsigned fcs;
	fd_set rfds;
	struct timeval tv;
	int err;

	pkt_lost++;
	len = 0;
	for (int i = 0; i < maxlen; i++) {
		FD_ZERO(&rfds);
		FD_SET(fileno(stdout), &rfds);
		tv.tv_sec  = 0;
		tv.tv_usec = 1000;

		if ((err = select(fileno(stdout)+1, &rfds, NULL, NULL, &tv)) == -1) {
			perror ("select");
			exit (1);
		} else {
			if (err > 0) {
				char c;

				if ((c = fgetc(stdout)) > 0)
					buffer[i] = c;
					if (c == 0x7e) {
						len = i;
						break;
					} else
						continue;

				perror("reading serial");
				abort();
			} else {
				if (LOG1) fprintf(stderr, "reading time out\n");
				i--;
			}
		}
	}
	if (!len) {
		if (LOG0) fprintf(stderr, "Error receiving\n");
		return -1;
	}

	int i, j;
	for (i = 0, j = 0; i < len; i++, j++) {
		if (buffer[i] == 0x7d)
			buffer[++i] ^= 0x20;
		buffer[j] = buffer[i];
	}
	len += (j-i);

	print_pkt(buffer, len);
	fcs = pppfcs16(PPPINITFCS16, buffer, len);
	if (fcs == PPPGOODFCS16) {
		len -= 2;
		if (LOG0) fprintf(stderr, "FCS OK! ");
		if (LOG1) fprintf(stderr, "fcs 0x%04x", fcs);
		if (LOG0 | LOG1) fputc('\n', stderr); 
		pkt_lost--;
		return len;
	}
	len -= 2;

	if (LOG0) fprintf(stderr, "FCS WRONG! ");
	if (LOG1) fprintf(stderr, "fcs 0x%04x", fcs);
	if (LOG0 | LOG1) fputc('\n', stderr); 

	return -1;
}

struct rgtr_node *rcvd_rgtr()
{
	int len;

	static char unsigned buffer[MAXLEN];
	if ((len = ahdlc_rcvd(buffer, sizeof(buffer)) < 0))
		return NULL;
	return sio_parse(buffer, len);
}

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

	struct rgtr_node *ack_node = new_acknode();
	char unsigned ack_buffer[4];
	int ack_len = sizeof(ack_buffer);

	struct rgtr_node *queue;
	struct rgtr_node *rgtr0;

	// Reset ack //
	// --------- //

	if (LOG0) fprintf (stderr, ">>> SETTING ACK <<<\n");
	for(;;) {


		if (LOG1) fprintf (stderr, "Sending ACK\n");
		rgtr2raw(ack_buffer, &ack_len, set_acknode(ack_node, ack, 0x0));
		send_rgtr(set_rgtr0node(ack_node, ack_buffer, ack_len));

		if (LOG1) fprintf (stderr, "Waiting ACK\n");
		queue = rcvd_rgtr();
		if (!queue) {
			if (LOG1) fprintf (stderr, "packet error\n");
			continue;
		}

		if (LOG1) fprintf (stderr, "ACK received\n");
		rgtr0 = get_rgtrnode(RGTR0_ID, queue);
		rgtr0 = sio_parse(rgtr0->rgtr->payload.ptr, rgtr0->rgtr->hdr.len);

		if (!rgtr0) {
			if (LOG1) fprintf (stderr, "ACK error\n");
			continue;
		}

		if (((ack ^ get_rgtrnode(RGTRACK_ID, rgtr0)->rgtr->payload.ptr[0]) & 0x3f) == 0) {
			if (LOG1) fprintf (stderr, "ACK misnatch 0x%02, 0x%02\n",
				ack, get_rgtrnode(RGTRACK_ID, rgtr0)->rgtr->payload.ptr[0]);
			break;
		}

	}

	delete_queue(queue);
	delete_queue(rgtr0);
	if (LOG0) fprintf (stderr, ">>> ACKNOWLEGE SET <<<\n");

	// Processing data //
	// --------------- //

	if (!pktmd)
		if (LOG1) fprintf (stderr, "No-packet-size mode\n");

	for(;;) {
		short unsigned size;
		char  unsigned buffer[MAXLEN];

		if (LOG0) fprintf (stderr, ">>> READING PACKET <<<\n");
		if (pktmd) {
			if ((fread(&size, sizeof(unsigned short), 1, stdin) > 0))
				if (LOG1) fprintf (stderr, "Packet size %d\n", size);
			else
				break;
		}

		if ((n = fread(buffer, sizeof(unsigned char), size, stdin)) > 0) {
			if (LOG1) fprintf (stderr, "Packet read length %d\n", n);
			size = n;
			if (size > MAXLEN) {
				if (LOG1) fprintf (stderr, "Packet size %d greater than %d\n", size, MAXLEN);
				exit(1);
			}

			ack++;

			if (LOG0) fprintf (stderr, ">>> SENDING PACKET <<<\n");
			
			rgtr2raw(buffer, &ack_len, set_acknode(ack_node, ack, 0x0));
			send_rgtrrawdata(set_rgtr0node(ack_node, ack_buffer, ack_len), buffer, size);

			if (LOG0) fprintf (stderr, ">>> CHECKING ACK <<<\n");
			for(;;) {
				if (LOG1) fprintf (stderr, "waiting for acknowlege\n", n);
				queue = rcvd_rgtr();
				if (queue) {
					if (LOG1) fprintf (stderr, "acknowlege received\n", n);

					rgtr0 = get_rgtrnode(RGTR0_ID, queue);
					rgtr0 = sio_parse(rgtr0->rgtr->payload.ptr, rgtr0->rgtr->hdr.len);
					if (!rgtr0) {
						if (LOG1) fprintf (stderr, "ACK missed\n");
						continue;
					}

					if (((ack ^ get_rgtrnode(RGTRACK_ID, rgtr0)->rgtr->payload.ptr[0]) & 0x3f) == 0)
						break;
					else {
						if (LOG1) fprintf (stderr, "acknowlege sent 0x%02x received 0x%02x\n", ack & 0xff, ack_rcvd & 0xff);
						continue;
					}

				}

				if (LOG1) fprintf (stderr, "waiting time out\n", n);
				if (LOG1) fprintf (stderr, "sending package again\n", n);

				rgtr2raw(buffer, &ack_len, set_acknode(ack_node, ack, 0x0));
				send_rgtrrawdata(set_rgtr0node(ack_node, ack_buffer, ack_len), buffer, size);


			}

			if (LOG1) fprintf (stderr, "package acknowleged\n", n); //exit(1);

			if (LOG0) fprintf (stderr, ">>> CHECKING DMA STATUS <<<\n");
			for (;;) {
				get_rgtrnode(RGTRDMAADDR_ID, queue)->rgtr->payload.ptr[0];
				if (!((addr_rcvd & 0xc0000000) ^ 0xc0000000)) 
					break;

				delete_queue(queue);
				if (LOG1) fprintf (stderr, "dma not ready\n");
				if (LOG1) fprintf (stderr, "sending new acknowlege\n");
				rgtr2raw(ack_buffer, &ack_len, set_acknode(ack_node, ++ack, 0x0));
				send_rgtr(set_rgtr0node(ack_node, ack_buffer, ack_len));

				for (;;) {

					queue = rcvd_rgtr();
					rgtr0 = get_rgtrnode(RGTR0_ID, queue);
					rgtr0 = sio_parse(rgtr0->rgtr->payload.ptr, rgtr0->rgtr->hdr.len);

					if (queue && rgtr0 && ((ack ^ get_rgtrnode(RGTRACK_ID, rgtr0)->rgtr->payload.ptr[0]) & 0x3f) == 0)
						break;
					else
						continue;

					delete_queue(queue);
					delete_queue(rgtr0);
					rgtr2raw(ack_buffer, &ack_len, set_acknode(ack_node, ack, 0x0));
					send_rgtr(set_rgtr0node(ack_node, ack_buffer, ack_len));
				}
			}
			if (LOG1) fprintf (stderr, "dma ready\n");

		} else if (n < 0) {
			perror ("reading packet");
			exit(1);
		} else
			break;

	}

	return 0;
}
