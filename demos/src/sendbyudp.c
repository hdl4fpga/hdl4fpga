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
	int n;
	socklen_t sl_trgt = sizeof(sa_trgt);

#ifdef WINDOWS
	if (WSAStartup(MAKEWORD(2,2), &wsaData))
		exit(-1);
#endif
	n = 0;
	while ((c = getopt (argc, argv, "h:")) != -1) {
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

	n = 0;
	addr = 0;
	setbuf(stdin, NULL);
	while(!feof(stdin)) {
		fread(data, sizeof(char), sizeof(data), stdin);
		nanosleep((const struct timespec[]){{0, 100000000L}}, NULL);
		addr += 0x40;

		n++;
	}

	return 0;
}
