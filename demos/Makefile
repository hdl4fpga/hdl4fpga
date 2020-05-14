.PHONY: bin
all : bin/rgb8torgb565 bin/fmt16bits bin/stream

bin/stream : src/stream.c
	mkdir -p bin
	cc -O2 src/stream.c -o bin/stream

bin/rgb8torgb565 : src/rgb8torgb565.c
	mkdir -p bin
	cc -O2 src/rgb8torgb565.c -o bin/rgb8torgb565

bin/fmt16bits : src/fmt16bits.c
	mkdir -p bin
	cc -O2 src/fmt16bits.c -o bin/fmt16bits

clean :
	rm  -rf ./bin
