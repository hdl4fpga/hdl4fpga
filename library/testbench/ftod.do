onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/du/bin_frm
add wave -noupdate /testbench/du/bin_irdy
add wave -noupdate /testbench/du/bin_trdy
add wave -noupdate /testbench/du/bin_flt
add wave -noupdate /testbench/du/gnt_p/gnt
add wave -noupdate /testbench/du/gnt_p/req
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du/btod_e/bin_frm
add wave -noupdate -radix hexadecimal /testbench/du/btod_e/bin_irdy
add wave -noupdate -radix hexadecimal /testbench/du/btod_e/bin_trdy
add wave -noupdate -radix hexadecimal /testbench/du/btod_e/bin_di
add wave -noupdate -radix hexadecimal /testbench/du/btod_e/mem_di
add wave -noupdate -radix hexadecimal /testbench/du/btod_e/mem_do
add wave -noupdate /testbench/du/btod_e/btod_cnv
add wave -noupdate /testbench/du/btod_e/btod_ena
add wave -noupdate -radix hexadecimal /testbench/du/btod_e/mem_addr
add wave -noupdate /testbench/du/btod_e/btod_cy
add wave -noupdate -radix hexadecimal /testbench/du/btod_e/mem_addr
add wave -noupdate -radix hexadecimal /testbench/du/btod_e/mem_left
add wave -noupdate /testbench/du/btod_e/mem_left_up
add wave -noupdate /testbench/du/btod_e/mem_left_ena
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {279 ns} 0}
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
WaveRestoreZoom {0 ns} {628 ns}
