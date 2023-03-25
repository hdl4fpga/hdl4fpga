onerror {resume}
quietly virtual signal -install /testbench/du_e/sdrphy_e { /testbench/du_e/sdrphy_e/tp(1 to 8)} tp_delay
quietly virtual signal -install /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i { (context /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i )(dqs180 & dqspre )} xxx
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/btn(0)
add wave -noupdate -group du_ethrx /testbench/ipoe_b/ethrx_e/fcs_sb
add wave -noupdate -group du_ethrx /testbench/ipoe_b/ethrx_e/fcs_vld
add wave -noupdate -group du_ethrx -radix hexadecimal /testbench/ipoe_b/ethrx_e/fcs_rem
add wave -noupdate -expand -group eth_rx /testbench/du_e/eth_rx_clk
add wave -noupdate -expand -group eth_rx /testbench/du_e/eth_rx_dv
add wave -noupdate -expand -group eth_rx -radix hexadecimal /testbench/du_e/eth_rxd
add wave -noupdate -expand -group eth_rx /testbench/du_e/eth_tx_clk
add wave -noupdate -expand -group eth_rx /testbench/du_e/eth_tx_en
add wave -noupdate -expand -group eth_rx -radix hexadecimal /testbench/du_e/eth_txd
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_clk_p
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_reset
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_cs
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_cke
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_odt
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_ras
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_cas
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_we
add wave -noupdate -expand -group ddr3 -radix symbolic -childformat {{/testbench/du_e/ddr3_ba(2) -radix hexadecimal} {/testbench/du_e/ddr3_ba(1) -radix hexadecimal} {/testbench/du_e/ddr3_ba(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr3_ba(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_ba(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_ba(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr3_ba
add wave -noupdate -expand -group ddr3 -radix hexadecimal -childformat {{/testbench/du_e/ddr3_a(13) -radix hexadecimal} {/testbench/du_e/ddr3_a(12) -radix hexadecimal} {/testbench/du_e/ddr3_a(11) -radix hexadecimal} {/testbench/du_e/ddr3_a(10) -radix hexadecimal} {/testbench/du_e/ddr3_a(9) -radix hexadecimal} {/testbench/du_e/ddr3_a(8) -radix hexadecimal} {/testbench/du_e/ddr3_a(7) -radix hexadecimal} {/testbench/du_e/ddr3_a(6) -radix hexadecimal} {/testbench/du_e/ddr3_a(5) -radix hexadecimal} {/testbench/du_e/ddr3_a(4) -radix hexadecimal} {/testbench/du_e/ddr3_a(3) -radix hexadecimal} {/testbench/du_e/ddr3_a(2) -radix hexadecimal} {/testbench/du_e/ddr3_a(1) -radix hexadecimal} {/testbench/du_e/ddr3_a(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr3_a(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr3_a
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_dqs_p(1)
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_dqs_p(0)
add wave -noupdate -expand -group ddr3 -radix hexadecimal -childformat {{/testbench/du_e/ddr3_dq(15) -radix hexadecimal} {/testbench/du_e/ddr3_dq(14) -radix hexadecimal} {/testbench/du_e/ddr3_dq(13) -radix hexadecimal} {/testbench/du_e/ddr3_dq(12) -radix hexadecimal} {/testbench/du_e/ddr3_dq(11) -radix hexadecimal} {/testbench/du_e/ddr3_dq(10) -radix hexadecimal} {/testbench/du_e/ddr3_dq(9) -radix hexadecimal} {/testbench/du_e/ddr3_dq(8) -radix hexadecimal} {/testbench/du_e/ddr3_dq(7) -radix hexadecimal} {/testbench/du_e/ddr3_dq(6) -radix hexadecimal} {/testbench/du_e/ddr3_dq(5) -radix hexadecimal} {/testbench/du_e/ddr3_dq(4) -radix hexadecimal} {/testbench/du_e/ddr3_dq(3) -radix hexadecimal} {/testbench/du_e/ddr3_dq(2) -radix hexadecimal} {/testbench/du_e/ddr3_dq(1) -radix hexadecimal} {/testbench/du_e/ddr3_dq(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr3_dq(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr3_dq
add wave -noupdate -divider {New Divider}
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/mii_clk
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/pl_frm
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/pl_irdy
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/pl_trdy
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/pl_end
add wave -noupdate -group ethtx_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/pl_data
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/hwda_irdy
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/hwda_end
add wave -noupdate -group ethtx_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/hwda_data
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/hwsa_irdy
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/hwsa_end
add wave -noupdate -group ethtx_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/hwsa_data
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/hwtyp_irdy
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/hwtyp_end
add wave -noupdate -group ethtx_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/hwtyp_data
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/tx_irdy
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/tx_trdy
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/tx_end
add wave -noupdate -group ethtx_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/tx_data
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/mii_frm
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/mii_irdy
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/mii_trdy
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/mii_end
add wave -noupdate -group ethtx_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/mii_data
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/pre_trdy
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/pre_end
add wave -noupdate -group ethtx_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/pre_data
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/minpkt
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/fcs_irdy
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/fcs_mode
add wave -noupdate -group ethtx_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/fcs_data
add wave -noupdate -group ethtx_e /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/fcs_end
add wave -noupdate -group ethtx_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethtx_e/fcs_crc
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/mii_clk
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/pl_frm
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/pl_irdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/pl_trdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/pl_end
add wave -noupdate -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/pl_data
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_frm
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/dlltx_irdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/dlltx_end
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/nettx_irdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/nettx_trdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/nettx_end
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4a_frm
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4a_irdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4a_trdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4a_end
add wave -noupdate -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4a_data
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4len_frm
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4len_irdy
add wave -noupdate -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4len_data
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4proto_frm
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4proto_irdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4proto_trdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4proto_end
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4proto_data
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_irdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_trdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_end
add wave -noupdate -group ipv4_tx -radix hexadecimal -childformat {{/testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(7) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/state
add wave -noupdate -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/frm_ptr
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4shdr_frm
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4shdr_irdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4shdr_trdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4shdr_data
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4shdr_end
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4hdr_data
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4chsm_trdy
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4chsm_end
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4chsm_data
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/cksm_irdy
add wave -noupdate -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/cksm_data
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/chksum
add wave -noupdate -group ipv4_tx /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/chksum_rev
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/vendor_data
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcp_pkt
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcp_vendor
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dscb_frame
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcp_sp
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcp_dp
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcp_mac
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/mii_clk
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dlltx_irdy
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dlltx_end
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dlltx_data
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/netdatx_irdy
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/netdatx_end
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/netlentx_irdy
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/netlentx_end
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/nettx_end
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcppkt_irdy
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcppkt_trdy
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcppkt_ena
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcppkt_end
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcppkt_data
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_ptr
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/net_end
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/payload_size
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/udp_size
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_frm
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_irdy
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_trdy
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_end
add wave -noupdate -group dhcpdscb_e -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/dhcpcd_b/dhcpcd_e/dhcpdscb_e/dhcpdscb_data
add wave -noupdate -group dhcpdscb_e -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/adjdqs_req
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/adjdqs_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_b/dqsi
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_b/dqsi_buf
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datai_b/i_igbx(1)/adjdqi_b/ddqi
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqi(1)
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/adjdqi_req
add wave -noupdate -radix unsigned -childformat {{/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_delay(0) -radix unsigned} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_delay(1) -radix unsigned} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_delay(2) -radix unsigned} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_delay(3) -radix unsigned} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_delay(4) -radix unsigned}} -subitemconfig {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_delay(0) {-height 29 -radix unsigned} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_delay(1) {-height 29 -radix unsigned} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_delay(2) {-height 29 -radix unsigned} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_delay(3) {-height 29 -radix unsigned} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_delay(4) {-height 29 -radix unsigned}} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_delay
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sdram_dqi(1)
add wave -noupdate -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/adjdqi_rdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ddr3_dq(1)
add wave -noupdate /testbench/du_e/sdrphy_e/tp_delay
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sys_sti
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sys_sto
add wave -noupdate -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dq
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/adjsto_req
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/adjsto_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_b/adjsto_e/sdram_sti
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_b/adjsto_e/sdram_sto
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_b/adjsto_e/sel
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_b/dqs_smp
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do_dv
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqs180
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do_dv(0)
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(63) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(62) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(61) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(60) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(59) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(58) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(57) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(56) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(55) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(54) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(53) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(52) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(51) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(50) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(49) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(48) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(47) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(46) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(45) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(44) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(43) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(42) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(41) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(40) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(39) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(38) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(37) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(36) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(35) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(34) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(33) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(32) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(31) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(30) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(29) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(28) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(27) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(26) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(25) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(24) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(23) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(22) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(21) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(20) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(19) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(18) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(17) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(16) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(15) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(14) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(13) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(12) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(11) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(10) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(9) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(8) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(7) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(6) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(5) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(4) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(3) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(2) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(1) -radix hexadecimal} {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(63) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(62) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(61) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(60) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(59) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(58) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(57) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(56) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(55) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(54) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(53) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(52) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(51) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(50) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(49) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(48) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(47) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(46) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(45) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(44) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(43) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(42) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(41) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(40) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(39) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(38) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(37) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(36) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(35) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(34) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(33) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(32) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(31) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(30) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(29) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(28) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(27) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(26) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(25) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(24) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(23) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(22) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(21) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(20) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(19) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(18) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(17) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(16) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(15) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(14) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(13) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(12) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(11) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(10) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(9) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(8) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(7) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(6) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(5) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(4) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(3) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(2) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(1) {-height 29 -radix hexadecimal} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do(0) {-height 29 -radix hexadecimal}} /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sys_sti
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sys_sto
add wave -noupdate -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sdram_dqi
add wave -noupdate -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sys_dqo
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqspre
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/half_align
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/data_align
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/phy_dqi
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/phy_sti
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqsi_b/dqsi_buf
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datai_b/i_igbx(1)/adjdqi_b/ddqi
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {11484681087 fs} 0} {{Cursor 2} {52888886716 fs} 0} {{Cursor 3} {94702936445 fs} 0} {{Cursor 4} {52903413962 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 228
configure wave -valuecolwidth 312
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
WaveRestoreZoom {8324653685 fs} {14542622435 fs}
