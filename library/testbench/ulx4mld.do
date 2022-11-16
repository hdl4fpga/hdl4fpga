vcom ../../boards/ULX4M/diamond/graphics/demos_graphics_vho.vho
vcom ../../boards/ULX4M/apps/demos/testbenches/graphics.vhd
vsim  +notimingchecks -noglitch -t 10fs -novopt work.ulx4mld_graphics_structure_md -sdftyp du_e=../../boards/ULX4M/diamond/graphics/demos_graphics_vho.sdf
do ../../boards/ULX4M/apps/demos/testbenches/graphics.do
