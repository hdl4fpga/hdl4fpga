.PHONY: bin
all : bin/rgb8topixel bin/format bin/bundle bin/sioahdlc

bin/rgb8topixel : src/rgb8topixel.c
	mkdir -p bin
	cc -O2 src/rgb8topixel.c -o bin/rgb8topixel

bin/format : src/format.c
	mkdir -p bin
	cc -O2 src/format.c -o bin/format

bin/bundle : src/bundle.c
	mkdir -p bin
	cc -O2 src/bundle.c -o bin/bundle

bin/sioahdlc : src/ahdlc.h src/ahdlc.c src/sioahdlc.c
	mkdir -p bin
	cc -O2 src/ahdlc.h src/ahdlc.c src/sioahdlc.c -o bin/sioahdlc

clean :
	rm  -rf ./bin
