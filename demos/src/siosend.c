#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <errno.h>

#ifdef _WIN32
#include <ws2tcpip.h>
#include <wininet.h>
#include <fcntl.h>
#define	pipe(fds) _pipe(fds, 1024, O_BINARY)

WSADATA wsaData;
#else
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <signal.h>
#include <netdb.h>
#endif

#include <math.h>
#include "hdlc.h"

#define PORT	57001
#define QUEUE   4
#define MAXLEN (8*1024)

int pkt_sent = 0;
int pkt_lost = 0;

FILE *comm;
FILE *fout;

char hostname[256] = "";
int sckt;

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
	pool->free_objects[255] = -2;

	return pool;
}

int new_object(struct object_pool *pool)
{
	int object;

	if (pool->object_free == -1) {
		init_pool(pool);
	}
	if (pool->object_free == -2) {
		abort();
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
	if (!node) {
		if (LOG0) fprintf(stderr, "lookup of RID 0x%02x not found\n", id);
		return NULL;
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

	if (!node) {
		abort();
	}
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
#define RGTRACK_ID     0x01
#define RGTRDMAADDR_ID 0x16

struct rgtr_node *set_acknode(struct rgtr_node *node, int ack, int dup) {
	node->rgtr->data[0]  = (dup) ? 0x80 : 0x00;
	node->rgtr->data[0] |= (0x3f & ack);
	return node;
}

struct sockaddr_in sa_trgt;
socklen_t sl_trgt = sizeof(sa_trgt);

void socket_send(char * data, int len)
{
	if (sendto(sckt, data, len, 0, (struct sockaddr *) &sa_trgt, sl_trgt) == -1) {
		perror ("sending packet");
		abort();
	}
	pkt_sent++;
}

void hdlc_send(char * data, int len)
{
	u16 fcs;

    fcs = ~pppfcs16(PPPINITFCS16, data, len);
	fputc(0x7e, comm);
	for (int i = 0; i < len+sizeof(fcs); i++) {
		char c;

		if (i < len) {
			c = data[i];
		} else {
			c = ((char *) &fcs)[i-len];
		}

		if (c == 0x7e) {
			fputc(0x7d, comm);
			c ^= 0x20;
		} else if(c == 0x7d) {
			fputc(0x7d, comm);
			c ^= 0x20;
		}
		fputc(c, comm);
	}
	fputc(0x7e, comm);
	pkt_sent++;
}

void send_buffer(char * data, int len)
{
	if (strlen(hostname)) {
		socket_send(data,len);
	} else {
		hdlc_send(data, len);
	}
}

void send_rgtr(struct rgtr_node *node)
{
	char unsigned buffer[MAXLEN];
	int len = sizeof(buffer);

	rgtr2raw(buffer, &len, node);
	if (LOG1) {
		for (int i = 0; i < len; i++) fprintf (stderr, "0x%02x ", buffer[i]);
		fputc('\n', stderr);
	}

	send_buffer(buffer, len);
}

void send_rgtrrawdata(struct rgtr_node *node, char unsigned *data, int len)
{
	char unsigned buffer[MAXLEN];
	int len1 = sizeof(buffer);

	rgtr2raw(buffer, &len1, node);
	if (len+len1 > MAXLEN) {
		abort();
	}

	memcpy(buffer+len1, data, len);

	send_buffer(buffer, len+len1);
}


int socket_rcvd(char unsigned *buffer, int maxlen)
{
	static struct sockaddr_in sa_src;
	static socklen_t sl_src  = sizeof(sa_src);

	int len;
	int err;
	int retry;

	pkt_lost++;
	len = 0;
	retry = 0;
	{
		fd_set rfds;
		struct timeval tv;

		FD_ZERO(&rfds);
		FD_SET(sckt, &rfds);
		tv.tv_sec  = 0;
		tv.tv_usec = 1000;

		if ((err = select(sckt+1, &rfds, NULL, NULL, &tv)) == -1) {
			perror ("select");
			abort();
		} else {
			if (err > 0 && FD_ISSET(sckt, &rfds)) {
				if ((len = recvfrom(sckt, buffer, maxlen, 0, (struct sockaddr *) &sa_src, &sl_src)) < 0) {
					perror ("recvfrom");
					abort();
				}
				pkt_lost--;
				return len;
			} else {
				if (retry++ > 64) {
					return -1;
				}
				if (LOG1) {
					fprintf(stderr, "reading time out %d\n", retry);
				}
			}
		}
	}

	return -1;
}

int hdlc_rcvd(char unsigned *buffer, int maxlen)
{
	int len;
	int err;
	int retry;

	short unsigned fcs;
	struct timeval tv;

	if (LOG0) {
		fprintf(stderr, "HDLC reading\n");
	}

	pkt_lost++;
	len   = 0;
	retry = 0;
	for (int i = 0; i < maxlen; i++) {
		fd_set rfds;

		FD_ZERO(&rfds);
		FD_SET(fileno(comm), &rfds);
		tv.tv_sec  = 0;
		tv.tv_usec = 1000;

		if ((err = select(fileno(comm)+1, &rfds, NULL, NULL, &tv)) == -1) {
			perror ("select");
			abort();
		} else {
			if (err > 0 && FD_ISSET(fileno(comm), &rfds)) {
				if (fread (buffer+i, sizeof(char), 1, comm) > 0) {
					if (buffer[i] == 0x7e) {
						len = i;
						break;
					} else continue;
				}

				perror("reading serial");
				abort();
			} else {
				if (retry++ > 64) {
					return -1;
				}
				if (LOG1) {
					fprintf(stderr, "reading time out %d\n", retry);
				}
				i--;
			}
		}
	}
	if (!len) {
		if (LOG0) {
			fprintf(stderr, "Error receiving\n");
		}
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
	if (LOG0) {
		struct rgtr_node *print_queue;
		print_queue = rawdata2rgtr(buffer,len);
		print_rgtrs(print_queue);
		delete_queue(print_queue);
	}

	return -1;
}

struct rgtr_node *rcvd_rgtr()
{
	int len;
	struct rgtr_node *node;

	static char unsigned buffer[MAXLEN];
	if (strlen(hostname)) {
		if ((len = socket_rcvd(buffer, sizeof(buffer))) < 0) {
			return NULL;
		}
	} else {
		if ((len = hdlc_rcvd(buffer, sizeof(buffer))) < 0) {
			return NULL;
		}
	}
	node = rawdata2rgtr(buffer, len);
//	if (LOG2) print_rgtrs(node);

	return node;
}

void init_socket ()
{

	static struct hostent *host = NULL;
	static struct sockaddr_in sa_host;

#ifdef _WIN32
	if (WSAStartup(MAKEWORD(2,2), &wsaData)) {
		abort();
	}
#endif

	if (!(host=gethostbyname(hostname))) {
		fprintf (stderr, "Hostname '%s' not found\n", hostname);
		exit(1);
	}
	
	memset (&sa_trgt, 0, sizeof (sa_trgt));
	sa_trgt.sin_family = AF_INET;
	sa_trgt.sin_port   = htons(PORT);
	memcpy (&sa_trgt.sin_addr, host->h_addr, sizeof(sa_trgt.sin_addr));

	memset (&sa_host, 0, sizeof (sa_host));
	sa_host.sin_family = AF_INET;
	sa_host.sin_port   = htons(PORT);	
	sa_host.sin_addr.s_addr = htonl(INADDR_ANY);
	if ((sckt = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
		perror ("Can't open socket");
		abort();
	}

	if (bind(sckt, (const struct sockaddr *) &sa_host, sizeof(sa_host)) < 0) {
		perror ("can't bind socket");
		abort();
	}

	//	DON'T FRAGMENT, 
	// int tol = 2;	// Time To Live
	// setsockopt(sckt, IPPROTO_IP, IP_PMTUDISC_DO, &tol, sizeof(tol));

}

void init_comms ()
{
	if(!(comm = fdopen(3, "rw+"))) {
		if((comm = fdopen(STDIN_FILENO, "rw+"))) stdin = comm;
		fout = (comm) ? stdin : stderr;
		comm = stdout;
	} else {
		if (LOG0) fprintf (stderr, "fout -> std_out\n");
		fout = stdout;
		setbuf(comm, NULL);
	}
	setvbuf(stdin,  NULL, _IONBF, 0);
	setvbuf(stdout, NULL, _IONBF, 0);
}

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
			loglevel = 3;
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

	char unsigned ackout_buffer[3];
	struct rgtr_node *ack_out  = set_rgtrnode(new_rgtrnode(), RGTRACK_ID, ackout_buffer, sizeof(ackout_buffer));
	struct rgtr_node *queue_in = NULL;
	struct rgtr_node *ack_in   = NULL;

	// Reset ack //
	// --------- //

	if (LOG0) fprintf (stderr, ">>> SETTING ACK <<<\n");

	int ack = 0x0b;
	for(;;) {

	
		queue_in = delete_queue(queue_in);

		if (LOG1) {
			fprintf (stderr, "Sending ACK\n");
		}

		set_acknode(ack_out, ack, 0x00);
		send_rgtr(ack_out);

		if (LOG1) fprintf (stderr, "Waiting ACK\n");
		queue_in = rcvd_rgtr();
		if (!queue_in) {
			if (LOG1) fprintf (stderr, "packet error\n");
			continue;
		}

		if (LOG1) print_rgtrs(queue_in);
		if (LOG1) fprintf (stderr, "ACK received\n");
		ack_in = lookup(RGTRACK_ID, queue_in);

		if (!ack_in) {
			if (LOG1) fprintf (stderr, "ACK error\n");
			continue;
		}

		if (((ack ^ rgtr2int(ack_in)) & 0x3f) == 0) {
			break;
		} else {
			if (LOG1) {
				fprintf (stderr, "ACK mismatch 0x%02x, 0x%02x\n", ack, rgtr2int(ack_in));
			}
		}

	}

	queue_in = delete_queue(queue_in);
	if (LOG0) {
		fprintf (stderr, ">>> ACKNOWLEGE SET <<<\n");
	}

	// Processing data //
	// --------------- //

	if (!pktmd)
		if (LOG1) fprintf (stderr, "No-packet-size mode\n");

	for(;;) {
		int n;
		short unsigned length = MAXLEN;
		char  unsigned buffer[MAXLEN];

		if (LOG0) fprintf (stderr, ">>> READING PACKET <<<\n");
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

//				struct rgtr_node *head;
//				print_rgtrs (head = rawdata2rgtr(buffer, n));
//				delete_queue(head);
			}

			length = n;
			if (length > MAXLEN) {
				if (LOG1) {
					fprintf (stderr, "Packet length %d greater than %d\n", length, MAXLEN);
				}
				abort();
			}

			(ack = (ack += 1) % 0x40);

			if (LOG0) {
				fprintf (stderr, ">>> SENDING PACKET <<<\n");
			}
			
			set_acknode(ack_out, ack, 0x0);
			send_rgtrrawdata(ack_out, buffer, length);

			if (LOG0) {
				fprintf (stderr, ">>> CHECKING ACK <<<\n");
			}
			for(;;) {
				if (LOG1) {
					fprintf (stderr, "waiting for acknowlege\n", n);
				}

				queue_in = delete_queue(queue_in);
				queue_in = rcvd_rgtr();
				if (LOG1) {
					print_rgtrs(queue_in);
				}
				if (queue_in) {
					if (LOG1) fprintf (stderr, "acknowlege received\n", n);

					ack_in = lookup(RGTRACK_ID, queue_in);
					if (!ack_in) {
						if (LOG1) {
							fprintf (stderr, "ACK missed\n");
						}
						continue;
					}
					if (LOG1) {
						fprintf (stderr, "ack_in\n", n);
						print_rgtr(ack_in);
					}

					if (((ack ^ rgtr2int(ack_in)) & 0x3f) == 0) {
						if (((ack ^ rgtr2int(ack_in)) & 0x80) != 0) {
							struct rgtr_node *queue_out;
							int data;

							if (LOG1) {
								fprintf (stderr, "----> %x\n", ack);
							}
							queue_out = rawdata2rgtr(buffer, length);
							if (LOG1) {
								fprintf (stderr, "queue_out\n", n);
								print_rgtrs(queue_out);
							}
							abort();
							data = rgtr2int(lookup(RGTRDMAADDR_ID, queue_out));
							delete_queue(queue_out);

							if (data & 0x80000000L) {
								(ack = (ack += 1) % 0x40);
							} else {
								break;
							}
						} else {
							break;
						}
					} else {
						if (LOG1) {
							fprintf (stderr, "acknowlege sent 0x%02x received 0x%02x\n", (char unsigned) ack, (char unsigned) rgtr2int(ack_in));
						}
						continue;
					}

				}

				if (LOG1) fprintf (stderr, "waiting time out\n");
				if (LOG1) print_rgtrs(ack_out);
				if (LOG1) fprintf (stderr, "sending package again\n");

				if (LOG1) fprintf (stderr, "rgtr_out\n") ;
				set_acknode(ack_out, ack, 0x0);
				send_rgtrrawdata(ack_out, buffer, length);
				if (LOG1) fprintf (stderr, "rgtr_out\n") ;
			}

			if (LOG1) fprintf (stderr, "package acknowleged\n", n);

			if (LOG0) fprintf (stderr, ">>> CHECKING DMA STATUS <<<\n");
			for (;;) {
				
				struct rgtr_node *dmaaddr;

				if (LOG1) print_rgtrs(queue_in);
				
				if ((dmaaddr = lookup(RGTRDMAADDR_ID, queue_in))) {
					if (!((rgtr2int(dmaaddr) & 0xc0000000) ^ 0xc0000000)) {
						break;
					}
				}

				queue_in = delete_queue(queue_in);
				if (LOG1) fprintf (stderr, "dma not ready\n");
				if (LOG1) fprintf (stderr, "sending new acknowlege\n");
				set_acknode(ack_out, (ack = (ack += 1) % 0x40), 0x0);
				send_rgtr(ack_out);

				for (;;) {
					queue_in = rcvd_rgtr();
					if (queue_in) {
						if (ack_in = lookup(RGTRACK_ID, queue_in)) {
							if (((ack ^ rgtr2int(ack_in)) & 0x3f) == 0)
								break;
							else
								continue;
						}
					}
					set_acknode(ack_out, ack, 0x0);
					send_rgtr(ack_out);
				}
			}
			if (LOG1) fprintf (stderr, "dma ready\n");

			while(queue_in) {
				struct rgtr_node *node;

				if (fout && queue_in->rgtr->id != RGTR0_ID) {
					fputc(queue_in->rgtr->id, fout);
					fputc(queue_in->rgtr->len, fout);
					for (int i = 0; i < queue_in->rgtr->len+1; i++) {
						fputc(queue_in->rgtr->data[i], fout);
					}
				}
				node = queue_in;
				queue_in = queue_in->next;
				delete_rgtrnode(node);
			}
		} else {
			if(LOG0) fprintf(stderr, "eof %d\n", feof(stdin));
			break;
		}

	}

	return 0;
}
