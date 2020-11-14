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

int main (int argc, char *argv[])
{
#ifdef __MINGW32__
	WSADATA wsaData;
#endif
	int   c;
	char   hostname[256] = "";
	struct hostent *host = NULL;
	struct sockaddr_in sa_trgt;
	struct sockaddr_in sa_src;
	struct sockaddr_in sa_host;

	int s;
	socklen_t sl_src  = sizeof(sa_src);
	socklen_t sl_trgt = sizeof(sa_trgt);

	char sb_src[1024];
	unsigned char buffer[2048];
	unsigned char *bufptr;
	char pktmd;

	fd_set rfds;
	struct timeval tv;
	int err;
	int ack;
	int n;
	int l;
	int pkt_sent = 0;
	int pkt_lost = 0;
	unsigned short size;


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

	memset (&sa_trgt, 0, sizeof (sa_trgt));
	sa_trgt.sin_family = AF_INET;
	sa_trgt.sin_port   = htons(PORT);
	memcpy (&sa_trgt.sin_addr, host->h_addr, sizeof(sa_trgt.sin_addr));

	memset (&sa_host, 0, sizeof (sa_host));
	sa_host.sin_family = AF_INET;
	sa_host.sin_port   = htons(PORT);	
	sa_host.sin_addr.s_addr = htonl(INADDR_ANY);
	if ((s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
		perror ("Can't open socket");
		exit (1);
	}

	if (bind(s, (const struct sockaddr *) &sa_host, sizeof(sa_host)) < 0) {
		perror ("can't bind socket");
		exit (1);
	}

	//	DON'T FRAGMENT, 
	//	int tol = 2;	// Time To Live
	//	setsockopt(s, IPPROTO_IP, IP_PMTUDISC_DO, &tol, sizeof(val));
	//

	do {
		ack  = 0 ;
		size = 0;
		buffer[size++] = 0x00;
		buffer[size++] = 0x02;
		buffer[size++] = 0x00;
		buffer[size++] = 0x00;
		buffer[size++] = ack++;

		if (sendto(s, buffer, size, 0, (struct sockaddr *) &sa_trgt, sl_trgt) == -1) {
			perror ("sending packet");
			exit (1);
		}

		tv.tv_sec  = 0;
		tv.tv_usec = 1000;

		FD_ZERO(&rfds);
		FD_SET(s, &rfds);
		if ((err = select(s+1, &rfds, NULL, NULL, &tv))== -1) {
			perror ("select");
			exit (1);
		} else if (err > 0) {
			if ((l = recvfrom(s, sb_src, sizeof(sb_src), 0, (struct sockaddr *) &sa_src, &sl_src)) < 0) {
				perror ("recvfrom");
				exit (1);
			}
		}
	} while (!(err > 0));

	for(;;) {
		size = sizeof(buffer)-5;
		if (pktmd) {
			if ((fread(&size, sizeof(unsigned short), 1, stdin) > 0))
				fprintf (stderr, "packet size %d\n", size);
			else
				break;
		}

		if ((n = fread(buffer, sizeof(unsigned char), size, stdin)) > 0) {
			size = n;
			if (size > MAXSIZE) {
				fprintf (stderr, "packet size %d greater than %d\n", size, MAXSIZE);
				exit(1);
			}

			buffer[size++] = 0x00;
			buffer[size++] = 0x02;
			buffer[size++] = 0x00;
			buffer[size++] = 0x00;
			buffer[size++] = ack++;
			fprintf (stderr, "packet length %d\n", n);

			do {
				pkt_sent++;
				pkt_lost++;
				if (sendto(s, buffer, size, 0, (struct sockaddr *) &sa_trgt, sl_trgt) == -1) {
					perror ("sending packet");
					exit (1);
				}

				tv.tv_sec  = 0;
				tv.tv_usec = 1000;

				FD_ZERO(&rfds);
				FD_SET(s, &rfds);
				if ((err = select(s+1, &rfds, NULL, NULL, &tv))== -1) {
					perror ("select");
					exit (1);
				} else if (err > 0) {
					pkt_lost--;
					if ((l = recvfrom(s, sb_src, sizeof(sb_src), 0, (struct sockaddr *) &sa_src, &sl_src)) < 0) {
						perror ("recvfrom");
						exit (1);
					}
				}
			} while (!(err > 0));
			
		} else if (n < 0) {
			perror ("reading packet");
			exit(1);
		}
		else
			break;
	}

	fprintf (stderr, "Sent packets : %d\n Lost packets : %d\n Total sent : %d\n", pkt_sent-pkt_lost, pkt_lost, pkt_sent);

	return 0;
}
