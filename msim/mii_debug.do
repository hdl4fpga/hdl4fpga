onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -radix hexadecimal /testbench/clk
add wave -noupdate -format Logic -radix hexadecimal /testbench/mii_col
add wave -noupdate -format Logic -radix hexadecimal /testbench/mii_crs
add wave -noupdate -format Logic -radix hexadecimal /testbench/mii_refclk
add wave -noupdate -format Logic -radix hexadecimal /testbench/mii_rst
add wave -noupdate -format Logic -radix hexadecimal /testbench/mii_rxc
add wave -noupdate -format Literal -radix hexadecimal /testbench/mii_rxd
add wave -noupdate -format Logic -radix hexadecimal /testbench/mii_rxdv
add wave -noupdate -format Logic -radix hexadecimal /testbench/mii_rxer
add wave -noupdate -format Logic -radix hexadecimal /testbench/rst
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/mii_sys_a
add wave -noupdate -format Logic -radix hexadecimal /testbench/nuhs3dsp_e/mii_sys_clk
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/mii_sys_data
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/mii_sys_len
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic -radix hexadecimal /testbench/nuhs3dsp_e/mii_sys_rdy
add wave -noupdate -format Logic -radix hexadecimal /testbench/nuhs3dsp_e/sa_sys_rdy
add wave -noupdate -format Logic -radix hexadecimal /testbench/nuhs3dsp_e/mii_sys_req
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_sys_req
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_sys_ini
add wave -noupdate -format Logic -radix hexadecimal /testbench/nuhs3dsp_e/sa_sys_clk
add wave -noupdate -format Literal -radix ascii /testbench/nuhs3dsp_e/sa_sys_data
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sys_tmng_rdy
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sys_tmng_req
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sa_timing_e/sa_e
add wave -noupdate -format Literal -radix binary /testbench/nuhs3dsp_e/sa_ctrl_e/sa_db
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sys_init_rdy
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sa_timing_e/sa_e
add wave -noupdate -format Literal /testbench/nuhs3dsp_e/sa_ctrl_e/sa_timing_e/line__24/step
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3534525 ps} 0} {{Cursor 2} {4777435 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {21 us}
