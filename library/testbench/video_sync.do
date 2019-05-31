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
add wave -noupdate -radix unsigned -childformat {{/testbench/win_hzon(0) -radix unsigned} {/testbench/win_hzon(1) -radix unsigned} {/testbench/win_hzon(2) -radix unsigned} {/testbench/win_hzon(3) -radix unsigned}} -expand -subitemconfig {/testbench/win_hzon(0) {-height 29 -radix unsigned} /testbench/win_hzon(1) {-height 29 -radix unsigned} /testbench/win_hzon(2) {-height 29 -radix unsigned} /testbench/win_hzon(3) {-height 29 -radix unsigned}} /testbench/win_hzon
add wave -noupdate -radix unsigned /testbench/win_vton
add wave -noupdate -radix unsigned -childformat {{/testbench/sgmnt_x(0) -radix unsigned} {/testbench/sgmnt_x(1) -radix unsigned} {/testbench/sgmnt_x(2) -radix unsigned} {/testbench/sgmnt_x(3) -radix unsigned}} -subitemconfig {/testbench/sgmnt_x(0) {-height 29 -radix unsigned} /testbench/sgmnt_x(1) {-height 29 -radix unsigned} /testbench/sgmnt_x(2) {-height 29 -radix unsigned} /testbench/sgmnt_x(3) {-height 29 -radix unsigned}} /testbench/sgmnt_x
add wave -noupdate -radix unsigned -childformat {{/testbench/sgmnt_y(0) -radix unsigned} {/testbench/sgmnt_y(1) -radix unsigned} {/testbench/sgmnt_y(2) -radix unsigned} {/testbench/sgmnt_y(3) -radix unsigned}} -subitemconfig {/testbench/sgmnt_y(0) {-height 29 -radix unsigned} /testbench/sgmnt_y(1) {-height 29 -radix unsigned} /testbench/sgmnt_y(2) {-height 29 -radix unsigned} /testbench/sgmnt_y(3) {-height 29 -radix unsigned}} /testbench/sgmnt_y
add wave -noupdate -radix unsigned -childformat {{/testbench/sgmnt_w(0) -radix unsigned} {/testbench/sgmnt_w(1) -radix unsigned} {/testbench/sgmnt_w(2) -radix unsigned} {/testbench/sgmnt_w(3) -radix unsigned}} -subitemconfig {/testbench/sgmnt_w(0) {-height 29 -radix unsigned} /testbench/sgmnt_w(1) {-height 29 -radix unsigned} /testbench/sgmnt_w(2) {-height 29 -radix unsigned} /testbench/sgmnt_w(3) {-height 29 -radix unsigned}} /testbench/sgmnt_w
add wave -noupdate -radix unsigned -childformat {{/testbench/sgmnt_h(0) -radix unsigned} {/testbench/sgmnt_h(1) -radix unsigned} {/testbench/sgmnt_h(2) -radix unsigned} {/testbench/sgmnt_h(3) -radix unsigned}} -subitemconfig {/testbench/sgmnt_h(0) {-height 29 -radix unsigned} /testbench/sgmnt_h(1) {-height 29 -radix unsigned} /testbench/sgmnt_h(2) {-height 29 -radix unsigned} /testbench/sgmnt_h(3) {-height 29 -radix unsigned}} /testbench/sgmnt_h
add wave -noupdate /testbench/win_hzsync
add wave -noupdate /testbench/win_vtsync
add wave -noupdate -expand /testbench/layout_e/y_e/s_on
add wave -noupdate -expand /testbench/layout_e/y_e/s_sync
add wave -noupdate -radix unsigned /testbench/win_x
add wave -noupdate -radix unsigned /testbench/win_y
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {90359009 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 304
configure wave -valuecolwidth 313
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
WaveRestoreZoom {90227681 ns} {90490337 ns}
