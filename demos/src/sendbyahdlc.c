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

struct object_pool {
	int object_free;
	int free_objects[256];
};

struct object_pool *init_pool (struct object_pool *pool)
{

	pool->object_free = 0;
	for (int i = 0; i < 256-1; i++) {
		pool->free_objects[i] = i+1;
	}
	pool->free_objects[255] = -1;

	return pool;
}

int new_object(struct object_pool *pool)
{
	int object;

	if (pool->object_free == -1)
		init_pool(pool);
	object = pool->object_free;
	pool->object_free = pool->free_objects[pool->object_free];

	return object;
}

void delete_object(struct object_pool *pool, int object)
{
	pool->free_objects[object] = pool->object_free;
	pool->object_free = object;
}

struct rgtr {
	char unsigned id;
	char unsigned len;
	char unsigned data[1];
};

struct rgtr_node {
	struct rgtr *rgtr;
	struct rgtr_node *next;
};

struct rgtrnode_pool {
	struct object_pool pool;
	struct rgtr_node objects[256];
} node_pool = { { -1, } , };

struct rgtr_node *new_rgtrnode()
{
	struct rgtr_node *node;

	int object = new_object(&node_pool.pool);
	if (LOG1) fprintf (stderr, "new object %d\n", object);
	node = node_pool.objects+object;
	node->rgtr = NULL;
	node->next = NULL;

	return node;
}

struct rgtr_node *delete_rgtrnode(struct rgtr_node *node)
{
	if (node) {
		if (LOG1) fprintf (stderr, "free object %ld\n", node-node_pool.objects);
		delete_object(&node_pool.pool, node-node_pool.objects);
		node->rgtr = NULL;
		node->next = NULL;
	}
	return NULL;
}

struct rgtr_node * delete_queue(struct rgtr_node *node)
{
	while (node) {
		struct rgtr_node *next;
		next = node->next;
		delete_rgtrnode(node);
		node = next;
	}
	return NULL;
}

struct rgtr_node *lookup(int id, struct rgtr_node *node)
{
	while(node) {
		if(node->rgtr->id == id) break;
		node = node->next;
	}
	if (node->rgtr->id != id) return NULL;
	return node;
}

struct rgtr_node *set_rgtrnode(struct rgtr_node *node, int id, char unsigned *buffer, int len)
{
	node->rgtr = (struct rgtr *) buffer;
	node->rgtr->id  = id;
	node->rgtr->len = len-3;
	if (LOG1) {
		fprintf (stderr, "set_rgtrnode\n");
		fprintf (stderr, "\t id   : 0x%02x\n", node->rgtr->id);
		fprintf (stderr, "\t len  : 0x%02x\n", node->rgtr->len);
		fprintf (stderr, "\t data : ");
		for (int i = 0; i < (node->rgtr->len+1); i++) 
			fprintf (stderr, "0x%02x ", node->rgtr->data[i]);
		fputc('\n', stderr);
	}

	return node;
}

struct rgtr_node *nest_rgtrnode (struct rgtr_node *node, char unsigned id, char unsigned len)
{
	return set_rgtrnode(new_rgtrnode(), id, node->rgtr->data, len+2);
}

char unsigned *rgtr2raw(char unsigned *data, int * len, struct rgtr_node *node)
{
	char unsigned *ptr;

	*len = 0;
	ptr = data;
	if (LOG1) fprintf (stderr, "rgtr2raw\n");
	while(node) {
		if (LOG1) {
			fprintf (stderr, "\t id   : 0x%02x\n", node->rgtr->id);
			fprintf (stderr, "\t len  : 0x%02x\n", node->rgtr->len);
			fprintf (stderr, "\t data : ");
			for (int i = 0; i < (node->rgtr->len+1); i++) 
				fprintf (stderr, "0x%02x ", node->rgtr->data[i]);
			fputc('\n', stderr);
		}

		*ptr++ = node->rgtr->id;
		*ptr++ = node->rgtr->len;
		memcpy(ptr, node->rgtr->data, node->rgtr->len+1);
		ptr  += (node->rgtr->len+1);
		*len += ((node->rgtr->len+1) + 2);
		node  = node->next;
	}
	return data;
}

struct rgtr_node *rawdata2rgtr(char unsigned *data, int len)
{
	struct rgtr_node *head;
	struct rgtr_node *node;
	char unsigned *ptr;

	head = NULL;
	ptr = data;
	while (ptr-data < len) {
		if (!head) {
			head = new_rgtrnode();
			node = head;
		} else {
			node->next = new_rgtrnode();
			node = node->next;
		}
		node->rgtr = (struct rgtr *) ptr;
		node->next = 0;
		ptr  += node->rgtr->len + 3;

	}
	return head;
}

struct rgtr_node *childrgtrs(struct rgtr *rgtr)
{
	if (!rgtr) return NULL;
	return rawdata2rgtr(rgtr->data, rgtr->len+1);
}

int unsigned rgtr2int (struct rgtr_node *node)
{
	int unsigned data;

	data = 0;
	for (int i = 0; i < node->rgtr->len+1; i++) {
		data <<= 8;
		data |= node->rgtr->data[i];
	}
	return data;
}

#define print_rgtr(x)  fprint_rgtr(stderr, x)
#define print_rgtrs(x) fprint_rgtrs(stderr, x)

void fprint_rgtr (FILE *file, struct rgtr_node *node)
{
	fprintf (file, "id   : 0x%02x\n", node->rgtr->id);
	fprintf (file, "len  : 0x%02x\n", node->rgtr->len);
	fprintf (file, "data : ");
	for (int i = 0; i < (node->rgtr->len+1); i++) fprintf (file, "0x%02x ", node->rgtr->data[i]);
	fputc('\n', file);
}

void fprint_rgtrs (FILE *file, struct rgtr_node *node)
{
	while(node) {
		fprint_rgtr(file, node);
		node = node->next;
	}
}

#define RGTR0_ID       0x00
#define RGTRACK_ID     0x00
#define RGTRDMAADDR_ID 0x16

struct rgtr_node *set_acknode(struct rgtr_node *node, int ack, int dup) {
	node->rgtr->data[0]  = (dup) ? 0x80 : 0x00;
	node->rgtr->data[0] |= (0x3f & ack);
	return node;
}

void init_ahdlc ()
{
	stdin = fdopen(STDIN_FILENO, "w+");
	setbuf(stdin,  NULL);
	setbuf(stdout, NULL);
	setbuf(stderr, NULL);
}

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
	ahdlc_send(buffer, len1+len);
}

void ahdlc_sendrgtr(struct rgtr_node *node)
{
	char unsigned buffer[MAXLEN];
	int len = sizeof(buffer);

	rgtr2raw(buffer, &len, node);
	if (LOG1) {
		for (int i = 0; i < len; i++) fprintf (stderr, "0x%02x ", buffer[i]);
		fputc('\n', stderr);
	}
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

int ahdlc_rcvd(char unsigned *buffer, int maxlen)
{
	int len;

	short unsigned fcs;
	struct timeval tv;
	int err;

	pkt_lost++;
	len = 0;
	for (int i = 0; i < maxlen; i++) {
		fd_set rfds;

		FD_ZERO(&rfds);
		FD_SET(fileno(stdout), &rfds);
		tv.tv_sec  = 0;
		tv.tv_usec = 1000;

		if ((err = select(fileno(stdout)+1, &rfds, NULL, NULL, &tv)) == -1) {
			perror ("select");
			abort();
		} else {
			if (err > 0 && FD_ISSET(fileno(stdout), &rfds)) {
				if (fread (buffer+i, sizeof(char), 1, stdout) > 0) {
					if (buffer[i] == 0x7e) {
						len = i;
						break;
					} else continue;
				}

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
	if ((len = ahdlc_rcvd(buffer, sizeof(buffer))) < 0)
		return NULL;
	return rawdata2rgtr(buffer, len);
}

int main (int argc, char *argv[])
{

	char hostname[256];
	int pktmd;
	int c;
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

	char unsigned rgtr0_buffer[5];
	struct rgtr_node *rgtr0_out = set_rgtrnode(new_rgtrnode(), RGTR0_ID,   rgtr0_buffer,   sizeof(rgtr0_buffer));
	struct rgtr_node *ack_out   = nest_rgtrnode(rgtr0_out, RGTRACK_ID, 1);

	struct rgtr_node *queue_in = NULL;
	struct rgtr_node *rgtr0_in = NULL;

	// Reset ack //
	// --------- //

	if (LOG0) fprintf (stderr, ">>> SETTING ACK <<<\n");

	int ack = 0x0a;
	for(;;) {

	
		queue_in = delete_queue(queue_in);
		rgtr0_in = delete_queue(rgtr0_in);

		if (LOG1) fprintf (stderr, "Sending ACK\n");

		set_acknode(ack_out, ack, 0x0);
		send_rgtr(rgtr0_out);

		if (LOG1) fprintf (stderr, "Waiting ACK\n");
		queue_in = rcvd_rgtr();
		if (!queue_in) {
			if (LOG1) fprintf (stderr, "packet error\n");
			continue;
		}

		if (LOG1) print_rgtrs(queue_in);
		if (LOG1) fprintf (stderr, "ACK received\n");
		rgtr0_in = lookup(RGTR0_ID, queue_in);
		rgtr0_in = childrgtrs(rgtr0_in->rgtr);

		if (!rgtr0_in) {
			if (LOG1) fprintf (stderr, "ACK error\n");
			continue;
		}

		if (((ack ^ rgtr2int(lookup(RGTRACK_ID, rgtr0_in))) & 0x3f) == 0) {
			break;
		} else if (LOG1) fprintf (stderr, "ACK mismatch 0x%02x, 0x%02x\n",
			ack, lookup(RGTRACK_ID, rgtr0_in)->rgtr->data[0]);

	}

	queue_in = delete_queue(queue_in);
	rgtr0_in = delete_queue(rgtr0_in);
	if (LOG0) fprintf (stderr, ">>> ACKNOWLEGE SET <<<\n");

	// Processing data //
	// --------------- //

	if (!pktmd)
		if (LOG1) fprintf (stderr, "No-packet-size mode\n");

	for(;;) {
		int n;
		short unsigned size = MAXLEN;
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
				abort();
			}

			ack++;

			if (LOG0) fprintf (stderr, ">>> SENDING PACKET <<<\n");
			
			set_acknode(ack_out, ack, 0x0);
			send_rgtrrawdata(rgtr0_out, buffer, size);

			if (LOG0) fprintf (stderr, ">>> CHECKING ACK <<<\n");
			for(;;) {
				if (LOG1) fprintf (stderr, "waiting for acknowlege\n", n);
				queue_in = rcvd_rgtr();
				if (LOG1) print_rgtrs(queue_in);
				if (queue_in) {
					if (LOG1) fprintf (stderr, "acknowlege received\n", n);

					rgtr0_in = lookup(RGTR0_ID, queue_in);
					rgtr0_in = childrgtrs(rgtr0_in->rgtr);
					if (!rgtr0_in) {
						if (LOG1) fprintf (stderr, "ACK missed\n");
						continue;
					}

					if (((ack ^ rgtr2int(lookup(RGTRACK_ID, rgtr0_in))) & 0x3f) == 0) break;
					else {
						if (LOG1) fprintf (stderr, "acknowlege sent 0x%02x received 0x%02x\n", 
							(char unsigned) ack, 
							(char unsigned) rgtr2int(lookup(RGTRACK_ID, rgtr0_in)));
						continue;
					}

				}

				if (LOG1) fprintf (stderr, "waiting time out\n", n);
				if (LOG1) fprintf (stderr, "sending package again\n", n);

				set_acknode(ack_out, ack, 0x0);
				send_rgtrrawdata(rgtr0_out, buffer, size);
			}

			if (LOG1) fprintf (stderr, "package acknowleged\n", n);

			if (LOG0) fprintf (stderr, ">>> CHECKING DMA STATUS <<<\n");
			for (;;) {
				
				if (LOG1) print_rgtrs(queue_in);
				
				if (!((rgtr2int(lookup(RGTRDMAADDR_ID, queue_in)) & 0xc0000000) ^ 0xc0000000)) break;

				queue_in = delete_queue(queue_in);
				rgtr0_in = delete_queue(rgtr0_in);
				if (LOG1) fprintf (stderr, "dma not ready\n");
				if (LOG1) fprintf (stderr, "sending new acknowlege\n");
				set_acknode(ack_out, ++ack, 0x0);
				send_rgtr(rgtr0_out);

				for (;;) {
					queue_in = rcvd_rgtr();
					if (queue_in) {
						rgtr0_in = lookup(RGTR0_ID, queue_in);
						if (rgtr0_in) {
							rgtr0_in = childrgtrs(rgtr0_in->rgtr);
							if (rgtr0_in) {
								if (((ack ^ rgtr2int(lookup(RGTRACK_ID, rgtr0_in))) & 0x3f) == 0)
									break;
								else
									continue;
							}
						}
					}
					set_acknode(ack_out, ack, 0x0);
					send_rgtr(rgtr0_out);
				}
			}
			if (LOG1) fprintf (stderr, "dma ready\n");

		} else if (n < 0) {
			perror ("reading packet");
			exit(1);
		} else break;

	}
	print_rgtr(lookup(0xff, queue_in));
	return 0;
}
