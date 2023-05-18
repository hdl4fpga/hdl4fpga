onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/src_clk
add wave -noupdate /testbench/du_e/src_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/src_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/dst_clk
add wave -noupdate -radix unsigned -childformat {{/testbench/du_e/shf(4) -radix unsigned} {/testbench/du_e/shf(3) -radix hexadecimal} {/testbench/du_e/shf(2) -radix hexadecimal} {/testbench/du_e/shf(1) -radix hexadecimal} {/testbench/du_e/shf(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/shf(4) {-height 29 -radix unsigned} /testbench/du_e/shf(3) {-height 29 -radix hexadecimal} /testbench/du_e/shf(2) {-height 29 -radix hexadecimal} /testbench/du_e/shf(1) {-height 29 -radix hexadecimal} /testbench/du_e/shf(0) {-height 29 -radix hexadecimal}} /testbench/du_e/shf
add wave -noupdate -radix hexadecimal /testbench/du_e/shfd
add wave -noupdate -radix hexadecimal /testbench/du_e/rgtr
add wave -noupdate -radix hexadecimal /testbench/du_e/dst_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/srcltdst_g/line__206/acc
add wave -noupdate /testbench/du_e/srcltdst_g/line__206/shr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3228589 ps} 0} {{Cursor 2} {1357914 ps} 0}
quietly wave cursor active 2
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
configure wave -timelineunits us
update
WaveRestoreZoom {207599 ps} {3522361 ps}
