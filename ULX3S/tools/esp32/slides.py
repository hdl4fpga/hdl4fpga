# micropython ESP32
# OSD SPI loader

# press 4 arrows, OSD will appear
# navigate to SD directory with only *.h4f files
# select one file and press right arrow
# press left/right to switch slides

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
          p8slide = ptr8(addressof(self.slide_shown))
          if btn==33: # btn5 cursor left
            if p8slide[0]>0:
              p8slide[0]-=1
              self.move(-1)
              #self.view()
          if btn==65: # btn6 cursor right
            if p8slide[0]<int(self.nslides)-1:
              p8slide[0]+=1
              self.move(1)
              #self.view()
          if btn==3: # btn1 F1
            self.view()
          self.cs.on()
          self.h4f.rgtr(0x19,self.h4f.i24(int(self.slide_pixels)*(p8slide[0]%int(self.ncache))))
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

  def bgreader_old(self,timer):
    if self.finished>0 or self.reading_slide<0:
      self.timer.deinit()
      return
    # if we are not finished, we get here
    reading_slide=self.reading_slide%self.ncache
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
        dc=(self.slide_shown[0]+self.ncache-self.nbackward)%self.ncache
        n=self.prev_slide_shown-self.slide_shown[0]
      else:
        dc=(self.prev_slide_shown+self.nforward)%self.ncache
        n=self.slide_shown[0]-self.prev_slide_shown
      # TODO: improve discarding condition,
      # discarding this is not always neccessary
      for i in range(n):
        if dc==reading_slide:
          must_close=1
          restore_pos=0
        self.caches_pos[dc]=0
        self.caches_y_rd[dc]=0
        dc=(dc+1)%self.ncache
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
      before_first=self.nbackward-self.slide_shown[0]
      if before_first<0:
        before_first=0
      after_last=self.slide_shown[0]+self.nforward-self.nslides
      if after_last<0:
        after_last=0
      print("before_first=%d after_last=%d" % (before_first,after_last))
      next_forward_slide=-1
      i=self.slide_shown[0]
      n=i+self.nforward+before_first-after_last
      if n<0:
        n=0
      if n>self.nslides:
        n=self.nslides
      while i<n:
        ic=i%self.ncache
        if self.caches_y_rd[ic]<self.caches_y[ic]:
          next_forward_slide=i
          break
        i+=1
      next_backward_slide=-1
      i=self.slide_shown[0]-1
      n=i-self.nbackward-after_last+before_first
      if n<0:
        n=0
      if n>self.nslides:
        n=self.nslides
      while i>=n:
        ic=i%self.ncache
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
      if filename.endswith(".h4f"):
        self.h4f.load_hdl4fpga_image(open(filename,"rb"),self.slide_shown[0]%self.ncache*self.slide_pixels)
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
    self.nslides=self.nfiles
    gc.collect()

  # *** SLIDESHOW ***
  # self.direntries, self.file0
  def init_slides(self):
    self.xres=800
    self.yres=600
    self.bpp=16
    membytes=32*1024*1024
    self.slide_pixels=self.xres*self.yres
    self.ncache=membytes//(self.slide_pixels*self.bpp//8)
    self.ncache=7 # NOTE DEBUG
    self.priority_forward=2
    self.priority_backward=1
    self.nbackward=self.ncache*self.priority_backward//(self.priority_forward+self.priority_backward)
    self.nforward=self.ncache-self.nbackward;
    #print(self.nforward, self.nbackward, self.nbackward+self.nforward)
    self.rdi=0 # currently reading image
    self.vi=0 # currently viewed image
    self.cache_li=[] # image to be loaded
    self.cache_ti=[] # top image
    self.cache_ty=[] # top good lines 0..(y-1)
    self.cache_tyend=[] # top y load max
    self.cache_bi=[] # bot image
    self.cache_by=[] # bot good lines y..yres
    for i in range(self.ncache):
      self.cache_li.append(i)
      self.cache_ti.append(-1)
      self.cache_ty.append(0)
      self.cache_tyend.append(self.yres)
      self.cache_bi.append(-1)
      self.cache_by.append(0)
    self.bg_file=None
    self.slide_shown=bytearray(1)
    self.PPM_line_buf=bytearray((self.bpp//8)*self.xres)
    self.finished=1

  def start_bgreader(self):
    #print("start bgreader",self.slide_shown[0])
    #return
    if self.finished:
      self.finished=0
      self.rdi=self.slide_shown[0]
      self.timer.init(mode=Timer.PERIODIC, period=15, callback=self.bgreader)

  # image to be discarded at changed view
  def next_to_discard(self):
    return (self.vi+self.nforward-1)%self.ncache

  # choose next, ordered by priority
  def next_to_read(self):
    before_first=self.nbackward-self.vi
    if before_first<0:
      before_first=0
    after_last=self.vi+self.nforward-self.nslides
    if after_last<0:
      after_last=0
    #print("before_first=%d after_last=%d" % (before_first,after_last))
    next_forward_slide=-1
    i=self.vi
    n=i+self.nforward+before_first-after_last
    if n<0:
      n=0
    if n>self.nslides:
      n=self.nslides
    while i<n:
      ic=i%self.ncache
      if self.cache_ti[ic]!=self.cache_li[ic] \
      or self.cache_ty[ic]<self.yres:
        next_forward_slide=i
        break
      i+=1
    next_backward_slide=-1
    i=self.vi-1
    n=i-self.nbackward-after_last+before_first
    if n<0:
      n=0
    if n>self.nslides:
      n=self.nslides
    while i>=n:
      ic=i%self.ncache
      if self.cache_ti[ic]!=self.cache_li[ic] \
      or self.cache_ty[ic]<self.yres:
        next_backward_slide=i
        break
      i-=1
    next_reading_slide=-1
    if next_forward_slide>=0 and next_backward_slide>=0:
      if (next_forward_slide-self.vi)*self.priority_backward < \
        (self.vi-next_backward_slide)*self.priority_forward:
        next_reading_slide=next_forward_slide
      else:
        next_reading_slide=next_backward_slide
    else:
      if next_forward_slide>=0:
        next_reading_slide=next_forward_slide
      else:
        if next_backward_slide>=0:
          next_reading_slide=next_backward_slide
    return next_reading_slide

  # which image to replace after a move
  def replace(self,mv):
    dc_replace=-1
    if mv>0:
      dc_replace=self.vi+self.nforward-1
      if dc_replace>=self.nslides:
        dc_replace-=self.ncache
    if mv<0:
      dc_replace=(self.vi-self.nbackward-1)
      if dc_replace<0:
        dc_replace+=self.ncache
    return dc_replace

  # move with discarding images in cache
  def move(self,mv):
    vi=self.vi+mv
    if vi<0 or vi>self.nslides or mv==0:
      return
    self.cache_li[self.next_to_discard()]=self.replace(mv)
    self.vi+=mv
    self.cache_li[self.next_to_discard()]=self.replace(mv)
    self.rdi=self.next_to_read()

  # file should be already closed when calling this
  def next_file(self):
    #print("next_file")
    filename=self.fullpath(self.direntries[self.file0+self.rdi][0])
    self.bg_file=open(filename,"rb")
    # Y->seek to first position to read from
    bytpp=self.bpp//8 # in file
    rdi=self.rdi%self.ncache
    self.bg_file.seek(bytpp*self.xres*self.cache_li[rdi])
    print("%d RD %s" % (self.rdi,filename))

  def read_scanline(self):
    bytpp=self.bpp//8 # on screen
    rdi=self.rdi%self.ncache
    self.bg_file.readinto(self.PPM_line_buf)
    # write PPM_line_buf to screen
    addr=self.xres*(rdi*self.yres+self.cache_ty[rdi])
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

  # background read, call it periodically
  def bgreader(self):
    if self.rdi<0:
      self.finished=1
      self.timer.deinit()
      return
    rdi=self.rdi%self.ncache
    if self.cache_ti[rdi]!=self.cache_li[rdi]:
      # cache contains different image than the one to be loaded
      # y begin from top
      self.cache_ti[rdi]=self.cache_li[rdi]
      self.cache_ty[rdi]=0
      # y end depends on cache content
      # if bottom part is already in cache, reduce tyend
      if self.cache_bi[rdi]==self.cache_ti[rdi]:
        self.cache_tyend[rdi]=self.cache_by[rdi]
      else:
        self.cache_tyend[rdi]=self.yres
    if self.bg_file==None:
      self.next_file()
    if self.cache_ty[rdi]<self.cache_tyend[rdi]:
      # file read
      self.read_scanline()
      self.cache_ty[rdi]+=1
      if self.cache_ty[rdi]>self.cache_by[rdi]:
        self.cache_by[rdi]=self.cache_ty[rdi]
    if self.cache_ty[rdi]>=self.cache_tyend[rdi]:
      # slide complete, close file, find next
      self.cache_ty[rdi]=self.yres
      self.cache_bi[rdi]=self.cache_li[rdi]
      self.cache_by[rdi]=0
      self.bg_file=None
      self.rdi=self.next_to_read()
      if self.rdi<0:
        self.finished=1
        self.timer.deinit()

  # visualize current cache content
  def view(self):
    dci=self.next_to_discard()
    rdi=self.rdi%self.ncache
    for i in range(self.ncache):
      print("[%2dT%-2d]" % (self.cache_ti[i],self.cache_ty[i]//10),end="")
    print("")
    for i in range(self.ncache):
      print("[%2d   ]" % (self.cache_li[i]),end="")
    print("")
    for i in range(self.ncache):
      print("[%2dB%-2d]" % (self.cache_bi[i],self.cache_by[i]//10),end="")
    print("")
    cvi=self.vi%self.ncache
    for i in range(self.ncache):
      mark="       "
      if i==dci:
        mark=" %2s^^^ " % (i)
      if i==cvi:
        mark=" %2d=== " % (self.vi)
      if self.rdi>=0:
        if i==rdi:
          mark=mark[0:3]+"*"+mark[4:]
      print(mark,end="")
    print("")


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

bitstream="/sd/hdl4fpga/bitstreams/ulx3s_12f_graphics_spi.bit"
#bitstream="none"
try:
  os.mount(SDCard(slot=3),"/sd")
  ecp5.prog(bitstream)
except:
  print(bitstream+" file not found")
gc.collect()
run=osd()
