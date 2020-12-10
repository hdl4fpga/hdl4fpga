/*
 * u16 represents an unsigned 16-bit number.  Adjust the typedef for
 * your hardware.
 */

typedef unsigned short u16;

#define PPPINITFCS16    0xffff  /* Initial FCS value */
#define PPPGOODFCS16    0xf0b8  /* Good final FCS value */

u16 reverse(register u16 num, register int len);
u16 pppfcs16(register u16 fcs, register unsigned char *cp, register int len);
