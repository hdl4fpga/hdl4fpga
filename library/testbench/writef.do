onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/wr_frm
add wave -noupdate /testbench/wr_trdy
add wave -noupdate -radix hexadecimal /testbench/wr_do
add wave -noupdate -divider btof
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/bin_frm
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/bin_irdy
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/bin_trdy
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/bin_flt
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/bin_di
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/fix_frm
add wave -noupdate -divider btos
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/btos_e/bin_frm
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/btos_e/bin_irdy
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/btos_e/bin_trdy
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/btos_e/bin_flt
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/btos_e/bin_di
add wave -noupdate -divider btod
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/btos_e/btod_e/bin_frm
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/btos_e/btod_e/bin_irdy
add wave -noupdate /testbench/writef_e/wrfbuf_e/btof_e/btos_e/btod_e/bin_trdy
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/btos_e/btod_e/bin_di
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/btos_e/btod_e/mem_addr
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/btos_e/btod_e/mem_di
add wave -noupdate -radix hexadecimal /testbench/writef_e/wrfbuf_e/btof_e/btos_e/btod_e/mem_do
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {64 ns} 0}
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
WaveRestoreZoom {0 ns} {724 ns}
