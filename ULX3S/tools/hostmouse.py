#!/usr/bin/env python3

# AUTHOR=EMARD
# LICENSE=GPL

# Reads linux mouse input device (evdev).
# Converts mouse events to scopeio serial commands.
# Currently it can only move mouse pointer.
# Mouse clicks are received but not supported yet.

import evdev
import serial
import struct

# fix packet with header, escapes, trailer
def to_packet(p):
  retval = struct.pack("BB", 0, 0)
  for char in p:
    if char == 0 or char == 0x5C:
      retval += struct.pack("B", 0x5C)
    retval += struct.pack("B", char)
  retval += struct.pack("B", 0)
  return retval
  
def pointer(x,y):
  rgtr = (y & 0xFFF)*(2**12) + (x & 0xFFF)
  return to_packet(struct.pack(">BBI", 0x15, 3, rgtr))

def mouse_report(dx,dy,dz,btn_left,btn_middle,btn_right):
  return to_packet(struct.pack(">BBBBBB", 0x0F, 3, (-dz) & 0xFF, (-dy) & 0xFF, dx & 0xFF, (btn_left & 1) + (btn_right & 1)*(2**1) + (btn_middle & 1)*(2**2)))

def print_packet(x):
  for c in x:
    print("%02X" % (c), end='');
  print("")

if __name__ == '__main__':
    # this string will search for mouse in list of evdev inputs
    # Usually this should match a part of USB mouse device name
    mouse_input_name = 'Mouse'
    # this port is scopeio serial port
    serial_port = '/dev/ttyUSB0'

    X = 0
    Y = 0
    Z = 0
    DX = 0
    DY = 0
    DZ = 0
    BTN_LEFT = 0
    BTN_RIGHT = 0
    BTN_MIDDLE = 0

    DEVICE = None

    DEVICES = [evdev.InputDevice(fn) for fn in evdev.list_devices()]

    for d in DEVICES:
        if mouse_input_name in d.name:
            DEVICE = d
            print('Found %s at %s...' % (d.name, d.path))
            break


    if DEVICE:
        scopeio = serial.Serial(serial_port, 115200, timeout=1)
        print("Sending mouse events to serial port %s" % scopeio.name)
        print('Started listening to device')
        for event in DEVICE.read_loop():
            if event.type == evdev.ecodes.EV_REL:
                if event.code == evdev.ecodes.REL_X:
                    DX = event.value
                    X += DX
                if event.code == evdev.ecodes.REL_Y:
                    DY = event.value
                    Y += DY
                if event.code == evdev.ecodes.REL_WHEEL:
                    DZ = event.value
                    Z += DZ
                #print('X=%d Y=%d Z=%d' % (X, Y, Z))
                #packet = pointer(X,Y)
                packet = mouse_report(DX,DY,DZ,BTN_LEFT,BTN_MIDDLE,BTN_RIGHT)
                DZ = 0
                DX = 0
                DY = 0
                #print_packet(packet)
                scopeio.write(packet)

            if event.type == evdev.ecodes.EV_KEY:
                if event.code == evdev.ecodes.ecodes['BTN_LEFT']:
                    BTN_LEFT = event.value
                if event.code == evdev.ecodes.ecodes['BTN_MIDDLE']:
                    BTN_MIDDLE = event.value
                if event.code == evdev.ecodes.ecodes['BTN_RIGHT']:
                    BTN_RIGHT = event.value
                #print('BTN_LEFT=%d BTN_MIDDLE=%d BTN_RIGHT=%d' % (BTN_LEFT, BTN_MIDDLE, BTN_RIGHT))
                packet = mouse_report(0,0,0,BTN_LEFT,BTN_MIDDLE,BTN_RIGHT)
                #print_packet(packet)
                scopeio.write(packet)
