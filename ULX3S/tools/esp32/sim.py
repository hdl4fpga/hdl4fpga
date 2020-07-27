#!/usr/bin/env python3

# pygame simulation to develop cache refill system

import pygame

class demo:
  def __init__(self):
    print("a")
    self.nslides=10 # number images to be displayed
    self.ncache=5 # number of images that can fit in cache
    self.xres=80 # screen hor resolution
    self.yres=60 # screen ver resolution
    self.vi=0 # currently viewed image
    self.cache_li=[] # loading image
    self.cache_ti=[] # top image
    self.cache_ty=[] # top good lines 0..(y-1)
    self.cache_bi=[] # bot image
    self.cache_by=[] # bot good lines y..yres
    for i in range(self.ncache):
      self.cache_li.append(-1)
      self.cache_ti.append(-1)
      self.cache_ty.append(0)
      self.cache_bi.append(-1)
      self.cache_by.append(0)
    self.view()

  def view(self):
    for i in range(self.ncache):
      print("[%2dT%-2d]" % (self.cache_ti[i],self.cache_ty[i]),end="")
    print("")
    for i in range(self.ncache):
      print("[%2d   ]" % (self.cache_li[i]),end="")
    print("")
    for i in range(self.ncache):
      print("[%2dT%-2d]" % (self.cache_bi[i],self.cache_by[i]),end="")
    print("")
    cvi=self.vi%self.ncache
    for i in range(self.ncache):
      mark="      "
      if cvi==i:
        mark="%2d===" % (self.vi)
      print(" %5s" % (mark),end="")
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

while(True):
  event = pygame.event.wait()
  if event.type == pygame.KEYDOWN:
    if event.key == pygame.K_ESCAPE or event.key == pygame.K_PAUSE:
      print("QUIT")
      break
    if event.key == pygame.K_0:
      print(0) # black
    if event.key == pygame.K_1:
      print(1) # red
    if event.key == pygame.K_SPACE: # time passes
      run.view()
    if event.key == pygame.K_LEFT:
      if run.vi>0:
        run.vi-=1
        run.view()
    if event.key == pygame.K_RIGHT:
      if run.vi<run.nslides:
        run.vi+=1
        run.view()
