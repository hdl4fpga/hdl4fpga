onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/clk_25mhz
add wave -noupdate -expand -group ftdi /testbench/ftdi_txd
add wave -noupdate -expand -group ftdi /testbench/ftdi_rxd
add wave -noupdate -group rgmii /testbench/du_e/rgmii_rx_clk
add wave -noupdate -group rgmii /testbench/du_e/rgmii_rx_dv
add wave -noupdate -group rgmii -radix hexadecimal -childformat {{/testbench/du_e/rgmii_rxd(0) -radix hexadecimal} {/testbench/du_e/rgmii_rxd(1) -radix hexadecimal} {/testbench/du_e/rgmii_rxd(2) -radix hexadecimal} {/testbench/du_e/rgmii_rxd(3) -radix hexadecimal}} -subitemconfig {/testbench/du_e/rgmii_rxd(0) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_rxd(1) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_rxd(2) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_rxd(3) {-height 29 -radix hexadecimal}} /testbench/du_e/rgmii_rxd
add wave -noupdate -group rgmii -divider {New Divider}
add wave -noupdate -group rgmii /testbench/du_e/rgmii_tx_clk
add wave -noupdate -group rgmii /testbench/du_e/rgmii_tx_en
add wave -noupdate -group rgmii -radix hexadecimal /testbench/du_e/rgmii_txd
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
add wave -noupdate -expand -group ddram -radix hexadecimal -childformat {{/testbench/du_e/ddram_dq(15) -radix hexadecimal} {/testbench/du_e/ddram_dq(14) -radix hexadecimal} {/testbench/du_e/ddram_dq(13) -radix hexadecimal} {/testbench/du_e/ddram_dq(12) -radix hexadecimal} {/testbench/du_e/ddram_dq(11) -radix hexadecimal} {/testbench/du_e/ddram_dq(10) -radix hexadecimal} {/testbench/du_e/ddram_dq(9) -radix hexadecimal} {/testbench/du_e/ddram_dq(8) -radix hexadecimal} {/testbench/du_e/ddram_dq(7) -radix hexadecimal} {/testbench/du_e/ddram_dq(6) -radix hexadecimal} {/testbench/du_e/ddram_dq(5) -radix hexadecimal} {/testbench/du_e/ddram_dq(4) -radix hexadecimal} {/testbench/du_e/ddram_dq(3) -radix hexadecimal} {/testbench/du_e/ddram_dq(2) -radix hexadecimal} {/testbench/du_e/ddram_dq(1) -radix hexadecimal} {/testbench/du_e/ddram_dq(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddram_dq(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddram_dq(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddram_dq
add wave -noupdate -expand -group ddram -radix hexadecimal /testbench/du_e/ddram_dm
add wave -noupdate -expand -group ddram -expand /testbench/du_e/ddram_dqs
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/eclk
add wave -noupdate /testbench/du_e/sdrphy_e/sclk
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand /testbench/du_e/sdrphy_e/dqs_locked
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_cfgrdy
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/phy_frm
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/phy_trdy
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/phy_rw
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/phy_inirdy
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/phy_wlreq
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/phy_wlrdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdr3phy_i/rl_b/adjbrst_e/adj_rdy
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdr3phy_i/rl_b/adjbrst_e/adj_req
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdr3phy_i/rl_b/adjbrst_e/step_req
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdr3phy_i/rl_b/adjbrst_e/step_rdy
add wave -noupdate /testbench/du_e/sdrphy_e/sclk
add wave -noupdate /testbench/du_e/sdrphy_e/eclk
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdr3phy_i/rl_b/adjbrst_e/input
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdr3phy_i/rl_b/adjbrst_e/pause_req
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdr3phy_i/rl_b/adjbrst_e/pause_rdy
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdr3phy_i/rl_b/adjbrst_e/step_req
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdr3phy_i/rl_b/adjbrst_e/step_rdy
add wave -noupdate -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdr3phy_i/lat
add wave -noupdate -radix hexadecimal /testbench/du_e/sdrphy_e/byte_g(0)/sdr3phy_i/dqsbuf_b/readclksel
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdr3phy_i/dqsbuf_b/dqsbufm_i/DATAVALID
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdr3phy_i/dqsbuf_b/dqsbufm_i/BURSTDET
add wave -noupdate /testbench/du_e/sdrphy_e/byte_g(0)/sdr3phy_i/dqsbuf_b/dqsbufm_i/PAUSE
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/adapter_b/sync_e/video_hzcntr
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/adapter_b/sync_e/video_vtcntr
add wave -noupdate /testbench/du_e/graphics_e/video_clk
add wave -noupdate /testbench/du_e/graphics_e/video_shift_clk
add wave -noupdate /testbench/du_e/graphics_e/video_hzsync
add wave -noupdate /testbench/du_e/graphics_e/video_vtsync
add wave -noupdate /testbench/du_e/graphics_e/video_blank
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/graphics_e/video_frm
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/graphics_e/video_on
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/graphics_e/video_hzon
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/graphics_e/video_vton
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/adapter_b/graphics_e/video_word
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/adapter_b/graphics_e/video_pixel
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/graphics_e/video_rdy
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/graphics_e/video_req
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/graphics_e/dma_b/trdy
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/graphics_e/dma_b/treq
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/graphics_e/dma_b/vrdy
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/graphics_e/dma_b/vreq
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/graphics_e/desser_g/desser_e/desser_clk
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/graphics_e/desser_g/desser_e/des_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/adapter_b/graphics_e/desser_g/desser_e/des_data
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/adapter_b/graphics_e/desser_g/desser_e/ser_data
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/graphics_e/vram_e/max_depthgt1_g/mem_e/rd_addr
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/adapter_b/graphics_e/vram_e/max_depthgt1_g/mem_e/rd_data
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/adapter_b/graphics_e/vram_e/dst_data
add wave -noupdate /testbench/du_e/graphics_e/dmacfgvideo_req
add wave -noupdate /testbench/du_e/graphics_e/dmacfgvideo_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/dmavideo_req
add wave -noupdate /testbench/du_e/graphics_e/dmavideo_rdy
add wave -noupdate /testbench/du_e/graphics_e/adapter_b/graphics_e/dma_b/dmacfg_p/state
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/ctlr_do
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/ctlr_do_dv
add wave -noupdate /testbench/du_e/graphics_e/sio_b/tx_b/sodata_b/dmaso_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/sio_b/tx_b/sodata_b/dmaso_data
add wave -noupdate /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_di_dv
add wave -noupdate -radix hexadecimal /testbench/du_e/graphics_e/sdrctlr_b/sdrctlr_e/ctlr_di
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20110654524 fs} 0} {{Cursor 2} {192208514660 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 217
configure wave -valuecolwidth 124
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
WaveRestoreZoom {20098069714 fs} {20123704480 fs}
