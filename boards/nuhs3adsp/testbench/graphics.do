onerror {resume}
quietly virtual signal -install /testbench/du_e/grahics_e { (context /testbench/du_e/grahics_e )( sin_data(7) & sin_data(6) & sin_data(5) & sin_data(4) & sin_data(3) & sin_data(2) & sin_data(1) & sin_data(0) )} sin_rdata
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e { (context /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e )( tag_data(7) & tag_data(6) & tag_data(5) & tag_data(4) & tag_data(3) & tag_data(2) & tag_data(1) & tag_data(0) )} tag_rdata
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e { (context /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e )( plrx_data(7) & plrx_data(6) & plrx_data(5) & plrx_data(4) & plrx_data(3) & plrx_data(2) & plrx_data(1) & plrx_data(0) )} plrx_rdata
quietly virtual signal -install /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e { (context /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e )( so_data(7) & so_data(6) & so_data(5) & so_data(4) & so_data(3) & so_data(2) & so_data(1) & so_data(0) )} so_rdata
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group mii_rx /testbench/du_e/mii_rxc
add wave -noupdate -expand -group mii_rx /testbench/du_e/mii_rxdv
add wave -noupdate -expand -group mii_rx -radix hexadecimal /testbench/du_e/mii_rxd
add wave -noupdate -expand -group mii_tx /testbench/du_e/mii_txc
add wave -noupdate -expand -group mii_tx /testbench/du_e/mii_txen
add wave -noupdate -expand -group mii_tx -radix hexadecimal /testbench/du_e/mii_txd
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
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/miirx_frm
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/miirx_irdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/miirx_trdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/miirx_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/tag_frm
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/tag_irdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/tag_end
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/tag_trdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/plrx_frm
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/plrx_irdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/plrx_trdy
add wave -noupdate -label plrx_data -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/plrx_rdata
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/sio_flow_e/rx_frm
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/sio_flow_e/rx_irdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/sio_flow_e/rx_trdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/sio_flow_e/rgtr_frm
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/so_frm
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/so_irdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/so_trdy
add wave -noupdate -label so_data -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/so_rdata
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/sin_frm
add wave -noupdate /testbench/du_e/grahics_e/sin_irdy
add wave -noupdate /testbench/du_e/grahics_e/sin_trdy
add wave -noupdate -label sin_data -radix hexadecimal /testbench/du_e/grahics_e/sin_rdata
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dma_gnt(1)
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do_dv(0)
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dev_do_dv(1)
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_di_dv
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_di_req
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {140993435 ps} 0}
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
WaveRestoreZoom {139680935 ps} {142305935 ps}
