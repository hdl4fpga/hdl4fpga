#ifndef LFSR_H
#define LFSR_H

__int128 unsigned lfsr_mask(int size);
__int128 unsigned lfsr_p (int size);
__int128 unsigned lfsr_next(__int128 unsigned lfsr, int lfsr_size);

#endif
