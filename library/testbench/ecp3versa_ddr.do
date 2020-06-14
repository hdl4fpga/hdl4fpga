onerror {resume}
quietly virtual signal -install /testbench/du_e { /testbench/du_e/ddrphy_a(12 downto 0)} g_ddrphy_a
quietly virtual signal -install /testbench/du_e { /testbench/du_e/ddrphy_b(2 downto 0)} g_ddrphy_b
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group micron /testbench/mt_u/rst_n
add wave -noupdate -expand -group micron /testbench/mt_u/ck
add wave -noupdate -expand -group micron /testbench/mt_u/ck_n
add wave -noupdate -expand -group micron /testbench/mt_u/cke
add wave -noupdate -expand -group micron /testbench/mt_u/cs_n
add wave -noupdate -expand -group micron /testbench/mt_u/ras_n
add wave -noupdate -expand -group micron /testbench/mt_u/cas_n
add wave -noupdate -expand -group micron /testbench/mt_u/we_n
add wave -noupdate -expand -group micron /testbench/mt_u/dm_tdqs
add wave -noupdate -expand -group micron -radix binary /testbench/mt_u/ba
add wave -noupdate -expand -group micron -radix hexadecimal /testbench/mt_u/addr
add wave -noupdate -expand -group micron -radix hexadecimal /testbench/mt_u/dq
add wave -noupdate -expand -group micron /testbench/mt_u/dqs
add wave -noupdate -expand -group micron -expand /testbench/mt_u/dqs_n
add wave -noupdate -expand -group micron /testbench/mt_u/tdqs_n
add wave -noupdate -expand -group micron /testbench/mt_u/odt
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/clk
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/led(7) -radix hexadecimal} {/testbench/du_e/led(6) -radix hexadecimal} {/testbench/du_e/led(5) -radix hexadecimal} {/testbench/du_e/led(4) -radix hexadecimal} {/testbench/du_e/led(3) -radix hexadecimal} {/testbench/du_e/led(2) -radix hexadecimal} {/testbench/du_e/led(1) -radix hexadecimal} {/testbench/du_e/led(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/led(7) {-height 29 -radix hexadecimal} /testbench/du_e/led(6) {-height 29 -radix hexadecimal} /testbench/du_e/led(5) {-height 29 -radix hexadecimal} /testbench/du_e/led(4) {-height 29 -radix hexadecimal} /testbench/du_e/led(3) {-height 29 -radix hexadecimal} /testbench/du_e/led(2) {-height 29 -radix hexadecimal} /testbench/du_e/led(1) {-height 29 -radix hexadecimal} /testbench/du_e/led(0) {-height 29 -radix hexadecimal}} /testbench/du_e/led
add wave -noupdate /testbench/du_e/fpga_gsrn
add wave -noupdate /testbench/du_e/phy1_rst
add wave -noupdate /testbench/du_e/phy1_rxc
add wave -noupdate /testbench/du_e/phy1_rx_dv
add wave -noupdate -radix hexadecimal /testbench/du_e/phy1_rx_d
add wave -noupdate /testbench/du_e/ddr_eclk
add wave -noupdate /testbench/du_e/ddr_sclk
add wave -noupdate /testbench/du_e/ddr_sclk2x
add wave -noupdate /testbench/du_e/ctlr_inirdy
add wave -noupdate -radix hexadecimal /testbench/du_e/g_ddrphy_b
add wave -noupdate -radix hexadecimal /testbench/du_e/g_ddrphy_a
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand /testbench/du_e/dmacfg_req
add wave -noupdate /testbench/du_e/dmacfg_rdy
add wave -noupdate -radix hexadecimal /testbench/du_e/dmaio_len
add wave -noupdate -radix hexadecimal /testbench/du_e/dmaio_addr
add wave -noupdate /testbench/du_e/dmaio_dv
add wave -noupdate /testbench/du_e/dmacfgvideo_req
add wave -noupdate /testbench/du_e/dmacfgvideo_rdy
add wave -noupdate /testbench/du_e/dmavideo_req
add wave -noupdate /testbench/du_e/dmavideo_rdy
add wave -noupdate -radix hexadecimal /testbench/du_e/dmavideo_len
add wave -noupdate -radix hexadecimal /testbench/du_e/dmavideo_addr
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_e/dmatrans_iaddr
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_e/dmatrans_ilen
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_e/dmatrans_taddr
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_e/dmatrans_tlen
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/scopeio_export_b/src_frm
add wave -noupdate /testbench/du_e/scopeio_export_b/si_frm
add wave -noupdate /testbench/du_e/scopeio_export_b/si_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_export_b/si_data
add wave -noupdate -expand /testbench/du_e/dmacfg_req
add wave -noupdate -expand /testbench/du_e/dmacfg_rdy
add wave -noupdate -expand /testbench/du_e/dev_req
add wave -noupdate -expand /testbench/du_e/dev_rdy
add wave -noupdate -radix hexadecimal /testbench/du_e/led
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrctlr_e/ctlr_clks(0)
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrctlr_e/ctlr_do_dv(0)
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrctlr_e/ctlr_do
add wave -noupdate /testbench/du_e/ctlr_di_dv
add wave -noupdate /testbench/du_e/ctlr_di_req
add wave -noupdate -radix hexadecimal /testbench/du_e/dmaio_len
add wave -noupdate -radix hexadecimal /testbench/du_e/dmaio_addr
add wave -noupdate /testbench/du_e/dmaio_dv
add wave -noupdate -radix hexadecimal /testbench/du_e/dmavideo_len
add wave -noupdate -radix hexadecimal /testbench/du_e/dmavideo_addr
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_e/dmatrans_iaddr
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_e/dmatrans_ilen
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_e/dmatrans_taddr
add wave -noupdate -radix hexadecimal /testbench/du_e/dmactlr_e/dmatrans_e/dmatrans_tlen
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/scopeio_export_b/si_frm
add wave -noupdate /testbench/du_e/scopeio_export_b/si_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_export_b/si_data
add wave -noupdate -expand /testbench/du_e/dmacfg_req
add wave -noupdate -expand /testbench/du_e/dmacfg_rdy
add wave -noupdate -expand /testbench/du_e/dev_req
add wave -noupdate -expand /testbench/du_e/dev_rdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 5} {706720008450 fs} 0} {{Cursor 2} {706724017690 fs} 0}
quietly wave cursor active 2
configure wave -namecolwidth 239
configure wave -valuecolwidth 149
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
WaveRestoreZoom {706712320150 fs} {706735679850 fs}
