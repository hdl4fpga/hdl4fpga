onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider testbench
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk
add wave -noupdate -radix hexadecimal /testbench/dq
add wave -noupdate /testbench/dqs
add wave -noupdate /testbench/dqs_n
add wave -noupdate -radix hexadecimal /testbench/addr
add wave -noupdate /testbench/ba
add wave -noupdate /testbench/clk_p
add wave -noupdate /testbench/clk_n
add wave -noupdate /testbench/cke
add wave -noupdate /testbench/cs_n
add wave -noupdate /testbench/ras_n
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/we_n
add wave -noupdate /testbench/dm
add wave -noupdate /testbench/odt
add wave -noupdate -divider ml509
add wave -noupdate /testbench/ml509_e/ddrs_rst
add wave -noupdate /testbench/ml509_e/dcm_lckd
add wave -noupdate -divider ddr2baphy
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddr3phy_i/ddr_rst
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddr3phy_i/ddr_cs
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddr3phy_i/ddr_ck
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddr3phy_i/ddr_cke
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddr3phy_i/ddr_odt
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddr3phy_i/ddr_ras
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddr3phy_i/ddr_cas
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddr3phy_i/ddr_we
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddr3phy_i/ddr_b
add wave -noupdate -radix hexadecimal /testbench/ml509_e/ddrphy_e/ddr3phy_i/ddr_a
add wave -noupdate -divider scope
add wave -noupdate /testbench/ml509_e/scope_e/ddr_cs
add wave -noupdate /testbench/ml509_e/scope_e/ddr_cke
add wave -noupdate /testbench/ml509_e/scope_e/ddr_ras
add wave -noupdate /testbench/ml509_e/scope_e/ddr_cas
add wave -noupdate /testbench/ml509_e/scope_e/ddr_we
add wave -noupdate -radix hexadecimal /testbench/ml509_e/scope_e/ddr_a
add wave -noupdate /testbench/ml509_e/scope_e/ddr_b
add wave -noupdate -divider xdr
add wave -noupdate -group xdr_constant /testbench/ml509_e/scope_e/ddr_e/bl_cod
add wave -noupdate -group xdr_constant /testbench/ml509_e/scope_e/ddr_e/bl_tab
add wave -noupdate -group xdr_constant /testbench/ml509_e/scope_e/ddr_e/cl_tab
add wave -noupdate -group xdr_constant /testbench/ml509_e/scope_e/ddr_e/cwl_tab
add wave -noupdate -divider xdr_sch
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/CL_COD
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/CWL_COD
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/DQSOL_TAB
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/DQSX_LAT
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/DQSZL_TAB
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/DQSZX_TAB
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/DQZL_TAB
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/DQZX_TAB
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/RWNL_TAB
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/RWNX_LAT
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/STRL_TAB
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/STRX_LAT
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/WID_LAT
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/WWNL_TAB
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/WWNX_LAT
add wave -noupdate -divider xdr_init
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_init_e/xdr_init_clk
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_init_e/xdr_init_rst
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_init_e/xdr_init_req
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_init_e/xdr_init_pc
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_init_e/xdr_init_cs
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_init_e/xdr_init_cke
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_init_e/xdr_init_ras
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_init_e/xdr_init_cas
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_init_e/xdr_init_we
add wave -noupdate -radix hexadecimal /testbench/ml509_e/scope_e/ddr_e/xdr_init_e/xdr_init_a
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_init_e/xdr_init_b
add wave -noupdate -divider xdr_mpu
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_mpu_e/xdr_mpu_ras
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_mpu_e/xdr_mpu_cas
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_mpu_e/xdr_mpu_we
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_mpu_e/lat_timer
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_mpu_e/xdr_state
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_mpu_e/xdr_mpu_wri
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_mpu_e/xdr_mpu_wwin
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_mpu_e/xdr_mpu_rea
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_mpu_e/xdr_mpu_rwin
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1555000 ps} 0} {{Cursor 2} {21562000 ps} 0} {{Cursor 3} {22042100 ps} 0} {{Cursor 4} {22015100 ps} 0}
quietly wave cursor active 4
configure wave -namecolwidth 209
configure wave -valuecolwidth 103
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
configure wave -timelineunits ps
update
WaveRestoreZoom {22177860 ps} {22411692 ps}
