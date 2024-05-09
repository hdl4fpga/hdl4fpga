vcom ../../boards/orangecrab/diamond/graphics/apps_graphics_vho.vho
vcom ../../boards/orangecrab/testbenches/graphics.vhd
vsim  +notimingchecks -noglitch -t 10fs -novopt work.orangecrab_graphics_structure_md -sdftyp du_e=../../boards/orangecrab/diamond/graphics/apps_graphics_vho.sdf
do ../../boards/orangecrab/testbenches/graphics_structure.do
