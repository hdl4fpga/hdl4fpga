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
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_end
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/mii_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_e/frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_mode
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_crc
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/ethrx_e/mii_clk
add wave -noupdate /testbench/ethrx_e/mii_irdy
add wave -noupdate /testbench/ethrx_e/mii_frm
add wave -noupdate -radix hexadecimal /testbench/ethrx_e/mii_data
add wave -noupdate /testbench/ethrx_e/crc_equ
add wave -noupdate /testbench/ethrx_e/crc_sb
add wave -noupdate -radix hexadecimal /testbench/ethrx_e/crc_rem
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/cksm_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/cksm_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum_rev
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4chsm_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4chsm_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4shdr_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4hdr_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_end
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_trdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/meta_b/protomux_e/sio_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_trdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/meta_b/protomux_e/sio_irdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/meta_b/protomux_e/so_end
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2554487830 fs} 1}
quietly wave cursor active 1
configure wave -namecolwidth 323
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
WaveRestoreZoom {1718935400 fs} {3490810400 fs}
