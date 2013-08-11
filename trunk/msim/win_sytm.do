onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/n
add wave -noupdate /testbench/vga_don
add wave -noupdate /testbench/vga_frm
add wave -noupdate /testbench/video_clk
add wave -noupdate -radix hexadecimal /testbench/win_sytm_e/col_pag
add wave -noupdate -radix hexadecimal /testbench/win_sytm_e/row_cnt
add wave -noupdate -radix hexadecimal /testbench/win_sytm_e/col_cnt(0)
add wave -noupdate -radix hexadecimal -childformat {{/testbench/win_sytm_e/col_cnt(0) -radix hexadecimal} {/testbench/win_sytm_e/col_cnt(1) -radix hexadecimal} {/testbench/win_sytm_e/col_cnt(2) -radix hexadecimal} {/testbench/win_sytm_e/col_cnt(3) -radix hexadecimal} {/testbench/win_sytm_e/col_cnt(4) -radix hexadecimal} {/testbench/win_sytm_e/col_cnt(5) -radix hexadecimal} {/testbench/win_sytm_e/col_cnt(6) -radix hexadecimal} {/testbench/win_sytm_e/col_cnt(7) -radix hexadecimal} {/testbench/win_sytm_e/col_cnt(8) -radix hexadecimal} {/testbench/win_sytm_e/col_cnt(9) -radix hexadecimal} {/testbench/win_sytm_e/col_cnt(10) -radix hexadecimal} {/testbench/win_sytm_e/col_cnt(11) -radix hexadecimal}} -subitemconfig {/testbench/win_sytm_e/col_cnt(0) {-height 16 -radix hexadecimal} /testbench/win_sytm_e/col_cnt(1) {-height 16 -radix hexadecimal} /testbench/win_sytm_e/col_cnt(2) {-height 16 -radix hexadecimal} /testbench/win_sytm_e/col_cnt(3) {-height 16 -radix hexadecimal} /testbench/win_sytm_e/col_cnt(4) {-height 16 -radix hexadecimal} /testbench/win_sytm_e/col_cnt(5) {-height 16 -radix hexadecimal} /testbench/win_sytm_e/col_cnt(6) {-height 16 -radix hexadecimal} /testbench/win_sytm_e/col_cnt(7) {-height 16 -radix hexadecimal} /testbench/win_sytm_e/col_cnt(8) {-height 16 -radix hexadecimal} /testbench/win_sytm_e/col_cnt(9) {-height 16 -radix hexadecimal} /testbench/win_sytm_e/col_cnt(10) {-height 16 -radix hexadecimal} /testbench/win_sytm_e/col_cnt(11) {-height 16 -radix hexadecimal}} /testbench/win_sytm_e/col_cnt
add wave -noupdate /testbench/win_sytm_e/rowpag_load
add wave -noupdate -radix hexadecimal -childformat {{/testbench/win_coloff(11) -radix hexadecimal} {/testbench/win_coloff(10) -radix hexadecimal} {/testbench/win_coloff(9) -radix hexadecimal} {/testbench/win_coloff(8) -radix hexadecimal} {/testbench/win_coloff(7) -radix hexadecimal} {/testbench/win_coloff(6) -radix hexadecimal} {/testbench/win_coloff(5) -radix hexadecimal} {/testbench/win_coloff(4) -radix hexadecimal} {/testbench/win_coloff(3) -radix hexadecimal} {/testbench/win_coloff(2) -radix hexadecimal} {/testbench/win_coloff(1) -radix hexadecimal} {/testbench/win_coloff(0) -radix hexadecimal}} -subitemconfig {/testbench/win_coloff(11) {-height 16 -radix hexadecimal} /testbench/win_coloff(10) {-height 16 -radix hexadecimal} /testbench/win_coloff(9) {-height 16 -radix hexadecimal} /testbench/win_coloff(8) {-height 16 -radix hexadecimal} /testbench/win_coloff(7) {-height 16 -radix hexadecimal} /testbench/win_coloff(6) {-height 16 -radix hexadecimal} /testbench/win_coloff(5) {-height 16 -radix hexadecimal} /testbench/win_coloff(4) {-height 16 -radix hexadecimal} /testbench/win_coloff(3) {-height 16 -radix hexadecimal} /testbench/win_coloff(2) {-height 16 -radix hexadecimal} /testbench/win_coloff(1) {-height 16 -radix hexadecimal} /testbench/win_coloff(0) {-height 16 -radix hexadecimal}} /testbench/win_coloff
add wave -noupdate /testbench/win_sytm_e/colpag_ena
add wave -noupdate -radix hexadecimal -childformat {{/testbench/win_colpag(1) -radix hexadecimal} {/testbench/win_colpag(0) -radix hexadecimal}} -subitemconfig {/testbench/win_colpag(1) {-height 16 -radix hexadecimal} /testbench/win_colpag(0) {-height 16 -radix hexadecimal}} /testbench/win_colpag
add wave -noupdate /testbench/win_colid
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/win_rowid
add wave -noupdate -radix hexadecimal /testbench/win_sytm_e/col_pag
add wave -noupdate -radix hexadecimal /testbench/win_sytm_e/cdata
add wave -noupdate /testbench/win_sytm_e/colpag_load
add wave -noupdate /testbench/win_sytm_e/rowpag_ena
add wave -noupdate -radix hexadecimal /testbench/win_rowoff
add wave -noupdate -radix hexadecimal /testbench/win_rowpag
add wave -noupdate -radix hexadecimal /testbench/win_sytm_e/row_pag
add wave -noupdate -radix hexadecimal /testbench/win_sytm_e/rdata
add wave -noupdate /testbench/video_vga_e/vsync
add wave -noupdate /testbench/video_vga_e/hsync
add wave -noupdate /testbench/vga_don
add wave -noupdate /testbench/video_vga_e/vparm
add wave -noupdate /testbench/video_vga_e/sync_gen/line__95/vcntr(0)
add wave -noupdate /testbench/video_vga_e/sync_gen/line__95/vcntr
add wave -noupdate /testbench/video_vga_e/heof
add wave -noupdate /testbench/video_vga_e/heot
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {33012344257 ps} 0} {{Cursor 2} {33056517857 ps} 0}
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
WaveRestoreZoom {33755624970 ps} {36118125002 ps}
