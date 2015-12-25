onerror {resume}
quietly virtual signal -install /testbench { /testbench/dq(15 downto 0)} dq16
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider testbench
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/mii_refclk
add wave -noupdate /testbench/mii_treq
add wave -noupdate /testbench/mii_rxdv
add wave -noupdate /testbench/mii_rxc
add wave -noupdate /testbench/ml509_e/phy_rxctl_rxdv
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/dqs(1)
add wave -noupdate /testbench/ml509_e/ddrs_clk90
add wave -noupdate /testbench/dqs(0)
add wave -noupdate -expand /testbench/dqs
add wave -noupdate -radix hexadecimal /testbench/dq16
add wave -noupdate -radix hexadecimal /testbench/addr
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_init_e/xdr_mr_addr
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_init_e/xdr_mr_data
add wave -noupdate /testbench/ba
add wave -noupdate /testbench/clk_p(0)
add wave -noupdate /testbench/cke
add wave -noupdate /testbench/cs_n
add wave -noupdate /testbench/ras_n
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/odt
add wave -noupdate /testbench/we_n
add wave -noupdate /testbench/dqs(1)
add wave -noupdate /testbench/dqs(0)
add wave -noupdate -divider ml509
add wave -noupdate /testbench/ml509_e/ddr2_dqs_p(1)
add wave -noupdate /testbench/ml509_e/ddr2_dqs_p(0)
add wave -noupdate /testbench/ml509_e/ddrs_rst
add wave -noupdate /testbench/ml509_e/dcm_lckd
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddr_dqso
add wave -noupdate /testbench/ml509_e/ddrphy_e/byte_g(1)/ddrdqphy_i/ddr_dqso
add wave -noupdate /testbench/ml509_e/ddrphy_e/sys_dqso
add wave -noupdate /testbench/ml509_e/ddrphy_e/sys_dqst
add wave -noupdate -divider ddr2baphy
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddrbaphy_i/ddr_rst
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddrbaphy_i/ddr_cs
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddrbaphy_i/ddr_ck
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddrbaphy_i/ddr_cke
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddrbaphy_i/ddr_odt
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddrbaphy_i/ddr_ras
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddrbaphy_i/ddr_cas
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddrbaphy_i/ddr_we
add wave -noupdate /testbench/ml509_e/ddrphy_e/ddrbaphy_i/ddr_b
add wave -noupdate -radix hexadecimal /testbench/ml509_e/ddrphy_e/ddrbaphy_i/ddr_a
add wave -noupdate -expand /testbench/ml509_e/ddrphy_e/sys_dqsi
add wave -noupdate /testbench/ml509_e/ddrphy_dmo
add wave -noupdate -expand /testbench/ml509_e/ddrphy_dmi
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/sys_clks(1)
add wave -noupdate -divider scope
add wave -noupdate /testbench/ml509_e/scope_e/ddr_cs
add wave -noupdate /testbench/ml509_e/scope_e/ddr_cke
add wave -noupdate /testbench/ml509_e/scope_e/ddr_ras
add wave -noupdate /testbench/ml509_e/scope_e/ddr_cas
add wave -noupdate /testbench/ml509_e/scope_e/ddr_we
add wave -noupdate -radix hexadecimal /testbench/ml509_e/scope_e/ddr_a
add wave -noupdate /testbench/ml509_e/scope_e/ddr_b
add wave -noupdate -radix hexadecimal /testbench/ml509_e/ddrphy_e/sys_dqi
add wave -noupdate -radix hexadecimal /testbench/ml509_e/ddrphy_e/sys_dqo
add wave -noupdate /testbench/ml509_e/ddrphy_e/sys_dqso
add wave -noupdate /testbench/ml509_e/ddrphy_e/sys_dqst
add wave -noupdate -divider xdr
add wave -noupdate /testbench/ml509_e/scope_e/ddr_sti
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_sto
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/rpho90
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
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/DQZL_TAB
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/RWNL_TAB
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/RWNX_LAT
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/STRL_TAB
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/STRX_LAT
add wave -noupdate -group constant /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/WID_LAT
add wave -noupdate -group constant -expand /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/WWNL_TAB
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
add wave -noupdate -radix hexadecimal /testbench/ml509_e/scope_e/ddr_e/xdr_mpu_e/lat_timer
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_mpu_e/xdr_state
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_mpu_e/xdr_mpu_wri
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_mpu_e/xdr_mpu_wwin
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_mpu_e/xdr_mpu_rea
add wave -noupdate /testbench/ml509_e/scope_e/ddr_e/xdr_mpu_e/xdr_mpu_rwin
add wave -noupdate /testbench/ml509_e/scope_e/dataio_e/ddrs_creq
add wave -noupdate /testbench/ml509_e/scope_e/dataio_e/ddrio_b/ddrs_breq
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/ml509_e/scope_e/dataio_e/ddrs_rreq
add wave -noupdate /testbench/ml509_e/scope_e/dataio_e/datai_brst_req
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand /testbench/ml509_e/scope_e/ddr_e/xdr_wenas
add wave -noupdate -expand /testbench/ml509_e/scope_e/ddr_e/xdr_sch_e/xdr_wwn
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4013600 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 174
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
WaveRestoreZoom {3952568 ps} {4074632 ps}
