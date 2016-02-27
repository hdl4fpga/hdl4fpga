onerror {resume}
quietly virtual signal -install /testbench {/testbench/dq  } dq16
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/clk_p
add wave -noupdate /testbench/cke
add wave -noupdate /testbench/cs_n
add wave -noupdate /testbench/ras_n
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/we_n
add wave -noupdate /testbench/ba
add wave -noupdate -radix hexadecimal /testbench/addr
add wave -noupdate -expand /testbench/dqs
add wave -noupdate -radix hexadecimal /testbench/dq
add wave -noupdate /testbench/dm
add wave -noupdate /testbench/nuhs3dsp_e/scope_e_ddrs_do_rdy(0)
add wave -noupdate /testbench/nuhs3dsp_e/ddrs_clk0
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/scope_e_ddrs_do
add wave -noupdate /testbench/nuhs3dsp_e/txd
add wave -noupdate /testbench/nuhs3dsp_e/ddr_st_dqs
add wave -noupdate /testbench/nuhs3dsp_e/ddr_st_lp_dqs
add wave -noupdate /testbench/nuhs3dsp_e/ddr_st_lp_dqs_IBUF_11299
add wave -noupdate /testbench/nuhs3dsp_e/ddr_st_lp_dqs_IBUF_0
add wave -noupdate /testbench/nuhs3dsp_e/ddrphy_dqsi
add wave -noupdate /testbench/nuhs3dsp_e/ddrphy_dqsi_2_0
add wave -noupdate /testbench/nuhs3dsp_e/ddrphy_dqsi_3_0
add wave -noupdate /testbench/nuhs3dsp_e/ddrphy_dqsi_0_0
add wave -noupdate /testbench/nuhs3dsp_e/ddrphy_dqsi_1_0
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 7} {25236386 ps} 0} {{Cursor 8} {25238856 ps} 0}
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
configure wave -timelineunits ps
update
WaveRestoreZoom {25223437 ps} {25249381 ps}
