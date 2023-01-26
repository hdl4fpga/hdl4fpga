onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group phy1 /testbench/du_e/phy1_gtxclk
add wave -noupdate -expand -group phy1 -radix hexadecimal /testbench/du_e/phy1_rx_dv
add wave -noupdate -expand -group phy1 -radix hexadecimal /testbench/du_e/phy1_rx_d
add wave -noupdate -expand -group phy1 /testbench/du_e/phy1_tx_en
add wave -noupdate -expand -group phy1 -radix hexadecimal /testbench/du_e/phy1_tx_d
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_clk
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_rst
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_cke
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_cs
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_ras
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_cas
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_we
add wave -noupdate -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_a
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_dm
add wave -noupdate -group ddr3 -expand /testbench/du_e/ddr3_dqs
add wave -noupdate -group ddr3 -radix hexadecimal /testbench/du_e/ddr3_dq
add wave -noupdate -group ddr3 /testbench/du_e/ddr3_odt
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/mii_clk
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmptx_frm
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmptx_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmptx_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmptx_end
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmpd_b/icmpd_e/icmptx_data
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/icmp_gnt
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/meta_b/ldatai
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/pl_frm
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/pl_irdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/pl_trdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/pl_end
add wave -noupdate -expand -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/pl_data
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4a_frm
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4a_irdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4a_end
add wave -noupdate -expand -group ipv4_tx -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4a_data
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/mtdlltx_irdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/mtdlltx_trdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/mtdlltx_end
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/nettx_irdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/nettx_trdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/nettx_end
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_frm
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_irdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_trdy
add wave -noupdate -expand -group ipv4_tx /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_end
add wave -noupdate -expand -group ipv4_tx -radix hexadecimal -childformat {{/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(0) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(1) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(2) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(3) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(4) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(5) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(6) -radix hexadecimal} {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(7) -radix hexadecimal}} -subitemconfig {/testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(0) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(1) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(2) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(3) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(4) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(5) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(6) {-height 29 -radix hexadecimal} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data(7) {-height 29 -radix hexadecimal}} /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ipv4_e/ipv4tx_e/ipv4_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/meta_b/hwdatx_end
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/meta_b/hwsatx_end
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/meta_b/hwtyptx_end
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/meta_b/hwdatx_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/meta_b/hwsatx_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/meta_b/hwtyptx_data
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/mtdlltx_irdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/mtdlltx_trdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/mtdlltx_end
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/xxx/ethtx_e/hwllc_irdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/xxx/ethtx_e/hwllc_trdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/xxx/ethtx_e/hwllc_end
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/xxx/ethtx_e/hwllc_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/xxx/ethtx_e/pl_frm
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/xxx/ethtx_e/pl_irdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/xxx/ethtx_e/pl_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/xxx/ethtx_e/pl_data
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/xxx/ethtx_e/pl_end
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/mactx_full
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/xxx/ethtx_e/metatx_end
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/xxx/ethtx_e/fcs_end
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/xxx/ethtx_e/mii_frm
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/xxx/ethtx_e/mii_irdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/xxx/ethtx_e/mii_trdy
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/xxx/ethtx_e/mii_end
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/mii_clk
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/xxx/ethtx_e/mii_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/ipoe_b/ethrx_e/mii_frm
add wave -noupdate /testbench/ipoe_b/ethrx_e/mii_clk
add wave -noupdate /testbench/ipoe_b/ethrx_e/pream_vld
add wave -noupdate /testbench/ipoe_b/ethrx_e/dllrx_e/dll_frm
add wave -noupdate /testbench/ipoe_b/ethrx_e/fcs_vld
add wave -noupdate /testbench/ipoe_b/ethrx_e/fcs_sb
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/fcs_sb
add wave -noupdate /testbench/du_e/ipoe_b/udpdaisy_e/sio_udp_e/mii_ipoe_e/ethrx_e/fcs_vld
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/reset
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/reset_datapath
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/refclk
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/eclk
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/sclk
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/sclk2x
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/all_lock
add wave -noupdate -group sdrphy_b/csa -radix hexadecimal /testbench/du_e/sdrphy_b/ecp3_csa_e/pll_control/retry_cnt
add wave -noupdate -group sdrphy_b/csa -radix hexadecimal /testbench/du_e/sdrphy_b/ecp3_csa_e/pll_control/timer
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/pll_control/state
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/clk_phase/reset
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/clk_phase/eclk
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/clk_phase/eclksync
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/clk_phase/sclk
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/clk_phase/align_status
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/clk_phase/dqclk1bar_ff
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/clk_phase/phase_ff_1
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/clk_phase/phase_ff_0
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/good
add wave -noupdate -group sdrphy_b/csa /testbench/du_e/sdrphy_b/ecp3_csa_e/err
add wave -noupdate -group sdrphy_e/byte_g(0) /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/rl_b/adjsto_b/line__170/cntr
add wave -noupdate -group sdrphy_e/byte_g(0) /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/rl_b/adjsto_b/det
add wave -noupdate -group sdrphy_e/byte_g(0) /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/locked
add wave -noupdate -group sdrphy_e/byte_g(0) /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/eclk
add wave -noupdate -group sdrphy_e/byte_g(0) /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/sclk
add wave -noupdate -group sdrphy_e/byte_g(0) /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/dqclk1
add wave -noupdate -group sdrphy_e/byte_g(0) /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/dqclk0
add wave -noupdate -group sdrphy_e/byte_g(0) /testbench/du_e/sdrphy_b/sdrphy_e/byte_g(0)/sdr3phy_i/dqsw
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {95159683072 fs} 0} {{Cursor 2} {95750000737 fs} 0}
quietly wave cursor active 2
configure wave -namecolwidth 264
configure wave -valuecolwidth 99
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
WaveRestoreZoom {95683115418 fs} {95827204452 fs}
