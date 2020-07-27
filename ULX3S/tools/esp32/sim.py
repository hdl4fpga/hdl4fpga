#!/usr/bin/env python3

# pygame simulation to develop cache refill system

import pygame

class demo:
  def __init__(self):
    self.nslides=13 # number images to be displayed
    self.ncache=7 # number of images that can fit in cache
    self.xres=8 # screen hor resolution
    self.yres=6 # screen ver resolution

    self.priority_forward=2
    self.priority_backward=1
    self.nbackward=self.ncache*self.priority_backward//(self.priority_forward+self.priority_backward)
    self.nforward=self.ncache-self.nbackward;
    print(self.nforward, self.nbackward, self.nbackward+self.nforward)
    self.rdi=0 # currently reading image
    self.vi=0 # currently viewed image
    self.cache_li=[] # image to be loaded
    self.cache_ti=[] # top image
    self.cache_ty=[] # top good lines 0..(y-1)
    self.cache_bi=[] # bot image
    self.cache_by=[] # bot good lines y..yres
    for i in range(self.ncache):
      self.cache_li.append(i)
      self.cache_ti.append(-1)
      self.cache_ty.append(0)
      self.cache_bi.append(-1)
      self.cache_by.append(0)
    self.view()

  # image to be discarded at changed view
  def next_to_discard(self):
    return (self.vi+self.nforward-1)%self.ncache

  # consider priority
  def next_to_read(self):
    # TODO priority reading: decide which slide is next
    # finish if no more slides to read
    before_first=self.nbackward-self.vi
    if before_first<0:
      before_first=0
    after_last=self.vi+self.nforward-self.nslides
    if after_last<0:
      after_last=0
    #print("before_first=%d after_last=%d" % (before_first,after_last))
    #return -1
    next_forward_slide=-1
    i=self.vi
    n=i+self.nforward+before_first-after_last
    if n<0:
      n=0
    if n>self.nslides:
      n=self.nslides
    while i<n:
      ic=i%self.ncache
      if self.cache_ti[ic]!=self.cache_li[ic]:
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
      if self.cache_ti[ic]!=self.cache_li[ic]:
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


  def move(self,mv):
    self.vi+=mv
    dci=self.next_to_discard()
    dc_replace=-2
    if mv>0:
      dc_replace=self.vi+self.nforward-1
      if dc_replace>=self.nslides:
        dc_replace-=self.ncache
    if mv<0:
      dc_replace=(self.vi-self.nbackward-1)
      if dc_replace<0:
        dc_replace+=self.ncache
    self.cache_li[dci]=dc_replace
    self.rdi=self.next_to_read()

  def bgreader(self):
    if self.rdi<0:
      return
    rdi=self.rdi%self.ncache
    if self.cache_ti[rdi]!=self.cache_li[rdi]:
      self.cache_ti[rdi]=self.cache_li[rdi]
      self.cache_ty[rdi]=0
    if self.cache_ty[rdi]<self.yres:
      self.cache_ty[rdi]+=1
    else:
      self.rdi=self.next_to_read()

  def view(self):
    dci=self.next_to_discard()
    rdi=self.rdi%self.ncache
    for i in range(self.ncache):
      print("[%2dT%-2d]" % (self.cache_ti[i],self.cache_ty[i]),end="")
    print("")
    for i in range(self.ncache):
      print("[%2d   ]" % (self.cache_li[i]),end="")
    print("")
    for i in range(self.ncache):
      print("[%2dB%-2d]" % (self.cache_bi[i],self.cache_by[i]),end="")
    print("")
    cvi=self.vi%self.ncache
    for i in range(self.ncache):
      #     1234567
      mark="       "
      if i==dci:
        mark=" %2s^^^ " % (i)
      if i==cvi:
        mark=" %2d=== " % (self.vi)
      if self.rdi>=0:
        if i==rdi:
          mark="*"+mark[1:]
      print(mark,end="")
    print("")

run=demo()

pygame.init()
(width, height) = (320, 200)
screen = pygame.display.set_mode((width, height))
pygame.display.set_caption(u'Press ESC or PAUSE to quit')
pygame.display.flip()
#pygame.event.set_grab(True)
pygame.mouse.set_visible(False)
font = pygame.font.SysFont('DSEG14 Classic', height)
#pygame.time.set_timer(pygame.USEREVENT,1000)

while(True):
  event = pygame.event.wait()
  if event.type == pygame.KEYDOWN:
    if event.key == pygame.K_ESCAPE or event.key == pygame.K_PAUSE or event.key == pygame.K_q:
      print("QUIT")
      break
    if event.key == pygame.K_0:
      print(0) # black
    if event.key == pygame.K_1:
      print(1) # red
    if event.key == pygame.K_SPACE: # time passes
      run.bgreader()
      run.view()
    if event.key == pygame.K_LEFT:
      if run.vi>0:
        run.move(-1)
        run.view()
    if event.key == pygame.K_RIGHT:
      if run.vi<run.nslides-1:
        run.move(1)
        run.view()
  if event.type == pygame.USEREVENT: # NOTE TIMER
    run.view()
