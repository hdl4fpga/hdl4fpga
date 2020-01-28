onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/s3estarter_e/xtal
add wave -noupdate -expand /testbench/s3estarter_e/ddrsys_clks
add wave -noupdate /testbench/s3estarter_e/dmactlr_e/dmactlr_rst
add wave -noupdate /testbench/s3estarter_e/dmactlr_e/dmactlr_clk
add wave -noupdate /testbench/s3estarter_e/dmactlr_e/dmactlr_frm
add wave -noupdate /testbench/s3estarter_e/dmactlr_e/dmactlr_irdy
add wave -noupdate /testbench/s3estarter_e/dmactlr_e/dmactlr_trdy
add wave -noupdate /testbench/s3estarter_e/dmactlr_e/dmactlr_we
add wave -noupdate -radix hexadecimal /testbench/s3estarter_e/dmactlr_e/dmactlr_iaddr
add wave -noupdate -radix hexadecimal /testbench/s3estarter_e/dmactlr_e/dmactlr_ilen
add wave -noupdate -radix hexadecimal /testbench/s3estarter_e/dmactlr_e/dmactlr_taddr
add wave -noupdate -radix hexadecimal /testbench/s3estarter_e/dmactlr_e/dmactlr_tlen
add wave -noupdate /testbench/s3estarter_e/dmactlr_e/ctlr_inirdy
add wave -noupdate /testbench/s3estarter_e/dmactlr_e/ctlr_refreq
add wave -noupdate /testbench/s3estarter_e/dmactlr_e/ctlr_irdy
add wave -noupdate /testbench/s3estarter_e/dmactlr_e/ctlr_trdy
add wave -noupdate /testbench/s3estarter_e/dmactlr_e/ctlr_rw
add wave -noupdate /testbench/s3estarter_e/dmactlr_e/ctlr_act
add wave -noupdate /testbench/s3estarter_e/dmactlr_e/ctlr_cas
add wave -noupdate -radix hexadecimal /testbench/s3estarter_e/dmactlr_e/ctlr_b
add wave -noupdate -radix hexadecimal /testbench/s3estarter_e/dmactlr_e/ctlr_a
add wave -noupdate /testbench/s3estarter_e/ddrphy_rst
add wave -noupdate /testbench/s3estarter_e/ddrphy_cke
add wave -noupdate /testbench/s3estarter_e/ddrphy_cs
add wave -noupdate /testbench/s3estarter_e/ddrphy_ras
add wave -noupdate /testbench/s3estarter_e/ddrphy_cas
add wave -noupdate /testbench/s3estarter_e/ddrphy_we
add wave -noupdate /testbench/s3estarter_e/ddrphy_odt
add wave -noupdate -radix hexadecimal /testbench/s3estarter_e/ddrphy_b
add wave -noupdate -radix hexadecimal /testbench/s3estarter_e/ddrphy_a
add wave -noupdate /testbench/s3estarter_e/ddrphy_dqsi
add wave -noupdate /testbench/s3estarter_e/ddrphy_dqst
add wave -noupdate /testbench/s3estarter_e/ddrphy_dqso
add wave -noupdate /testbench/s3estarter_e/ddrphy_dmi
add wave -noupdate /testbench/s3estarter_e/ddrphy_dmt
add wave -noupdate /testbench/s3estarter_e/ddrphy_dmo
add wave -noupdate -radix hexadecimal /testbench/s3estarter_e/ddrphy_dqi
add wave -noupdate /testbench/s3estarter_e/ddrphy_dqt
add wave -noupdate -radix hexadecimal /testbench/s3estarter_e/ddrphy_dqo
add wave -noupdate /testbench/s3estarter_e/ddrphy_sto
add wave -noupdate /testbench/s3estarter_e/ddrphy_sti
add wave -noupdate -divider DDRCTLR
add wave -noupdate -divider DDRDRMA
add wave -noupdate -divider {Micron DDR}
add wave -noupdate /testbench/ddr_model_g/Clk
add wave -noupdate /testbench/ddr_model_g/Clk_n
add wave -noupdate /testbench/ddr_model_g/Cke
add wave -noupdate /testbench/ddr_model_g/Cs_n
add wave -noupdate /testbench/ddr_model_g/Ras_n
add wave -noupdate /testbench/ddr_model_g/Cas_n
add wave -noupdate /testbench/ddr_model_g/We_n
add wave -noupdate /testbench/ddr_model_g/Ba
add wave -noupdate -radix hexadecimal -childformat {{{/testbench/ddr_model_g/Addr[12]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[11]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[10]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[9]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[8]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[7]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[6]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[5]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[4]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[3]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[2]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[1]} -radix hexadecimal} {{/testbench/ddr_model_g/Addr[0]} -radix hexadecimal}} -subitemconfig {{/testbench/ddr_model_g/Addr[12]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[11]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[10]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[9]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[8]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[7]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[6]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[5]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[4]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[3]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[2]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[1]} {-height 29 -radix hexadecimal} {/testbench/ddr_model_g/Addr[0]} {-height 29 -radix hexadecimal}} /testbench/ddr_model_g/Addr
add wave -noupdate /testbench/ddr_model_g/Dm
add wave -noupdate /testbench/s3estarter_e/ddrphy_e/ddr_dqst
add wave -noupdate /testbench/s3estarter_e/ddr_dqso
add wave -noupdate /testbench/ddr_model_g/Dq
add wave -noupdate -expand /testbench/ddr_model_g/Dqs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {203981855 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 304
configure wave -valuecolwidth 163
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
WaveRestoreZoom {203914774 ps} {204245979 ps}
