onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/rst
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Logic /testbench/lcd_e
add wave -noupdate -format Logic /testbench/lcd_rs
add wave -noupdate -format Logic /testbench/lcd_rw
add wave -noupdate -format Literal -radix ascii /testbench/lcd_data
add wave -noupdate -format Logic /testbench/lcd_backlight
add wave -noupdate -format Logic /testbench/rst
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Logic /testbench/lcd_backlight
add wave -noupdate -format Literal -radix ascii /testbench/lcd_data
add wave -noupdate -format Logic /testbench/lcd_e
add wave -noupdate -format Logic /testbench/lcd_rs
add wave -noupdate -format Logic /testbench/lcd_rw
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sa_timing_e/sys_clk
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /testbench/nuhs3dsp_e/sa_ctrl_e/sa_db
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sys_tmng_oe
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sys_init_rdy
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sys_init_req
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Literal /testbench/nuhs3dsp_e/sa_ctrl_e/sa_init_e/sa_do
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sa_init_e/sa_rs
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sa_init_e/sa_rw
add wave -noupdate -format Literal /testbench/nuhs3dsp_e/sa_ctrl_e/sa_init_e/step
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sa_init_e/sys_clk
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sa_init_e/sys_rdy
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sa_init_e/sys_req
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sa_timing_e/sa_e
add wave -noupdate -format Literal /testbench/nuhs3dsp_e/sa_ctrl_e/sa_timing_e/step
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sa_timing_e/sys_clk
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sa_timing_e/sys_oe
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sa_timing_e/sys_rdy
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sa_timing_e/sys_req
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/sa_ctrl_e/sa_timing_e/sys_rw
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3168 ns} 0}
configure wave -namecolwidth 178
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
WaveRestoreZoom {2814 ns} {15306 ns}
