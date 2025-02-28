onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group uart /testbench/du_e/ftdi_rxd
add wave -noupdate -group uart /testbench/du_e/ftdi_txd
add wave -noupdate -expand -group rmii_eth /testbench/du_e/rmii_refclk
add wave -noupdate -expand -group rmii_eth /testbench/du_e/rmii_nintclk
add wave -noupdate -expand -group rmii_eth /testbench/du_e/rmii_rxdv
add wave -noupdate -expand -group rmii_eth -radix unsigned /testbench/du_e/rmii_rxd
add wave -noupdate -expand -group rmii_eth /testbench/du_e/rmii_txen
add wave -noupdate -expand -group rmii_eth -radix hexadecimal /testbench/du_e/rmii_txd
add wave -noupdate -group sdram /testbench/du_e/sdram_clk
add wave -noupdate -group sdram /testbench/du_e/sdram_cke
add wave -noupdate -group sdram /testbench/du_e/sdram_csn
add wave -noupdate -group sdram /testbench/du_e/sdram_rasn
add wave -noupdate -group sdram /testbench/du_e/sdram_casn
add wave -noupdate -group sdram /testbench/du_e/sdram_wen
add wave -noupdate -group sdram -radix hexadecimal /testbench/du_e/sdram_a
add wave -noupdate -group sdram /testbench/du_e/sdram_ba
add wave -noupdate -group sdram /testbench/du_e/sdram_dqm
add wave -noupdate -group sdram -radix hexadecimal /testbench/du_e/sdram_d
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/ipoe_b/ethrx_e/fcs_vld
add wave -noupdate /testbench/ipoe_b/ethrx_e/fcs_sb
add wave -noupdate -radix hexadecimal /testbench/ipoe_b/ethrx_e/fcs_rem
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {122049800169 fs} 0} {{Cursor 2} {95375095109 fs} 0} {{Cursor 3} {69141786685 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 632
configure wave -valuecolwidth 161
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
WaveRestoreZoom {121723546845 fs} {121957118812 fs}
