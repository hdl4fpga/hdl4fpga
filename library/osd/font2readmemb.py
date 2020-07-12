#!/usr/bin/env python3

# convert binary file (usually 2K or 4K to verilog $readmemb()
import sys

font_height=16
msb_first=1

def printer(n, b):
  if n >= 32 and n <= 127:
    print("// 0x%02X %c" % (n, n))
  else:
    print("// 0x%02X" % n)
  if msb_first:
    for c in b:
      for i in range(8):
        print((c&0x80)>>7, end="")
        c <<= 1
      print("")
  else: # lsb first
    for c in b:
      for i in range(8):
        print(c&1, end="")
        c >>= 1
      print("")

def converter():
  f=sys.stdin
  print('// spi_osd.v: initial $readmemb("font_bizcat8x16.mem", font);')
  b = bytearray(font_height)
  i = 0
  while True:
    b = f.buffer.read(16)
    if b:
      printer(i,b)
      i += 1
    else:
      break
  f.close()

converter()
