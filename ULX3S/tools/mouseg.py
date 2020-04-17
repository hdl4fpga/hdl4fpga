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
#udp_port = 57001  # use UDP
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
  rgtr = ((y & 0xFFF)<<12) + (x & 0xFFF)
  return struct.pack(">BBI", 0x15, 3, rgtr)

def mouse_report(dx,dy,dz,btn_left,btn_middle,btn_right):
  return struct.pack(">BBBBBB", 0x0F, 3, (-dz) & 0xFF, (-dy) & 0xFF, dx & 0xFF, (btn_left & 1) + ((btn_right & 1)<<1) + ((btn_middle & 1)<<2))

def print_packet(x):
  for c in x:
    print("%02X" % (c), end='');
  print("")

def packet_grid_color(pid,c):
  return struct.pack(">BBI", 0x11, 3, ((c & 63) << 9) | (pid << 3) | 0x7)

def send_grid_color(c):
  packet = packet_grid_color(0,c)
  if udp_port:
    scopeio_udp.sendto(packet, (udp_host, udp_port))
  else:
    scopeio.write(escape(packet))


pygame.init()
(width, height) = (320, 200)
screen = pygame.display.set_mode((width, height))
pygame.display.set_caption(u'Press ESC or PAUSE to quit')
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
    if event.key == pygame.K_ESCAPE or event.key == pygame.K_PAUSE:
      print("QUIT")
      break
    if event.key == pygame.K_0:
      send_grid_color(0) # black
    if event.key == pygame.K_1:
      send_grid_color(48) # red
    if event.key == pygame.K_2:
      send_grid_color(12) # green
    if event.key == pygame.K_3:
      send_grid_color(6) # blue
    if event.key == pygame.K_4:
      send_grid_color(61) # yellow
    if event.key == pygame.K_5:
      send_grid_color(51) # violet
    if event.key == pygame.K_6:
      send_grid_color(39) # violet2 
    if event.key == pygame.K_7:
      send_grid_color(7)
    if event.key == pygame.K_8:
      send_grid_color(8)
    if event.key == pygame.K_9:
      send_grid_color(9)
    if event.key == pygame.K_a:
      send_grid_color(10)
    if event.key == pygame.K_b:
      send_grid_color(11)
    if event.key == pygame.K_c:
      send_grid_color(12)
    if event.key == pygame.K_d:
      send_grid_color(13)
    if event.key == pygame.K_e:
      send_grid_color(14)
    if event.key == pygame.K_f:
      send_grid_color(15)
    text = str(event.unicode)
    screen.blit(font.render(text, True, (255, 255, 255)), (0, 0))
    pygame.display.flip()
  if event.type == pygame.KEYUP:
    screen.fill((0,0,0))
    pygame.display.flip()

  wheel = 0
  if event.type == pygame.MOUSEBUTTONDOWN: # for wheel events
    if event.button == 4: # wheel UP
      wheel = 1
    if event.button == 5: # wheel DOWN
      wheel = -1
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
