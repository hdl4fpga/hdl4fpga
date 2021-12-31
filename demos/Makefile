.PHONY: bin
all : bin/rgb8topixel bin/format bin/bundle bin/siosend bin/memtest

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
	cc -O3 src/siolib.c src/hdlc.c src/siosend.c -o bin/siosend

bin/memtest : src/hdlc.h src/hdlc.c src/siolib.h src/siolib.c src/memtest.c
	mkdir -p bin
	cc -O3 src/siolib.c src/hdlc.c src/memtest.c -o bin/memtest

clean :
	rm  -rf ./bin
