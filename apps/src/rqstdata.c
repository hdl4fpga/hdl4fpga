// Copyright (c) <2015> <Miguel Angel Sagreras>                                    //
//                                                                                 //
// Permission is hereby granted, free of charge, to any person obtaining a copy of //
// this software and associated documentation files (the "Software"), to deal in   //
// the Software without restriction, including without limitation the rights to    //
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   //
// of the Software, and to permit persons to whom the Software is furnished to do  //
// so, subject to the following conditions:                                        //
//                                                                                 //
// The above copyright notice and this permission notice shall be included in all  //
// copies or substantial portions of the Software.                                 //
//                                                                                 //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    //
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        //
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     //
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          //
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   //
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   //
// SOFTWARE.                                                                       //
//                                                                                 //

#include <stdlib.h>
#include <stdio.h>
#include <netinet/in.h>

#ifdef _WIN32
	_setmode(_fileno(stdin), _O_BINARY);
#endif

char buff[256];
int main (int argc, char *argv[])
{
	union {
		char byte[4];
		int word;
	} hton;
	char *ptr;

	setbuf(stdout, NULL);
	for(int i = 0; i < 16; i++) {
		ptr = buff+sizeof(short);
		hton.word = htonl((i << 10));
    	*ptr++ = 0x17;
    	*ptr++ = 0x02;
    	*ptr++ = 0x00;
    	*ptr++ = 0x03;
    	*ptr++ = 0xff;
    	*ptr++ = 0x16;
    	*ptr++ = 0x03;
    	*ptr++ = hton.byte[0] | 0x80;
    	*ptr++ = hton.byte[1];
    	*ptr++ = hton.byte[2];
    	*ptr++ = hton.byte[3];
		*(short *)buff = ptr-buff-sizeof(short);
		if (fwrite (buff, sizeof(char), ptr-buff, stdout) < 0) {
			perror("exit\n");
			exit(-1);
		}
		fprintf(stderr, "pase %d\n",i);
	}

	return 0;
}

