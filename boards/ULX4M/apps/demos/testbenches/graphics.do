onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/clk_25mhz
add wave -noupdate -expand -group rgmii /testbench/du_e/rgmii_rx_clk
add wave -noupdate -expand -group rgmii /testbench/du_e/rgmii_rx_dv
add wave -noupdate -expand -group rgmii -radix hexadecimal /testbench/du_e/rgmii_rxd
add wave -noupdate -expand -group rgmii /testbench/du_e/rgmii_tx_clk
add wave -noupdate -expand -group rgmii /testbench/du_e/rgmii_tx_en
add wave -noupdate -expand -group rgmii -radix hexadecimal /testbench/du_e/rgmii_txd
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
add wave -noupdate -expand -group ddram -expand /testbench/du_e/ddram_dqs
add wave -noupdate -expand -group ddram -radix hexadecimal /testbench/du_e/ddram_dq
add wave -noupdate -group mem_sync -group states /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/INIT
add wave -noupdate -group mem_sync -group states /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/FREEZE
add wave -noupdate -group mem_sync -group states /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/STOP
add wave -noupdate -group mem_sync -group states /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/DDR
add wave -noupdate -group mem_sync -group states /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/PAUSE
add wave -noupdate -group mem_sync -group states /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/UDDCNTLN
add wave -noupdate -group mem_sync -group states /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/READY
add wave -noupdate -group mem_sync -group states /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/UPDATE_PAUSE
add wave -noupdate -group mem_sync -group states /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/UPDATE_UDDCNTLN
add wave -noupdate -group mem_sync -group states /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/COUNT_8T
add wave -noupdate -group mem_sync -group states /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/COUNT_4T
add wave -noupdate -group mem_sync -group states /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/COUNT_LOCK
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/rst
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/start_clk
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/dll_lock
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/pll_lock
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/update
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/pause
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/stop
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/freeze
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/uddcntln
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/dll_rst
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/ddr_rst
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/ready
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/count
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/cs_memsync
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/ns_memsync
add wave -noupdate -group mem_sync -expand /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/flag
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/flag_d
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/lock_d1
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/lock_d2
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/ddr_rst_d1
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/counter_4t
add wave -noupdate -group mem_sync /testbench/du_e/ddrphy_e/mem_sync_b/mem_sync_i/ddr_rst_d
add wave -noupdate -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/DQSI
add wave -noupdate -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/ECLK
add wave -noupdate -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/SCLK
add wave -noupdate -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/DDRDEL
add wave -noupdate -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/DQSR90
add wave -noupdate -group dqsbufm_0 -radix hexadecimal /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wrpntr
add wave -noupdate -group dqsbufm_0 -radix hexadecimal /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rdpntr
add wave -noupdate -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/dqs_clean
add wave -noupdate -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/DATAVALID
add wave -noupdate -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/BURSTDET
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/phy_sti
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/phadctor_i/taps
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/phadctor_i/line__28/num_of_steps
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/phadctor_i/line__28/num_of_taps
add wave -noupdate -radix binary -childformat {{/testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/phadctor_i/line__28/gaptab(1) -radix unsigned} {/testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/phadctor_i/line__28/gaptab(0) -radix unsigned}} -expand -subitemconfig {/testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/phadctor_i/line__28/gaptab(1) {-height 29 -radix unsigned} /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/phadctor_i/line__28/gaptab(0) {-height 29 -radix unsigned}} /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/phadctor_i/line__28/gaptab
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/phy_dqo
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/byte_g(1)/ddr3phy_i/phy_dqo
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/phy_dqo
add wave -noupdate /testbench/du_e/ddrphy_e/phy_wlreq
add wave -noupdate /testbench/du_e/ddrphy_e/phy_wlrdy
add wave -noupdate /testbench/du_e/ddrphy_e/phy_rlreq
add wave -noupdate /testbench/du_e/ddrphy_e/phy_rlrdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/phy_frm
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/phy_we
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/phy_trdy
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/phy_rw
add wave -noupdate /testbench/du_e/grahics_e/ddrctlr_b/ddrctlr_e/ddr_pgm_e/ddr_pgm_pc
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/phy_rlcal
add wave -noupdate /testbench/du_e/ddrphy_e/read_leveling_l_b/leveled
add wave -noupdate /testbench/du_e/ddrphy_e/phy_frm
add wave -noupdate /testbench/du_e/ddrphy_e/phy_trdy
add wave -noupdate /testbench/du_e/ddrphy_e/phy_rw
add wave -noupdate /testbench/du_e/ddrphy_e/phy_ini
add wave -noupdate /testbench/du_e/ddrphy_e/phy_cmd
add wave -noupdate /testbench/du_e/ddrphy_e/phy_rlseq
add wave -noupdate /testbench/du_e/ddrphy_e/read_leveling_l_b/ddr_idle
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {438140560 fs} 0} {{Cursor 2} {11636802390 fs} 0} {{Cursor 3} {14992176490 fs} 0}
quietly wave cursor active 2
configure wave -namecolwidth 283
configure wave -valuecolwidth 209
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
WaveRestoreZoom {11583806360 fs} {11645329800 fs}
