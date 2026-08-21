make ; make -f Makefile.work
../../boards/ULX3S/diamond/delete_entity.sh ../../boards/ULX3S/diamond/ser_debug/apps_ser_debug_vho.vho ulx3s
vcom  ../../boards/ULX3S/diamond/ser_debug/apps_ser_debug_vho.vho
vsim -sdftyp /du_e=/home/msagre/work/hdl4fpga/boards/ULX3S/diamond/ser_debug/apps_ser_debug_vho.sdf -novopt work.ulx3s_serdebug_structure_md
do wave.do
