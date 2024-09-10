onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/sdram_clk
add wave -noupdate /testbench/du_e/sdram_cke
add wave -noupdate /testbench/du_e/sdram_csn
add wave -noupdate /testbench/du_e/sdram_wen
add wave -noupdate /testbench/du_e/sdram_rasn
add wave -noupdate /testbench/du_e/sdram_casn
add wave -noupdate /testbench/du_e/sdram_a
add wave -noupdate /testbench/du_e/sdram_ba
add wave -noupdate /testbench/du_e/sdram_dqm
add wave -noupdate /testbench/du_e/sdram_d
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/scopeio_e/capture_b/stream_e/stream_clk
add wave -noupdate /testbench/du_e/scopeio_e/capture_b/stream_e/stream_irdy
add wave -noupdate /testbench/du_e/scopeio_e/capture_b/stream_e/stream_data
add wave -noupdate -radix hexadecimal /testbench/du_e/scopeio_e/capture_b/stream_e/stream_b/line__139/level
add wave -noupdate /testbench/du_e/scopeio_e/capture_b/stream_e/wm_req
add wave -noupdate /testbench/du_e/scopeio_e/capture_b/stream_e/wm_rdy
add wave -noupdate /testbench/du_e/scopeio_e/capture_b/stream_e/dmacfg_clk
add wave -noupdate /testbench/du_e/scopeio_e/capture_b/stream_e/dmacfg_req
add wave -noupdate /testbench/du_e/scopeio_e/capture_b/stream_e/dmacfg_rdy
add wave -noupdate /testbench/du_e/scopeio_e/capture_b/stream_e/ctlr_clk
add wave -noupdate /testbench/du_e/scopeio_e/capture_b/stream_e/dma_req
add wave -noupdate /testbench/du_e/scopeio_e/capture_b/stream_e/dma_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlr_clk
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlr_rst
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlr_al
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlr_bl
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlr_cl
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlr_cwl
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlr_wrl
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlr_rtt
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlr_cmd
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlr_inirdy
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_wlreq
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_wlrdy
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_rlreq
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_rlrdy
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_irdy
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_trdy
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_rw
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_ini
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_rst
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_cke
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_cs
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_ras
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_cas
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_we
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_odt
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_b
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_a
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_dqst
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_dqso
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_dmi
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_dmo
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_dqt
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_dqi
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_dqo
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_dqv
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_sto
add wave -noupdate -group scopeio_sdr /testbench/du_e/scopeio_e/ctlrphy_sti
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {116573386340 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 705
configure wave -valuecolwidth 108
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
WaveRestoreZoom {0 fs} {84488793100 fs}
