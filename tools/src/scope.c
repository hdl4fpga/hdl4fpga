#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

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

#define PORT	1024
#define QUEUE   4
int main (int argc, char *argv[])
{
#ifdef WINDOWS
	WSADATA wsaData;
#endif
	int    nopt;
	char   c;
	char   hostname[256] = "";
	struct hostent *host = NULL;
	struct sockaddr_in sa_host;
	struct sockaddr_in sa_src;
	struct sockaddr_in sa_trgt;

	int s;
	char sb_src[1024];
	char sb_trgt[17];
	socklen_t sl_src  = sizeof(sa_src);
	socklen_t sl_trgt = sizeof(sa_trgt);

	int i, j, n, k;
	int npkt;
	int size;

#ifdef WINDOWS
	if (WSAStartup(MAKEWORD(2,2), &wsaData))
		exit(-1);
#endif
	
	nopt = 0;
	while ((c = getopt (argc, argv, "p:d:h::")) != -1) {
		switch (c) {
		case 'p':
			nopt++;
			sscanf (optarg, "%d", &npkt);
			break;
		case 'd':
			nopt++;
			sscanf (optarg, "%d", &size);
			break;
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

	if (nopt < 2) {
		fprintf (stderr, "usage : scope -p num_of_packets -d data_size [ -h hostname ]\n");
		exit(1);
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

	memset (&sa_host, 0, sizeof (sa_host));
	sa_host.sin_family = AF_INET;
	sa_host.sin_port   = htons(PORT);	
	sa_host.sin_addr.s_addr = htonl(INADDR_ANY);

	if ((s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
		perror ("Can't open socket");
		exit (1);
	}

	if (bind (s, (const struct sockaddr *) &sa_host, sizeof(sa_host)) < 0) {
		perror ("can't bind socket");
		exit (1);
	}

	for (k = 0; k < QUEUE && npkt > 0; k++, npkt--) {
		if (sendto(s, sb_trgt, sizeof(sb_trgt), 0, (struct sockaddr *) &sa_trgt, sl_trgt)==-1) {
			perror ("sendto()");
			exit (1);
		}
	}

	for (i = 0; i < npkt; i++) {
		do {
			if ((n = recvfrom(s, sb_src, sizeof(sb_src), 0, (struct sockaddr *) &sa_src, &sl_src)) < 0) {
				perror ("recvfrom");
				exit (1);
			}
		} while(htonl(sa_src.sin_addr.s_addr) != 0xc0a802c8);

		if (sendto(s, sb_trgt, sizeof(sb_trgt), 0, (struct sockaddr *) &sa_trgt, sl_trgt)==-1) {
			perror ("sendto()");
			exit (1);
		}

		for (j = 0; j < sizeof(sb_src); j += (size/8)) {
			switch (size) {
			case 32:
				printf("0x%08x\n",
					*(unsigned int *)(sb_src+j));
				break;
			case 64:
				printf("0x%08x%08x\n",
					*(unsigned int *)(sb_src+j+4),
					*(unsigned int *)(sb_src+j));
				break;
			case 128:
				printf("0x%08x%08x%08x%08x\n",
					*(unsigned int *)(sb_src+j+12),
					*(unsigned int *)(sb_src+j+8),
					*(unsigned int *)(sb_src+j+4),
					*(unsigned int *)(sb_src+j));
				break;
			}
		}
	}

	for (i = 0; i < k; i++) {

		do {
			if ((n = recvfrom(s, sb_src, sizeof(sb_src), 0, (struct sockaddr *) &sa_src, &sl_src)) < 0) {
				perror ("recvfrom");
				exit (1);
			}
		} while(htonl(sa_src.sin_addr.s_addr) != 0xc0a802c8);

		for (j = 0; j < sizeof(sb_src); j += (size/8)) {
			switch (size) {
			case 32:
				printf("0x%08x\n",
					*(unsigned int *)(sb_src+j));
				break;
			case 64:
				printf("0x%08x%08x\n",
					*(unsigned int *)(sb_src+j+4),
					*(unsigned int *)(sb_src+j));
				break;
			case 128:
				printf("0x%08x%08x%08x%08x\n",
					*(unsigned int *)(sb_src+j+12),
					*(unsigned int *)(sb_src+j+8),
					*(unsigned int *)(sb_src+j+4),
					*(unsigned int *)(sb_src+j));
				break;
			}
		}
	}

	return 0;
}
