onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/ecp3versa_e/cga_e/sys_clk
add wave -noupdate -radix hexadecimal /testbench/ecp3versa_e/cga_e/font_code
add wave -noupdate -radix hexadecimal /testbench/ecp3versa_e/cga_e/sys_row
add wave -noupdate -radix hexadecimal -childformat {{/testbench/ecp3versa_e/cga_e/sys_col(10) -radix hexadecimal} {/testbench/ecp3versa_e/cga_e/sys_col(9) -radix hexadecimal} {/testbench/ecp3versa_e/cga_e/sys_col(8) -radix hexadecimal} {/testbench/ecp3versa_e/cga_e/sys_col(7) -radix hexadecimal} {/testbench/ecp3versa_e/cga_e/sys_col(6) -radix hexadecimal} {/testbench/ecp3versa_e/cga_e/sys_col(5) -radix hexadecimal} {/testbench/ecp3versa_e/cga_e/sys_col(4) -radix hexadecimal}} -subitemconfig {/testbench/ecp3versa_e/cga_e/sys_col(10) {-height 16 -radix hexadecimal} /testbench/ecp3versa_e/cga_e/sys_col(9) {-height 16 -radix hexadecimal} /testbench/ecp3versa_e/cga_e/sys_col(8) {-height 16 -radix hexadecimal} /testbench/ecp3versa_e/cga_e/sys_col(7) {-height 16 -radix hexadecimal} /testbench/ecp3versa_e/cga_e/sys_col(6) {-height 16 -radix hexadecimal} /testbench/ecp3versa_e/cga_e/sys_col(5) {-height 16 -radix hexadecimal} /testbench/ecp3versa_e/cga_e/sys_col(4) {-height 16 -radix hexadecimal}} /testbench/ecp3versa_e/cga_e/sys_col
add wave -noupdate /testbench/ecp3versa_e/vga_vld
add wave -noupdate -radix hexadecimal /testbench/ecp3versa_e/vga_vcntr
add wave -noupdate -radix hexadecimal /testbench/ecp3versa_e/vga_hcntr
add wave -noupdate /testbench/ecp3versa_e/vga_hsync
add wave -noupdate /testbench/ecp3versa_e/vga_vsync
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 128
configure wave -valuecolwidth 197
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
WaveRestoreZoom {0 ns} {22840 ns}
