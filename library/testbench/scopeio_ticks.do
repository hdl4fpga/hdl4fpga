onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/frm
add wave -noupdate /testbench/wu_frm
add wave -noupdate /testbench/ticks_e/wu_irdy
add wave -noupdate /testbench/ticks_e/wu_trdy
add wave -noupdate -radix hexadecimal /testbench/float
add wave -noupdate -radix hexadecimal /testbench/format
add wave -noupdate -radix hexadecimal /testbench/writeu_e/btof_e/bin_di
add wave -noupdate -radix hexadecimal /testbench/writeu_e/btof_e/bin_flt
add wave -noupdate -radix hexadecimal /testbench/writeu_e/btof_e/bin_irdy
add wave -noupdate -radix hexadecimal /testbench/writeu_e/btof_e/bin_trdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/writeu_e/btof_e/bcd_trdy
add wave -noupdate -radix hexadecimal /testbench/writeu_e/btof_e/bcd_do
add wave -noupdate /testbench/writeu_e/btof_e/stof_trdy
add wave -noupdate /testbench/writeu_e/btof_e/stof_e/frm
add wave -noupdate -radix decimal /testbench/writeu_e/btof_e/vector_e/vector_left
add wave -noupdate -radix decimal /testbench/writeu_e/btof_e/vector_e/vector_right
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {303 ns} 0}
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
WaveRestoreZoom {0 ns} {2444 ns}
