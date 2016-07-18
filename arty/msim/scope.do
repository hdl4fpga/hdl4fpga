onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/arty_e/scope_e/dataio_rst
add wave -noupdate /testbench/arty_e/scope_e/miirx_b/pktrx_rdy
add wave -noupdate -radix hexadecimal /testbench/arty_e/scope_e/miirx_b/cntr
add wave -noupdate /testbench/mii_txen
add wave -noupdate /testbench/arty_e/eth_tx_clk
add wave -noupdate /testbench/arty_e/eth_tx_en
add wave -noupdate -radix hexadecimal /testbench/arty_e/eth_txd
add wave -noupdate /testbench/arty_e/eth_rx_dv
add wave -noupdate -radix hexadecimal /testbench/arty_e/eth_rxd
add wave -noupdate /testbench/arty_e/scope_e/ddr2mii_req
add wave -noupdate /testbench/arty_e/scope_e/ddr2mii_rdy
add wave -noupdate /testbench/arty_e/scope_e/miitx_req
add wave -noupdate /testbench/arty_e/scope_e/miitx_rdy
add wave -noupdate /testbench/arty_e/scope_e/miidma_req
add wave -noupdate /testbench/arty_e/scope_e/miidma_rdy
add wave -noupdate /testbench/arty_e/scope_e/miidma_txen
add wave -noupdate -radix hexadecimal /testbench/arty_e/scope_e/miidma_txd
add wave -noupdate /testbench/arty_e/gclk100
add wave -noupdate /testbench/ddr_clk_p
add wave -noupdate /testbench/cke
add wave -noupdate /testbench/rst_n
add wave -noupdate /testbench/cs_n
add wave -noupdate /testbench/ras_n
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/we_n
add wave -noupdate /testbench/odt
add wave -noupdate -radix hexadecimal -childformat {{/testbench/ba(2) -radix hexadecimal} {/testbench/ba(1) -radix hexadecimal} {/testbench/ba(0) -radix hexadecimal}} -subitemconfig {/testbench/ba(2) {-height 16 -radix hexadecimal} /testbench/ba(1) {-height 16 -radix hexadecimal} /testbench/ba(0) {-height 16 -radix hexadecimal}} /testbench/ba
add wave -noupdate -radix hexadecimal /testbench/addr
add wave -noupdate -expand /testbench/dqs_p
add wave -noupdate -radix hexadecimal -childformat {{/testbench/dq(15) -radix hexadecimal} {/testbench/dq(14) -radix hexadecimal} {/testbench/dq(13) -radix hexadecimal} {/testbench/dq(12) -radix hexadecimal} {/testbench/dq(11) -radix hexadecimal} {/testbench/dq(10) -radix hexadecimal} {/testbench/dq(9) -radix hexadecimal} {/testbench/dq(8) -radix hexadecimal} {/testbench/dq(7) -radix hexadecimal} {/testbench/dq(6) -radix hexadecimal} {/testbench/dq(5) -radix hexadecimal} {/testbench/dq(4) -radix hexadecimal} {/testbench/dq(3) -radix hexadecimal} {/testbench/dq(2) -radix hexadecimal} {/testbench/dq(1) -radix hexadecimal} {/testbench/dq(0) -radix hexadecimal}} -subitemconfig {/testbench/dq(15) {-height 16 -radix hexadecimal} /testbench/dq(14) {-height 16 -radix hexadecimal} /testbench/dq(13) {-height 16 -radix hexadecimal} /testbench/dq(12) {-height 16 -radix hexadecimal} /testbench/dq(11) {-height 16 -radix hexadecimal} /testbench/dq(10) {-height 16 -radix hexadecimal} /testbench/dq(9) {-height 16 -radix hexadecimal} /testbench/dq(8) {-height 16 -radix hexadecimal} /testbench/dq(7) {-height 16 -radix hexadecimal} /testbench/dq(6) {-height 16 -radix hexadecimal} /testbench/dq(5) {-height 16 -radix hexadecimal} /testbench/dq(4) {-height 16 -radix hexadecimal} /testbench/dq(3) {-height 16 -radix hexadecimal} /testbench/dq(2) {-height 16 -radix hexadecimal} /testbench/dq(1) {-height 16 -radix hexadecimal} /testbench/dq(0) {-height 16 -radix hexadecimal}} /testbench/dq
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqsi
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/adjdqs_req
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/adjdqs_rdy
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/adjdqi_req
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/imdr_i/ctrl
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/imdr_i/clk
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/imdr_i/d(0)
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/imdr_i/q
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/adjdqi_rdy
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/adjsto_req
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/adjsto_rdy
add wave -noupdate -expand /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(0)/imdr_i/d
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/adjsto_e/ddr_smp
add wave -noupdate -radix unsigned /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/adjsto_e/line__33/cnt
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/adjsto_e/line__70/tmr(0)
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/adjsto_e/sel
add wave -noupdate -radix hexadecimal /testbench/arty_e/scope_e/dataio_e/ddrs_bnka
add wave -noupdate -radix hexadecimal /testbench/arty_e/scope_e/dataio_e/ddrs_rowa
add wave -noupdate -radix hexadecimal /testbench/arty_e/scope_e/dataio_e/ddrs_cola
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/sys_rdsel
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/adjsto_e/st
add wave -noupdate -color Red /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/sys_rdclk
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqsi
add wave -noupdate /testbench/arty_e/ddrphy_e/sys_iodclk
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/dqsidelay_i/CNTVALUEOUT
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/smp(0)
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {17458286 ps} 0} {{Cursor 2} {15745000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 275
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
configure wave -timelineunits ns
update
WaveRestoreZoom {17443278 ps} {17562462 ps}
