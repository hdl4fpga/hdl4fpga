onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/rst
add wave -noupdate -format Logic /testbench/clk
add wave -noupdate -format Logic /testbench/mii_col
add wave -noupdate -format Logic /testbench/mii_crs
add wave -noupdate -format Logic /testbench/mii_refclk
add wave -noupdate -format Logic /testbench/mii_rst
add wave -noupdate -format Logic /testbench/mii_txc
add wave -noupdate -format Logic /testbench/mii_txen
add wave -noupdate -format Literal -radix hexadecimal /testbench/mii_txd
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/mii_du_dat_cntr
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/mii_du_mem_a
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/mii_du_mem_do
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1294 ns} 0} {{Cursor 2} {665 ns} 0}
configure wave -namecolwidth 236
configure wave -valuecolwidth 282
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
WaveRestoreZoom {436 ns} {1750 ns}
