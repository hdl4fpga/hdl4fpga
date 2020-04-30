#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <time.h>

#ifdef WINDOWS
#include <ws2tcpip.h>
#include <wininet.h>
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
int main (int argc, char *argv[])
{
#ifdef WINDOWS
	WSADATA wsaData;
#endif
	int    addr;
	char   c;
	char   hostname[256] = "";
	struct hostent *host = NULL;
	struct sockaddr_in sa_trgt;

	int s;
	socklen_t sl_trgt = sizeof(sa_trgt);

#ifdef WINDOWS
	if (WSAStartup(MAKEWORD(2,2), &wsaData))
		exit(-1);
#endif
	
	while ((c = getopt (argc, argv, "h::")) != -1) {
		switch (c) {
		case 'h':
			if (optarg)
				sscanf (optarg, "%s", hostname);
			break;
		case '?':
			fprintf (stderr, "usage : scope -p num_of_packets -d data_size [ -h hostname ]\n");
			exit(1);
		default:
			exit(1);
		}
	}

	if (!strlen(hostname)) {
		strcpy (hostname, "kit");
	}
	fprintf (stderr, "Setting 'kit' as hostname\n", hostname);

	if (!(host=gethostbyname(hostname))) {
		fprintf (stderr, "hostname '%s' not found\n", hostname);
		exit(1);
	}

	memset (&sa_trgt, 0, sizeof (sa_trgt));
	sa_trgt.sin_family = AF_INET;
	sa_trgt.sin_port   = htons(PORT);
	memcpy (&sa_trgt.sin_addr, host->h_addr, sizeof(sa_trgt.sin_addr));

	if ((s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
		perror ("Can't open socket");
		exit (1);
	}

	addr = 0;
	setbuf(stdin, NULL);
	while(!feof(stdin)) {
		char data[3*256/4];
		char memaddr[5+2];
		char memlen[5+2];
		char memdata[256+2+2];

		memaddr[0] = 0x16;
		memaddr[1] = 0x02;
		memaddr[2] = (addr >> 16) & 0xff;
		memaddr[3] = (addr >>  8) & 0xff;
		memaddr[4] = (addr >>  0) & 0xff;
		memaddr[5] = 0xff;
		memaddr[6] = 0xff;

		memlen[0] = 0x17;
		memlen[1] = 0x02;
		memlen[2] = 0x00;
		memlen[3] = 0x00;
		memlen[4] = 0x3f;
		memlen[5] = 0xff;
		memlen[6] = 0xff;

		memdata[0] = 0x18;
		memdata[1] = 0xff;
		memdata[258] = 0xff;
		memdata[259] = 0xff;

		fread(data, sizeof(char), sizeof(data), stdin);
		for (int i=0; i < sizeof(data)/3; i++) {
			memdata[4*i+0+2] = data[3*i+0];
			memdata[4*i+1+2] = data[3*i+1];
			memdata[4*i+2+2] = data[3*i+2];
			memdata[4*i+3+2] = 0xff;
		}

		if (sendto(s, memaddr, sizeof(memaddr), 0, (struct sockaddr *) &sa_trgt, sl_trgt)==-1) {
			perror ("sendto()");
			exit (1);
		} else if (sendto(s, memdata, sizeof(memdata), 0, (struct sockaddr *) &sa_trgt, sl_trgt)==-1) {
			perror ("sendto()");
			exit (1);
		} else if (sendto(s, memlen, sizeof(memlen), 0, (struct sockaddr *) &sa_trgt, sl_trgt)==-1) {
			perror ("sendto()");
			exit (1);
		}
		nanosleep((const struct timespec[]){{0, 10000000L}}, NULL);
		addr += 0x40;
	}

	return 0;
}
