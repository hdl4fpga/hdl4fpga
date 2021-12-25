onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdram_clk
add wave -noupdate /testbench/du_e/sdram_cke
add wave -noupdate /testbench/du_e/sdram_csn
add wave -noupdate /testbench/du_e/sdram_wen
add wave -noupdate /testbench/du_e/sdram_rasn
add wave -noupdate /testbench/du_e/sdram_casn
add wave -noupdate /testbench/du_e/sdram_ba
add wave -noupdate -radix hexadecimal /testbench/du_e/sdram_a
add wave -noupdate /testbench/du_e/sdram_d
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/so_frm
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/so_irdy
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/so_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/so_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_e/mii_clk
add wave -noupdate /testbench/du_e/ipoe_e/mii_rxdv
add wave -noupdate /testbench/du_e/ipoe_e/mii_rxd
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/fcs_sb
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/fcs_vld
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_e/mii_txen
add wave -noupdate /testbench/du_e/ipoe_e/mii_txd
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/plrx_frm
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/plrx_irdy
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/plrx_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/plrx_data
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {101770000000 fs} 0}
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
WaveRestoreZoom {99244687500 fs} {112369687500 fs}
