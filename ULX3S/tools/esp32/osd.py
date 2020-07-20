# micropython ESP32
# OSD SPI loader

# AUTHOR=EMARD
# LICENSE=BSD

# this code is SPI master to FPGA SPI slave
# FPGA sends pulse to GPIO after BTN state is changed.
# on GPIO pin interrupt from FPGA:
# btn_state = SPI_read
# SPI_write(buffer)
# FPGA SPI slave will accept image and start it

from machine import SPI, Pin, SDCard, Timer
from micropython import const, alloc_emergency_exception_buf
from uctypes import addressof
from struct import unpack
from collections import namedtuple
import os
import gc
import ecp5
import ld_h4f

class osd:
  def __init__(self):
    alloc_emergency_exception_buf(100)
    self.screen_x = const(64)
    self.screen_y = const(20)
    self.cwd = "/"
    self.init_fb()
    self.exp_names = " KMGTE"
    self.mark = bytearray([32,16,42]) # space, right triangle, asterisk
    self.read_dir()
    self.spi_read_irq = bytearray([1,0xF1,0,0,0,0,0])
    self.spi_read_btn = bytearray([1,0xFB,0,0,0,0,0])
    self.spi_result = bytearray(7)
    self.spi_enable_osd = bytearray([0,0xFE,0,0,0,1])
    self.spi_write_osd = bytearray([0,0xFD,0,0,0])
    self.spi_channel = const(2)
    self.spi_freq = const(3000000)
    self.init_pinout_sd()
    #self.spi=SPI(self.spi_channel, baudrate=self.spi_freq, polarity=0, phase=0, bits=8, firstbit=SPI.MSB, sck=Pin(self.gpio_sck), mosi=Pin(self.gpio_mosi), miso=Pin(self.gpio_miso))
    self.init_spi()
    self.init_slides()
    self.enable = bytearray(1)
    self.h4f=ld_h4f.ld_h4f(self.spi,self.cs)
    self.timer = Timer(3)
    self.irq_handler(0)
    self.irq_handler_ref = self.irq_handler # allocation happens here
    self.spi_request = Pin(0, Pin.IN, Pin.PULL_UP)
    self.spi_request.irq(trigger=Pin.IRQ_FALLING, handler=self.irq_handler_ref)

  def init_spi(self):
    self.spi=SPI(self.spi_channel, baudrate=self.spi_freq, polarity=0, phase=0, bits=8, firstbit=SPI.MSB, sck=Pin(self.gpio_sck), mosi=Pin(self.gpio_mosi), miso=Pin(self.gpio_miso))
    self.cs=Pin(self.gpio_cs,Pin.OUT)
    self.cs.off()

# init file browser
  def init_fb(self):
    self.fb_topitem = 0
    self.fb_cursor = 0
    self.fb_selected = -1

  @micropython.viper
  def init_pinout_sd(self):
    self.gpio_cs   = const(5)
    self.gpio_sck  = const(16)
    self.gpio_mosi = const(4)
    self.gpio_miso = const(12)

  @micropython.viper
  def irq_handler(self, pin):
    p8result = ptr8(addressof(self.spi_result))
    self.cs.on()
    self.spi.write_readinto(self.spi_read_irq,self.spi_result)
    self.cs.off()
    btn_irq = p8result[6]
    if btn_irq&0x80: # btn event IRQ flag
      self.cs.on()
      self.spi.write_readinto(self.spi_read_btn,self.spi_result)
      self.cs.off()
      btn = p8result[6]
      p8enable = ptr8(addressof(self.enable))
      if p8enable[0]&2: # wait to release all BTNs
        if btn==1:
          p8enable[0]&=1 # clear bit that waits for all BTNs released
      else: # all BTNs released
        if (btn&0x78)==0x78: # all cursor BTNs pressed at the same time
          self.show_dir() # refresh directory
          p8enable[0]=(p8enable[0]^1)|2;
          self.osd_enable(p8enable[0]&1)
        if p8enable[0]==1:
          if btn==9: # btn3 cursor up
            self.start_autorepeat(-1)
          if btn==17: # btn4 cursor down
            self.start_autorepeat(1)
          if btn==1:
            self.timer.deinit() # stop autorepeat
          if btn==33: # btn5 cursor left
            self.updir()
          if btn==65: # btn6 cursor right
            self.select_entry()
        else:
          if btn==9: # btn3 cursor up
            self.start_bgreader()
          p8slide = ptr8(addressof(self.slide_shown))
          if btn==33: # btn5 cursor left
            if p8slide[0]>0:
              p8slide[0]-=1
              #ic=(p8slide[0]+int(self.ncached)-int(self.nbackward)-1)%int(self.ncached)
              #self.caches_y_rd[ic]=0
              #self.caches_pos[ic]=0
          if btn==65: # btn6 cursor right
            if p8slide[0]<int(self.nfiles)-1:
              p8slide[0]+=1
              #ic=(p8slide[0]+int(self.nforward)-1)%int(self.ncached)
              #self.caches_y_rd[ic]=0
              #self.caches_pos[ic]=0
          self.cs.on()
          self.h4f.rgtr(0x19,self.h4f.i24(int(self.slide_pixels)*(p8slide[0]%int(self.ncached))))
          self.cs.off()

  def start_autorepeat(self, i:int):
    self.autorepeat_direction=i
    self.move_dir_cursor(i)
    self.timer_slow=1
    self.timer.init(mode=Timer.PERIODIC, period=500, callback=self.autorepeat)

  def autorepeat(self, timer):
    if self.timer_slow:
      self.timer_slow=0
      self.timer.init(mode=Timer.PERIODIC, period=30, callback=self.autorepeat)
    self.move_dir_cursor(self.autorepeat_direction)
    self.irq_handler(0) # catch stale IRQ

  def start_bgreader(self):
    if self.finished:
      self.finished=0
      self.reading_slide=self.slide_shown[0]
      #for i in range(self.ncached):
      #  self.caches_y_rd[i]=0
      #  self.caches_pos[i]=0
      self.timer.init(mode=Timer.PERIODIC, period=20, callback=self.bgreader)

  def bgreader(self,timer):
    if self.finished>0 or self.reading_slide<0:
      self.timer.deinit()
      return
    # if we are not finished, we get here
    reading_slide=self.reading_slide%self.ncached
    if self.file_open==0:
      filename=self.fullpath(self.direntries[self.file0+self.reading_slide][0])
      self.bg_file=open(filename,"rb")
      self.bg_file.seek(self.caches_pos[reading_slide])
      self.file_open=1
      print("%d RD %s" % (self.reading_slide,filename))
    # file is open now
    restore_pos=1
    must_close=0
    # if viewed slide has changed:
    if self.slide_shown[0] != self.prev_slide_shown:
      # close file if it was being viewed and baing loaded
      if self.prev_slide_shown == self.reading_slide:
        must_close=1
      # discard those cached that will be replaced with new files
      if self.slide_shown[0] < self.prev_slide_shown:
        dc=(self.slide_shown[0]+self.ncached-self.nbackward-1)%self.ncached
        n=self.prev_slide_shown-self.slide_shown[0]
      else:
        dc=(self.prev_slide_shown+self.nforward-1)%self.ncached
        n=self.slide_shown[0]-self.prev_slide_shown
      for i in range(n):
        if dc==reading_slide:
          must_close=1
          restore_pos=0
        self.caches_pos[dc]=0
        self.caches_y_rd[dc]=0
        dc=(dc+1)%self.ncached
      # ... end discarding cache ...
    if must_close:
      if restore_pos:
        self.caches_pos[reading_slide]=self.bg_file.tell()
      self.bg_file.close()
      self.file_open=0
      self.reading_slide=self.slide_shown[0]
      self.prev_slide_shown=self.slide_shown[0]
      return
    self.prev_slide_shown=self.slide_shown[0]
    # check are all Y lines of image loaded
    bytpp=self.bpp//8 # in file
    if self.caches_y_rd[reading_slide] < self.caches_y[reading_slide]:
      # load state, read one line, save state and exit
      line_pixels=self.caches_x_rd[reading_slide]
      read_remaining=bytpp*line_pixels
      seek_skip=0
      # clamp read remaining and calculate seek at the end
      if read_remaining > bytpp*self.caches_x[reading_slide]:
        seek_skip=bg_file.tell() + read_remaining
        read_remaining=bytpp*self.caches_x[reading_slide]
      self.bg_file.readinto(self.PPM_line_buf)
      if seek_skip:
        self.bg_file.seek(seek_skip)
      # write PPM_line_buf to screen
      addr=self.xres*(reading_slide*self.yres+self.caches_y_rd[reading_slide])
      # DMA transfer <= 2048 bytes each
      # DMA transfer must be divided in N buffer uploads
      # buffer upload <= 256 bytes each
      nbuf=8
      astep=200
      abuf=0
      self.cs.on()
      self.h4f.rgtr(0x16,self.h4f.i24(addr))
      for j in range(nbuf):
        self.h4f.rgtr(0x18,self.PPM_line_buf[abuf:abuf+astep])
        abuf+=astep
      self.h4f.rgtr(0x17,self.h4f.i24(nbuf*astep//bytpp-1))
      self.cs.off()
      self.caches_y_rd[reading_slide]+=1
      # next line next time 
    else: # all y-lines done, close file
      self.bg_file.close()
      self.file_open=0
      # TODO priority reading: decide which slide is next
      # finish if no more slides to read
      next_forward_slide=-1
      i=self.slide_shown[0]
      n=i+self.nforward
      if n>self.nfiles:
        n=self.nfiles
      while i<n:
        ic=i%self.ncached
        if self.caches_y_rd[ic]<self.caches_y[ic]:
          next_forward_slide=i
          break
        i+=1
      next_backward_slide=-1
      i=self.slide_shown[0]-1
      n=i-self.nbackward
      if n<0:
        n=0
      while i>=n:
        ic=i%self.ncached
        if self.caches_y_rd[ic]<self.caches_y[ic]:
          next_backward_slide=i
          break
        i-=1
      next_reading_slide=-1
      if next_forward_slide>=0 and next_backward_slide>=0:
        if (next_forward_slide-self.slide_shown[0])*self.priority_backward < \
          (self.slide_shown[0]-next_backward_slide)*self.priority_forward:
          next_reading_slide=next_forward_slide
        else:
          next_reading_slide=next_backward_slide
      else:
        if next_forward_slide>=0:
          next_reading_slide=next_forward_slide
        else:
          if next_backward_slide>=0:
            next_reading_slide=next_backward_slide
      self.reading_slide=next_reading_slide
      if self.reading_slide<0:
        self.finished=1
        self.timer.deinit()
        print("finished")

  def select_entry(self):
    if self.direntries[self.fb_cursor][1]: # is it directory
      oldselected = self.fb_selected - self.fb_topitem
      self.fb_selected = self.fb_cursor
      try:
        self.cwd = self.fullpath(self.direntries[self.fb_cursor][0])
      except:
        self.fb_selected = -1
      self.show_dir_line(oldselected)
      self.show_dir_line(self.fb_cursor - self.fb_topitem)
      self.init_fb()
      self.read_dir()
      self.show_dir()
    else:
      self.change_file()

  def updir(self):
    if len(self.cwd) < 2:
      self.cwd = "/"
    else:
      s = self.cwd.split("/")[:-1]
      self.cwd = ""
      for name in s:
        if len(name) > 0:
          self.cwd += "/"+name
    self.init_fb()
    self.read_dir()
    self.show_dir()

  def fullpath(self,fname):
    if self.cwd.endswith("/"):
      return self.cwd+fname
    else:
      return self.cwd+"/"+fname

  def change_file(self):
    oldselected = self.fb_selected - self.fb_topitem
    self.fb_selected = self.fb_cursor
    try:
      filename = self.fullpath(self.direntries[self.fb_cursor][0])
    except:
      filename = False
      self.fb_selected = -1
    self.show_dir_line(oldselected)
    self.show_dir_line(self.fb_cursor - self.fb_topitem)
    if filename:
      if filename.endswith(".bit"):
        self.spi_request.irq(handler=None)
        self.timer.deinit()
        self.enable[0]=0
        self.osd_enable(0)
        self.spi.deinit()
        tap=ecp5.ecp5()
        tap.prog_stream(open(filename,"rb"),blocksize=1024)
        if filename.endswith("_sd.bit"):
          os.umount("/sd")
          for i in bytearray([2,4,12,13,14,15]):
            p=Pin(i,Pin.IN)
            a=p.value()
            del p,a
        result=tap.prog_close()
        del tap
        gc.collect()
        #os.mount(SDCard(slot=3),"/sd") # BUG, won't work
        self.init_spi() # because of ecp5.prog() spi.deinit()
        self.spi_request.irq(trigger=Pin.IRQ_FALLING, handler=self.irq_handler_ref)
        self.irq_handler(0) # handle stuck IRQ
      if filename.endswith(".nes") \
      or filename.endswith(".snes") \
      or filename.endswith(".smc") \
      or filename.endswith(".sfc"):
        import ld_nes
        s=ld_nes.ld_nes(self.spi,self.cs)
        s.ctrl(1)
        s.ctrl(0)
        s.load_stream(open(filename,"rb"))
        del s
        gc.collect()
      if filename.startswith("/sd/ti99_4a/") and filename.endswith(".bin"):
        import ld_ti99_4a
        s=ld_ti99_4a.ld_ti99_4a(self.spi,self.cs)
        s.load_rom_auto(open(filename,"rb"),filename)
        del s
        gc.collect()
        self.enable[0]=0
        self.osd_enable(0)
      if (filename.startswith("/sd/msx") and filename.endswith(".rom")) \
      or filename.endswith(".mx1"):
        import ld_msx
        s=ld_msx.ld_msx(self.spi,self.cs)
        s.load_msx_rom(open(filename,"rb"))
        del s
        gc.collect()
        self.enable[0]=0
        self.osd_enable(0)
      if filename.endswith(".z80"):
        self.enable[0]=0
        self.osd_enable(0)
        import ld_zxspectrum
        s=ld_zxspectrum.ld_zxspectrum(self.spi,self.cs)
        s.loadz80(filename)
        del s
        gc.collect()
      if filename.endswith(".ora") or filename.endswith(".orao"):
        self.enable[0]=0
        self.osd_enable(0)
        import ld_orao
        s=ld_orao.ld_orao(self.spi,self.cs)
        s.loadorao(filename)
        del s
        gc.collect()
      if filename.endswith(".vsf"):
        self.enable[0]=0
        self.osd_enable(0)
        import ld_vic20
        s=ld_vic20.ld_vic20(self.spi,self.cs)
        s.loadvsf(filename)
        del s
        gc.collect()
      if filename.endswith(".prg"):
        self.enable[0]=0
        self.osd_enable(0)
        import ld_vic20
        s=ld_vic20.ld_vic20(self.spi,self.cs)
        s.loadprg(filename)
        del s
        gc.collect()
      if filename.endswith(".cas"):
        self.enable[0]=0
        self.osd_enable(0)
        import ld_trs80
        s=ld_trs80.ld_trs80(self.spi,self.cs)
        s.loadcas(filename)
        del s
        gc.collect()
      if filename.endswith(".cmd"):
        self.enable[0]=0
        self.osd_enable(0)
        import ld_trs80
        s=ld_trs80.ld_trs80(self.spi,self.cs)
        s.loadcmd(filename)
        del s
        gc.collect()
      if filename.endswith(".h4f"):
        self.h4f.load_hdl4fpga_image(open(filename,"rb"),self.slide_shown[0]%self.ncached*self.slide_pixels)
        gc.collect()
        self.enable[0]=0
        self.osd_enable(0)

  @micropython.viper
  def osd_enable(self, en:int):
    pena = ptr8(addressof(self.spi_enable_osd))
    pena[5] = en&1
    self.cs.on()
    self.spi.write(self.spi_enable_osd)
    self.cs.off()

  @micropython.viper
  def osd_print(self, x:int, y:int, i:int, text):
    p8msg=ptr8(addressof(self.spi_write_osd))
    a=0xF000+(x&63)+((y&31)<<6)
    p8msg[2]=i
    p8msg[3]=a>>8
    p8msg[4]=a
    self.cs.on()
    self.spi.write(self.spi_write_osd)
    self.spi.write(text)
    self.cs.off()

  @micropython.viper
  def osd_cls(self):
    p8msg=ptr8(addressof(self.spi_write_osd))
    p8msg[3]=0xF0
    p8msg[4]=0
    self.cs.on()
    self.spi.write(self.spi_write_osd)
    self.spi.read(1280,32)
    self.cs.off()

  # y is actual line on the screen
  def show_dir_line(self, y):
    if y < 0 or y >= self.screen_y:
      return
    mark = 0
    invert = 0
    if y == self.fb_cursor - self.fb_topitem:
      mark = 1
      invert = 1
    if y == self.fb_selected - self.fb_topitem:
      mark = 2
    i = y+self.fb_topitem
    if i >= len(self.direntries):
      self.osd_print(0,y,0,"%64s" % "")
      return
    if self.direntries[i][1]: # directory
      self.osd_print(0,y,invert,"%c%-57s     D" % (self.mark[mark],self.direntries[i][0]))
    else: # file
      mantissa = self.direntries[i][2]
      exponent = 0
      while mantissa >= 1024:
        mantissa >>= 10
        exponent += 1
      self.osd_print(0,y,invert,"%c%-57s %4d%c" % (self.mark[mark],self.direntries[i][0], mantissa, self.exp_names[exponent]))

  def show_dir(self):
    for i in range(self.screen_y):
      self.show_dir_line(i)

  def move_dir_cursor(self, step):
    oldcursor = self.fb_cursor
    if step == 1:
      if self.fb_cursor < len(self.direntries)-1:
        self.fb_cursor += 1
    if step == -1:
      if self.fb_cursor > 0:
        self.fb_cursor -= 1
    if oldcursor != self.fb_cursor:
      screen_line = self.fb_cursor - self.fb_topitem
      if screen_line >= 0 and screen_line < self.screen_y: # move cursor inside screen, no scroll
        self.show_dir_line(oldcursor - self.fb_topitem) # no highlight
        self.show_dir_line(screen_line) # highlight
      else: # scroll
        if screen_line < 0: # cursor going up
          screen_line = 0
          if self.fb_topitem > 0:
            self.fb_topitem -= 1
            self.show_dir()
        else: # cursor going down
          screen_line = self.screen_y-1
          if self.fb_topitem+self.screen_y < len(self.direntries):
            self.fb_topitem += 1
            self.show_dir()

  def read_dir(self):
    self.direntries = []
    ls = sorted(os.listdir(self.cwd))
    for fname in ls:
      stat = os.stat(self.fullpath(fname))
      if stat[0] & 0o170000 == 0o040000:
        self.direntries.append([fname,1,0]) # directory
    self.file0=len(self.direntries)
    for fname in ls:
      stat = os.stat(self.fullpath(fname))
      if stat[0] & 0o170000 != 0o040000:
        self.direntries.append([fname,0,stat[6]]) # file
    self.nfiles=len(self.direntries)-self.file0
    gc.collect()

  # NOTE: this can be used for debugging
  #def osd(self, a):
  #  if len(a) > 0:
  #    enable = 1
  #  else:
  #    enable = 0
  #  self.cs.on()
  #  self.spi.write(bytearray([0,0xFE,0,0,0,enable])) # enable OSD
  #  self.cs.off()
  #  if enable:
  #    self.cs.on()
  #    self.spi.write(bytearray([0,0xFD,0,0,0])) # write content
  #    self.spi.write(bytearray(a)) # write content
  #    self.cs.off()
  
  # *** SLIDESHOW ***
  # self.direntries, self.file0
  def init_slides(self):
    self.xres=800
    self.yres=600
    self.bpp=16
    membytes=32*1024*1024
    self.priority_forward=2
    self.priority_backward=1
    self.slide_pixels=self.xres*self.yres
    self.ncached=membytes//(self.slide_pixels*self.bpp//8)
    # DEBUG: force only 4 ncached (3 forward, 1 backward)
    self.ncached=6
    #print(self.ncached)
    self.nbackward=self.ncached*self.priority_backward//(self.priority_forward+self.priority_backward)
    self.nforward=self.ncached-self.nbackward;
    #print(self.nforward, self.nbackward, self.nbackward+self.nforward)
    #self.cache_status=[]
    #cache_stat=namedtuple("cache_stat",("n","x","y","x_rd","y_rd","pos"))
    # cache status
    #self.caches_i=[] # index of file in direntries 0..n
    self.caches_x=[] # screen
    self.caches_y=[] # screen
    self.caches_x_rd=[] # file X
    self.caches_y_rd=[] # file Y (starts from 0)
    self.caches_pos=[] # file seek
    # i: slide number
    for i in range(self.ncached):
      #self.cache_status.append(cache_stat(i,self.xres,self.yres,self.xres,0,0))
      #self.caches_i.append(i)
      self.caches_x.append(self.xres)
      self.caches_y.append(self.yres)
      self.caches_x_rd.append(self.xres)
      self.caches_y_rd.append(0)
      self.caches_pos.append(0)
    self.finished=1
    self.file_open=0
    # slide numbers index of direntries, starting from file0
    self.prev_slide_shown=0
    self.reading_slide=0
    self.slide_shown=bytearray(1)
    self.PPM_line_buf=bytearray((self.bpp//8)*self.xres)

  def ctrl(self,i):
    self.cs.on()
    self.spi.write(bytearray([0, 0xFF, 0xFF, 0xFF, 0xFF, i]))
    self.cs.off()

  def peek(self,addr,length):
    self.ctrl(2)
    self.cs.on()
    self.spi.write(bytearray([1,(addr >> 24) & 0xFF, (addr >> 16) & 0xFF, (addr >> 8) & 0xFF, addr & 0xFF, 0]))
    b=bytearray(length)
    self.spi.readinto(b)
    self.cs.off()
    self.ctrl(0)
    return b

  def poke(self,addr,data):
    self.ctrl(2)
    self.cs.on()
    self.spi.write(bytearray([0,(addr >> 24) & 0xFF, (addr >> 16) & 0xFF, (addr >> 8) & 0xFF, addr & 0xFF]))
    self.spi.write(data)
    self.cs.off()
    self.ctrl(0)

def peek(addr,length=1):
  return run.peek(addr,length)

def poke(addr,data):
  run.poke(addr,data)

bitstream="/sd/hdl4fpga/bitstreams/ulx3s_12f_graphic_spi.bit"
try:
  os.mount(SDCard(slot=3),"/sd")
  ecp5.prog(bitstream)
except:
  print(bitstream+" file not found")
gc.collect()
run=osd()
