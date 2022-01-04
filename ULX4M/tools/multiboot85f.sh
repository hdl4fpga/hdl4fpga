#!/bin/sh
LANG=C LD_LIBRARY_PATH=/mt/scratch/tmp/openfpga/prjtrellis/libtrellis /mt/scratch/tmp/openfpga/prjtrellis/libtrellis/ecpmulti \
  --db /mt/scratch/tmp/openfpga/prjtrellis/database \
  --flashsize 128 \
  --input-idcode 0x41113043 \
  --input /tmp/ulx3s_85f_scope_oled.bit \
  --input /tmp/ulx3s_85f_scope_dvi.bit --address 0x200000 \
  --output-idcode 0x41113043 \
  --output /tmp/ulx3s_85f_scope_oled_dvi.bit
