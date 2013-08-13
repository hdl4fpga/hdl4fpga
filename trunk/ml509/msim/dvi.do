onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/ml509_e/video_clk
add wave -noupdate /testbench/ml509_e/video_clk90
add wave -noupdate -radix hexadecimal /testbench/dvi_d
add wave -noupdate /testbench/dvi_de
add wave -noupdate /testbench/dvi_h
add wave -noupdate /testbench/dvi_reset
add wave -noupdate /testbench/dvi_v
add wave -noupdate /testbench/dvi_xclk_p
add wave -noupdate /testbench/dvi_xclk_n
add wave -noupdate /testbench/ml509_e/video_vga_e/frm
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {16514595178 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {16514492301 ps} {16514810621 ps}
