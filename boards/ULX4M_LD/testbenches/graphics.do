onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/clk_25mhz
add wave -noupdate -group ftdi /testbench/ftdi_txd
add wave -noupdate -group ftdi /testbench/ftdi_rxd
add wave -noupdate -group rgmii /testbench/du_e/rgmii_rx_clk
add wave -noupdate -group rgmii /testbench/du_e/rgmii_rx_dv
add wave -noupdate -group rgmii -radix hexadecimal -childformat {{/testbench/du_e/rgmii_rxd(0) -radix hexadecimal} {/testbench/du_e/rgmii_rxd(1) -radix hexadecimal} {/testbench/du_e/rgmii_rxd(2) -radix hexadecimal} {/testbench/du_e/rgmii_rxd(3) -radix hexadecimal}} -subitemconfig {/testbench/du_e/rgmii_rxd(0) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_rxd(1) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_rxd(2) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_rxd(3) {-height 29 -radix hexadecimal}} /testbench/du_e/rgmii_rxd
add wave -noupdate -group rgmii -divider {New Divider}
add wave -noupdate -group rgmii /testbench/du_e/rgmii_tx_clk
add wave -noupdate -group rgmii /testbench/du_e/rgmii_tx_en
add wave -noupdate -group rgmii -radix hexadecimal -childformat {{/testbench/du_e/rgmii_txd(0) -radix hexadecimal} {/testbench/du_e/rgmii_txd(1) -radix hexadecimal} {/testbench/du_e/rgmii_txd(2) -radix hexadecimal} {/testbench/du_e/rgmii_txd(3) -radix hexadecimal}} -subitemconfig {/testbench/du_e/rgmii_txd(0) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_txd(1) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_txd(2) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_txd(3) {-height 29 -radix hexadecimal}} /testbench/du_e/rgmii_txd
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_clk
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_reset_n
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_cke
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_cs_n
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_ras_n
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_cas_n
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_we_n
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_odt
add wave -noupdate -expand -group ddram -radix hexadecimal /testbench/du_e/ddram_a
add wave -noupdate -expand -group ddram -radix hexadecimal /testbench/du_e/ddram_ba
add wave -noupdate -expand -group ddram -radix hexadecimal /testbench/du_e/ddram_dm
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_dqs
add wave -noupdate -expand -group ddram -radix hexadecimal -childformat {{/testbench/du_e/ddram_dq(15) -radix hexadecimal} {/testbench/du_e/ddram_dq(14) -radix hexadecimal} {/testbench/du_e/ddram_dq(13) -radix hexadecimal} {/testbench/du_e/ddram_dq(12) -radix hexadecimal} {/testbench/du_e/ddram_dq(11) -radix hexadecimal} {/testbench/du_e/ddram_dq(10) -radix hexadecimal} {/testbench/du_e/ddram_dq(9) -radix hexadecimal} {/testbench/du_e/ddram_dq(8) -radix hexadecimal} {/testbench/du_e/ddram_dq(7) -radix hexadecimal} {/testbench/du_e/ddram_dq(6) -radix hexadecimal} {/testbench/du_e/ddram_dq(5) -radix hexadecimal} {/testbench/du_e/ddram_dq(4) -radix hexadecimal} {/testbench/du_e/ddram_dq(3) -radix hexadecimal} {/testbench/du_e/ddram_dq(2) -radix hexadecimal} {/testbench/du_e/ddram_dq(1) -radix hexadecimal} {/testbench/du_e/ddram_dq(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddram_dq(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddram_dq
add wave -noupdate -expand -group usb /testbench/du_e/usb_fpga_dp
add wave -noupdate -expand -group usb /testbench/du_e/usb_fpga_dn
add wave -noupdate -divider {New Divider}
add wave -noupdate -group sdrphy_e /testbench/du_e/sdrphy_e/sclk
add wave -noupdate -group sdrphy_e /testbench/du_e/sdrphy_e/eclk
add wave -noupdate -group sdrphy_e /testbench/du_e/sdrphy_e/sys_dmi
add wave -noupdate -group sdrphy_e /testbench/du_e/sdrphy_e/sys_dqt
add wave -noupdate -group sdrphy_e -radix hexadecimal /testbench/du_e/sdrphy_e/sys_dqi
add wave -noupdate -group sdrphy_e -radix hexadecimal /testbench/du_e/sdrphy_e/sys_dqo
add wave -noupdate -group sdrphy_e /testbench/du_e/sdrphy_e/sys_dqsi
add wave -noupdate -group sdrphy_e /testbench/du_e/sdrphy_e/sys_dqst
add wave -noupdate -group sdrphy_e /testbench/du_e/sdrphy_e/sys_dqv
add wave -noupdate -group sdrphy_e /testbench/du_e/sdrphy_e/sys_sti
add wave -noupdate -group sdrphy_e -radix hexadecimal /testbench/du_e/sdrphy_e/sys_sto
add wave -noupdate -group sdrphy_e -expand -group byte_g0 /testbench/du_e/sdrphy_e/byte_g(0)/sdrphy_i/burstdet
add wave -noupdate -group sdrphy_e -expand -group byte_g0 /testbench/du_e/sdrphy_e/byte_g(0)/sdrphy_i/datavalid
add wave -noupdate -group sdrphy_e -expand -group byte_g0 -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrphy_i/dqi
add wave -noupdate -group sdrphy_e -expand -group byte_g0 /testbench/du_e/sdrphy_e/byte_g(0)/sdrphy_i/sys_sti
add wave -noupdate -group sdrphy_e -expand -group byte_g0 -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrphy_i/sys_dqo
add wave -noupdate -group sdrphy_e -expand -group byte_g0 -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrphy_i/sys_dqi
add wave -noupdate -group sdrphy_e -expand -group byte_g0 -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdrphy_i/sdram_dq
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/usbtb_e/dev_cfgd
add wave -noupdate -radix hexadecimal /testbench/usbtb_e/hdlctx_data
add wave -noupdate /testbench/usbtb_e/hdlctx_trdy
add wave -noupdate /testbench/du_e/usb_g/usb_e/so_frm
add wave -noupdate /testbench/du_e/usb_g/usb_e/so_irdy
add wave -noupdate /testbench/du_e/usb_g/usb_e/so_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/usb_g/usb_e/so_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/usbtb_e/usb_txen
add wave -noupdate /testbench/usbtb_e/usb_txbs
add wave -noupdate /testbench/usbtb_e/usb_txd
add wave -noupdate /testbench/du_e/usb_g/usb_e/usbdev_e/txen
add wave -noupdate /testbench/du_e/usb_g/usb_e/usbdev_e/txbs
add wave -noupdate /testbench/du_e/usb_g/usb_e/usbdev_e/txd
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/dmactlr_b/dmactlr_e/ctlr_refreq
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/sdram_pgm_e/sdram_ref_req
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/sdram_pgm_e/sdram_ref_rdy
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/sdram_pgm_e/pgm_refq
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/sdram_pgm_e/pgm_refy
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/sdram_pgm_e/sdram_mpu_trdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/ctlr_clk
add wave -noupdate /testbench/du_e/graphics_e/dmactlr_b/line__891/state
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_do_dv(0)
add wave -noupdate /testbench/du_e/graphics_e/dev_gnt(1)
add wave -noupdate /testbench/du_e/graphics_e/dmactlr_b/line__891/gnt_dv(1)
add wave -noupdate /testbench/du_e/graphics_e/dmaio_do_dv
add wave -noupdate /testbench/du_e/graphics_e/sio_b/tx_b/sodata_b/dmaso_irdy
add wave -noupdate /testbench/du_e/graphics_e/sio_b/tx_b/sodata_b/dmaso_trdy
add wave -noupdate -expand /testbench/du_e/graphics_e/dmactlr_b/dev_do_dv
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/sio_b/tx_b/sodata_b/fifo_irdy
add wave -noupdate /testbench/du_e/graphics_e/sio_b/tx_b/sodata_b/fifo_trdy
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/sio_b/tx_b/sodata_b/sodata_e/low_cntr
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/sio_b/tx_b/sodata_b/sodata_e/high_cntr
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/sio_b/tx_b/sodata_irdy
add wave -noupdate /testbench/du_e/graphics_e/sio_b/tx_b/sodata_trdy
add wave -noupdate /testbench/du_e/graphics_e/sio_b/tx_b/sodata_end
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/sout_clk
add wave -noupdate /testbench/du_e/graphics_e/sout_frm
add wave -noupdate /testbench/du_e/graphics_e/sout_irdy
add wave -noupdate /testbench/du_e/graphics_e/sout_trdy
add wave -noupdate /testbench/du_e/graphics_e/sout_end
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/usbtb_e/indata_req
add wave -noupdate /testbench/usbtb_e/indata_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/ctlrphy_cke
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {86848030 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 214
configure wave -valuecolwidth 178
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
WaveRestoreZoom {86310230 ps} {87270070 ps}
