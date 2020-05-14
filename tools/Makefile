all : bin/rgb8to16bpp bin/stream dataset/image.strm

bin/stream : src/stream.c
	cc -O2 src/stream.c -o bin/stream

bin/rgb8to16bpp : src/rgb8to16bpp.c
	cc -O2 src/rgb8to16bpp.c -o bin/rgb8to16bpp

dataset/image.strm : bin/rgb8to16bpp bin/stream dataset/image.rgb
	./bin/rgb8to16bpp < ./dataset/image.rgb|./bin/stream > ./dataset/image.strm

clean :
	rm  ./bin/rgb8to16bpp
	rm  ./bin/stream
	rm  ./dataset/image.strm
