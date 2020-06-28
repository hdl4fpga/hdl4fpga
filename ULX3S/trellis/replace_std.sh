#!/bin/sh
# helper script to replace std->hdl4fpgapkg in all files
find ../../library -name "*.vhd" -exec sed -i -e "s/hdl4fpga[.]std/hdl4fpga.hdl4fpgapkg/g" {} \;
find ../scopeio    -name "*.vhd" -exec sed -i -e "s/hdl4fpga[.]std/hdl4fpga.hdl4fpgapkg/g" {} \;
