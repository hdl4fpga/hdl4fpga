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
add wave -noupdate -expand /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sys_dqt
add wave -noupdate /testbench/du_e/sdrphy_e/sys_dqt
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(1)/sdrdqphy_i/dqso_b/ogbx_i/reg_g(0)/oserdese_g/xc7a_g/oser_i/CLK
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(1)/sdrdqphy_i/dqso_b/ogbx_i/reg_g(0)/oserdese_g/xc7a_g/oser_i/CLKDIV
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(1)/sdrdqphy_i/dqso_b/ogbx_i/reg_g(0)/oserdese_g/xc7a_g/oser_i/T1
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(1)/sdrdqphy_i/dqso_b/ogbx_i/reg_g(0)/oserdese_g/xc7a_g/oser_i/T2
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(1)/sdrdqphy_i/dqso_b/ogbx_i/reg_g(0)/oserdese_g/xc7a_g/oser_i/T3
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(1)/sdrdqphy_i/dqso_b/ogbx_i/reg_g(0)/oserdese_g/xc7a_g/oser_i/T4
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/dqso_b/ogbx_i/reg_g(0)/oserdese_g/xc7a_g/oser_i/TQ
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(1)/sdrdqphy_i/clk
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(1)/sdrdqphy_i/clk_shift
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/tp_delay
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sys_dqt(3)
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sdqt(3)
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix unsigned /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/gear4_g/phdata_e/cntr
add wave -noupdate -radix unsigned /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/gear4_g/phdata_e/cntr270
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/phy_dqv
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/phy_dqo
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/ctlrphy_dqv
add wave -noupdate /testbench/du_e/graphics_e/ctlrphy_dqv
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do_dv
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sys_dqi
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand /testbench/du_e/sdrphy_e/sys_dqv
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sdqe
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(31) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(30) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(29) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(28) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(27) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(26) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(25) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(24) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(23) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(22) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(21) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(20) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(19) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(18) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(17) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(16) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(15) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(14) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(13) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(12) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(11) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(10) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(9) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(8) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(7) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(6) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(5) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(4) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(3) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(2) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(1) -radix hexadecimal} {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(31) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(30) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(29) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(28) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(27) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(26) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(25) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(24) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(23) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(22) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(21) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(20) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(19) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(18) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(17) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(16) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(15) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(14) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(13) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(12) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(11) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(10) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(9) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(8) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(7) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(6) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(5) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(4) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(3) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(2) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(1) {-height 29 -radix hexadecimal} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi(0) {-height 29 -radix hexadecimal}} /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datao_b/sdqi
add wave -noupdate -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sdram_dqo
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sys_dqi
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sys_dqv
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/sdram_sch_dqz
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/sdram_sch_wwn
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/sys_sto
add wave -noupdate -radix hexadecimal /testbench/du_e/sdrphy_e/sys_dqo
add wave -noupdate -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datai_b/sdqo
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/data_align
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/datai_b/rd_fifo_g/gear_g(3)/fifo_i/out_frm
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/rdv
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdrdqphy_i/sys_sti
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {43205629962 fs} 0} {{Cursor 2} {42670277920 fs} 0} {{Cursor 3} {42667224704 fs} 0} {{Cursor 4} {52909445000 fs} 0}
quietly wave cursor active 4
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
WaveRestoreZoom {52875905762 fs} {52911794434 fs}
