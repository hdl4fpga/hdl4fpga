OS := $(shell echo $(OS))

ifeq ($(OS), Windows_NT)
	EXE = .exe
	LIBUSB_PATH    ?= 'E:/libusb/libusb-MinGW-x64'
	LIBUSB_NAME    ?= 'usb-1.0'
	LIBUSB_INCLUDE ?= -I$(LIBUSB_PATH)/include
	LIBUSB_LIBRARY ?= -L$(LIBUSB_PATH)/lib -l$(LIBUSB_NAME)
else
	.PHONY: bin
	UNAME := $(shell unam)
	# include Makefile.posix
endif

all : bin/rgb8topixel$(EXE) bin/format$(EXE) bin/bundle$(EXE) bin/siosend$(EXE) bin/memtest$(EXE) bin/usbtest$(EXE)
	echo $(EXE)

bin :
	mkdir bin

bin/rgb8topixel$(EXE) : bin src/rgb8topixel.c
	gcc -O3 src/rgb8topixel.c -o bin/rgb8topixel

bin/format$(EXE) : bin src/format.c
	gcc -O3 src/format.c -o bin/format

bin/bundle$(EXE) : bin src/bundle.c
	gcc -O3 src/bundle.c -o bin/bundle

bin/usbtest$(EXE) : bin src/usbtest.c src/lfsr.c
	gcc -O3 $(LIBUSB_INCLUDE) src/usbtest.c src/lfsr.c $(LIBUSB_LIBRARY) -o bin/usbtest

bin/siosend$(EXE) : bin src/hdlc.h src/hdlc.c src/siolib.h src/siolib.c src/siosend.c
	gcc -O3 $(LIBUSB_INCLUDE) src/siolib.c src/hdlc.c src/siosend.c -lws2_32 $(LIBUSB_LIBRARY) -o bin/siosend

bin/memtest$(EXE) : bin src/lfsr.h src/lfsr.c src/hdlc.h src/hdlc.c src/siolib.h src/siolib.c src/memtest.c
	gcc -O3 $(LIBUSB_INCLUDE) src/lfsr.c src/siolib.c src/hdlc.c src/memtest.c -lws2_32 $(LIBUSB_LIBRARY) -o bin/memtest

clean :
ifeq ($(OS), Windows_NT)
	del /Q /F /S bin
	rmdir bin
else
	rm  -rf ./bin
endif