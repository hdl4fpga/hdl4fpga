# Diamond command line project

This project is intended to run Lattice Diamond from
linux command line. Common issue is that Diamond assumes
sh is bash but on debian/ubuntu it is not the case,
so use "diamond-fix-scripts" to replace it automatically.

original sources use library "hdl4fpga" but makefile scripts
her generate diamond ".ldf" project without tagging of some 
files as libraries, so current workaround is to rename all 
"hdl4fpga." -> "work.", automatic renamer sed script
is in "change-hdl4fpga-to-work" directory

Check if there is corrent path to Diamond (directory where it is installed)
at scripts/diamond_path.mk

Standard workflow is:

    make clean
    make program        # program FPGA temporarily
    make flash          # write to FPGA config FLASH
