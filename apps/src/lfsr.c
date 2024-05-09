#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "lfsr.h"

__int128 unsigned lfsr_mask(int size)
{
	__int128 unsigned mask;

	mask = -1;
	mask >>= (128-size);

	return mask;
}

__int128 unsigned lfsr_p (int size)
{
	unsigned __int128 p;

	assert(size==128 || size==64 || size==32);
	switch(size) {
	case 128:
		p   = 0xE100000000000000;
		p <<= 64;
		break;
	case 64:
		p = 0xD800000000000000;
		break;
	case 32:
		p = 0xA3000000;
		break;
	}
	p ^= (((__int128) 1) << (size-1));
	return p;
}

__int128 unsigned lfsr_next(__int128 unsigned lfsr, int lfsr_size)
{
	return ((lfsr>>1)|((lfsr&1)<<(lfsr_size-1))) ^ (((lfsr&1) ? lfsr_mask(lfsr_size) : 0) & lfsr_p(lfsr_size));
}


void lfsr_print(__int128 lfsr, size_t lfsr_size)
{
	assert(lfsr_size==128 || lfsr_size==64 || lfsr_size==32);
	switch(lfsr_size) {
	case 32:
		fprintf(stderr,"0x%08lx\n", (long unsigned int) lfsr);
		break;
	case 64:
		fprintf(stderr,"0x%016llx\n", (long long unsigned int) lfsr);
		break;
	case 128:
		fprintf(stderr,"0x%016llx%016llx\n",
			(long long unsigned int ) (lfsr >> 64),
			(long long unsigned int ) (lfsr &  lfsr_mask(lfsr_size)));
		break;
	}
}
