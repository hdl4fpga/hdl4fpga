# micropython ESP32
# MSX 1.0 ROM image loader (can also upload ROM to m68k)

# AUTHOR=EMARD
# LICENSE=BSD

from struct import unpack
from time import sleep_ms

class ld_h4f:
  def __init__(self,spi,cs):
    self.spi=spi
    self.cs=cs
    self.cs.off()
    spi.init(baudrate=8000000)
    # reverse nibble table
    self.rn=bytearray(16)
    for i in range(16):
      v=i
      r=0
      for j in range(4):
        r<<=1
        r|=v&1
        v>>=1
      self.rn[i]=r

  # read from file -> write to SPI RAM
  # blocksize max 2048 in steps of 256
  # max 1280 without significant flicker
  def load_hdl4fpga_image(self, filedata, addr=0, maxlen=0x10000000, blocksize=1024):
    N=blocksize//256
    pkt_blocksize = bytearray([
      self.reverse_byte((N*blocksize//2-1)>>16),
      self.reverse_byte((N*blocksize//2-1)>>8),
      self.reverse_byte( N*blocksize//2-1)])
    block = bytearray(blocksize)
    bytes_loaded = 0
    self.cs.on()
    while bytes_loaded < maxlen:
      if filedata.readinto(block):
        # address
        self.rgtr_write(0x16,bytearray([
          self.reverse_byte((bytes_loaded//2)>>16),
          self.reverse_byte((bytes_loaded//2)>>8),
          self.reverse_byte( bytes_loaded//2)]))
        # fill buffer
        for i in range(N):
          self.rgtr_write(0x18,block[i*256:(i+1)*256])
        # DMA transfer
        self.rgtr_write(0x17,pkt_blocksize)
        bytes_loaded += blocksize
      else:
        break
    self.cs.off()

  # read from SPI RAM -> write to file
  def save_stream(self, filedata, addr=0, length=1024, blocksize=1024):
    bytes_saved = 0
    block = bytearray(blocksize)
    # Request save
    self.cs.on()
    self.spi.write(bytearray([1,(addr >> 24) & 0xFF, (addr >> 16) & 0xFF, (addr >> 8) & 0xFF, addr & 0xFF, 0]))
    while bytes_saved < length:
      self.spi.readinto(block)
      filedata.write(block)
      bytes_saved += len(block)
    self.cs.off()

  def reverse_byte(self,x):
    return ((self.rn[x&0xF])<<4) | self.rn[(x&0xF0)>>4]

  # x is bytearray, length 1-256
  def rgtr_write(self,cmd,x):
    #self.cs.on()
    self.spi.write(bytearray([self.reverse_byte(cmd),self.reverse_byte(len(x)-1)]))
    self.spi.write(x)
    #self.cs.off()

  #def cls(self):
  #  self.rgtr_write(0x16,bytearray([0,0,0])) # address
  #  a = bytearray(256) # initial all 0
  #  for i in range(8):
  #    self.rgtr_write(0x18,a)
  #  self.rgtr_write(0x17,bytearray([0xFF,0xFF,0xFF])) # end
  #  sleep_ms(200)
    