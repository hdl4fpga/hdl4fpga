onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/mii_clk
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/miirx_frm
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/miirx_irdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/miirx_trdy
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/ipoe_b/du_e/miirx_data
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ethrx_e/crc_sb
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ethrx_e/crc_equ
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/arpd_e/arpd_rdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/arpd_e/arpd_req
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/arpd_e/arptx_frm
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/arpd_e/arptx_irdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/arpd_e/arptx_trdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/arpd_e/arptx_end
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/ipoe_b/du_e/arpd_e/arptx_data
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ethpltx_trdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ethpltx_irdy
add wave -noupdate -expand /testbench/du_e/ipoe_g/ipoe_b/du_e/arbiter_b/dev_gnt
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ethtx_frm
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ethtx_irdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ethtx_e/hwllc_irdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ethtx_e/hwllc_trdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ethtx_e/hwllc_end
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ethtx_e/mii_frm
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ethtx_e/mii_irdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ethtx_e/mii_trdy
add wave -noupdate /testbench/du_e/ipoe_g/ipoe_b/du_e/ethtx_e/mii_end
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/ipoe_b/du_e/ethtx_e/mii_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/ipoe_b/du_e/ethtx_e/fcs_data
add wave -noupdate -radix hexadecimal /testbench/du_e/ipoe_g/ipoe_b/du_e/ethtx_e/hwllc_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7651096670 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 237
configure wave -valuecolwidth 248
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
WaveRestoreZoom {5300111700 fs} {13175111700 fs}
