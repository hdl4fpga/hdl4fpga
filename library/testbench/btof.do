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
add wave -noupdate -divider DTOS
add wave -noupdate /testbench/du_e/dtos_e/line__58/state
add wave -noupdate /testbench/du_e/dtos_e/frm
add wave -noupdate /testbench/du_e/dtos_e/bcd_trdy
add wave -noupdate /testbench/du_e/dtos_e/bcd_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/dtos_e/bcd_di
add wave -noupdate /testbench/du_e/dtos_e/dtos_ena
add wave -noupdate /testbench/du_e/dtos_e/dtos_ini
add wave -noupdate /testbench/du_e/dtos_e/dtos_zero
add wave -noupdate /testbench/du_e/dtos_e/dtos_cy
add wave -noupdate -radix hexadecimal /testbench/du_e/dtos_e/dtos_di
add wave -noupdate /testbench/du_e/dtos_e/mem_ena
add wave -noupdate /testbench/du_e/dtos_e/mem_full
add wave -noupdate -radix decimal /testbench/du_e/dtos_e/mem_left
add wave -noupdate -radix decimal /testbench/du_e/dtos_e/mem_right
add wave -noupdate /testbench/du_e/dtos_e/mem_left_up
add wave -noupdate /testbench/du_e/dtos_e/mem_left_ena
add wave -noupdate /testbench/du_e/dtos_e/mem_right_up
add wave -noupdate /testbench/du_e/dtos_e/mem_right_ena
add wave -noupdate -radix hexadecimal /testbench/du_e/dtos_e/mem_addr
add wave -noupdate -radix hexadecimal /testbench/du_e/dtos_e/mem_do
add wave -noupdate -radix hexadecimal /testbench/du_e/dtos_e/mem_di
add wave -noupdate -divider STOF
add wave -noupdate /testbench/du_e/stof_e/line__65/state
add wave -noupdate /testbench/du_e/stof_e/frm
add wave -noupdate /testbench/du_e/stof_e/bcd_end
add wave -noupdate -radix hexadecimal /testbench/du_e/stof_e/bcd_unit
add wave -noupdate -radix hexadecimal /testbench/du_e/stof_e/bcd_prec
add wave -noupdate -radix hexadecimal /testbench/du_e/stof_e/bcd_width
add wave -noupdate -radix decimal /testbench/du_e/stof_e/bcd_left
add wave -noupdate -radix decimal /testbench/du_e/stof_e/bcd_right
add wave -noupdate -radix hexadecimal /testbench/du_e/stof_e/bcd_di
add wave -noupdate /testbench/du_e/stof_e/bcd_irdy
add wave -noupdate /testbench/du_e/stof_e/bcd_trdy
add wave -noupdate -radix decimal /testbench/du_e/stof_e/mem_addr
add wave -noupdate -radix hexadecimal /testbench/du_e/stof_e/mem_do
add wave -noupdate -radix hexadecimal /testbench/du_e/stof_e/fmt_do
add wave -noupdate -radix hexadecimal /testbench/line__84/num
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {260 ns} 0} {{Cursor 2} {980 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 219
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
WaveRestoreZoom {0 ns} {736 ns}
