# Diamond command line project

This project is intended to run Lattice Diamond from
linux command line. Common issue is that Diamond assumes
"sh" is "bash" but on debian/ubuntu it is not the case,
so use "diamond-fix-scripts" to replace it automatically.

Check at scripts/diamond_path.mk
if there is correct path to "Diamond"
(directory path where "Diamond" is installed)

Standard workflow is:

    make clean
    make program        # program FPGA temporarily
    make flash          # write to FPGA config FLASH
