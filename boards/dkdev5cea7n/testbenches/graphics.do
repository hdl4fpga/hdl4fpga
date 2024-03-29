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
add wave -noupdate -expand -group eth_rx /testbench/du_e/eth_rx_clk
add wave -noupdate -expand -group eth_rx /testbench/du_e/eth_rx_dv
add wave -noupdate -expand -group eth_rx -radix hexadecimal /testbench/du_e/eth_rxd
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
add wave -noupdate -divider {New Divider}
add wave -noupdate -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/taps
add wave -noupdate -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/clk
add wave -noupdate -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/req
add wave -noupdate -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/rdy
add wave -noupdate -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/step_req
add wave -noupdate -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/step_rdy
add wave -noupdate -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/edge
add wave -noupdate -group adjdqs1 -radix binary /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/phase
add wave -noupdate -group adjdqs1 -radix unsigned -childformat {{/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/delay(0) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/delay(1) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/delay(2) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/delay(3) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/delay(4) -radix unsigned}} -subitemconfig {/testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/delay(0) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/delay(1) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/delay(2) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/delay(3) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/delay(4) {-height 29 -radix unsigned}} /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/delay
add wave -noupdate -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/inv
add wave -noupdate -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/edge_req
add wave -noupdate -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/edge_rdy
add wave -noupdate -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/rledge
add wave -noupdate -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/smp
add wave -noupdate -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/seq
add wave -noupdate -group adjdqs1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjdqs_e/avrge
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
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/edge_rdy
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/phase
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/rledge
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/seq
add wave -noupdate -group adjdqi0_1 /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(1)/adjdqi_b/adjdqi_e/avrge
add wave -noupdate -group dqsimr1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/imdr_i/rst
add wave -noupdate -group dqsimr1 -expand /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/imdr_i/clk
add wave -noupdate -group dqsimr1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/imdr_i/clk(1)
add wave -noupdate -group dqsimr1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/imdr_i/d(0)
add wave -noupdate -group dqsimr1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/imdr_i/q
add wave -noupdate -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/GEAR
add wave -noupdate -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/bl
add wave -noupdate -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/ddr_clk
add wave -noupdate -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/sys_req
add wave -noupdate -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/sys_rdy
add wave -noupdate -group adjsto1 /testbench/du_e/ddrphy_e/sys_sti
add wave -noupdate -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/step_req
add wave -noupdate -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/step_rdy
add wave -noupdate -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/dqs_smp
add wave -noupdate -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/ddr_sti
add wave -noupdate -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/ddr_sto
add wave -noupdate -group adjsto1 /testbench/du_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqsi_b/adjsto_e/sel
add wave -noupdate -divider {New Divider}
add wave -noupdate -group ethrx_e /testbench/ethrx_e/mii_clk
add wave -noupdate -group ethrx_e /testbench/ethrx_e/mii_frm
add wave -noupdate -group ethrx_e /testbench/ethrx_e/mii_irdy
add wave -noupdate -group ethrx_e /testbench/ethrx_e/mii_trdy
add wave -noupdate -group ethrx_e -radix hexadecimal /testbench/ethrx_e/mii_rdata
add wave -noupdate -group ethrx_e /testbench/ethrx_e/fcs_sb
add wave -noupdate -group ethrx_e /testbench/ethrx_e/fcs_vld
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ddr_mpu_e/ddr_mpu_p/id
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ddr_init_e/ddr_timer_id
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do_dv
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ctlr_do
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/read_leveling_l_b/leveling
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/read_leveling_l_b/readcycle_p/z
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iod_clk
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iod_clk
add wave -noupdate /testbench/du_e/ddrphy_e/read_leveling_l_b/readcycle_p/state
add wave -noupdate /testbench/du_e/ddrphy_e/phy_trdy
add wave -noupdate /testbench/du_e/ddrphy_e/read_leveling_l_b/ddr_idle
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/read_req
add wave -noupdate /testbench/du_e/ddrphy_e/read_rdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/phy_wlreq
add wave -noupdate /testbench/du_e/ddrphy_e/phy_wlrdy
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/sys_wlreq
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/sys_wlrdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/sys_rlreq
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/sys_rlrdy
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/write_req
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/write_rdy
add wave -noupdate /testbench/du_e/ddrphy_e/read_leveling_l_b/readcycle_p/state
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(7)/adjdqi_b/adjdqi_e/step_req
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(7)/adjdqi_b/adjdqi_e/step_rdy
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(7)/adjdqi_b/adjdqi_e/edge_req
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/iddr_g(7)/adjdqi_b/adjdqi_e/edge_rdy
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/pause_req
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/pause_rdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqipau_req(0)
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqipau_rdy(0)
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/rl_b/line__134/state
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/rl_b/line__192/z
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqipause_req
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqipause_rdy
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqspau_req
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/read_req
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/read_brst
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/adjdqs_req
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/devcfg_rdy
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dev_rdy
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_e/dmatrans_rdy
add wave -noupdate /testbench/du_e/grahics_e/dmactlr_b/dmactlr_e/dmatrans_rdy
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/sys_wlrdy
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/sys_rlrdy
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/read_rdy
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/write_rdy
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/adjdqs_rdy
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/adjdqi_rdy
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/adjsto_rdy
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqipau_rdy
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqipause_rdy
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/dqspau_rdy
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddrdqphy_i/pause_rdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8577100 ps} 0} {{Cursor 2} {701577100 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 221
configure wave -valuecolwidth 202
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
WaveRestoreZoom {8495068 ps} {8659132 ps}
