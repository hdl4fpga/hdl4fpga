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
	unsigned long long sb_src[1024/8];
	char sb_trgt[17];
	socklen_t sl_src  = sizeof(sa_src);
	socklen_t sl_trgt = sizeof(sa_trgt);

	int i, j, n;
	int npkt;
	unsigned char lfsr = 0xff;

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

		if ((n = recvfrom(s, sb_src, sizeof(sb_src), 0, (struct sockaddr *) &sa_src, &sl_src)) < 0) {
			perror ("recvfrom");
			abort ();
		}

		for (j = 0; j < sizeof(sb_src)/sizeof(sb_src[0]); j++) {
			unsigned char lfbs;
			unsigned char bit;
			unsigned long long check;
			int k;

						        
			check = 
				 (((((((((unsigned long long)lfsr<<8)&0xff00) | (~(unsigned long long)lfsr<<0)&0x00ff) << 16) & 0xffff0000) |
				    (((~((unsigned long long)lfsr<<8)&0xff00  | ( (unsigned long long)lfsr<<0)) & 0xffff))) << 32) & 0xffffffff00000000) |
				   (((((((unsigned long long)lfsr<<8)&0xff00) | (~(unsigned long long)lfsr<<0)&0x00ff) << 16) & 0xffff0000) |
				    (((~((unsigned long long)lfsr<<8)&0xff00  | ( (unsigned long long)lfsr<<0)) & 0xffff)));

			printf("0x%016llx 0x%016llx\n", htobe64(sb_src[j]), check);
			if (check != htobe64(sb_src[j])){
				fprintf(stderr, "Failed %d, %d, ", i, j);
				fprintf(stderr,"0x%016llx 0x%016llx\n", htobe64(sb_src[j]), check);
				abort();
			}

			lfbs = (lfsr & 0x71);
			bit = 0;

			for (k = 0; k < 8; k++) {
				bit  ^= (lfbs & 0x01);
				lfbs >>= 1;
			}
			lfsr >>= 1;
			lfsr |= ((bit) ? 0x80 : 0x00);
		}
	}

	return 0;
}
