onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/btof_bcdfrm
add wave -noupdate /testbench/btof_bcdirdy
add wave -noupdate /testbench/btof_bcdtrdy
add wave -noupdate /testbench/axis_e/axis_dv
add wave -noupdate /testbench/axis_e/axis_sel
add wave -noupdate -radix hexadecimal /testbench/axis_e/axis_scale
add wave -noupdate -radix hexadecimal /testbench/axis_e/axis_base
add wave -noupdate /testbench/axis_e/ticks_b/init
add wave -noupdate -radix unsigned -childformat {{/testbench/axis_e/ticks_b/stop(11) -radix unsigned} {/testbench/axis_e/ticks_b/stop(10) -radix unsigned} {/testbench/axis_e/ticks_b/stop(9) -radix unsigned} {/testbench/axis_e/ticks_b/stop(8) -radix unsigned} {/testbench/axis_e/ticks_b/stop(7) -radix unsigned} {/testbench/axis_e/ticks_b/stop(6) -radix unsigned} {/testbench/axis_e/ticks_b/stop(5) -radix unsigned} {/testbench/axis_e/ticks_b/stop(4) -radix unsigned} {/testbench/axis_e/ticks_b/stop(3) -radix unsigned} {/testbench/axis_e/ticks_b/stop(2) -radix unsigned} {/testbench/axis_e/ticks_b/stop(1) -radix unsigned} {/testbench/axis_e/ticks_b/stop(0) -radix unsigned}} -subitemconfig {/testbench/axis_e/ticks_b/stop(11) {-height 29 -radix unsigned} /testbench/axis_e/ticks_b/stop(10) {-height 29 -radix unsigned} /testbench/axis_e/ticks_b/stop(9) {-height 29 -radix unsigned} /testbench/axis_e/ticks_b/stop(8) {-height 29 -radix unsigned} /testbench/axis_e/ticks_b/stop(7) {-height 29 -radix unsigned} /testbench/axis_e/ticks_b/stop(6) {-height 29 -radix unsigned} /testbench/axis_e/ticks_b/stop(5) {-height 29 -radix unsigned} /testbench/axis_e/ticks_b/stop(4) {-height 29 -radix unsigned} /testbench/axis_e/ticks_b/stop(3) {-height 29 -radix unsigned} /testbench/axis_e/ticks_b/stop(2) {-height 29 -radix unsigned} /testbench/axis_e/ticks_b/stop(1) {-height 29 -radix unsigned} /testbench/axis_e/ticks_b/stop(0) {-height 29 -radix unsigned}} /testbench/axis_e/ticks_b/stop
add wave -noupdate -radix decimal -childformat {{/testbench/axis_e/ticks_b/iterator(11) -radix hexadecimal} {/testbench/axis_e/ticks_b/iterator(10) -radix hexadecimal} {/testbench/axis_e/ticks_b/iterator(9) -radix hexadecimal} {/testbench/axis_e/ticks_b/iterator(8) -radix hexadecimal} {/testbench/axis_e/ticks_b/iterator(7) -radix hexadecimal} {/testbench/axis_e/ticks_b/iterator(6) -radix hexadecimal} {/testbench/axis_e/ticks_b/iterator(5) -radix hexadecimal} {/testbench/axis_e/ticks_b/iterator(4) -radix hexadecimal} {/testbench/axis_e/ticks_b/iterator(3) -radix hexadecimal} {/testbench/axis_e/ticks_b/iterator(2) -radix hexadecimal} {/testbench/axis_e/ticks_b/iterator(1) -radix hexadecimal} {/testbench/axis_e/ticks_b/iterator(0) -radix hexadecimal}} -subitemconfig {/testbench/axis_e/ticks_b/iterator(11) {-height 29 -radix hexadecimal} /testbench/axis_e/ticks_b/iterator(10) {-height 29 -radix hexadecimal} /testbench/axis_e/ticks_b/iterator(9) {-height 29 -radix hexadecimal} /testbench/axis_e/ticks_b/iterator(8) {-height 29 -radix hexadecimal} /testbench/axis_e/ticks_b/iterator(7) {-height 29 -radix hexadecimal} /testbench/axis_e/ticks_b/iterator(6) {-height 29 -radix hexadecimal} /testbench/axis_e/ticks_b/iterator(5) {-height 29 -radix hexadecimal} /testbench/axis_e/ticks_b/iterator(4) {-height 29 -radix hexadecimal} /testbench/axis_e/ticks_b/iterator(3) {-height 29 -radix hexadecimal} /testbench/axis_e/ticks_b/iterator(2) {-height 29 -radix hexadecimal} /testbench/axis_e/ticks_b/iterator(1) {-height 29 -radix hexadecimal} /testbench/axis_e/ticks_b/iterator(0) {-height 29 -radix hexadecimal}} /testbench/axis_e/ticks_b/iterator
add wave -noupdate -radix decimal /testbench/axis_e/ticks_b/start
add wave -noupdate -radix decimal -childformat {{/testbench/axis_e/ticks_b/step(11) -radix decimal} {/testbench/axis_e/ticks_b/step(10) -radix decimal} {/testbench/axis_e/ticks_b/step(9) -radix decimal} {/testbench/axis_e/ticks_b/step(8) -radix decimal} {/testbench/axis_e/ticks_b/step(7) -radix decimal} {/testbench/axis_e/ticks_b/step(6) -radix decimal} {/testbench/axis_e/ticks_b/step(5) -radix decimal} {/testbench/axis_e/ticks_b/step(4) -radix decimal} {/testbench/axis_e/ticks_b/step(3) -radix decimal} {/testbench/axis_e/ticks_b/step(2) -radix decimal} {/testbench/axis_e/ticks_b/step(1) -radix decimal} {/testbench/axis_e/ticks_b/step(0) -radix decimal}} -subitemconfig {/testbench/axis_e/ticks_b/step(11) {-height 29 -radix decimal} /testbench/axis_e/ticks_b/step(10) {-height 29 -radix decimal} /testbench/axis_e/ticks_b/step(9) {-height 29 -radix decimal} /testbench/axis_e/ticks_b/step(8) {-height 29 -radix decimal} /testbench/axis_e/ticks_b/step(7) {-height 29 -radix decimal} /testbench/axis_e/ticks_b/step(6) {-height 29 -radix decimal} /testbench/axis_e/ticks_b/step(5) {-height 29 -radix decimal} /testbench/axis_e/ticks_b/step(4) {-height 29 -radix decimal} /testbench/axis_e/ticks_b/step(3) {-height 29 -radix decimal} /testbench/axis_e/ticks_b/step(2) {-height 29 -radix decimal} /testbench/axis_e/ticks_b/step(1) {-height 29 -radix decimal} /testbench/axis_e/ticks_b/step(0) {-height 29 -radix decimal}} /testbench/axis_e/ticks_b/step
add wave -noupdate /testbench/axis_e/ticks_b/complete
add wave -noupdate -radix decimal /testbench/axis_e/binvalue
add wave -noupdate /testbench/axis_e/btof_binfrm
add wave -noupdate /testbench/axis_e/btof_binirdy
add wave -noupdate /testbench/axis_e/btof_bintrdy
add wave -noupdate -radix hexadecimal /testbench/axis_e/btof_bindi
add wave -noupdate -radix hexadecimal /testbench/axis_e/btof_bcddo
add wave -noupdate /testbench/axis_e/btof_bcdirdy
add wave -noupdate /testbench/axis_e/btof_bcdtrdy
add wave -noupdate -radix hexadecimal -childformat {{/testbench/axis_e/bcdvalue(31) -radix hexadecimal} {/testbench/axis_e/bcdvalue(30) -radix hexadecimal} {/testbench/axis_e/bcdvalue(29) -radix hexadecimal} {/testbench/axis_e/bcdvalue(28) -radix hexadecimal} {/testbench/axis_e/bcdvalue(27) -radix hexadecimal} {/testbench/axis_e/bcdvalue(26) -radix hexadecimal} {/testbench/axis_e/bcdvalue(25) -radix hexadecimal} {/testbench/axis_e/bcdvalue(24) -radix hexadecimal} {/testbench/axis_e/bcdvalue(23) -radix hexadecimal} {/testbench/axis_e/bcdvalue(22) -radix hexadecimal} {/testbench/axis_e/bcdvalue(21) -radix hexadecimal} {/testbench/axis_e/bcdvalue(20) -radix hexadecimal} {/testbench/axis_e/bcdvalue(19) -radix hexadecimal} {/testbench/axis_e/bcdvalue(18) -radix hexadecimal} {/testbench/axis_e/bcdvalue(17) -radix hexadecimal} {/testbench/axis_e/bcdvalue(16) -radix hexadecimal} {/testbench/axis_e/bcdvalue(15) -radix hexadecimal} {/testbench/axis_e/bcdvalue(14) -radix hexadecimal} {/testbench/axis_e/bcdvalue(13) -radix hexadecimal} {/testbench/axis_e/bcdvalue(12) -radix hexadecimal} {/testbench/axis_e/bcdvalue(11) -radix hexadecimal} {/testbench/axis_e/bcdvalue(10) -radix hexadecimal} {/testbench/axis_e/bcdvalue(9) -radix hexadecimal} {/testbench/axis_e/bcdvalue(8) -radix hexadecimal} {/testbench/axis_e/bcdvalue(7) -radix hexadecimal} {/testbench/axis_e/bcdvalue(6) -radix hexadecimal} {/testbench/axis_e/bcdvalue(5) -radix hexadecimal} {/testbench/axis_e/bcdvalue(4) -radix hexadecimal} {/testbench/axis_e/bcdvalue(3) -radix hexadecimal} {/testbench/axis_e/bcdvalue(2) -radix hexadecimal} {/testbench/axis_e/bcdvalue(1) -radix hexadecimal} {/testbench/axis_e/bcdvalue(0) -radix hexadecimal}} -subitemconfig {/testbench/axis_e/bcdvalue(31) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(30) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(29) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(28) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(27) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(26) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(25) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(24) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(23) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(22) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(21) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(20) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(19) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(18) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(17) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(16) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(15) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(14) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(13) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(12) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(11) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(10) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(9) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(8) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(7) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(6) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(5) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(4) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(3) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(2) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(1) {-height 29 -radix hexadecimal} /testbench/axis_e/bcdvalue(0) {-height 29 -radix hexadecimal}} /testbench/axis_e/bcdvalue
add wave -noupdate /testbench/axis_e/hz_tv
add wave -noupdate -radix hexadecimal /testbench/axis_e/hz_taddr
add wave -noupdate -radix hexadecimal /testbench/axis_e/vt_taddr
add wave -noupdate -radix hexadecimal /testbench/axis_e/vt_tv
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/btof_e/btof_e/frm
add wave -noupdate /testbench/btof_e/btof_e/bin_irdy
add wave -noupdate /testbench/btof_e/btof_e/bin_trdy
add wave -noupdate /testbench/btof_e/btof_e/bin_flt
add wave -noupdate -radix hexadecimal /testbench/btof_e/btof_e/bin_di
add wave -noupdate /testbench/btof_e/btof_e/bin_neg
add wave -noupdate /testbench/btof_e/btof_e/bcd_frm
add wave -noupdate /testbench/btof_e/btof_e/bcd_irdy
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/btof_e/btof_e/stof_frm
add wave -noupdate /testbench/btof_e/btof_e/stof_irdy
add wave -noupdate -color {Green Yellow} /testbench/btof_e/btof_e/bcd_trdy
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix hexadecimal /testbench/btof_e/btof_e/bcd_width
add wave -noupdate -radix hexadecimal /testbench/btof_e/btof_e/bcd_unit
add wave -noupdate -radix hexadecimal /testbench/btof_e/btof_e/bcd_prec
add wave -noupdate -radix hexadecimal /testbench/btof_e/btof_e/bcd_endian
add wave -noupdate -radix hexadecimal /testbench/btof_e/btof_e/bcd_align
add wave -noupdate -radix hexadecimal /testbench/btof_e/btof_e/bcd_sign
add wave -noupdate /testbench/btof_e/btof_e/bcd_end
add wave -noupdate -radix hexadecimal /testbench/btof_e/btof_e/bcd_do
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5330 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 264
configure wave -valuecolwidth 194
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
WaveRestoreZoom {37506 ns} {40132 ns}
