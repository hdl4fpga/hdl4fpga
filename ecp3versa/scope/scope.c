#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifdef WINDOWS
#include <ws2tcpip.h>
#include <wininet.h>
#define htobe64(x) \
	((((unsigned long long)(x) & (unsigned long long)0x00000000000000ffULL) << 56) |\
	 (((unsigned long long)(x) & (unsigned long long)0x000000000000ff00ULL) << 40) |\
	 (((unsigned long long)(x) & (unsigned long long)0x0000000000ff0000ULL) << 24) |\
	 (((unsigned long long)(x) & (unsigned long long)0x00000000ff000000ULL) <<  8) |\
	 (((unsigned long long)(x) & (unsigned long long)0x000000ff00000000ULL) >>  8) |\
	 (((unsigned long long)(x) & (unsigned long long)0x0000ff0000000000ULL) >> 24) |\
	 (((unsigned long long)(x) & (unsigned long long)0x00ff000000000000ULL) >> 40) |\
	 (((unsigned long long)(x) & (unsigned long long)0xff00000000000000ULL) >> 56))

#else
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <signal.h>
#include <netdb.h>
#endif

#include <math.h>

#define PORT	1024

int main (int argc, char *argv[])
{
#ifdef WINDOWS
	WSADATA wsaData;
#endif
	struct hostent *hostname;
	struct sockaddr_in sa_host;
	struct sockaddr_in sa_src;
	struct sockaddr_in sa_trgt;

	int s;
	char sb_src[1024];
	char sb_trgt[17];
	socklen_t sl_src  = sizeof(sa_src);
	socklen_t sl_trgt = sizeof(sa_trgt);

	int i, j, n;
	int npkt;
	int size;

#ifdef WINDOWS
	if (WSAStartup(MAKEWORD(2,2), &wsaData))
		exit(-1);
#endif
	
	if (!(argc > 1)) {
		fprintf (stderr, "no argument %d", argc);
		exit(-1);
	}

	sscanf (argv[1], "%d", &npkt);

	if (!(hostname = gethostbyname("kit"))) {
		perror ("hostbyname");
		exit (-1);
	}

	if (argc > 2) {
		sscanf (argv[2], "%d", &size);
	} else {
		size = 64;
	}

	memset (&sa_trgt, 0, sizeof (sa_trgt));
	sa_trgt.sin_family = AF_INET;
	sa_trgt.sin_port   = htons(PORT);
	memcpy (&sa_trgt.sin_addr, hostname->h_addr, sizeof(sa_trgt.sin_addr));

	memset (&sa_host, 0, sizeof (sa_host));
	sa_host.sin_family = AF_INET;
	sa_host.sin_port   = htons(PORT);	
	sa_host.sin_addr.s_addr = htonl(INADDR_ANY);

	if ((s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
		perror ("can't get a socket");
		abort ();
	}

	if (bind (s, (const struct sockaddr *) &sa_host, sizeof(sa_host)) < 0) {
		perror ("can't bind the socket");
		abort ();
	}

	for (i = 0; i < npkt; i++) {
		if (sendto(s, sb_trgt, sizeof(sb_trgt), 0, (struct sockaddr *) &sa_trgt, sl_trgt)==-1) {
			perror ("sendto()");
			abort ();
		}

		do {
			if ((n = recvfrom(s, sb_src, sizeof(sb_src), 0, (struct sockaddr *) &sa_src, &sl_src)) < 0) {
				perror ("recvfrom");
				abort ();
			}
		} while(htonl(sa_src.sin_addr.s_addr) != 0xc0a802c8);

		for (j = 0; j < sizeof(sb_src); j += (size/8)) {
			switch (size) {
			case 32:
				printf("0x%08lx\n", (long unsigned int)htonl(*(long unsigned int *)(sb_src+j)));
				break;
			case 64:
				printf("0x%016llx\n", (long long unsigned int)htobe64(*(long long unsigned int *)(sb_src+j)));
				break;
			case 128:
				printf("0x%016llx%016llx\n",
					(long long unsigned int)htobe64(*(long long unsigned int *)(sb_src+j+8)),
					(long long unsigned int)htobe64(*(long long unsigned int *)(sb_src+j)));
				break;
			}
		}
	}
	return 0;
}
