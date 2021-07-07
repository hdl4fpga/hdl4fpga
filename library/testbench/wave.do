onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/mii_clk
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/miitx_frm
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/miitx_irdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/miitx_trdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/miitx_end
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/ipoe_b/du_e/miitx_data
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {42187732170 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 248
configure wave -valuecolwidth 156
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
WaveRestoreZoom {38816239090 fs} {50588619 ps}
