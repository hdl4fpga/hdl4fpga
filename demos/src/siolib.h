#ifndef SIOLIB_H
#define SIOLIB_H

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

extern int pkt_sent;
extern int pkt_lost;

struct object_pool {
	int object_free;
	int free_objects[256];
};

struct object_pool *init_pool (struct object_pool *pool);
int new_object(struct object_pool *pool);
void delete_object(struct object_pool *pool, int object);

struct rgtr {
	char unsigned id;
	char unsigned len;
	char unsigned data[1];
};

struct rgtr_node {
	struct rgtr *rgtr;
	struct rgtr_node *next;
};

struct rgtr_node *new_rgtrnode();
struct rgtr_node *delete_rgtrnode(struct rgtr_node *node);
struct rgtr_node * delete_queue(struct rgtr_node *node);
struct rgtr_node *lookup(int id, struct rgtr_node *node);
struct rgtr_node *set_rgtrnode(struct rgtr_node *node, int id, char unsigned *buffer, int len);
struct rgtr_node *nest_rgtrnode (struct rgtr_node *node, char unsigned id, char unsigned len);
struct rgtr_node *rgtr2raw(char unsigned *data, int * len, struct rgtr_node *node);
struct rgtr_node *rawdata2rgtr(char unsigned *data, int len);
struct rgtr_node *childrgtrs(struct rgtr *rgtr);
int unsigned rgtr2int (struct rgtr_node *node);
struct rgtr_node *rcvd_rgtr();
struct rgtr_node *set_acknode(struct rgtr_node *node, int ack, int dup) ;

#define print_rgtr(x)  fprint_rgtr(stderr, x)
#define print_rgtrs(x) fprint_rgtrs(stderr, x)

void fprint_rgtr (FILE *file, struct rgtr_node *node);
void fprint_rgtrs (FILE *file, struct rgtr_node *node);

#define RGTR0_ID       0x00
#define RGTRACK_ID     0x01
#define RGTRDMAADDR_ID 0x16

void sio_setloglevel(int);
void sio_sethostname(char *);
void init_comms ();
void uart_send(char c, FILE *comm);
void hdlc_send(char * data, int len);
int  hdlc_rcvd(char unsigned *buffer, int maxlen);
void send_buffer(char * data, int len);
void send_rgtr(struct rgtr_node *node);
void send_rgtrrawdata(struct rgtr_node *node, char unsigned *data, int len);
void init_socket ();
void socket_send(char * data, int len);
int socket_rcvd(char unsigned *buffer, int maxlen);
int sio_init (int ack_val);
struct rgtr_node *sio_request (char *buffer, size_t length);
void sio_dump (FILE *, struct rgtr_node *queue_in);
char *to_bytearray(char *bytearray, const char *hexstr);
int sio2raw(char *buffer, char unsigned rgtr_id, const char unsigned *siobuf, size_t size);
int raw2sio(char *siobuf, char unsigned rgtr_id, const char *buffer, size_t size);

#endif
