onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/du_e/eth_tx_clk
add wave -noupdate /testbench/du_e/eth_tx_en
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/eth_txd(0) -radix hexadecimal} {/testbench/du_e/eth_txd(1) -radix hexadecimal} {/testbench/du_e/eth_txd(2) -radix hexadecimal} {/testbench/du_e/eth_txd(3) -radix hexadecimal}} -subitemconfig {/testbench/du_e/eth_txd(0) {-height 29 -radix hexadecimal} /testbench/du_e/eth_txd(1) {-height 29 -radix hexadecimal} /testbench/du_e/eth_txd(2) {-height 29 -radix hexadecimal} /testbench/du_e/eth_txd(3) {-height 29 -radix hexadecimal}} /testbench/du_e/eth_txd
add wave -noupdate /testbench/du_e/ser_debug_e/ser_clk
add wave -noupdate /testbench/du_e/ser_debug_e/ser_frm
add wave -noupdate /testbench/du_e/ser_debug_e/ser_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ser_debug_e/ser_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_b/du_e/miitx_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/miitx_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/miitx_trdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/miitx_end
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/miitx_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_mode
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_end
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_crc
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/mii_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_irdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/ethrx_e/mii_clk
add wave -noupdate /testbench/ethrx_e/mii_irdy
add wave -noupdate /testbench/ethrx_e/mii_frm
add wave -noupdate -radix hexadecimal /testbench/ethrx_e/mii_data
add wave -noupdate /testbench/ethrx_e/crc_equ
add wave -noupdate /testbench/ethrx_e/crc_sb
add wave -noupdate -radix hexadecimal /testbench/ethrx_e/crc_rem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {24076885480 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 188
configure wave -valuecolwidth 191
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
WaveRestoreZoom {0 fs} {28350 ns}
