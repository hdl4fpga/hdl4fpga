onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/xdr_clk
add wave -noupdate /testbench/xdr_wait_clk
add wave -noupdate /testbench/xdr_rst
add wave -noupdate /testbench/xdr_ras
add wave -noupdate /testbench/xdr_cas
add wave -noupdate /testbench/xdr_we
add wave -noupdate /testbench/du/xdr_init_a
add wave -noupdate -radix hexadecimal /testbench/du/xdr_init_b
add wave -noupdate /testbench/du/xdr_init_pc
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du/dst(21) -radix hexadecimal} {/testbench/du/dst(20) -radix hexadecimal} {/testbench/du/dst(19) -radix hexadecimal} {/testbench/du/dst(18) -radix hexadecimal} {/testbench/du/dst(17) -radix hexadecimal} {/testbench/du/dst(16) -radix hexadecimal} {/testbench/du/dst(15) -radix hexadecimal} {/testbench/du/dst(14) -radix hexadecimal} {/testbench/du/dst(13) -radix hexadecimal} {/testbench/du/dst(12) -radix hexadecimal} {/testbench/du/dst(11) -radix hexadecimal} {/testbench/du/dst(10) -radix hexadecimal} {/testbench/du/dst(9) -radix hexadecimal} {/testbench/du/dst(8) -radix hexadecimal} {/testbench/du/dst(7) -radix hexadecimal} {/testbench/du/dst(6) -radix hexadecimal} {/testbench/du/dst(5) -radix hexadecimal} {/testbench/du/dst(4) -radix hexadecimal} {/testbench/du/dst(3) -radix hexadecimal} {/testbench/du/dst(2) -radix hexadecimal} {/testbench/du/dst(1) -radix hexadecimal} {/testbench/du/dst(0) -radix hexadecimal}} -subitemconfig {/testbench/du/dst(21) {-height 16 -radix hexadecimal} /testbench/du/dst(20) {-height 16 -radix hexadecimal} /testbench/du/dst(19) {-height 16 -radix hexadecimal} /testbench/du/dst(18) {-height 16 -radix hexadecimal} /testbench/du/dst(17) {-height 16 -radix hexadecimal} /testbench/du/dst(16) {-height 16 -radix hexadecimal} /testbench/du/dst(15) {-height 16 -radix hexadecimal} /testbench/du/dst(14) {-height 16 -radix hexadecimal} /testbench/du/dst(13) {-height 16 -radix hexadecimal} /testbench/du/dst(12) {-height 16 -radix hexadecimal} /testbench/du/dst(11) {-height 16 -radix hexadecimal} /testbench/du/dst(10) {-height 16 -radix hexadecimal} /testbench/du/dst(9) {-height 16 -radix hexadecimal} /testbench/du/dst(8) {-height 16 -radix hexadecimal} /testbench/du/dst(7) {-height 16 -radix hexadecimal} /testbench/du/dst(6) {-height 16 -radix hexadecimal} /testbench/du/dst(5) {-height 16 -radix hexadecimal} /testbench/du/dst(4) {-height 16 -radix hexadecimal} /testbench/du/dst(3) {-height 16 -radix hexadecimal} /testbench/du/dst(2) {-height 16 -radix hexadecimal} /testbench/du/dst(1) {-height 16 -radix hexadecimal} /testbench/du/dst(0) {-height 16 -radix hexadecimal}} /testbench/du/dst
add wave -noupdate /testbench/du/timer_e/timers
add wave -noupdate /testbench/du/xdr_timer_id
add wave -noupdate /testbench/du/timer_e/tmr_id
add wave -noupdate /testbench/du/xdr_timer_req
add wave -noupdate /testbench/du/xdr_timer_rdy
add wave -noupdate /testbench/du/xdr_init_req
add wave -noupdate /testbench/du/timer_e/timer_e/req
add wave -noupdate /testbench/du/timer_e/timer_e/rdy
add wave -noupdate /testbench/du/timer_e/timer_e/data
add wave -noupdate /testbench/du/timer_e/timer_e/cntr_g(0)/cntr
add wave -noupdate -expand /testbench/du/timer_e/timer_e/cy
add wave -noupdate /testbench/du/timer_e/timer_e/cntr_g(0)/cntr
add wave -noupdate -radix unsigned -childformat {{/testbench/du/timer_e/timer_values(TMR_RST) -radix unsigned} {/testbench/du/timer_e/timer_values(TMR_RRDY) -radix unsigned} {/testbench/du/timer_e/timer_values(TMR_CKE) -radix unsigned} {/testbench/du/timer_e/timer_values(TMR_MRD) -radix unsigned} {/testbench/du/timer_e/timer_values(TMR_ZQINIT) -radix unsigned} {/testbench/du/timer_e/timer_values(TMR_REF) -radix unsigned}} -expand -subitemconfig {/testbench/du/timer_e/timer_values(TMR_RST) {-height 16 -radix unsigned} /testbench/du/timer_e/timer_values(TMR_RRDY) {-height 16 -radix unsigned} /testbench/du/timer_e/timer_values(TMR_CKE) {-height 16 -radix unsigned} /testbench/du/timer_e/timer_values(TMR_MRD) {-height 16 -radix unsigned} /testbench/du/timer_e/timer_values(TMR_ZQINIT) {-height 16 -radix unsigned} /testbench/du/timer_e/timer_values(TMR_REF) {-height 16 -radix unsigned}} /testbench/du/timer_e/timer_values
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2250906 ps} 0} {{Cursor 2} {140550 ps} 0}
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
WaveRestoreZoom {0 ps} {1050 ns}
