onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk
add wave -noupdate -radix hexadecimal /testbench/float
add wave -noupdate /testbench/frm
add wave -noupdate /testbench/du/irdy
add wave -noupdate /testbench/du/trdy
add wave -noupdate /testbench/wu_frm
add wave -noupdate /testbench/du/wu_irdy
add wave -noupdate /testbench/du/wu_trdy
add wave -noupdate -radix unsigned /testbench/du/wu_bcdwidth
add wave -noupdate -radix decimal /testbench/du/wu_bcdprec
add wave -noupdate -radix decimal /testbench/du/wu_bcdunit
add wave -noupdate -radix hexadecimal /testbench/du/wu_float
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {70 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 157
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
WaveRestoreZoom {40 ns} {840 ns}
