onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/arty_e/scope_e/ddr_e/xdr_pgm_e/xdr_pgm_cal
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/arty_e/ddrphy_e/sys_cas(0)
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/arty_e/scope_e/ddr_e/xdr_pgm_e/xdr_pgm_req
add wave -noupdate /testbench/dqs_p(0)
add wave -noupdate /testbench/arty_e/ddrphy_e/rotba(0)
add wave -noupdate /testbench/arty_e/ddrs_clk0div
add wave -noupdate /testbench/arty_e/ddrphy_e/sys_rlseq
add wave -noupdate /testbench/arty_e/ddrphy_e/ddrbaphy_i/sys_cas
add wave -noupdate /testbench/arty_e/scope_e/ddr_e/xdr_pgm_e/xdr_pgm_cmd
add wave -noupdate /testbench/arty_e/ddrphy_e/rlcal
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
add wave -noupdate -radix hexadecimal /testbench/dq
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/arty_e/scope_e/dataio_e/ddrs_bnka
add wave -noupdate -radix hexadecimal /testbench/arty_e/scope_e/dataio_e/ddrs_rowa
add wave -noupdate -radix hexadecimal /testbench/arty_e/scope_e/dataio_e/ddrs_cola
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/sys_rdsel
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/adjsto_e/st
add wave -noupdate -color Red /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/sys_rdclk
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqsi
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/adjsto_e/smp
add wave -noupdate -radix hexadecimal -childformat {{/testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/adjsto_e/line__28/cnt(0) -radix hexadecimal} {/testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/adjsto_e/line__28/cnt(1) -radix hexadecimal} {/testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/adjsto_e/line__28/cnt(2) -radix hexadecimal}} -subitemconfig {/testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/adjsto_e/line__28/cnt(0) {-height 16 -radix hexadecimal} /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/adjsto_e/line__28/cnt(1) {-height 16 -radix hexadecimal} /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/adjsto_e/line__28/cnt(2) {-height 16 -radix hexadecimal}} /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/adjsto_e/line__28/cnt
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/adjsto_e/sel
add wave -noupdate /testbench/arty_e/ddrphy_e/sys_iodclk
add wave -noupdate -divider {New Divider}
add wave -noupdate -color Red /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqs_clk
add wave -noupdate -radix hexadecimal /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/dqsidelay_i/CNTVALUEOUT
add wave -noupdate -radix hexadecimal /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqso_b/adjsto_e/line__28/cnt(0)
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(0)/ddrdqphy_i/smp(0)
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {16563750 ps} 0} {{Cursor 2} {16496825 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 150
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
WaveRestoreZoom {16421515 ps} {16556763 ps}
