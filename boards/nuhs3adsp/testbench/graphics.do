onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -group mii_rx /testbench/du_e/mii_rxc
add wave -noupdate -group mii_rx /testbench/du_e/mii_rxdv
add wave -noupdate -group mii_rx -radix hexadecimal /testbench/du_e/mii_rxd
add wave -noupdate -group mii_tx /testbench/du_e/mii_txc
add wave -noupdate -group mii_tx /testbench/du_e/mii_txen
add wave -noupdate -group mii_tx -radix hexadecimal /testbench/du_e/mii_txd
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_ckp
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_cs
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_cke
add wave -noupdate -expand -group ddr -divider {New Divider}
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_ras
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_cas
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_we
add wave -noupdate -expand -group ddr -radix hexadecimal /testbench/du_e/ddr_ba
add wave -noupdate -expand -group ddr -radix hexadecimal /testbench/du_e/ddr_a
add wave -noupdate -expand -group ddr -divider {New Divider}
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_dqs
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_dq
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_st_dqs
add wave -noupdate -expand -group ddr /testbench/du_e/ddr_st_lp_dqs
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/mii_pre_e/mii_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/mii_data
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/serdes_e/des_frm
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/serdes_e/des_irdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/serdes_e/des_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/serdes_e/des_data
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/hwda_irdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/hwsa_irdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/hwtyp_irdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/pl_irdy
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmprx_frm
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmprx_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_e/icmprx_data
add wave -noupdate /testbench/du_e/grahics_e/coln_bits
add wave -noupdate /testbench/du_e/grahics_e/sio_b/line__284/word_bits
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/coln_bits
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/coln_align
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {208879958 ps} 0}
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
WaveRestoreZoom {208863622 ps} {209007178 ps}
