onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /testbench/stof_e/fix_inc
add wave -noupdate -radix unsigned /testbench/stof_e/bcd_inc
add wave -noupdate -radix decimal /testbench/stof_e/bcd_left
add wave -noupdate -radix decimal /testbench/stof_e/bcd_right
add wave -noupdate /testbench/stof_e/bcd_frm
add wave -noupdate -radix hexadecimal /testbench/stof_e/fix_ptr
add wave -noupdate -radix hexadecimal /testbench/stof_e/fix_do
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {13 ns} 0}
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
WaveRestoreZoom {0 ns} {212 ns}
