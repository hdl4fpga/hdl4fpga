onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/du_e/sys_rst
add wave -noupdate -format Logic /testbench/du_e/sys_clk
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /testbench/du_e/sys_cmd_req
add wave -noupdate -format Logic /testbench/du_e/sys_cmd_rdy
add wave -noupdate -format Logic /testbench/du_e/sys_cas
add wave -noupdate -format Logic /testbench/du_e/sys_rw
add wave -noupdate -format Literal /testbench/du_e/sys_ba
add wave -noupdate -format Literal -radix hexadecimal /testbench/du_e/sys_a
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /testbench/du_e/sys_data_req
add wave -noupdate -format Logic /testbench/du_e/sys_data_rdy
add wave -noupdate -format Literal -radix hexadecimal /testbench/du_e/sys_do
add wave -noupdate -format Literal -radix hexadecimal /testbench/du_e/sys_di
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /testbench/du_e/next_addr
add wave -noupdate -color Coral -format Literal -radix hexadecimal /testbench/du_e/bnk
add wave -noupdate -format Literal -radix hexadecimal /testbench/du_e/col
add wave -noupdate -format Literal -radix hexadecimal /testbench/du_e/row
add wave -noupdate -format Logic /testbench/du_e/sys_ok
add wave -noupdate -format Literal /testbench/du_e/data_bytes
add wave -noupdate -format Literal /testbench/du_e/cols_bits
add wave -noupdate -format Literal /testbench/du_e/byte_bits
add wave -noupdate -format Literal /testbench/du_e/brt
add wave -noupdate -format Literal /testbench/du_e/bank_bits
add wave -noupdate -format Literal /testbench/du_e/addr_bits
add wave -noupdate -format Literal -radix hexadecimal /testbench/du_e/seed1
add wave -noupdate -format Literal -radix hexadecimal /testbench/du_e/seed2
add wave -noupdate -format Literal -radix hexadecimal /testbench/du_e/seed3
add wave -noupdate -format Literal -radix hexadecimal /testbench/du_e/seed4
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {168082 ps} 0}
configure wave -namecolwidth 146
configure wave -valuecolwidth 79
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
configure wave -timelineunits ps
update
WaveRestoreZoom {84473 ps} {198646 ps}
