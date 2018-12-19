onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/bin_frm
add wave -noupdate /testbench/bin_irdy
add wave -noupdate /testbench/bin_trdy
add wave -noupdate /testbench/bin_flt
add wave -noupdate -radix hexadecimal /testbench/bin_di
add wave -noupdate -radix hexadecimal /testbench/bcd_do
add wave -noupdate -radix hexadecimal /testbench/bcd_left
add wave -noupdate -radix hexadecimal /testbench/bcd_right
add wave -noupdate -radix hexadecimal /testbench/btod_e/vector_addr
add wave -noupdate -radix hexadecimal /testbench/btod_e/vector_do
add wave -noupdate -radix hexadecimal /testbench/btod_e/vector_di
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/btod_e/dtos_e/bcd_frm
add wave -noupdate -radix hexadecimal /testbench/btod_e/dtos_e/bcd_irdy
add wave -noupdate -radix hexadecimal /testbench/btod_e/dtos_e/bcd_trdy
add wave -noupdate -radix hexadecimal /testbench/btod_e/dtos_e/bcd_di
add wave -noupdate -radix hexadecimal /testbench/btod_e/dtos_e/dtos_di
add wave -noupdate -radix hexadecimal /testbench/btod_e/dtos_e/dtos_do
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/btod_e/dtos_e/bcdddiv2e_e/bcd_di
add wave -noupdate -radix hexadecimal /testbench/btod_e/dtos_e/bcdddiv2e_e/bcd_do
add wave -noupdate -radix hexadecimal -childformat {{/testbench/btod_e/dtos_e/bcdddiv2e_e/bcd_exp(0) -radix hexadecimal} {/testbench/btod_e/dtos_e/bcdddiv2e_e/bcd_exp(1) -radix hexadecimal} {/testbench/btod_e/dtos_e/bcdddiv2e_e/bcd_exp(2) -radix hexadecimal} {/testbench/btod_e/dtos_e/bcdddiv2e_e/bcd_exp(3) -radix hexadecimal}} -subitemconfig {/testbench/btod_e/dtos_e/bcdddiv2e_e/bcd_exp(0) {-height 23 -radix hexadecimal} /testbench/btod_e/dtos_e/bcdddiv2e_e/bcd_exp(1) {-height 23 -radix hexadecimal} /testbench/btod_e/dtos_e/bcdddiv2e_e/bcd_exp(2) {-height 23 -radix hexadecimal} /testbench/btod_e/dtos_e/bcdddiv2e_e/bcd_exp(3) {-height 23 -radix hexadecimal}} /testbench/btod_e/dtos_e/bcdddiv2e_e/bcd_exp
add wave -noupdate /testbench/btod_e/bin_irdy
add wave -noupdate /testbench/btod_e/bin_trdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {196 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 190
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
WaveRestoreZoom {0 ns} {484 ns}
