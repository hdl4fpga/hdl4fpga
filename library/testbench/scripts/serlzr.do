onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/src_clk
add wave -noupdate /testbench/du_e/src_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/src_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/dst_clk
add wave -noupdate -radix unsigned -childformat {{/testbench/du_e/shf(2) -radix hexadecimal} {/testbench/du_e/shf(1) -radix hexadecimal} {/testbench/du_e/shf(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/shf(2) {-height 29 -radix hexadecimal} /testbench/du_e/shf(1) {-height 29 -radix hexadecimal} /testbench/du_e/shf(0) {-height 29 -radix hexadecimal}} /testbench/du_e/shf
add wave -noupdate -radix hexadecimal /testbench/du_e/shfd
add wave -noupdate -radix hexadecimal /testbench/du_e/rgtr
add wave -noupdate -radix hexadecimal /testbench/du_e/dst_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/src_clk
add wave -noupdate /testbench/du_e/src_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/src_data
add wave -noupdate /testbench/du_e/src_irdy
add wave -noupdate /testbench/du_e/src_trdy
add wave -noupdate /testbench/du_e/dst_frm
add wave -noupdate /testbench/du_e/dst_clk
add wave -noupdate /testbench/du_e/dst_irdy
add wave -noupdate /testbench/du_e/dst_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/dst_data(0)
add wave -noupdate /testbench/du_e/srcgtdst_g/line__185/acc
add wave -noupdate /testbench/du_e/srcgtdst_g/line__185/shr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4239939 ps} 0}
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {6300 ns}
