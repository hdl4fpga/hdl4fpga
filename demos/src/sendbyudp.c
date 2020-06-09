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
#define MAXSIZE 1500

int main (int argc, char *argv[])
{
#ifdef WINDOWS
	WSADATA wsaData;
#endif
	int   c;
	char   hostname[256] = "";
	struct hostent *host = NULL;
	struct sockaddr_in sa_trgt;

	int s;
	socklen_t sl_trgt = sizeof(sa_trgt);

	unsigned char buffer[2048];
	unsigned char *bufptr;
	char pktmd;

#ifdef WINDOWS
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

	if ((s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
		perror ("Can't open socket");
		exit (1);
	}

	int n;
	unsigned short size;
	size = sizeof(buffer)-2;
	for(;;) {
		if (pktmd) {
			if ((fread(&size, sizeof(unsigned short), 1, stdin) > 0))
				fprintf (stderr, "packet size %d\n", size);
			else
				return 0;
		}

			
		if ((n = fread(buffer, sizeof(unsigned char), size, stdin)) > 0) {
			if (size > MAXSIZE) {
				fprintf (stderr, "packet size %d greater than %d\n", size, MAXSIZE);
				exit(-1);
			}

			buffer[size++] = 0xff;
			buffer[size++] = 0xff;
			fprintf (stderr, "packet length %d\n", n);
			if (sendto(s, buffer, size, 0, (struct sockaddr *) &sa_trgt, sl_trgt) == -1) {
				perror ("sending packet");
				exit (-1);
			}
			nanosleep((const struct timespec[]){ {0, 500000L } }, NULL);
		} else if (n < 0) {
			perror ("reading packet");
			exit(-1);
		}
		else
			break;
	}

	return 0;
}
