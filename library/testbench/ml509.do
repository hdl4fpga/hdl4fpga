vcom ../../boards/ml509/ise/graphics/netgen/par/ml509_timesim.vhd 
vsim +notimingchecks -novopt -sdftyp du_e=../../boards/ml509/ise/graphics/netgen/par/ml509_timesim.sdf
do ../../boards/ml509/apps/demos/testbenches/graphics.do
run 40 us
