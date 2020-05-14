.PHONY: bin
all : bin/rgb8to16bpp bin/stream

bin/stream : src/stream.c
	mkdir -p bin
	cc -O2 src/stream.c -o bin/stream

bin/rgb8to16bpp : src/rgb8to16bpp.c
	mkdir -p bin
	cc -O2 src/rgb8to16bpp.c -o bin/rgb8to16bpp

clean :
	rm  -rf ./bin
