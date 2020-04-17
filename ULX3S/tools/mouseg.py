#!/usr/bin/env python3

# AUTHOR=EMARD
# LICENSE=GPL

# apt-get install fonts-dseg

import pygame
import struct
import serial
import socket

serial_port = "/dev/ttyUSB0"
udp_host = "192.168.18.166"
# udp_port = 57001  # use UDP
udp_port = False  # use SERIAL

if udp_port:
  scopeio_udp = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  print("Sending mouse events to %s:%s" % (udp_host,udp_port))
else:
  scopeio = serial.Serial(serial_port, 115200, timeout=1)
  print("Sending mouse events to serial port %s" % scopeio.name)

# fix packet with header, escapes, trailer
def escape(p):
  retval = struct.pack("BB", 0, 0)
  for char in p:
    if char == 0 or char == 0x5C:
      retval += struct.pack("B", 0x5C)
    retval += struct.pack("B", char)
  retval += struct.pack("B", 0)
  return retval
  
def pointer(x,y):
  rgtr = (y & 0xFFF)*(2**12) + (x & 0xFFF)
  return struct.pack(">BBI", 0x15, 3, rgtr)

def mouse_report(dx,dy,dz,btn_left,btn_middle,btn_right):
  return struct.pack(">BBBBBB", 0x0F, 3, (-dz) & 0xFF, (-dy) & 0xFF, dx & 0xFF, (btn_left & 1) + (btn_right & 1)*(2**1) + (btn_middle & 1)*(2**2))

def print_packet(x):
  for c in x:
    print("%02X" % (c), end='');
  print("")

pygame.init()
(width, height) = (320, 200)
screen = pygame.display.set_mode((width, height))
pygame.display.set_caption(u'Press PAUSE to quit')
pygame.display.flip()
pygame.event.set_grab(True)
pygame.mouse.set_visible(False)
font = pygame.font.SysFont('DSEG14 Classic', height)

# mouse pointer visual feedback
x=0
y=0

while(True):
  event = pygame.event.wait()
  if event.type == pygame.KEYDOWN:
    if event.key == pygame.K_PAUSE:
      print("PAUSE")
      break
    text = str(event.unicode)
    screen.blit(font.render(text, True, (255, 255, 255)), (0, 0))
    pygame.display.flip()
  if event.type == pygame.KEYUP:
    screen.fill((0,0,0))
    pygame.display.flip()

  wheel = 0
  if event.type == pygame.MOUSEBUTTONDOWN: # for wheel events
    if event.button == 4: # wheel UP
      wheel = -1
    if event.button == 5: # wheel DOWN
      wheel = 1
  (dx, dy) = pygame.mouse.get_rel()
  dz = wheel
  (btn_left, btn_middle, btn_right) = pygame.mouse.get_pressed()

  packet = mouse_report(dx, dy, dz, btn_left, btn_middle, btn_right)
  if udp_port:
    scopeio_udp.sendto(packet, (udp_host, udp_port))
  else:
    scopeio.write(escape(packet))

  # visual feedback for mouse
  pygame.draw.line(screen, (0, 0, 0), (x, 0), (x, height-1))
  pygame.draw.line(screen, (0, 0, 0), (0, y), (width-1, y))
  x += dx
  x %= width
  y += dy
  y %= height
  pygame.draw.line(screen, (255, 255, 255), (x, 0), (x, height-1))
  pygame.draw.line(screen, (255, 255, 255), (0, y), (width-1, y))
  pygame.display.flip()
