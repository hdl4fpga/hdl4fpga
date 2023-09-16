OS := $(shell echo $(OS))

ifeq ($(OS), Windows_NT)
	EXE = .exe
	LIBUSB_DIR  ?= 'E:/libusb/libusb-MinGW-x64'
	LIBUSB_NAME ?= 'usb-1.0'
else
	.PHONY: bin
	UNAME := $(shell unam)
	# include Makefile.posix
endif

all : bin bin/rgb8topixel$(EXE) bin/format$(EXE) bin/bundle$(EXE) bin/siosend$(EXE) bin/memtest$(EXE) bin/usbtest$(EXE)

bin : 
	mkdir bin

bin/rgb8topixel$(EXE) : src/rgb8topixel.c
	gcc -O3 src/rgb8topixel.c -o bin/rgb8topixel

bin/format$(EXE) : src/format.c
	gcc -O3 src/format.c -o bin/format

bin/bundle$(EXE) : src/bundle.c
	gcc -O3 src/bundle.c -o bin/bundle

bin/usbtest$(EXE) : src/usbtest.c src/lfsr.c
	gcc -O3 -I$(LIBUSB_DIR)/include src/usbtest.c src/lfsr.c -L$(LIBUSB_DIR)/lib -l$(LIBUSB_NAME) -o bin/usbtest

bin/siosend$(EXE) : src/hdlc.h src/hdlc.c src/siolib.h src/siolib.c src/siosend.c
	gcc -O3 -I$(LIBUSB_DIR)/include src/siolib.c src/hdlc.c src/siosend.c -L$(LIBUSB_DIR)/lib -l$(LIBUSB_NAME) -lws2_32 -o bin/siosend

bin/memtest$(EXE) : src/lfsr.h src/lfsr.c src/hdlc.h src/hdlc.c src/siolib.h src/siolib.c src/memtest.c
	gcc -O3 -I$(LIBUSB_DIR)/include src/lfsr.c src/siolib.c src/hdlc.c src/memtest.c -L$(LIBUSB_DIR)/lib -l$(LIBUSB_NAME) -lws2_32 -o bin/memtest

clean :
ifeq ($(OS), Windows_NT)
	del /Q /F /S bin
else
	rm  -rf ./bin
endif

