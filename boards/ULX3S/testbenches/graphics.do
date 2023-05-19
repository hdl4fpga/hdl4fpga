onerror {resume}
quietly virtual signal -install /testbench/du_e { (context /testbench/du_e )(rmii_tx0 & rmii_tx1 )} rmii_tx
quietly virtual signal -install /testbench/du_e { (context /testbench/du_e )(rmii_rx0 & rmii_rx1 )} rmii_rx
quietly WaveActivateNextPane {} 0
add wave -noupdate -group uart /testbench/du_e/ftdi_txd
add wave -noupdate -group uart /testbench/du_e/ftdi_rxd
add wave -noupdate -group uart /testbench/du_e/ftdi_txd
add wave -noupdate -group uart /testbench/du_e/ftdi_rxd
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_clk
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_cke
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_csn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_rasn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_casn
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_wen
add wave -noupdate -expand -group sdram -radix hexadecimal /testbench/du_e/sdram_a
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_ba
add wave -noupdate -expand -group sdram /testbench/du_e/sdram_dqm
add wave -noupdate -expand -group sdram -radix hexadecimal -childformat {{/testbench/du_e/sdram_d(15) -radix hexadecimal} {/testbench/du_e/sdram_d(14) -radix hexadecimal} {/testbench/du_e/sdram_d(13) -radix hexadecimal} {/testbench/du_e/sdram_d(12) -radix hexadecimal} {/testbench/du_e/sdram_d(11) -radix hexadecimal} {/testbench/du_e/sdram_d(10) -radix hexadecimal} {/testbench/du_e/sdram_d(9) -radix hexadecimal} {/testbench/du_e/sdram_d(8) -radix hexadecimal} {/testbench/du_e/sdram_d(7) -radix hexadecimal} {/testbench/du_e/sdram_d(6) -radix hexadecimal} {/testbench/du_e/sdram_d(5) -radix hexadecimal} {/testbench/du_e/sdram_d(4) -radix hexadecimal} {/testbench/du_e/sdram_d(3) -radix hexadecimal} {/testbench/du_e/sdram_d(2) -radix hexadecimal} {/testbench/du_e/sdram_d(1) -radix hexadecimal} {/testbench/du_e/sdram_d(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/sdram_d(15) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(14) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(13) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(12) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(11) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(10) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(9) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(8) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(7) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(6) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(5) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(4) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(3) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(2) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(1) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_d(0) {-height 29 -radix hexadecimal}} /testbench/du_e/sdram_d
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_g/mii_clk
add wave -noupdate -expand -group rmii_rx /testbench/du_e/rmii_crsdv
add wave -noupdate -expand -group rmii_rx -label rmii_rxd -radix hexadecimal -childformat {{/testbench/du_e/rmii_rx(1) -radix hexadecimal} {/testbench/du_e/rmii_rx(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/rmii_rx0 {-radix hexadecimal} /testbench/du_e/rmii_rx1 {-radix hexadecimal}} /testbench/du_e/rmii_rx
add wave -noupdate -expand -group rmii_tx /testbench/du_e/rmii_tx_en
add wave -noupdate -expand -group rmii_tx -label rmii_txd -radix hexadecimal -childformat {{/testbench/du_e/rmii_tx(1) -radix hexadecimal} {/testbench/du_e/rmii_tx(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/rmii_tx0 {-radix hexadecimal} /testbench/du_e/rmii_tx1 {-radix hexadecimal}} /testbench/du_e/rmii_tx
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group graphics_e -radix hexadecimal /testbench/du_e/graphics_e/ctlrphy_dqi
add wave -noupdate -expand -group graphics_e /testbench/du_e/graphics_e/ctlrphy_sto
add wave -noupdate -expand -group graphics_e /testbench/du_e/graphics_e/ctlrphy_sti
add wave -noupdate -expand -group graphics_e -radix hexadecimal /testbench/du_e/graphics_e/ctlrphy_dqi
add wave -noupdate -expand -group graphics_e /testbench/du_e/graphics_e/dma_do
add wave -noupdate -expand -group graphics_e /testbench/du_e/graphics_e/dma_do_dv
add wave -noupdate -expand -group graphics_e -radix hexadecimal /testbench/du_e/graphics_e/ctlrphy_dqi
add wave -noupdate -expand -group graphics_e -expand /testbench/du_e/graphics_e/ctlrphy_sto
add wave -noupdate -expand -group graphics_e -expand /testbench/du_e/graphics_e/ctlrphy_sti
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/sclk
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/sys_sti
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/sys_sto
add wave -noupdate -expand -group sdrphy_e -radix hexadecimal /testbench/du_e/sdrphy_e/sys_dqo
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/sclk
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/sys_sti
add wave -noupdate -expand -group sdrphy_e /testbench/du_e/sdrphy_e/sys_sto
add wave -noupdate -expand -group sdrphy_e -radix hexadecimal /testbench/du_e/sdrphy_e/sys_dqo
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/video_clk
add wave -noupdate /testbench/du_e/graphics_e/video_shift_clk
add wave -noupdate /testbench/du_e/graphics_e/video_hzsync
add wave -noupdate /testbench/du_e/graphics_e/video_vtsync
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {61003308638 fs} 0} {{Cursor 2} {54760001270 fs} 0} {{Cursor 3} {180829124298 fs} 0} {{Cursor 4} {42749974882 fs} 0}
quietly wave cursor active 3
configure wave -namecolwidth 271
configure wave -valuecolwidth 256
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
WaveRestoreZoom {180805175781 fs} {181010253907 fs}
