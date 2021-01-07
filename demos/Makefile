.PHONY: bin
all : bin/rgb8topixel bin/format bin/bundle bin/sendbyahdlc bin/sendbyudp

bin/rgb8topixel : src/rgb8topixel.c
	mkdir -p bin
	cc -O2 src/rgb8topixel.c -o bin/rgb8topixel

bin/format : src/format.c
	mkdir -p bin
	cc -O2 src/format.c -o bin/format

bin/bundle : src/bundle.c
	mkdir -p bin
	cc -O2 src/bundle.c -o bin/bundle

bin/sendbyudp : src/sendbyudp.c
	mkdir -p bin
	cc -O2 src/sendbyudp.c -o bin/sendbyudp

bin/sendbyahdlc : src/ahdlc.h src/ahdlc.c src/sendbyahdlc.c
	mkdir -p bin
	cc -O2 src/ahdlc.h src/ahdlc.c src/sendbyahdlc.c -o bin/sendbyahdlc

clean :
	rm  -rf ./bin
