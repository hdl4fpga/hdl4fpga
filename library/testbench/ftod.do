onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /testbench/rst
add wave -noupdate -radix hexadecimal /testbench/clk
add wave -noupdate -radix hexadecimal /testbench/du/btod_e/bin_di
add wave -noupdate -radix hexadecimal /testbench/du/btod_e/bcd_di
add wave -noupdate -radix hexadecimal /testbench/du/btod_e/bcd_do
add wave -noupdate /testbench/du/btod_e/bcd_cy
add wave -noupdate /testbench/bin_dv
add wave -noupdate /testbench/du/btod_dcy
add wave -noupdate /testbench/du/btod_bdv
add wave -noupdate -radix hexadecimal /testbench/du/queue_e/queue_addr
add wave -noupdate -radix hexadecimal /testbench/du/queue_e/queue_di
add wave -noupdate -radix hexadecimal /testbench/du/queue_e/queue_do
add wave -noupdate -radix hexadecimal /testbench/du/queue_e/mem_ptr
add wave -noupdate -radix hexadecimal /testbench/du/queue_e/queue_head
add wave -noupdate -radix hexadecimal /testbench/du/queue_e/queue_tail
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {78 ns} 0}
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
