onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/clk
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/frm
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/pll_data
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/pll_irdy
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/pll_trdy
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/ser_data
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/ser_irdy
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/ser_last
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/ser_trdy
add wave -noupdate /testbench/du/flt
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du/btof_e/bin_di
add wave -noupdate /testbench/du/btof_e/bin_flt
add wave -noupdate /testbench/du/btof_e/bin_irdy
add wave -noupdate /testbench/du/btof_e/bin_trdy
add wave -noupdate -radix hexadecimal /testbench/du/btof_e/bcd_do
add wave -noupdate /testbench/du/btof_e/bcd_end
add wave -noupdate /testbench/du/btof_e/bcd_irdy
add wave -noupdate /testbench/du/btof_e/bcd_trdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du/frm
add wave -noupdate /testbench/du/irdy
add wave -noupdate /testbench/du/trdy
add wave -noupdate -radix hexadecimal /testbench/du/format
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1114 ns} 0}
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
WaveRestoreZoom {0 ns} {1530 ns}
