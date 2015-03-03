#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <signal.h>
#include <netdb.h>
#include <math.h>

#define PORT	1024

main (int argc, char *argv[])
{
	struct hostent *hostname;
	struct sockaddr_in sa_host;
	struct sockaddr_in sa_src;
	struct sockaddr_in sa_trgt;

	int s;
	char sb_char[1024];
	unsigned long long *sb_src;
	char sb_trgt[17];
	socklen_t sl_src  = sizeof(sa_src);
	socklen_t sl_trgt = sizeof(sa_trgt);

	int i, j, n;
	int npkt;

	if (!(argc > 1)) {
		fprintf (stderr, "no argument %d", argc);
		abort();
	}

	sscanf (argv[1], "%d", &npkt);


	if (!(hostname = gethostbyname("kit"))) {
		perror ("hostbyname");
		abort ();
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

		if ((n = recvfrom(s, sb_char, sizeof(sb_char), 0, (struct sockaddr *) &sa_src, &sl_src)) < 0) {
			perror ("recvfrom");
			abort ();
		}

		sb_src = (unsigned long long *) (sb_char+2);
		for (j = 0; j < sizeof(sb_char)/sizeof(sb_src[0]); j++)
			printf("0x%016llx\n", htobe64(sb_src[j]));
						        


	}
	return 0;
}
