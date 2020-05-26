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
	char   c;
	char   hostname[256] = "";
	struct hostent *host = NULL;
	struct sockaddr_in sa_trgt;

	int s;
	socklen_t sl_trgt = sizeof(sa_trgt);

	unsigned char len;
	unsigned char rid;
	unsigned char buffer[1024];
	unsigned char *bufptr;

#ifdef WINDOWS
	if (WSAStartup(MAKEWORD(2,2), &wsaData))
		exit(-1);
#endif
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
		fprintf (stderr, "Setting 'kit' as hostname\n", hostname);
	}

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

	bufptr = buffer;
	for(int i = 0; fread(&rid, sizeof(char), 1, stdin) > 0; i++) {
		*bufptr++ = rid;
		if (fread(&len, sizeof(char), 1, stdin) > 0) {
			*bufptr++ = len;
				fprintf(stderr,"%d\n", len);

			if (fread(bufptr, sizeof(char), len+1, stdin) > 0) {
				bufptr += (len+1);
				if (rid == 0x17) {
					*bufptr++ = 0xff;
					*bufptr++ = 0xff;
					if (sendto(s, buffer, bufptr-buffer, 0, (struct sockaddr *) &sa_trgt, sl_trgt) == -1) {
						perror ("sendto()");
						exit (-1);
					}
					bufptr = buffer;
				}
			} else {
				exit(-1);
			}
			nanosleep((const struct timespec[]){ {0, 10000000L } }, NULL);
		} else {
			exit(-1);
		}
	}

	return 0;
}
