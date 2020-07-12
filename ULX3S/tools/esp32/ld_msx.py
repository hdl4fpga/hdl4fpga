# micropython ESP32
# MSX 1.0 ROM image loader (can also upload ROM to m68k)

# AUTHOR=EMARD
# LICENSE=BSD

# this code is SPI master to FPGA SPI slave
# FPGA sends pulse to GPIO after BTN state is changed.
# on GPIO pin interrupt from FPGA:
# btn_state = SPI_read
# SPI_write(buffer)
# FPGA SPI slave will accept image and start it

#from machine import SPI, Pin, SDCard, Timer
#from micropython import const, alloc_emergency_exception_buf
#from uctypes import addressof
from struct import unpack
#from time import sleep_ms
#import os

#import ecp5
#import gc

class ld_msx:
  def __init__(self,spi,cs):
    self.spi=spi
    self.cs=cs
    self.cs.off()
    #self.rom="/sd/zxspectrum/roms/opense.rom"

  # LOAD/SAVE and CPU control

  # read from file -> write to SPI RAM
  def load_msx_rom(self, filedata, addr=0, maxlen=0x10000, blocksize=1024):
    self.ctrl(6) # 2:bus request + 4:halt
    # Request load
    self.cs.on()
    self.spi.write(bytearray([0,(addr >> 24) & 0xFF, (addr >> 16) & 0xFF, (addr >> 8) & 0xFF, addr & 0xFF]))
    block = bytearray(blocksize)
    bytes_loaded = 0
    while bytes_loaded < maxlen:
      if filedata.readinto(block):
        self.spi.write(block)
        if bytes_loaded == 0:
          header = block[0:16]
        bytes_loaded += blocksize
      else:
        break
    self.cs.off()
    self.ctrl(1) # 1:reset
    #if header[2] == 0 and header[3] == 0:
    if (header[3] & 0xF0) == 0x40:
      self.ctrl(16) # 16:32K ROM soft-switch, run
    else:
      self.ctrl(0) # run

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

  def ctrl(self,i):
    self.cs.on()
    self.spi.write(bytearray([0, 0xFF, 0xFF, 0xFF, 0xFF, i]))
    self.cs.off()

  def cpu_halt(self):
    self.ctrl(2)

  def cpu_continue(self):
    self.ctrl(0)

