onerror {resume}
quietly virtual signal -install /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i { (context /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i )&{DYNDELAY7 , DYNDELAY6 , DYNDELAY5 , DYNDELAY4 , DYNDELAY3 , DYNDELAY2 , DYNDELAY1 , DYNDELAY0 }} dyndelay_0
quietly virtual signal -install /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i {/testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/READCLKSEL2  } readclksel_0
quietly virtual signal -install /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i { (context /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i )&{READCLKSEL2 , READCLKSEL1 , READCLKSEL0 }} readclksel_0001
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
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/sclk
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/SCLK
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/READCLKSEL2
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/READCLKSEL1
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/READCLKSEL0
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/READ1
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/READ0
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/DQSI
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/PAUSE
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/BURSTDET
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/dqsbufm_i/DATAVALID
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/adjstep_rdy
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/adjstep_req
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/input
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/datavalid
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/burstdet
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/base
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/phase
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/readclksel
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/lat
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/line__158/state
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/dtct_req
add wave -noupdate /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rl_b/adjbrst_e/dtct_rdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12121592140 fs} 0} {{Cursor 2} {12679667480 fs} 0} {{Cursor 3} {14626382370 fs} 0}
quietly wave cursor active 2
configure wave -namecolwidth 233
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
configure wave -timelineunits us
update
WaveRestoreZoom {11830446880 fs} {13528888080 fs}
