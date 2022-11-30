onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/clk_25mhz
add wave -noupdate -group rgmii /testbench/du_e/rgmii_rx_clk
add wave -noupdate -group rgmii /testbench/du_e/rgmii_rx_dv
add wave -noupdate -group rgmii -radix hexadecimal -childformat {{/testbench/du_e/rgmii_rxd(0) -radix hexadecimal} {/testbench/du_e/rgmii_rxd(1) -radix hexadecimal} {/testbench/du_e/rgmii_rxd(2) -radix hexadecimal} {/testbench/du_e/rgmii_rxd(3) -radix hexadecimal}} -expand -subitemconfig {/testbench/du_e/rgmii_rxd(0) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_rxd(1) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_rxd(2) {-height 29 -radix hexadecimal} /testbench/du_e/rgmii_rxd(3) {-height 29 -radix hexadecimal}} /testbench/du_e/rgmii_rxd
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
add wave -noupdate -expand -group ddram /testbench/du_e/ddram_dqs
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/led
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/dll_frm
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/dll_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/dll_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/graphics_e/sio_clk
add wave -noupdate /testbench/du_e/graphics_e/sin_frm
add wave -noupdate /testbench/du_e/graphics_e/sin_irdy
add wave -noupdate /testbench/du_e/graphics_e/sin_trdy
add wave -noupdate /testbench/du_e/graphics_e/sin_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/hwdarx_vld
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4da_vld
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udprx_frm
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udp_rx_e/udp_frm
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udprx_frm
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udprx_irdy
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/udp_e/udprx_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {17513420250 fs} 0} {{Cursor 2} {47058761500 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 290
configure wave -valuecolwidth 164
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
WaveRestoreZoom {0 fs} {105 us}
