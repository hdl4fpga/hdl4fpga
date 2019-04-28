onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/clk
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/frm
add wave -noupdate -radix hexadecimal /testbench/format
add wave -noupdate /testbench/wu_frm
add wave -noupdate /testbench/wu_irdy
add wave -noupdate /testbench/wu_trdy
add wave -noupdate -radix hexadecimal /testbench/wu_value
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/pll_data
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/pll_irdy
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/pll_trdy
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/ser_data
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/ser_irdy
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/ser_last
add wave -noupdate -radix hexadecimal /testbench/du/pll2ser_e/ser_trdy
add wave -noupdate /testbench/du/flt
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du/btof_e/bin_di
add wave -noupdate /testbench/du/btof_e/bin_flt
add wave -noupdate /testbench/du/btof_e/bin_irdy
add wave -noupdate /testbench/du/btof_e/bin_trdy
add wave -noupdate -radix hexadecimal /testbench/du/btof_e/bcd_do
add wave -noupdate /testbench/du/btof_e/bcd_end
add wave -noupdate /testbench/du/btof_e/bcd_irdy
add wave -noupdate /testbench/du/btof_e/bcd_trdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du/frm
add wave -noupdate /testbench/du/irdy
add wave -noupdate /testbench/du/trdy
add wave -noupdate -radix hexadecimal /testbench/du/format
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix decimal /testbench/du/btof_e/dtos_e/mem_addr
add wave -noupdate -radix hexadecimal /testbench/du/btof_e/dtos_e/mem_di
add wave -noupdate -radix hexadecimal /testbench/du/btof_e/dtos_e/mem_do
add wave -noupdate -radix decimal /testbench/du/btof_e/dtos_e/mem_left
add wave -noupdate -radix decimal /testbench/du/btof_e/dtos_e/mem_right
add wave -noupdate /testbench/du/btof_e/dtos_e/mem_ena
add wave -noupdate -radix hexadecimal /testbench/du/btof_e/dtos_e/bcd_di
add wave -noupdate /testbench/du/btof_e/dtos_e/dtos_ena
add wave -noupdate /testbench/du/btof_e/dtos_e/dtos_ini
add wave -noupdate -radix hexadecimal /testbench/du/btof_e/dtos_e/dtos_di
add wave -noupdate -radix hexadecimal /testbench/du/btof_e/dtos_e/dtos_cy
add wave -noupdate -radix hexadecimal /testbench/du/btof_e/dtos_e/dtos_do
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du/btof_e/dtos_e/bcdddiv2e_e/bcd_cy
add wave -noupdate -radix hexadecimal /testbench/du/btof_e/dtos_e/bcdddiv2e_e/bcd_di
add wave -noupdate -radix hexadecimal /testbench/du/btof_e/dtos_e/bcdddiv2e_e/bcd_do
add wave -noupdate /testbench/du/btof_e/dtos_e/bcdddiv2e_e/bcd_ena
add wave -noupdate -radix decimal /testbench/du/btof_e/dtos_e/bcdddiv2e_e/bcd_exp
add wave -noupdate /testbench/du/btof_e/dtos_e/bcdddiv2e_e/bcd_ini
add wave -noupdate /testbench/du/btof_e/dtos_e/bcdddiv2e_e/clk
add wave -noupdate -radix unsigned /testbench/du/btof_e/dtos_e/bcdddiv2e_e/max
add wave -noupdate /testbench/du/btof_e/dtos_e/bcdddiv2e_e/shtio_d
add wave -noupdate /testbench/du/btof_e/dtos_e/bcdddiv2e_e/shtio_q
add wave -noupdate -radix unsigned /testbench/du/btof_e/dtos_e/bcdddiv2e_e/size
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {719 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 293
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
WaveRestoreZoom {275 ns} {1179 ns}
