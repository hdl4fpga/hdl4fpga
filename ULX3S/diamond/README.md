# Diamond project for ULX3S

Default video resolution is 1280x768 @60Hz.
If it doesn't work, try to compile for 800x600 @60Hz.
On some monitors/TVs 1920@1080 @30Hz would be displayed.
With some luck and overclock, it might be possible to 
get 1280x1024 @60Hz.

Control over serial port works at US1 port.
Default port setting is 115200,8N1.
Probably it might be recompiled to work up to 3M baud.

Control over PS/2 mouse works at US2 port. 
Use USB-OTG (micro USB to female normal USB) adapter
to connect USB+PS/2 combo mouse and additional
PS/2 to USB adapter to connect PS/2 mouse.

Mouse models known to work:

    Logitech optical wheel M-BT58   (USB+PS/2)
    Logitech optical wheel M-BAD58B (USB+PS/2)
    Logitech mechanical 3-btn no wheel  (PS/2)
    Microsoft optical IntelliMouse  (USB+PS/2)

# compile from GUI

Run diamond GUI and load this project:

    ulx3s_12f_scope.ldf

Resulting bitstream to be uploaded to FPGA will be
saved as "*.bit" file.

# Compile from command line

This project can also run Lattice Diamond from
linux command line.

Common issue is that Diamond assumes
"sh" is "bash" but on debian/ubuntu it is not the case,
so use "diamond-fix-scripts" to replace it automatically.

Check at scripts/diamond_path.mk
if there is correct path to "Diamond"
(directory path where "Diamond" is installed)

Standard workflow for 1280x768 @60Hz is:

    make clean
    make program        # program FPGA temporarily
    make flash          # write to FPGA config FLASH

for other resolutions, change constant "vlayout_id"
in the file "../scopeio/scopeio.vhd" and use different
makefile:

    make -f makefile-800x600.diamond
    make -f makefile-1280x1024.diamond
    make -f makefile-1920x1080.diamond

