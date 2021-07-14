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
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/du_e/miitx_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/miitx_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/du_e/miitx_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/miitx_data(7) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/du_e/miitx_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_mode
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_crc
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ethtx_e/fcs_end
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/ethrx_e/mii_clk
add wave -noupdate /testbench/ethrx_e/mii_irdy
add wave -noupdate /testbench/ethrx_e/mii_frm
add wave -noupdate -radix hexadecimal /testbench/ethrx_e/mii_data
add wave -noupdate /testbench/ethrx_e/crc_equ
add wave -noupdate /testbench/ethrx_e/crc_sb
add wave -noupdate -radix hexadecimal /testbench/ethrx_e/crc_rem
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/meta_b/lentx_full
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/meta_b/lentx_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/meta_b/lentx_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4chsm_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4chsm_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4shdr_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4len_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4hdr_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4_trdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_frm
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/ipv4proto_trdy
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/cksm_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/cksm_data
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/mii_1cksm_e/ci
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/mii_1cksm_e/op1
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/mii_1cksm_e/op2
add wave -noupdate /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/mii_1cksm_e/co
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/mii_1cksm_e/sum
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(7) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(8) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(9) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(10) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(11) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(12) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(13) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(14) -radix hexadecimal} {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(15) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(7) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(8) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(9) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(10) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(11) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(12) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(13) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(14) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum(15) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/du_e/ipv4_e/ipv4tx_e/chksum
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {875135630 fs} 0}
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
WaveRestoreZoom {236842100 fs} {1555079640 fs}
