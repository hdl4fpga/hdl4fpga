onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/nuhs3dsp_e/cga_e/sys_clk
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/cga_e/sys_row
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/cga_e/sys_col
add wave -noupdate /testbench/nuhs3dsp_e/cga_e/sys_we
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/cga_e/sys_code
add wave -noupdate /testbench/nuhs3dsp_e/cga_e/vga_clk
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/cga_e/vga_row
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/cga_e/vga_col
add wave -noupdate /testbench/nuhs3dsp_e/cga_e/vga_dot
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/cga_e/cga_row
add wave -noupdate -color Cyan -radix hexadecimal -childformat {{/testbench/nuhs3dsp_e/cga_e/cga_col(9) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_col(8) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_col(7) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_col(6) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_col(5) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_col(4) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_col(3) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_col(2) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_col(1) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_col(0) -radix hexadecimal}} -subitemconfig {/testbench/nuhs3dsp_e/cga_e/cga_col(9) {-color Cyan -height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_col(8) {-color Cyan -height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_col(7) {-color Cyan -height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_col(6) {-color Cyan -height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_col(5) {-color Cyan -height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_col(4) {-color Cyan -height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_col(3) {-color Cyan -height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_col(2) {-color Cyan -height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_col(1) {-color Cyan -height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_col(0) {-color Cyan -height 16 -radix hexadecimal}} /testbench/nuhs3dsp_e/cga_e/cga_col
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/cga_e/cgaram_row
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/cga_e/cgaram_col
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/cga_e/cgaram_code
add wave -noupdate -color Orchid -radix hexadecimal /testbench/nuhs3dsp_e/cga_e/font_code
add wave -noupdate -color {Orange Red} -radix hexadecimal /testbench/nuhs3dsp_e/cga_e/font_row
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/cga_e/font_line
add wave -noupdate -color {Violet Red} -radix hexadecimal -childformat {{/testbench/nuhs3dsp_e/cga_e/cga_line(7) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_line(6) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_line(5) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_line(4) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_line(3) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_line(2) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_line(1) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_line(0) -radix hexadecimal}} -subitemconfig {/testbench/nuhs3dsp_e/cga_e/cga_line(7) {-color {Violet Red} -height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_line(6) {-color {Violet Red} -height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_line(5) {-color {Violet Red} -height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_line(4) {-color {Violet Red} -height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_line(3) {-color {Violet Red} -height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_line(2) {-color {Violet Red} -height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_line(1) {-color {Violet Red} -height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_line(0) {-color {Violet Red} -height 16 -radix hexadecimal}} /testbench/nuhs3dsp_e/cga_e/cga_line
add wave -noupdate -radix hexadecimal -childformat {{/testbench/nuhs3dsp_e/cga_e/cga_sel(2) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_sel(1) -radix hexadecimal} {/testbench/nuhs3dsp_e/cga_e/cga_sel(0) -radix hexadecimal}} -subitemconfig {/testbench/nuhs3dsp_e/cga_e/cga_sel(2) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_sel(1) {-height 16 -radix hexadecimal} /testbench/nuhs3dsp_e/cga_e/cga_sel(0) {-height 16 -radix hexadecimal}} /testbench/nuhs3dsp_e/cga_e/cga_sel
add wave -noupdate /testbench/nuhs3dsp_e/vga_dot
add wave -noupdate /testbench/nuhs3dsp_e/cga_e/fontrom_e/rom
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/sys_col
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/sys_row
add wave -noupdate /testbench/nuhs3dsp_e/vga_blank
add wave -noupdate /testbench/nuhs3dsp_e/vga_clk
add wave -noupdate /testbench/nuhs3dsp_e/vga_don
add wave -noupdate /testbench/nuhs3dsp_e/vga_frm
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/vga_hcntr
add wave -noupdate /testbench/nuhs3dsp_e/vga_hsync
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/vga_vcntr
add wave -noupdate /testbench/nuhs3dsp_e/vga_vsync
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 11} {1512134999 ps} 0} {{Cursor 12} {1512161650 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 146
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
WaveRestoreZoom {1512154126 ps} {1512304060 ps}
