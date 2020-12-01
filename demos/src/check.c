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

#define PORT	57001
#define QUEUE   4
#define MAXSIZE 1500
#define printnl fprintf(stderr,"\n")


char ack_rcvd = 0;
long long addr_rcvd;

char rbuff[1024];

void sio_parse(char * buff, int l)
{
	enum states { stt_id, stt_len, stt_data };
	enum states state;

	int id;
	int len;
	int i;

	long long data;

	addr_rcvd = 0;
	state = stt_id;
	for (i = 0; i < l; i++) {
		switch(state) {
		case stt_id:
			id    = buff[i];
//			fprintf(stderr, "id 0x%02x\n", id);
			state = stt_len;
			break;
		case stt_len:
			len   = (unsigned char) buff[i];
//			fprintf(stderr, "len %d\n", len);
			state = stt_data;
			data  = 0;
			break;
		case stt_data:
			data <<= 8;
			data |= (buff[i] & 0xff);
			if (len-- > 0) {
				state = stt_data;
			} else {
				switch(id){
				case 0x00:
					ack_rcvd = (char) data;
					fprintf(stderr, "ack 0x%02x ", (unsigned char) ack_rcvd);
					break;
				case 0x16:
					addr_rcvd = data;
					fprintf(stderr, "address 0x%08llx ", addr_rcvd);
					break;
				}
				state = stt_id;
			}
		}
	}
}

int    sckt;
struct hostent *host = NULL;
struct sockaddr_in sa_trgt;
struct sockaddr_in sa_host;
socklen_t sl_trgt = sizeof(sa_trgt);

void init_socket ()
{
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
		exit (1);
	}

	if (bind(sckt, (const struct sockaddr *) &sa_host, sizeof(sa_host)) < 0) {
		perror ("can't bind socket");
		exit (1);
	}

	//	DON'T FRAGMENT, 
	//	int tol = 2;	// Time To Live
	//	setsockopt(sckt, IPPROTO_IP, IP_PMTUDISC_DO, &tol, sizeof(val));
	//
}

char sbuff[2048];
char *sload = sbuff+5;
int  pkt_sent = 0;
int  ack      = 0;

void send_pkt(int psize)
{
	int len = 0;

	sbuff[len++] = 0x00;
	sbuff[len++] = 0x02;
	sbuff[len++] = 0x00;
	sbuff[len++] = 0x00;
	sbuff[len++] = (ack & 0x03f);
	len += psize;

	if (sendto(sckt, sbuff, len, 0, (struct sockaddr *) &sa_trgt, sl_trgt) == -1) {
		perror ("sending packet");
		exit (1);
	}
	pkt_sent++;
}

struct sockaddr_in sa_src;
socklen_t sl_src  = sizeof(sa_src);
int  pkt_lost = 0;

int rcvd_pkt()
{
	fd_set rfds;
	struct timeval tv;
	int err;
	int len;

	FD_ZERO(&rfds);
	FD_SET(sckt, &rfds);
	tv.tv_sec  = 0;
	tv.tv_usec = 1000;

	pkt_lost++;
	if ((err = select(sckt+1, &rfds, NULL, NULL, &tv)) == -1) {
		perror ("select");
		exit (1);
	} else {
		if (err > 0) {
			if ((len = recvfrom(sckt, rbuff, sizeof(rbuff), 0, (struct sockaddr *) &sa_src, &sl_src)) < 0) {
				perror ("recvfrom");
				exit (1);
			}
			pkt_lost--;
			return len;
		}
	}
	return 0;
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
	while ((c = getopt (argc, argv, "ph:")) != -1) {
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

	if (!strlen(hostname)) {
		strcpy (hostname, "kit");
		fprintf (stderr, "Setting 'kit' as hostname\n", hostname);
	}

	if (!(host=gethostbyname(hostname))) {
		fprintf (stderr, "Hostname '%s' not found\n", hostname);
		exit(1);
	}

	init_socket();

	// Reset ack //
	// --------- //

	for(;;) {
		send_pkt(0);
		sio_parse(sbuff, sload-sbuff); printnl;

		rlen = rcvd_pkt();
		sio_parse(rbuff, rlen); printnl;

		if (((ack ^ ack_rcvd) & 0x3f) == 0 && rlen > 0)
			break;
	}

	for(;;) {
		int size = sizeof(sbuff)-(sload-sbuff);

		if (pktmd) {
			if ((fread(&size, sizeof(unsigned short), 1, stdin) > 0))
				fprintf (stderr, "packet size %d\n", size);
			else
				break;
		}

		if ((n = fread(sload, sizeof(unsigned char), size, stdin)) > 0) {
			size = n;
			if (size > MAXSIZE) {
				fprintf (stderr, "packet size %d greater than %d\n", size, MAXSIZE);
				exit(1);
			}

			ack++;
			for(;;) {
				send_pkt(size);
				sio_parse(sbuff, sload-sbuff+size); printnl;

				rlen = rcvd_pkt();
				if (rlen > 0) {
					sio_parse(rbuff, rlen); printnl;
					if (((ack ^ ack_rcvd) & 0x3f) == 0 && rlen > 0)
						break;
				}
			}

			for (;;) {
				if (!((addr_rcvd & 0xc0000000) ^ 0xc0000000)) 
					break;

				ack++;
				send_pkt(0);
				sio_parse(sbuff, sload-sbuff); printnl;

				for (;;) {
					rlen = rcvd_pkt();
					if (rlen > 0) {
						sio_parse(rbuff, rlen); printnl;
						if (((ack ^ ack_rcvd) & 0x3f) == 0 && rlen > 0)
							break;
					} 
					send_pkt(0);
					sio_parse(sbuff, sload-sbuff); printnl;
				}
			}


		} else if (n < 0) {
			perror ("reading packet");
			exit(1);
		} else
			break;

	}

	return 0;
}
