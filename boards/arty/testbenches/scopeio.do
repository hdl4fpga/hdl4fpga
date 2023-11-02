onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/input_clk
add wave -noupdate /testbench/du_e/input_lck
add wave -noupdate /testbench/du_e/xadcctlr_b/drdy
add wave -noupdate /testbench/du_e/xadcctlr_b/eoc
add wave -noupdate -radix hexadecimal /testbench/du_e/xadcctlr_b/di
add wave -noupdate /testbench/du_e/xadcctlr_b/dwe
add wave -noupdate /testbench/du_e/xadcctlr_b/den
add wave -noupdate -radix hexadecimal /testbench/du_e/xadcctlr_b/daddr
add wave -noupdate /testbench/du_e/xadcctlr_b/channel
add wave -noupdate /testbench/du_e/video_clk
add wave -noupdate /testbench/du_e/sio_clk
add wave -noupdate /testbench/du_e/xadcctlr_b/xadc_e/adcclk
add wave -noupdate /testbench/du_e/input_ena
add wave -noupdate /testbench/du_e/xadcctlr_b/line__543/cfg_req
add wave -noupdate /testbench/du_e/xadcctlr_b/line__543/cfg_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/input_clk
add wave -noupdate /testbench/du_e/input_lck
add wave -noupdate /testbench/du_e/input_ena
add wave -noupdate -radix hexadecimal /testbench/du_e/input_sample
add wave -noupdate /testbench/du_e/input_samples
add wave -noupdate /testbench/du_e/input_maxchn
add wave -noupdate /testbench/du_e/xadcctlr_b/xadc_e/op_count
add wave -noupdate /testbench/du_e/xadcctlr_b/xadc_e/BUSY
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6273423 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 307
configure wave -valuecolwidth 283
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
configure wave -timelineunits us
update
WaveRestoreZoom {4132489 ps} {10308817 ps}
