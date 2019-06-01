onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /testbench/video_clk
add wave -noupdate -radix unsigned /testbench/video_hs
add wave -noupdate -radix unsigned /testbench/video_vs
add wave -noupdate -radix unsigned /testbench/video_vcntr
add wave -noupdate -radix unsigned /testbench/video_hcntr
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix unsigned /testbench/video_hzon
add wave -noupdate /testbench/layout_e/next_sidex
add wave -noupdate /testbench/layout_e/video_sidex
add wave -noupdate -radix unsigned /testbench/layout_e/video_divx
add wave -noupdate /testbench/layout_e/box_xon
add wave -noupdate -radix unsigned /testbench/box_posx
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix unsigned /testbench/video_vton
add wave -noupdate /testbench/layout_e/next_sidey
add wave -noupdate /testbench/layout_e/video_sidey
add wave -noupdate /testbench/layout_e/video_divy
add wave -noupdate /testbench/box_yon
add wave -noupdate -radix unsigned /testbench/box_posy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7505147 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 238
configure wave -valuecolwidth 120
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
WaveRestoreZoom {0 ns} {21 ms}
