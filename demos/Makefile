.PHONY: bin
all : bin/rgb8topixel bin/format bin/stream bin/sendbyudp

bin/stream : src/stream.c
	mkdir -p bin
	cc -O2 src/stream.c -o bin/stream

bin/rgb8topixel : src/rgb8topixel.c
	mkdir -p bin
	cc -O2 src/rgb8topixel.c -o bin/rgb8topixel

bin/format : src/format.c
	mkdir -p bin
	cc -O2 src/format.c -o bin/format

bin/sendbyudp : src/sendbyudp.c
	mkdir -p bin
	cc -O2 src/sendbyudp.c -o bin/sendbyudp

clean :
	rm  -rf ./bin
