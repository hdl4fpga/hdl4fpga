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
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/mii_du/mem_do
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/mii_du/du/xi
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/mii_du/sys_rdy
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/mii_du/sys_req
add wave -noupdate -format Literal -radix unsigned /testbench/nuhs3dsp_e/mii_du/tx_data_p/dat_cntr
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/mii_du/du/clk
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/mii_du/du/g
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/mii_du/du/pl
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/mii_du/du/xp
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/mii_du/du/so
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/mii_du/xo
add wave -noupdate -format Literal /testbench/nuhs3dsp_e/mii_du/tx_data_p/pre_int
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/mii_du/tx_data_p/txd_sel
add wave -noupdate -format Literal /testbench/nuhs3dsp_e/mii_du/tx_data_p/state
add wave -noupdate -format Literal /testbench/nuhs3dsp_e/mii_du/tx_data_p/dwn_cntr
add wave -noupdate -format Literal /testbench/nuhs3dsp_e/mii_du/tx_data_p/dat_cntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5884 ns} 0} {{Cursor 2} {5529 ns} 0}
configure wave -namecolwidth 121
configure wave -valuecolwidth 120
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
WaveRestoreZoom {0 ns} {7350 ns}
