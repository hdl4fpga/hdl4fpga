onerror {resume}
quietly virtual signal -install /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col_e { /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col_e/wr_cntr(1 to 3)} wr
quietly virtual signal -install /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col_e { /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col_e/rd_cntr(1 to 3)} rd
quietly virtual signal -install /testbench/du_e/grahics_e { (context /testbench/du_e/grahics_e )( sout_data(7) & sout_data(6) & sout_data(5) & sout_data(4) & sout_data(3) & sout_data(2) & sout_data(1) & sout_data(0) )} pp
quietly virtual signal -install /testbench/du_e/grahics_e { (context /testbench/du_e/grahics_e )( sout_data(7) & sout_data(6) & sout_data(5) & sout_data(4) & sout_data(3) & sout_data(2) & sout_data(1) & sout_data(0) )} soddata
quietly virtual signal -install /testbench/ethrx_e { (context /testbench/ethrx_e )( mii_data(3) & mii_data(2) & mii_data(1) & mii_data(0) )} mii_rdata
quietly virtual signal -install /testbench/du_e/grahics_e { (context /testbench/du_e/grahics_e )( sin_data(7) & sin_data(6) & sin_data(5) & sin_data(4) & sin_data(3) & sin_data(2) & sin_data(1) & sin_data(0) )} sin_rdata
quietly virtual signal -install /testbench/du_e/grahics_e/sio_b/metafifo_e { /testbench/du_e/grahics_e/sio_b/metafifo_e/tx_data(0 to 5)} wm
quietly virtual signal -install /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i { (context /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i )(dqs180 & dqspre )} dqss
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/btn(0)
add wave -noupdate -group eth_rx /testbench/du_e/eth_rx_clk
add wave -noupdate -group eth_rx /testbench/du_e/eth_rx_dv
add wave -noupdate -group eth_rx -radix hexadecimal /testbench/du_e/eth_rxd
add wave -noupdate -group eth_tx /testbench/du_e/eth_tx_clk
add wave -noupdate -group eth_tx /testbench/du_e/eth_tx_en
add wave -noupdate -group eth_tx -radix hexadecimal /testbench/du_e/eth_txd
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_clk_p
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_reset
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_cs
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_cke
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_odt
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_ras
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_cas
add wave -noupdate -expand -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_we
add wave -noupdate -expand -group ddr3 -divider {New Divider}
add wave -noupdate -expand -group ddr3 -radix symbolic -childformat {{/testbench/du_e/ddr3_ba(2) -radix hexadecimal} {/testbench/du_e/ddr3_ba(1) -radix hexadecimal} {/testbench/du_e/ddr3_ba(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr3_ba(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_ba(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_ba(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr3_ba
add wave -noupdate -expand -group ddr3 -radix hexadecimal -childformat {{/testbench/du_e/ddr3_a(13) -radix hexadecimal} {/testbench/du_e/ddr3_a(12) -radix hexadecimal} {/testbench/du_e/ddr3_a(11) -radix hexadecimal} {/testbench/du_e/ddr3_a(10) -radix hexadecimal} {/testbench/du_e/ddr3_a(9) -radix hexadecimal} {/testbench/du_e/ddr3_a(8) -radix hexadecimal} {/testbench/du_e/ddr3_a(7) -radix hexadecimal} {/testbench/du_e/ddr3_a(6) -radix hexadecimal} {/testbench/du_e/ddr3_a(5) -radix hexadecimal} {/testbench/du_e/ddr3_a(4) -radix hexadecimal} {/testbench/du_e/ddr3_a(3) -radix hexadecimal} {/testbench/du_e/ddr3_a(2) -radix hexadecimal} {/testbench/du_e/ddr3_a(1) -radix hexadecimal} {/testbench/du_e/ddr3_a(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr3_a(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_a(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr3_a
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_dqs_p(1)
add wave -noupdate -expand -group ddr3 /testbench/du_e/ddr3_dqs_p(0)
add wave -noupdate -expand -group ddr3 -radix hexadecimal -childformat {{/testbench/du_e/ddr3_dq(15) -radix hexadecimal} {/testbench/du_e/ddr3_dq(14) -radix hexadecimal} {/testbench/du_e/ddr3_dq(13) -radix hexadecimal} {/testbench/du_e/ddr3_dq(12) -radix hexadecimal} {/testbench/du_e/ddr3_dq(11) -radix hexadecimal} {/testbench/du_e/ddr3_dq(10) -radix hexadecimal} {/testbench/du_e/ddr3_dq(9) -radix hexadecimal} {/testbench/du_e/ddr3_dq(8) -radix hexadecimal} {/testbench/du_e/ddr3_dq(7) -radix hexadecimal} {/testbench/du_e/ddr3_dq(6) -radix hexadecimal} {/testbench/du_e/ddr3_dq(5) -radix hexadecimal} {/testbench/du_e/ddr3_dq(4) -radix hexadecimal} {/testbench/du_e/ddr3_dq(3) -radix hexadecimal} {/testbench/du_e/ddr3_dq(2) -radix hexadecimal} {/testbench/du_e/ddr3_dq(1) -radix hexadecimal} {/testbench/du_e/ddr3_dq(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddr3_dq(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddr3_dq(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddr3_dq
add wave -noupdate -group ethrx_e /testbench/ethrx_e/mii_clk
add wave -noupdate -group ethrx_e /testbench/ethrx_e/mii_frm
add wave -noupdate -group ethrx_e /testbench/ethrx_e/mii_irdy
add wave -noupdate -group ethrx_e /testbench/ethrx_e/mii_trdy
add wave -noupdate -group ethrx_e -radix hexadecimal /testbench/ethrx_e/mii_rdata
add wave -noupdate -group ethrx_e /testbench/ethrx_e/fcs_sb
add wave -noupdate -group ethrx_e /testbench/ethrx_e/fcs_vld
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/taps
add wave -noupdate -expand -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/num_of_taps
add wave -noupdate -expand -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/num_of_steps
add wave -noupdate -expand -group adjdqs1 -childformat {{/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/gaptab(5) -radix hexadecimal} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/gaptab(4) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/gaptab(3) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/gaptab(2) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/gaptab(1) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/gaptab(0) -radix unsigned}} -subitemconfig {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/gaptab(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/gaptab(4) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/gaptab(3) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/gaptab(2) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/gaptab(1) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/gaptab(0) {-height 29 -radix unsigned}} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/gaptab
add wave -noupdate -expand -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/clk
add wave -noupdate -expand -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/req
add wave -noupdate -expand -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/rdy
add wave -noupdate -expand -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/step_req
add wave -noupdate -expand -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/step_rdy
add wave -noupdate -expand -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/edge
add wave -noupdate -expand -group adjdqs1 -radix binary /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/phase
add wave -noupdate -expand -group adjdqs1 -radix unsigned /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/delay
add wave -noupdate -expand -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/inv
add wave -noupdate -expand -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/edge_req
add wave -noupdate -expand -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/edge_rdy
add wave -noupdate -expand -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/rledge
add wave -noupdate -expand -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/smp
add wave -noupdate -expand -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/seq
add wave -noupdate -expand -group adjdqs1 -radix binary -childformat {{/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/ledge(0) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/ledge(1) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/ledge(2) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/ledge(3) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/ledge(4) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/ledge(5) -radix unsigned}} -subitemconfig {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/ledge(0) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/ledge(1) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/ledge(2) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/ledge(3) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/ledge(4) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/ledge(5) {-height 29 -radix unsigned}} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/ledge
add wave -noupdate -expand -group adjdqs1 -radix binary -childformat {{/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/redge(0) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/redge(1) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/redge(2) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/redge(3) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/redge(4) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/redge(5) -radix unsigned}} -subitemconfig {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/redge(0) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/redge(1) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/redge(2) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/redge(3) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/redge(4) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/redge(5) {-height 29 -radix unsigned}} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/redge
add wave -noupdate -expand -group adjdqs1 -radix decimal /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/sum1
add wave -noupdate -expand -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/avrge
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/imdr_i/clk(0)
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/imdr_i/clk(1)
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqsi_buf
add wave -noupdate -divider {New Divider}
add wave -noupdate -group dqsimr1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/imdr_i/rst
add wave -noupdate -group dqsimr1 -expand /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/imdr_i/clk
add wave -noupdate -group dqsimr1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/imdr_i/clk(1)
add wave -noupdate -group dqsimr1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/imdr_i/d(0)
add wave -noupdate -group dqsimr1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/imdr_i/q
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqi(1)
add wave -noupdate -divider {New Divider}
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/taps
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/clk
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/req
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/rdy
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/step_req
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/step_rdy
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/edge
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/smp
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/inv
add wave -noupdate -group adjdqi0_1 -radix unsigned -childformat {{/testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/delay(0) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/delay(1) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/delay(2) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/delay(3) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/delay(4) -radix unsigned}} -subitemconfig {/testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/delay(0) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/delay(1) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/delay(2) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/delay(3) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/delay(4) {-height 29 -radix unsigned}} /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/delay
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/edge_req
add wave -noupdate -group adjdqi0_1 -radix unsigned /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(0)/adjdqi_b/adjdqi_e/sum1
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/edge_rdy
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/phase
add wave -noupdate -group adjdqi0_1 -radix unsigned /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/ledge
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/rledge
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/seq
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/avrge
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/num_of_taps
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/num_of_steps
add wave -noupdate -group adjdqi0_1 -radix unsigned -childformat {{/testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/gaptab(7) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/gaptab(6) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/gaptab(5) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/gaptab(4) -radix binary} {/testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/gaptab(3) -radix binary} {/testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/gaptab(2) -radix binary} {/testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/gaptab(1) -radix binary} {/testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/gaptab(0) -radix binary}} -subitemconfig {/testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/gaptab(7) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/gaptab(6) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/gaptab(5) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/gaptab(4) {-height 29 -radix binary} /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/gaptab(3) {-height 29 -radix binary} /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/gaptab(2) {-height 29 -radix binary} /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/gaptab(1) {-height 29 -radix binary} /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/gaptab(0) {-height 29 -radix binary}} /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/gaptab
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/sys_clks(3)
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqi(1)
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqsi_buf
add wave -noupdate -expand -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/GEAR
add wave -noupdate -expand -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/bl
add wave -noupdate -expand -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/ddr_clk
add wave -noupdate -expand -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/sys_req
add wave -noupdate -expand -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/sys_rdy
add wave -noupdate -expand -group adjsto1 /testbench/du_e/ddrphy_e/sys_sti
add wave -noupdate -expand -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/step_req
add wave -noupdate -expand -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/step_rdy
add wave -noupdate -expand -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/dqs_smp
add wave -noupdate -expand -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/ddr_sti
add wave -noupdate -expand -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/ddr_sto
add wave -noupdate -expand -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/sel
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dq
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_clks(0)
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ddrphy_e/sys_sti(7) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_sti(6) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_sti(5) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_sti(4) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_sti(3) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_sti(2) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_sti(1) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_sti(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddrphy_e/sys_sti(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_sti(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_sti(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_sti(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_sti(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_sti(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_sti(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_sti(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddrphy_e/sys_sti
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/sto
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_clks(1)
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqss
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqh
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqf
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ddrphy_e/sys_sto(7) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_sto(6) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_sto(5) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_sto(4) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_sto(3) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_sto(2) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_sto(1) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_sto(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddrphy_e/sys_sto(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_sto(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_sto(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_sto(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_sto(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_sto(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_sto(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_sto(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddrphy_e/sys_sto
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/ddrphy_e/sys_dqo(63) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(62) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(61) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(60) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(59) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(58) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(57) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(56) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(55) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(54) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(53) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(52) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(51) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(50) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(49) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(48) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(47) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(46) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(45) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(44) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(43) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(42) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(41) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(40) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(39) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(38) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(37) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(36) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(35) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(34) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(33) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(32) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(31) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(30) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(29) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(28) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(27) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(26) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(25) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(24) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(23) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(22) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(21) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(20) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(19) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(18) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(17) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(16) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(15) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(14) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(13) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(12) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(11) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(10) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(9) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(8) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(7) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(6) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(5) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(4) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(3) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(2) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(1) -radix hexadecimal} {/testbench/du_e/ddrphy_e/sys_dqo(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ddrphy_e/sys_dqo(63) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(62) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(61) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(60) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(59) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(58) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(57) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(56) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(55) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(54) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(53) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(52) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(51) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(50) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(49) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(48) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(47) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(46) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(45) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(44) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(43) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(42) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(41) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(40) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(39) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(38) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(37) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(36) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(35) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(34) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(33) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(32) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(31) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(30) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(29) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(28) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(27) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(26) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(25) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(24) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(23) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(22) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(21) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(20) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(19) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(18) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(17) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(16) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(15) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(14) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(13) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(12) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(11) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(10) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(9) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(8) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(7) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(6) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(5) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(4) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(3) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(2) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(1) {-height 29 -radix hexadecimal} /testbench/du_e/ddrphy_e/sys_dqo(0) {-height 29 -radix hexadecimal}} /testbench/du_e/ddrphy_e/sys_dqo
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/ctlr_clk
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/sys_sti(2)
add wave -noupdate /testbench/du_e/ddrphy_e/sys_sto(2)
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/sys_sti(0)
add wave -noupdate /testbench/du_e/ddrphy_e/sys_sto(0)
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/dmacfg_clk
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/dmacfg_req
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/dmacfg_rdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/ctlr_clk
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/dma_req
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/dma_rdy
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/ctlr_frm
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/rdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/req
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/src_trdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/src_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/src_data
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/dst_clk
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/dst_irdy1
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/dst_irdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/dst_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/max_depthgt1_g/mem_e/async_rddata
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/max_depthgt1_g/mem_e/rd_data
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/dst_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/sodata_e/desser_e/desser_clk
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/sodata_e/desser_e/des_frm
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/sodata_e/desser_e/des_irdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/sodata_e/desser_e/des_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/sodata_e/desser_e/des_data
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/sodata_e/desser_e/ser_irdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/sodata_e/desser_e/ser_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/sodata_e/desser_e/ser_data
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/sodata_e/desser_e/mux_ena
add wave -noupdate /testbench/du_e/grahics_e/sout_trdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/src2dst_e/src_frm
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/src2dst_e/src_frm
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/src2dst_e/rd_req
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/src2dst_e/rd_rdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/src2dst_e/src_clk
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/src2dst_e/src_data
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/src2dst_e/wr_addr
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/src2dst_e/rd_addr
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/src2dst_e/dst_clk
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/src2dst_e/mem_e/async_rddata
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/src2dst_e/dst_data
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/src_trdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/sys_clks(1)
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/dst2src_e/src_clk
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/dst2src_e/src_data
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/dst2src_e/wr_addr
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/dst2src_e/rd_addr
add wave -noupdate /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/dst2src_e/dst_clk
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/dst2src_e/mem_e/async_rddata
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/tx_b/sodata_b/dmadataout_e/sync_b/dst2src_e/dst_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/dmacfg_p/cfg_busy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/dmaio_trdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/dmaio_irdy
add wave -noupdate /testbench/du_e/grahics_e/ctlrphy_ini
add wave -noupdate /testbench/du_e/grahics_e/ctlr_inirdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/dmacfg_p/trans_busy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/ctlr_di_req
add wave -noupdate /testbench/du_e/grahics_e/sio_b/rx_b/dmadata_e/dst_irdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/rx_b/dmadata_e/dst_trdy
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dma_b/col
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_inirdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/dmacfg_clk
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/ctlr_clk
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/sout_frm
add wave -noupdate /testbench/du_e/grahics_e/sout_irdy
add wave -noupdate /testbench/du_e/grahics_e/sout_trdy
add wave -noupdate /testbench/du_e/grahics_e/sout_end
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/soddata
add wave -noupdate /testbench/du_e/grahics_e/sin_frm
add wave -noupdate /testbench/du_e/grahics_e/sio_clk
add wave -noupdate /testbench/du_e/grahics_e/sin_irdy
add wave -noupdate /testbench/du_e/grahics_e/sin_trdy
add wave -noupdate -label sin_data -radix hexadecimal /testbench/du_e/grahics_e/sin_rdata
add wave -noupdate /testbench/du_e/grahics_e/sio_b/metafifo_e/dst_irdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/metafifo_e/tx_irdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/metafifo_e/tx_trdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/metafifo_e/dst_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/metafifo_e/tx_b/cntr
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/sio_b/metafifo_e/wm
add wave -noupdate /testbench/du_e/grahics_e/sio_b/meta_end
add wave -noupdate /testbench/du_e/grahics_e/sio_b/sio_dmahdsk_e/ctlr_inirdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14366111 ps} 1} {{Cursor 2} {13450068 ps} 0} {{Cursor 3} {23733130 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 236
configure wave -valuecolwidth 244
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
WaveRestoreZoom {23706592 ps} {23804917 ps}
