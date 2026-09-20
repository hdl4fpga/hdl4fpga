onerror {resume}
quietly virtual signal -install /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/rxserlzr_e {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/rxserlzr_e/dst_data  } rev_data
quietly virtual signal -install /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e { (context /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e )( srzrx_data(7) & srzrx_data(6) & srzrx_data(5) & srzrx_data(4) & srzrx_data(3) & srzrx_data(2) & srzrx_data(1) & srzrx_data(0) )} rev_srzrx_data
quietly virtual signal -install /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e { (context /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e )( pylrx_data(7) & pylrx_data(6) & pylrx_data(5) & pylrx_data(4) & pylrx_data(3) & pylrx_data(2) & pylrx_data(1) & pylrx_data(0) )} rev_pylrx_data
quietly virtual signal -install /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e { (context /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e )( srztx_data(7) & srztx_data(6) & srztx_data(5) & srztx_data(4) & srztx_data(3) & srztx_data(2) & srztx_data(1) & srztx_data(0) )} rev_srztx_data
quietly virtual signal -install /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e { (context /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e )( rx_data(7) & rx_data(6) & rx_data(5) & rx_data(4) & rx_data(3) & rx_data(2) & rx_data(1) & rx_data(0) )} rev_rx_data
quietly virtual signal -install /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e { (context /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e )( tx_data(7) & tx_data(6) & tx_data(5) & tx_data(4) & tx_data(3) & tx_data(2) & tx_data(1) & tx_data(0) )} rev_tx_data
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {CGA CODE}
add wave -noupdate /testbench/du_e/video_g/ser_debug_e/ser_display_e/cga_we
add wave -noupdate -radix ascii /testbench/du_e/video_g/ser_debug_e/ser_display_e/cga_codes
add wave -noupdate -divider RX
add wave -noupdate /testbench/rmii_clk
add wave -noupdate /testbench/rmii_rxdv
add wave -noupdate -radix binary /testbench/rmii_rxd
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/fcs_sb
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/fcs_vld
add wave -noupdate -divider TX
add wave -noupdate /testbench/rmii_txen
add wave -noupdate -radix symbolic -childformat {{/testbench/rmii_txd(0) -radix hexadecimal} {/testbench/rmii_txd(1) -radix hexadecimal}} -subitemconfig {/testbench/rmii_txd(0) {-height 20 -radix hexadecimal} /testbench/rmii_txd(1) {-height 20 -radix hexadecimal}} /testbench/rmii_txd
add wave -noupdate /testbench/tb_ipoe_b/tbipoe_e/tbehrx_e/fcs_sb
add wave -noupdate /testbench/tb_ipoe_b/tbipoe_e/tbehrx_e/fcs_vld
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group miiipoe /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppylrx_frm
add wave -noupdate -expand -group miiipoe /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppylrx_irdy
add wave -noupdate -expand -group miiipoe /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppylrx_trdy
add wave -noupdate -expand -group miiipoe -radix binary -childformat {{/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppylrx_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppylrx_data(1) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppylrx_data(0) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppylrx_data(1) {-height 20 -radix hexadecimal}} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppylrx_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -group sio_udp /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_frm
add wave -noupdate -group sio_udp /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_irdy
add wave -noupdate -group sio_udp /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_trdy
add wave -noupdate -group sio_udp -radix hexadecimal -childformat {{/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(0) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(1) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(2) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(3) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(4) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(5) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(6) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data(7) {-height 20 -radix hexadecimal}} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srzrx_data
add wave -noupdate -group sio_udp -radix hexadecimal /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/rev_srzrx_data
add wave -noupdate -group sio_udp /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/pylfcs_sb
add wave -noupdate -group sio_udp /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/pylfcs_vld
add wave -noupdate -group sio_udp /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_frm
add wave -noupdate -group sio_udp /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_irdy
add wave -noupdate -group sio_udp /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_trdy
add wave -noupdate -group sio_udp -radix hexadecimal -childformat {{/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_data(0) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_data(1) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_data(2) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_data(3) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_data(4) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_data(5) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_data(6) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_data(7) {-height 20 -radix hexadecimal}} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/srztx_data
add wave -noupdate -group sio_udp -radix hexadecimal /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/rev_srztx_data
add wave -noupdate -group sio_udp /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppyltx_frm
add wave -noupdate -group sio_udp /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppyltx_irdy
add wave -noupdate -group sio_udp /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppyltx_trdy
add wave -noupdate -group sio_udp /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppyltx_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group sio_flow /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_clk
add wave -noupdate -expand -group sio_flow /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_frm
add wave -noupdate -expand -group sio_flow /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_irdy
add wave -noupdate -expand -group sio_flow /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_trdy
add wave -noupdate -expand -group sio_flow -radix hexadecimal -childformat {{/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data(0) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data(1) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data(2) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data(3) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data(4) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data(5) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data(6) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data(7) {-height 20 -radix hexadecimal}} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rx_data
add wave -noupdate -expand -group sio_flow -radix hexadecimal /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rev_rx_data
add wave -noupdate -expand -group sio_flow /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_frm
add wave -noupdate -expand -group sio_flow /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_irdy
add wave -noupdate -expand -group sio_flow /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_trdy
add wave -noupdate -expand -group sio_flow -radix hexadecimal -childformat {{/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_data(0) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_data(1) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_data(2) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_data(3) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_data(4) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_data(5) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_data(6) {-height 20 -radix hexadecimal} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_data(7) {-height 20 -radix hexadecimal}} /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/tx_data
add wave -noupdate -expand -group sio_flow -radix hexadecimal /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/sio_flow_e/rev_tx_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/udptx_frm
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/udptx_irdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/udptx_trdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/udptx_data
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/tx_b/header_irdys
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/tx_b/buffer_frm
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/tx_b/buffer_irdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/tx_b/buffer_trdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/tx_b/buffer_data
add wave -noupdate -expand -group udp_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppyltx_frm
add wave -noupdate -expand -group udp_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppyltx_irdy
add wave -noupdate -expand -group udp_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppyltx_trdy
add wave -noupdate -expand -group udp_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/udppyltx_data
add wave -noupdate -expand -group udp_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/udp_i/tx_b/udplength_act
add wave -noupdate -expand -group udp_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/udp_i/tx_b/chksum_act
add wave -noupdate -expand -group udp_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/udp_i/pyltx_data
add wave -noupdate -expand -group udp_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/udp_i/tx_b/buffer_frm
add wave -noupdate -expand -group udp_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/udp_i/tx_b/buffer_irdy
add wave -noupdate -expand -group udp_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/udp_i/tx_b/buffer_trdy
add wave -noupdate -expand -group udp_tx /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/miiipoe_i/ipv4_i/udp_i/tx_b/buffer_data
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/txserlzr_e/src_frm
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/txserlzr_e/src_irdy
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/txserlzr_e/src_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/txserlzr_e/src_data
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/txserlzr_e/dst_frm
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/txserlzr_e/dst_irdy
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/txserlzr_e/dst_trdy
add wave -noupdate /testbench/du_e/ipoe_g/mii_e/udpdaisy_e/sio_udp_e/txserlzr_e/dst_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2887500000 fs} 0} {{Cursor 2} {12720827700 fs} 0}
quietly wave cursor active 2
configure wave -namecolwidth 736
configure wave -valuecolwidth 100
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
WaveRestoreZoom {12593125 ps} {12765097970 fs}
