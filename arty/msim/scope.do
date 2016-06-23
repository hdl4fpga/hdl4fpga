onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/rst
add wave -noupdate /testbench/arty_e/gclk100
add wave -noupdate /testbench/ddr_clk_p
add wave -noupdate /testbench/cke
add wave -noupdate /testbench/rst_n
add wave -noupdate /testbench/cs_n
add wave -noupdate /testbench/ras_n
add wave -noupdate /testbench/cas_n
add wave -noupdate /testbench/we_n
add wave -noupdate /testbench/odt
add wave -noupdate -radix hexadecimal -childformat {{/testbench/ba(2) -radix hexadecimal} {/testbench/ba(1) -radix hexadecimal} {/testbench/ba(0) -radix hexadecimal}} -subitemconfig {/testbench/ba(2) {-height 16 -radix hexadecimal} /testbench/ba(1) {-height 16 -radix hexadecimal} /testbench/ba(0) {-height 16 -radix hexadecimal}} /testbench/ba
add wave -noupdate -radix hexadecimal /testbench/addr
add wave -noupdate -expand /testbench/dqs_p
add wave -noupdate -radix hexadecimal /testbench/arty_e/ddrphy_e/sys_dqi
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(1)/ddrdqphy_i/iddr_g(7)/iddr_i/C
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqso_b/adjsto_e/sys_clk0
add wave -noupdate -radix hexadecimal /testbench/dq
add wave -noupdate /testbench/dqs_p(0)
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqso_b/adjsto_e/st
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqso_b/adjsto_e/sel
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqso_b/adjsto_e/smp
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqso_b/adjsto_e/sti
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqso_b/adjsto_e/sto
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(1)/ddrdqphy_i/iddr_g(7)/dqi_i/prcs_refclk/TapCount_var
add wave -noupdate /testbench/arty_e/ddrphy_e/byte_g(1)/ddrdqphy_i/dqso_b/adjsto_e/line__28/cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {21924725 ps} 0} {{Cursor 2} {13470000 ps} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {13830168 ps} {14550534 ps}
