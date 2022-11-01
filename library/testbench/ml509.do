vcom ../../boards/ml509/ise/graphics/netgen/par/ml509_timesim.vhd 
vsim +notimingchecks -novopt work.ml509_graphics_structure_md -sdftyp du_e=../../boards/ml509/ise/graphics/netgen/par/ml509_timesim.sdf
do ../../boards/ml509/apps/demos/testbenches/graphics_structure.do
run 40 us
