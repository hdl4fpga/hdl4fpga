PROJ=scopeio

all: $(PROJ).bit

FPGA_SIZE=85

$(PROJ).json: synth.ys Makefile
	yosys -q synth.ys

$(PROJ).config: $(PROJ).json
	nextpnr-ecp5 --router router2 --json $(PROJ).json \
	--$(FPGA_SIZE)k --speed 6 --package CABGA381 \
	--lpf $(CONSTRAINTS) \
	--timing-allow-fail --no-tmdriv \
	--textcfg $@

$(PROJ).bit: $(PROJ).config
	ecppack --compress $< $@

prog: $(PROJ).bit
	fujprog $<

clean:
	rm -f $(PROJ).bit $(PROJ).config $(PROJ).json *~
