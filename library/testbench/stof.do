onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /testbench/stof_e/fix_inc
add wave -noupdate -radix unsigned /testbench/stof_e/bcd_inc
add wave -noupdate -radix decimal /testbench/stof_e/bcd_left
add wave -noupdate -radix decimal /testbench/stof_e/bcd_right
add wave -noupdate /testbench/stof_e/bcd_frm
add wave -noupdate -radix hexadecimal /testbench/stof_e/fix_ptr
add wave -noupdate -radix hexadecimal /testbench/stof_e/fix_do
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/stof_e/fixfmt_p/fmt
add wave -noupdate -radix hexadecimal /testbench/stof_e/fixfmt_p/codes
add wave -noupdate -radix hexadecimal /testbench/stof_e/fixfmt_p/fix_cnt
add wave -noupdate -radix hexadecimal /testbench/stof_e/fixfmt_p/bcd_cnt
add wave -noupdate -radix hexadecimal /testbench/stof_e/fixfmt_p/fix_pos
add wave -noupdate -radix hexadecimal /testbench/stof_e/fixfmt_p/bcd_pos
add wave -noupdate -radix decimal /testbench/stof_e/fixfmt_p/bcd_idx
add wave -noupdate -radix decimal /testbench/stof_e/fixfmt_p/fix_idx
add wave -noupdate /testbench/stof_e/clk
add wave -noupdate -radix hexadecimal /testbench/stof_e/codes_q
add wave -noupdate -radix hexadecimal /testbench/stof_e/codes_d
add wave -noupdate -radix hexadecimal /testbench/stof_e/fmt_q
add wave -noupdate -radix hexadecimal /testbench/stof_e/fmt_d
add wave -noupdate -radix unsigned /testbench/stof_e/fix_cntr
add wave -noupdate -radix unsigned /testbench/stof_e/bcd_cntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2 ns} 0}
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
WaveRestoreZoom {0 ns} {21 ns}
