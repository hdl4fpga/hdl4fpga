onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/stof_e/clk
add wave -noupdate /testbench/btos_e/bin_frm
add wave -noupdate /testbench/btos_e/bin_irdy
add wave -noupdate /testbench/btos_e/bin_trdy
add wave -noupdate /testbench/btos_e/bin_flt
add wave -noupdate -radix hexadecimal /testbench/btos_e/bin_di
add wave -noupdate -radix hexadecimal /testbench/fmt
add wave -noupdate -radix hexadecimal /testbench/btos_e/vector_e/vector_addr
add wave -noupdate -radix hexadecimal /testbench/btos_e/vector_e/vector_di
add wave -noupdate -radix hexadecimal /testbench/btos_e/vector_e/vector_do
add wave -noupdate -radix hexadecimal /testbench/btos_e/vector_e/vector_left
add wave -noupdate -radix hexadecimal /testbench/btos_e/dtos_e/addr
add wave -noupdate -radix hexadecimal /testbench/btos_e/vector_e/vector_right
add wave -noupdate /testbench/btos_e/left_up
add wave -noupdate /testbench/btos_e/left_ena
add wave -noupdate /testbench/btos_e/right_up
add wave -noupdate /testbench/btos_e/right_ena
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/stof_e/bcd_frm
add wave -noupdate /testbench/stof_e/bcd_irdy
add wave -noupdate /testbench/stof_e/bcd_trdy
add wave -noupdate -radix hexadecimal /testbench/stof_e/bcd_di
add wave -noupdate -radix decimal /testbench/stof_e/bcd_left
add wave -noupdate -radix decimal /testbench/stof_e/bcd_right
add wave -noupdate /testbench/stof_e/fix_irdy
add wave -noupdate /testbench/stof_e/fix_trdy
add wave -noupdate -radix hexadecimal -childformat {{/testbench/stof_e/fix_do(3) -radix hexadecimal} {/testbench/stof_e/fix_do(2) -radix hexadecimal} {/testbench/stof_e/fix_do(1) -radix hexadecimal} {/testbench/stof_e/fix_do(0) -radix hexadecimal}} -subitemconfig {/testbench/stof_e/fix_do(3) {-height 18 -radix hexadecimal} /testbench/stof_e/fix_do(2) {-height 18 -radix hexadecimal} /testbench/stof_e/fix_do(1) {-height 18 -radix hexadecimal} /testbench/stof_e/fix_do(0) {-height 18 -radix hexadecimal}} /testbench/stof_e/fix_do
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/stof_e/fixidx_d
add wave -noupdate -radix hexadecimal /testbench/stof_e/fixidx_q
add wave -noupdate -radix hexadecimal /testbench/stof_e/bcdidx_q
add wave -noupdate -radix hexadecimal /testbench/stof_e/bcdidx_d
add wave -noupdate -radix hexadecimal /testbench/stof_e/fixoff_d
add wave -noupdate -radix hexadecimal /testbench/stof_e/fixoff_q
add wave -noupdate -radix hexadecimal /testbench/stof_e/fixfmt_p/left
add wave -noupdate -radix hexadecimal /testbench/stof_e/fixfmt_p/fixoff
add wave -noupdate -radix hexadecimal /testbench/stof_e/fixfmt_p/fixidx
add wave -noupdate -radix hexadecimal /testbench/stof_e/fixfmt_p/bcdidx
add wave -noupdate -radix hexadecimal /testbench/fmt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {454 ns} 0}
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
WaveRestoreZoom {348 ns} {612 ns}
