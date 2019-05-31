onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /testbench/video_clk
add wave -noupdate -radix unsigned /testbench/video_hs
add wave -noupdate -radix unsigned /testbench/video_vs
add wave -noupdate -radix unsigned /testbench/video_vton
add wave -noupdate -radix unsigned /testbench/video_hzon
add wave -noupdate -radix unsigned /testbench/video_hzl
add wave -noupdate -radix unsigned /testbench/video_vld
add wave -noupdate -radix unsigned /testbench/video_vcntr
add wave -noupdate -radix unsigned /testbench/video_hcntr
add wave -noupdate /testbench/win_hzsync
add wave -noupdate /testbench/layout_e/xedge_e/video_ini
add wave -noupdate -radix unsigned /testbench/layout_e/video_divx
add wave -noupdate /testbench/layout_e/video_divy
add wave -noupdate /testbench/layout_e/video_edgex
add wave -noupdate /testbench/layout_e/video_edgey
add wave -noupdate /testbench/win_vtsync
add wave -noupdate /testbench/layout_e/edgey_e/video_ini
add wave -noupdate /testbench/layout_e/edgey_e/next_edge
add wave -noupdate /testbench/layout_e/last_edgey
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {16785340 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 155
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
WaveRestoreZoom {6285340 ns} {27285340 ns}
