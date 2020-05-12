all : bin/to16bpp bin/stream bin/stream1 dataset/iguazu.strm

bin/stream : src/stream.c
	gcc -O2 src/stream.c -o bin/stream

bin/stream1 : src/stream1.c
	gcc -O2 src/stream1.c -o bin/stream1

bin/to16bpp : src/to16bpp.c
	gcc -O2 src/to16bpp.c -o bin/to16bpp

dataset/iguazu.strm : bin/to16bpp bin/stream bin/stream1
	./bin/to16bpp < ../../hdl4fpga.pages/images/hdl4fpga/test/iguazufalls800x600.rgb|./bin/stream > ./dataset/iguazu.strm

clean :
	rm -rf ../ULX3S/diamond/demos_tcr.dir
	rm -rf ../ULX3S/diamond/graphics
	rm  bin/to16bpp
	rm  bin/stream
	rm  bin/stream1
