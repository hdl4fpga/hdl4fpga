#!/bin/bash
ghdl --gen-makefile --std=02 -P../../../library/ghdl/hdl4fpga -P../../../library/ghdl/ecp5u --workdir=./work --work=work ulx3s > Makefile 
