onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/sdram_clk
add wave -noupdate /testbench/du_e/sdram_rasn
add wave -noupdate /testbench/du_e/sdram_casn
add wave -noupdate /testbench/du_e/sdram_wen
add wave -noupdate -radix hexadecimal /testbench/du_e/sdram_ba
add wave -noupdate -radix hexadecimal -childformat {{/testbench/du_e/sdram_a(12) -radix hexadecimal} {/testbench/du_e/sdram_a(11) -radix hexadecimal} {/testbench/du_e/sdram_a(10) -radix hexadecimal} {/testbench/du_e/sdram_a(9) -radix hexadecimal} {/testbench/du_e/sdram_a(8) -radix hexadecimal} {/testbench/du_e/sdram_a(7) -radix hexadecimal} {/testbench/du_e/sdram_a(6) -radix hexadecimal} {/testbench/du_e/sdram_a(5) -radix hexadecimal} {/testbench/du_e/sdram_a(4) -radix hexadecimal} {/testbench/du_e/sdram_a(3) -radix hexadecimal} {/testbench/du_e/sdram_a(2) -radix hexadecimal} {/testbench/du_e/sdram_a(1) -radix hexadecimal} {/testbench/du_e/sdram_a(0) -radix hexadecimal}} -subitemconfig {/testbench/du_e/sdram_a(12) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(11) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(10) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(9) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(8) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(7) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(6) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(5) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(4) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(3) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(2) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(1) {-height 29 -radix hexadecimal} /testbench/du_e/sdram_a(0) {-height 29 -radix hexadecimal}} /testbench/du_e/sdram_a
add wave -noupdate -radix hexadecimal /testbench/du_e/sdram_d
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/grahics_e/sio_b/dmaio_trdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/dmaio_next
add wave -noupdate /testbench/du_e/grahics_e/dmaio_we
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmaio_len
add wave -noupdate -radix hexadecimal /testbench/du_e/grahics_e/dmaio_addr
add wave -noupdate /testbench/du_e/grahics_e/dmaio_req
add wave -noupdate /testbench/du_e/grahics_e/dmaio_rdy
add wave -noupdate /testbench/du_e/grahics_e/sio_b/dmasin_irdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sioudpp_e/flow_e/sigram_frm
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sioudpp_e/flow_e/sigram_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sioudpp_e/flow_e/sigram_data
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sioudpp_e/flow_e/rx_b/rgtr_frm
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sioudpp_e/flow_e/rx_b/rgtr_irdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_e/udpdaisy_e/sioudpp_e/flow_e/rx_b/rgtr_id
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sioudpp_e/flow_e/rx_b/rgtr_idv
add wave -noupdate /testbench/du_e/ipoe_e/udpdaisy_e/sioudpp_e/flow_e/rx_b/sout_irdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {111265533700 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 259
configure wave -valuecolwidth 287
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
WaveRestoreZoom {111182965820 fs} {111411422860 fs}
