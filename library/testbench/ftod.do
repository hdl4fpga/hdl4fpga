onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /testbench/rst
add wave -noupdate -radix hexadecimal /testbench/clk
add wave -noupdate /testbench/du/bin_frm
add wave -noupdate /testbench/du/bin_irdy
add wave -noupdate /testbench/du/bin_trdy
add wave -noupdate -radix hexadecimal /testbench/du/bin_di
add wave -noupdate -radix hexadecimal /testbench/du/btod_e/bcd_di
add wave -noupdate -radix hexadecimal /testbench/du/bcd_do
add wave -noupdate /testbench/bin_cnv
add wave -noupdate /testbench/du/btod_bdv
add wave -noupdate /testbench/du/btod_ini
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du/btod_dcy
add wave -noupdate /testbench/du/bincnv_p/cnv
add wave -noupdate /testbench/du/btod_cnv
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {35 ns} 0}
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
WaveRestoreZoom {0 ns} {500 ns}
