onerror {resume}
quietly virtual signal -install /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i { (context /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i )&{READCLKSEL2 , READCLKSEL1 , READCLKSEL0 }} readclksel
quietly virtual signal -install /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i { (context /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i )&{READ1 , READ0 }} read
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
add wave -noupdate -expand -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/DQSI
add wave -noupdate -expand -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/ECLK
add wave -noupdate -expand -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/SCLK
add wave -noupdate -expand -group dqsbufm_0 -expand /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/read
add wave -noupdate -expand -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/readclksel
add wave -noupdate -expand -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/DDRDEL
add wave -noupdate -expand -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/DQSR90
add wave -noupdate -expand -group dqsbufm_0 -radix hexadecimal /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wrpntr
add wave -noupdate -expand -group dqsbufm_0 -radix hexadecimal /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/rdpntr
add wave -noupdate -expand -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/dqs_clean
add wave -noupdate -expand -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/DATAVALID
add wave -noupdate -expand -group dqsbufm_0 /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/wl_b/dqsbufm_i/BURSTDET
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/phy_sti
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/phy_dqo
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/byte_g(1)/ddr3phy_i/phy_dqo
add wave -noupdate -radix hexadecimal /testbench/du_e/ddrphy_e/byte_g(0)/ddr3phy_i/phy_dqo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2411409200 fs} 0} {{Cursor 2} {23744348910 fs} 0} {{Cursor 3} {21643595860 fs} 0}
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
WaveRestoreZoom {23701539660 fs} {23773603180 fs}
