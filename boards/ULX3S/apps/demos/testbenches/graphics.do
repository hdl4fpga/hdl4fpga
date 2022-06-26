onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -group sdram /testbench/du_e/sdram_clk
add wave -noupdate -group sdram /testbench/du_e/sdram_cke
add wave -noupdate -group sdram /testbench/du_e/sdram_csn
add wave -noupdate -group sdram /testbench/du_e/sdram_wen
add wave -noupdate -group sdram /testbench/du_e/sdram_rasn
add wave -noupdate -group sdram /testbench/du_e/sdram_casn
add wave -noupdate -group sdram /testbench/du_e/sdram_ba
add wave -noupdate -group sdram -radix hexadecimal /testbench/du_e/sdram_a
add wave -noupdate -group sdram /testbench/du_e/sdram_d
add wave -noupdate -group uart /testbench/du_e/ftdi_txd
add wave -noupdate -group uart /testbench/du_e/ftdi_rxd
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {210574000000 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 221
configure wave -valuecolwidth 135
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 fs} {630 us}
