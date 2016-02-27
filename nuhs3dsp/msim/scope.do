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
add wave -noupdate /testbench/nuhs3dsp_e/ddrphy_e/sys_sti
add wave -noupdate -expand /testbench/nuhs3dsp_e/ddrphy_e/sys_sto
add wave -noupdate -divider {New Divider}
add wave -noupdate /testbench/nuhs3dsp_e/scope_e/dataio_e/miitxmem_e/miitx_clk
add wave -noupdate /testbench/nuhs3dsp_e/scope_e/dataio_e/miitxmem_e/miitx_ena
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/scope_e/dataio_e/miitxmem_e/txd
add wave -noupdate -radix hexadecimal /testbench/nuhs3dsp_e/scope_e/dataio_e/miitxmem_e/miitx_dat
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {25261100 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {25224578 ps} {25293141 ps}
