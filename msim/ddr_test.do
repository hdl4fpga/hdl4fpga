onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/rst
add wave -noupdate -format Logic /testbench/cke
add wave -noupdate -format Logic /testbench/cs_n
add wave -noupdate -format Logic /testbench/clk_n
add wave -noupdate -format Logic /testbench/ras_n
add wave -noupdate -format Logic /testbench/cas_n
add wave -noupdate -format Logic /testbench/we_n
add wave -noupdate -format Literal -radix hexadecimal /testbench/addr
add wave -noupdate -format Literal -radix hexadecimal /testbench/ba
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/clk0
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/clk90
add wave -noupdate -format Logic /testbench/clk_p
add wave -noupdate -format Literal /testbench/dqs
add wave -noupdate -format Literal -radix hexadecimal /testbench/dq
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/clk0
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/led18_o
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/led8_o
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Literal /testbench/nuhs3dsp_e/ddr_du_e_ddr_acc_du_ac_timer
add wave -noupdate -format Literal /testbench/nuhs3dsp_e/ddr_du_e_ddr_acc_du_bl_timer
add wave -noupdate -format Literal /testbench/nuhs3dsp_e/ddr_du_e_ddr_acc_du_cl_timer
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_st_lp_dqs
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {New Group} -format Logic /testbench/nuhs3dsp_e/led7
add wave -noupdate -expand -group {New Group} -format Logic /testbench/nuhs3dsp_e/led8
add wave -noupdate -expand -group {New Group} -format Logic /testbench/nuhs3dsp_e/led9
add wave -noupdate -expand -group {New Group} -format Logic /testbench/nuhs3dsp_e/led11
add wave -noupdate -expand -group {New Group} -format Logic /testbench/nuhs3dsp_e/led13
add wave -noupdate -expand -group {New Group} -format Logic /testbench/nuhs3dsp_e/led15
add wave -noupdate -expand -group {New Group} -format Logic /testbench/nuhs3dsp_e/led16
add wave -noupdate -expand -group {New Group} -format Logic /testbench/nuhs3dsp_e/led18
add wave -noupdate -divider -height 100 {New Divider}
add wave -noupdate -format Logic /testbench/ddr_lp_dqs
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_st_lp_dqs_ibuf_0
add wave -noupdate -format Literal /testbench/dqs
add wave -noupdate -divider -height 100 {New Divider}
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/led8_o
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_st_lp_dqs
add wave -noupdate -format Literal -expand /testbench/dm
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {388286072 ps} 0} {{Cursor 2} {398615713 ps} 0}
configure wave -namecolwidth 354
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {397990859 ps} {399953931 ps}
