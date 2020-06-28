#!/bin/sh
# helper script to replace std->hdl4fpgapkg in all files
find ../../ -name "*.vhd" -exec sed -i -e "s/hdl4fpga[.]std/hdl4fpga.hdl4fpgapkg/g" {} \;
# edit std.vhd file
cp ../../library/common/std.vhd ../../library/common/hdl4fpgapkg.vhd
sed -i -e "s/std is/hdl4fpgapkg is/g" ../../library/common/hdl4fpgapkg.vhd
