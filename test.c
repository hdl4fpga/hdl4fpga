#include <stdio.h>

main ()
{
	char line[32];
//	char num[] = {0x7,0x7,0x0f,0x17,0x1f,0x27,0x2f,0x37};
	char num[] = {0x18,0x18,0x10,0x10,0x08,0x08,0x00,0x00};
	long l;
	long l1;
	char j;
	char i;
	j=0;
	l=l1=0;
	while (gets(line)) {
		char val = 0;
		for (i = 16; i <= 17; i++) {
			char c = line[i];
			val *= 16;
			if ('0' <= c && c <= '9')
				c -= '0';
			else {
				c -= 'a';
				c += 10;
			}
			val += c;
		}
		if (val != num[j]) {
			printf ("%6d %s\n", l, line);
			l1 = l;
			j++;
		}
		j++;
		j %= 8;
		l++;
	}
}
