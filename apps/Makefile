OS := $(shell echo $(OS))

ifeq ($(OS), Windows_NT)
	EXE = .exe
	LIBUSB_PATH    ?= '.'
	LIBUSB_NAME    ?= 'usb-1.0'
	LIBUSB_INCLUDE ?= -I$(LIBUSB_PATH)/include
	LIBUSB_LIBRARY ?= -L$(LIBUSB_PATH)/lib -l$(LIBUSB_NAME) -static
	WSOCK          ?= -lws2_32
else
	UNAME := $(shell uname)
	LIBUSB_NAME    ?= usb-1.0
	LIBUSB_LIBRARY ?= -l$(LIBUSB_NAME)
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
	gcc -O3 $(LIBUSB_INCLUDE) src/usbtest.c src/lfsr.c $(LIBUSB_LIBRARY) -o bin/usbtest

bin/siosend$(EXE) : src/hdlc.h src/hdlc.c src/siolib.h src/siolib.c src/siosend.c
	gcc -O3 $(LIBUSB_INCLUDE) src/siolib.c src/hdlc.c src/siosend.c $(WSOCK) $(LIBUSB_LIBRARY) -o bin/siosend

bin/memtest$(EXE) : src/lfsr.h src/lfsr.c src/hdlc.h src/hdlc.c src/siolib.h src/siolib.c src/memtest.c
	gcc -O3 $(LIBUSB_INCLUDE) src/lfsr.c src/siolib.c src/hdlc.c src/memtest.c $(WSOCK) $(LIBUSB_LIBRARY) -o bin/memtest

clean :
ifeq ($(OS), Windows_NT)
	del /Q /F /S bin
	rmdir bin
else
	rm  -rf ./bin
endif
