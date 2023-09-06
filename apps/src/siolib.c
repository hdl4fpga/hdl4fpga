#include <ctype.h>
#include <time.h>
#include <libusb-1.0/libusb.h>
#include "siolib.h"

int pkt_sent = 0;
int pkt_lost = 0;

static FILE *comm;

static int sckt;
static int (*sio_send)(char * data, int len);
static int (*sio_rcvd)(char * data, int len);

#define LOG0 (loglevel & (1 << 0))
#define LOG1 (loglevel & (1 << 1))
#define LOG2 (loglevel & (1 << 2))
#define LOG3 (loglevel & (1 << 3))
static int loglevel;

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
		fprintf(stderr,"No free object\n");
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

struct rgtrnode_pool {
	struct object_pool pool;
	struct rgtr_node objects[256];
};

static struct rgtrnode_pool node_pool = { { -1, } , };

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

struct rgtr_node *rgtr2raw(char unsigned *data, int * len, struct rgtr_node *queue_in)
{
	struct rgtr_node *node;
	char unsigned *ptr;

	node = queue_in;
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
	return queue_in;
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
		fprintf(stderr, "Null node at rgtr2int\n");
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

struct rgtr_node *set_acknode(struct rgtr_node *node, int ack, int dup)
{
	node->rgtr->data[0]  = (dup) ? 0x80 : 0x00;
	node->rgtr->data[0] |= (0x3f & ack);
	return node;
}

struct sockaddr_in sa_trgt;
socklen_t sl_trgt = sizeof(sa_trgt);

static libusb_context *usbctx = NULL;
static libusb_device_handle *usbdev;
static unsigned char usbendp;

int usb_send(char * data, int len)
{
	static char buffer[1024];
	char *ptr = buffer;
	u16 fcs;

    fcs = ~pppfcs16(PPPINITFCS16, data, len);
	*ptr++ = 0x7e;
	for (int i = 0; i < len+sizeof(fcs); i++) {
		char c;

		if (i < len) {
			c = data[i];
		} else {
			c = ((char *) &fcs)[i-len];
		}

		if (c == 0x7e) {
			*ptr++ = 0x7d;
			c ^= 0x20;
		} else if(c == 0x7d) {
			*ptr++ = 0x7d;
			c ^= 0x20;
		}
		*ptr++ = c;
	}
	*ptr++ = 0x7e;
	int result;
	int transferred;
	fprintf(stderr,"usbendp 0x%02hhx %ld", usbendp, ptr-buffer);
	if ((result = libusb_bulk_transfer(usbdev, usbendp & ~0x80, buffer, ptr-buffer, &transferred, 0))!=0) {
		printf("Error in bulk transfer. Error code: %d\n", result);
		perror ("sending packet");
		abort();
	}
	exit(0);
	getchar();
	pkt_sent++;
}

int socket_send(char * data, int len)
{
	if (sendto(sckt, data, len, 0, (struct sockaddr *) &sa_trgt, sl_trgt) == -1) {
		perror ("sending packet");
		abort();
	}
	pkt_sent++;
}

void uart_send(char c, FILE *comm)
{
	fputc(c, comm);
	if (LOG2) {
//		fprintf(stderr, "TX data 0x%02x\n", (unsigned char) c);
	}
}

int hdlc_send(char * data, int len)
{
	u16 fcs;

    fcs = ~pppfcs16(PPPINITFCS16, data, len);
	uart_send(0x7e, comm);
	for (int i = 0; i < len+sizeof(fcs); i++) {
		char c;

		if (i < len) {
			c = data[i];
		} else {
			c = ((char *) &fcs)[i-len];
		}

		if (c == 0x7e) {
			uart_send(0x7d, comm);
			c ^= 0x20;
		} else if(c == 0x7d) {
			uart_send(0x7d, comm);
			c ^= 0x20;
		}
		uart_send(c, comm);
	}
	uart_send(0x7e, comm);
	pkt_sent++;
}

void send_buffer(char * data, int len)
{
	sio_send(data, len);
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
		fprintf(stderr, "LEN+LEN1 %d\n", len+len1);
		abort();
	}

	memcpy(buffer+len1, data, len);

	send_buffer(buffer, len+len1);
}

int socket_rcvd(char *buffer, int maxlen)
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

int usb_rcvd(char *buffer, int maxlen)
{

	if (LOG0) {
		fprintf(stderr, "USB reading\n");
	}

	pkt_lost++;
	int retry = 0;
	char *ptr = buffer;
	do {
		int result;
		int transferred;

		if (result = libusb_bulk_transfer(usbdev, usbendp | 0x80, ptr, maxlen-(ptr-buffer), &transferred, 0)) {
			printf("Error in bulk transfer. Error code: %d\n", result);
			return -1;
		} else if (transferred > 0) {
			int i; 
			int j;

			for (i = 0, j = 0; i < transferred; i++, j++) {
				if (ptr[i] == 0x7e) {
					break;
				} else if (ptr[i] == 0x7d) {
					ptr[++i] ^= 0x20;
				}
				ptr[j] = ptr[i];
			}
			transferred += (j-i);

			ptr += transferred;
			if (ptr[i] == 0x7e) {
				break;
			}
			retry = 0;
		} else {
			struct timespec req;
			struct timespec rem;

			for (req.tv_sec = 0, req.tv_nsec = 1e6; nanosleep(&req, &rem); req = rem);

			if (retry++ > 64) {
				return -1;
			}
		}
	} while ((ptr-buffer) < maxlen);

	short unsigned fcs = pppfcs16(PPPINITFCS16, buffer, ptr-buffer);
	ptr -= 2;
	if (fcs == PPPGOODFCS16) {
		if (LOG0) fprintf(stderr, "FCS OK! ");
		if (LOG1) fprintf(stderr, "fcs 0x%04x", fcs);
		if (LOG0 | LOG1) fputc('\n', stderr);
		pkt_lost--;
		return ptr-buffer;
	}

	if (LOG0) fprintf(stderr, "FCS WRONG! ");
	if (LOG1) fprintf(stderr, "fcs 0x%04x", fcs);
	if (LOG0 | LOG1) fputc('\n', stderr);
	if (LOG2) {
		struct rgtr_node *print_queue;
		print_queue = rawdata2rgtr(buffer,ptr-buffer);
		print_rgtrs(print_queue);
		delete_queue(print_queue);
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
					if (LOG3) {
//						fprintf(stderr, "RX data 0x%02x\n", (unsigned char) buffer[i]);
					}
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
	if (LOG2) {
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
	if ((len = sio_rcvd(buffer, sizeof(buffer))) < 0) {
		return NULL;
	}
	node = rawdata2rgtr(buffer, len);
//	if (LOG2) print_rgtrs(node);

	return node;
}

void init_usb (short vid, short pid, char endp)
{
	usbendp = endp;
	if (libusb_init(&usbctx) != 0) {
		printf("Error initializing libusb.\n");
		exit(-1);
	}

	usbdev = libusb_open_device_with_vid_pid(usbctx, vid, pid);
	fprintf(stderr, "%hx:%hx\n",  vid,  pid);
	if (usbdev == NULL) {
		printf("Failed to open the USB device.\n");
		libusb_exit(usbctx);
		exit(-1);
	}
	if (libusb_claim_interface(usbdev, 0) != 0) {
		printf("Failed to claim the interface of the USB device.\n");
		libusb_close(usbdev);
		libusb_exit(usbctx);
		exit(-1);
	}
	sio_send = usb_send;
	sio_rcvd = usb_rcvd;
}

void init_socket (char * hostname)
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

	sio_send = socket_send;
	sio_rcvd = socket_rcvd;

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
#ifndef __MINGW32__
	if(!(comm = fdopen(3, "rw+"))) {
		if((comm = fdopen(STDIN_FILENO, "rw+"))) stdin = comm;
		comm = stdout;
	} else {
		setbuf(comm, NULL);
	}
	setvbuf(stdin,  NULL, _IONBF, 0);
	setvbuf(stdout, NULL, _IONBF, 0);
#endif
}

void sio_setloglevel(int level)
{
	loglevel = level;
}

int ack = -1;

int sio_init (int ack_val)
{

	struct rgtr_node *queue_in = NULL;
	struct rgtr_node *ack_out;
	struct rgtr_node *ack_in   = NULL;
	char unsigned ackout_buffer[3];

	ack_out  = set_rgtrnode(new_rgtrnode(), RGTRACK_ID, ackout_buffer, sizeof(ackout_buffer));
	queue_in = delete_queue(queue_in);

	if (LOG1) {
		fprintf (stderr, "Sending ACK\n");
	}

	ack = ack_val;
	set_acknode(ack_out, ack, 0x80);
	send_rgtr(ack_out);
	delete_rgtrnode(ack_out);

	if (LOG1) {
		fprintf (stderr, "Waiting ACK\n");
	}
	queue_in = rcvd_rgtr();
	if (!queue_in) {
		if (LOG1) {
			fprintf (stderr, "packet error\n");
		}
		return -1;
	}

	if (LOG2) {
		print_rgtrs(queue_in);
	}
	if (LOG1) {
		fprintf (stderr, "ACK received\n");
	}
	ack_in = lookup(RGTRACK_ID, queue_in);

	if (!ack_in) {
		if (LOG1) {
			fprintf (stderr, "ACK error\n");
		}
		queue_in = delete_queue(queue_in);
		return -1;
	}

	if (((ack ^ rgtr2int(ack_in)) & 0x3f) == 0) {
		queue_in = delete_queue(queue_in);
		return 0;
	} else {
		if (LOG1) {
			fprintf (stderr, "ACK mismatch 0x%02x, 0x%02x\n", ack, rgtr2int(ack_in));
		}
	}
	queue_in = delete_queue(queue_in);
	return -1;
}

struct rgtr_node *sio_request (char *buffer, size_t length)
{
	struct rgtr_node *queue_in = NULL;
	struct rgtr_node *ack_in   = NULL;
	struct rgtr_node *ack_out;
	char unsigned ackout_buffer[3];

	if (ack == -1) {
		while(sio_init(0));
	}

	(ack = (ack += 1) % 0x40);
	if (LOG0) {
		fprintf (stderr, ">>> SENDING PACKET <<<\n");
	}

	ack_out  = set_rgtrnode(new_rgtrnode(), RGTRACK_ID, ackout_buffer, sizeof(ackout_buffer));
	set_acknode(ack_out, ack, 0x0);
	send_rgtrrawdata(ack_out, buffer, length);

	if (LOG0) {
		fprintf (stderr, ">>> CHECKING ACK <<<\n");
	}

	for(;;) {
		if (LOG1) {
			fprintf (stderr, "\twaiting for acknowlege\n");
		}

		queue_in = delete_queue(queue_in);
		queue_in = rcvd_rgtr();
		if (LOG2) {
			print_rgtrs(queue_in);
		}
		if (queue_in) {
			if (LOG1) {
				fprintf (stderr, "\tacknowlege received\n");
			}

			ack_in = lookup(RGTRACK_ID, queue_in);
			if (!ack_in) {
				if (LOG1) {
					fprintf (stderr, "\tACK missed\n");
				}
				continue;
			}
			if (LOG1) {
				fprintf (stderr, "\tack_in\n");
				print_rgtr(ack_in);
			}

			if (((ack ^ rgtr2int(ack_in)) & 0x3f) == 0) {
				if (((ack ^ rgtr2int(ack_in)) & 0x80) != 0) {
					struct rgtr_node *queue_out;
					int data;

					if (LOG1) {
						fprintf (stderr, "\t----> %x\n", ack);
					}

					queue_out = rawdata2rgtr(buffer, length);

					if (LOG1) {
						fprintf (stderr, "\tqueue_out\n");
					}
					if (LOG2) {
						print_rgtrs(queue_out);
					}
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
					fprintf (stderr, "\tacknowlege sent 0x%02x received 0x%02x\n", (char unsigned) ack, (char unsigned) rgtr2int(ack_in));
				}
				continue;
			}

		}

		if (LOG1) {
			fprintf (stderr, "\twaiting time out\n");
		}
		if (LOG2) {
			print_rgtrs(ack_out);
		}
		if (LOG1) {
			fprintf (stderr, "\tsending package again\n");
			fprintf (stderr, "\trgtr_out\n") ;
		}
		set_acknode(ack_out, ack, 0x0);
		send_rgtrrawdata(ack_out, buffer, length);
		if (LOG1) {
			fprintf (stderr, "\trgtr_out\n") ;
		}
	}

	if (LOG1) {
		fprintf (stderr, "\tpackage acknowleged\n");
	}

	if (LOG0) {
		fprintf (stderr, ">>> CHECKING DMA STATUS <<<\n");
	}
	for (;;) {

		struct rgtr_node *dmaaddr;

		if (LOG2) {
			print_rgtrs(queue_in);
		}

		if ((dmaaddr = lookup(RGTRDMAADDR_ID, queue_in))) {
			if (!((rgtr2int(dmaaddr) & 0x80) ^ 0x80)) {
				break;
			}
		} else {
			break;
		}

		queue_in = delete_queue(queue_in);
		if (LOG1) {
			fprintf (stderr, "\tdma not ready\n");
		}
		if (LOG1) {
			fprintf (stderr, "\tsending new acknowlege\n");
		}
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
	if (LOG1) {
		fprintf (stderr, "\tdma ready\n");
	}

	delete_rgtrnode(ack_out);
	return queue_in;
}

void sio_dump (FILE *fout, struct rgtr_node *queue_in)
{
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
	}
}

int unsigned to_hex (char c)
{
	if ('A' <= toupper(c) && toupper(c) <= 'F')
		return toupper(c)-'A'+10;
	else if ('0' <= toupper(c) && toupper(c) <= '9')
		return toupper(c)-'0';
	else {
		fprintf(stderr, "No hex char 0x%02x\n", (unsigned char) c);
		abort();
	}

}

char *to_bytearray(char *bytearray, const char *hexstr)
{

	for(;;) {
		for (int i = 0; i < 2; i++) {
			if (!*hexstr)
				return bytearray;
			*bytearray <<= 4;
			*bytearray |= (0xf & to_hex(*hexstr++));
		}
		bytearray++;
	}
}

int raw2sio(char  *siobuf, char unsigned rgtr_id, const char *buffer, size_t size)
{
	char unsigned *bufptr;
	char unsigned *sioptr;
	int length;

	bufptr = (char unsigned *) buffer;
	sioptr = (char unsigned *) siobuf;

	length    = size-1;
	*sioptr++ = rgtr_id;
	*sioptr++ = length % 256;
	memcpy(sioptr, bufptr, sioptr[-1]+1);
	length -=    sioptr[-1]+1;
	bufptr += sioptr[-1]+1;
	sioptr += sioptr[-1]+1;

	for (length >>= 8; !(length < 0); length--) {
		*sioptr++ = rgtr_id;
		*sioptr++ = 256-1;
		memcpy(sioptr, bufptr, 256);
		bufptr += 256;
		sioptr += 256;
	}

	return sioptr-(char unsigned *)siobuf;
}

int sio2raw(char *buffer, char unsigned rgtr_id, const char unsigned *siobuf, size_t size)
{
	char *bufptr;
	const char unsigned *sioptr;

	bufptr = buffer;
	sioptr = siobuf;

	for(sioptr = siobuf; sioptr < siobuf+size; sioptr += (*sioptr + 2)) {
		if (*sioptr == rgtr_id) {
			sioptr++;
			memcpy(bufptr, sioptr+1, *sioptr + 1);
			bufptr += *sioptr + 1;
		} else {
			sioptr++;
//			break;
		}
	}

	return bufptr-buffer;
}
