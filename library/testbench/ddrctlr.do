onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/s3estarter_e/xtal
add wave -noupdate /testbench/s3estarter_e/ddrdcm_e/dfsdcm_clk0
add wave -noupdate /testbench/s3estarter_e/dmactlr_rst
add wave -noupdate -divider {Micron DDR}
add wave -noupdate /testbench/ddr_model_g/Clk
add wave -noupdate /testbench/ddr_model_g/Clk_n
add wave -noupdate /testbench/ddr_model_g/Cke
add wave -noupdate /testbench/ddr_model_g/Cs_n
add wave -noupdate /testbench/ddr_model_g/Ras_n
add wave -noupdate /testbench/ddr_model_g/Cas_n
add wave -noupdate /testbench/ddr_model_g/We_n
add wave -noupdate -radix hexadecimal /testbench/ddr_model_g/Addr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {200551318 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 212
configure wave -valuecolwidth 163
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
configure wave -timelineunits ps
update
WaveRestoreZoom {200544689 ps} {201669907 ps}
