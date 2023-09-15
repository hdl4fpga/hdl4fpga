.PHONY: bin

all : bin/rgb8topixel bin/format bin/bundle bin/siosend bin/memtest bin/usbtest

bin/rgb8topixel : src/rgb8topixel.c
	mkdir -p bin
	cc -O3 src/rgb8topixel.c -o bin/rgb8topixel

bin/format : src/format.c
	mkdir -p bin
	cc -O3 src/format.c -o bin/format

bin/bundle : src/bundle.c
	mkdir -p bin
	cc -O3 src/bundle.c -o bin/bundle

bin/siosend : src/hdlc.h src/hdlc.c src/siolib.h src/siolib.c src/siosend.c
	mkdir -p bin
	cc -O3 src/siolib.c src/hdlc.c src/siosend.c -o bin/siosend -lusb-1.0

bin/memtest : src/lfsr.h src/lfsr.c src/hdlc.h src/hdlc.c src/siolib.h src/siolib.c src/memtest.c
	mkdir -p bin
	cc -O3 src/lfsr.c src/siolib.c src/hdlc.c src/memtest.c -o bin/memtest -lusb-1.0

bin/usbtest : src/usbtest.c src/lfsr.c
	gcc -O3 src/usbtest.c src/lfsr.c -o bin/usbtest -lusb-1.0

WINDOWS_LIBUSB_DIR = E:/libusb/libusb-MinGW-x64
bin\usbtest.exe : src/usbtest.c src/lfsr.c
	gcc -O3 -I$(WINDOWS_LIBUSB_DIR)/include src/usbtest.c src/lfsr.c -L$(WINDOWS_LIBUSB_DIR)/lib -l"usb-1.0" -o bin/usbtest.exe

bin\siosend.exe : src/hdlc.h src/hdlc.c src/siolib.h src/siolib.c src/siosend.c
	gcc -O3 -I$(WINDOWS_LIBUSB_DIR)/include src/siolib.c src/hdlc.c src/siosend.c -L$(WINDOWS_LIBUSB_DIR)/lib -l"usb-1.0" -lws2_32 -o bin/siosend.exe

clean :
	rm  -rf ./bin
