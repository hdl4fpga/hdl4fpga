onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/frm
add wave -noupdate -radix hexadecimal /testbench/du_e/bin_di
add wave -noupdate /testbench/du_e/bin_flt
add wave -noupdate /testbench/du_e/bin_irdy
add wave -noupdate /testbench/du_e/bin_neg
add wave -noupdate /testbench/du_e/bin_trdy
add wave -noupdate /testbench/du_e/bcd_irdy
add wave -noupdate /testbench/du_e/bcd_trdy
add wave -noupdate /testbench/bcd_end
add wave -noupdate -divider DBDBBl
add wave -noupdate -radix hexadecimal /testbench/du_e/btod_e/dbdbbl_e/bin_di
add wave -noupdate -radix hexadecimal /testbench/du_e/btod_e/dbdbbl_e/bcd_di
add wave -noupdate -radix hexadecimal /testbench/du_e/btod_e/dbdbbl_e/bcd_do
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/btod_e/state
add wave -noupdate -radix hexadecimal /testbench/du_e/btod_e/addr
add wave -noupdate -radix hexadecimal /testbench/du_e/btod_e/mem_left
add wave -noupdate /testbench/du_e/btod_e/btod_zero
add wave -noupdate /testbench/du_e/btod_e/btod_ini
add wave -noupdate -radix hexadecimal /testbench/du_e/btod_e/bin_di
add wave -noupdate -radix hexadecimal /testbench/du_e/btod_e/mem_di
add wave -noupdate -radix hexadecimal /testbench/du_e/btod_e/mem_do
add wave -noupdate -divider VECTOR
add wave -noupdate /testbench/du_e/vector_e/vector_clk
add wave -noupdate /testbench/du_e/vector_e/vector_ena
add wave -noupdate -radix hexadecimal /testbench/du_e/vector_e/vector_left
add wave -noupdate -radix hexadecimal /testbench/du_e/vector_e/vector_right
add wave -noupdate -radix hexadecimal /testbench/du_e/vector_e/vector_addr
add wave -noupdate -radix hexadecimal /testbench/du_e/vector_e/mem_ptr
add wave -noupdate -radix hexadecimal /testbench/du_e/vector_e/vector_di
add wave -noupdate -radix hexadecimal /testbench/du_e/vector_e/vector_do
add wave -noupdate -radix hexadecimal /testbench/du_e/vector_e/mem_e/async_rddata
add wave -noupdate -divider STOF
add wave -noupdate /testbench/du_e/stof_e/frm
add wave -noupdate -radix hexadecimal /testbench/du_e/stof_e/bcd_unit
add wave -noupdate -radix hexadecimal /testbench/du_e/stof_e/bcd_prec
add wave -noupdate -radix hexadecimal /testbench/du_e/stof_e/bcd_width
add wave -noupdate -radix hexadecimal /testbench/du_e/stof_e/bcd_left
add wave -noupdate -radix decimal /testbench/du_e/stof_e/bcd_right
add wave -noupdate -radix hexadecimal /testbench/du_e/stof_e/bcd_di
add wave -noupdate /testbench/du_e/stof_e/bcd_irdy
add wave -noupdate /testbench/du_e/stof_e/bcd_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/stof_e/mem_addr
add wave -noupdate -radix hexadecimal /testbench/du_e/stof_e/mem_do
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {970 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 125
configure wave -valuecolwidth 125
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
WaveRestoreZoom {141 ns} {1209 ns}
