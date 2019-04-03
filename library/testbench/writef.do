onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/bin_frm
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/bin_irdy
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/bin_trdy
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/bin_flt
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/bin_di
add wave -noupdate -divider btod
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/btod_e/bin_frm
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/btod_e/bin_irdy
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/btod_e/bin_trdy
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/btod_e/bin_di
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/btod_e/btod_ena
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/btod_e/btod_ini
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/btod_e/btod_zero
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/btod_e/btod_cy
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/btod_e/btod_di
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/btod_e/state
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/btod_e/addr
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/btod_e/btod_do
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/btod_e/mem_ena
add wave -noupdate -divider dtos
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/dtos_e/bcd_frm
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/dtos_e/bcd_irdy
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/dtos_e/bcd_trdy
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/dtos_e/bcd_di
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/dtos_e/dtos_ena
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/dtos_e/dtos_ini
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/dtos_e/dtos_zero
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/dtos_e/dtos_cy
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/dtos_e/dtos_di
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/dtos_e/state
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/dtos_e/addr
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/dtos_e/dtos_do
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/dtos_e/mem_ena
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/vector_e/vector_left
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/vector_e/vector_right
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/dtos_e/mem_right_ena
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/dtos_e/mem_right_up
add wave -noupdate -divider stof
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/stof_e/frm
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/stof_e/sign
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/stof_e/bcd_irdy
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/stof_e/bcd_trdy
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/stof_e/mem_do
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/stof_e/prec
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/stof_e/unit
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/stof_e/bcd_left
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/stof_e/bcd_right
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/stof_e/bcd_di
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/stof_e/bcd_end
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/stof_e/mem_addr
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/stof_e/sel_mux
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/stof_e/line__127/ptr
add wave -noupdate -divider btof
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/btod_trdy
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/state
add wave -noupdate -divider vector
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/vector_e/vector_rst
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/vector_e/vector_full
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/vector_e/vector_ena
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/vector_e/vector_addr
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/vector_e/vector_di
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/vector_e/vector_do
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/vector_e/vector_left
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/vector_e/vector_right
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/vector_e/left_ena
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/vector_e/left_up
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/vector_e/right_ena
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/vector_e/right_up
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {885 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 161
configure wave -valuecolwidth 186
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
WaveRestoreZoom {177 ns} {2337 ns}
