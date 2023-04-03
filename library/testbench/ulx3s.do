vcom ../../boards/ULX3S/diamond/graphics/demos_graphics_vho.vho
vcom ../../boards/ULX3S/apps/demos/testbenches/graphics.vhd
vsim  +notimingchecks -noglitch -t 10fs -novopt work.ulx3s_graphics_structure_md -sdftyp du_e=../../boards/ULX3S/diamond/graphics/demos_graphics_vho.sdf
do ../../boards/ULX3S/apps/demos/testbenches/graphics_structure.do
