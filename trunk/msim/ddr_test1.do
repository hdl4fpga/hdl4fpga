onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/rst
add wave -noupdate -format Logic /testbench/cs_n
add wave -noupdate -format Logic /testbench/cke
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/clk0
add wave -noupdate -format Logic /testbench/clk_p
add wave -noupdate -format Logic /testbench/ras_n
add wave -noupdate -format Logic /testbench/cas_n
add wave -noupdate -format Logic /testbench/we_n
add wave -noupdate -divider Address
add wave -noupdate -format Literal -radix hexadecimal /testbench/addr
add wave -noupdate -format Literal -radix hexadecimal /testbench/ba
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_st_lp_dqs
add wave -noupdate -divider Data
add wave -noupdate -format Literal -expand /testbench/dqs
add wave -noupdate -format Literal -radix hexadecimal /testbench/dq
add wave -noupdate -divider DDR_TP
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_tp_du_e/sys_rst
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_tp_du_e/sys_do_req
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_tp_du_e/sys_do_rdy
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/ddr_tp_du_e/gendata_p/seed1
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/ddr_tp_du_e/gendata_p/seed2
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/ddr_tp_du_e/gendata_p/seed3
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/ddr_tp_du_e/gendata_p/seed4
add wave -noupdate -format Literal /testbench/nuhs3dsp_e/ddr_tp_du_e/brt
add wave -noupdate -divider DDR
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/clk0
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_du_e/ddr_acc_du/ddr_acc_act
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_du_e/sys_cmd_req
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_du_e/sys_cmd_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_du_e/sys_di_req
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_du_e/sys_di_rdy
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/ddr_du_e/sys_di
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_du_e/sys_do_req
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_du_e/sys_do_rdy
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/ddr_du_e/sys_do
add wave -noupdate -divider DDR_ACC
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_du_e/ddr_acc_du/ddr_acc_dqz
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_du_e/ddr_acc_du/ddr_acc_dqsz
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_du_e/ddr_acc_du/ddr_acc_dwf
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_du_e/ddr_acc_du/ddr_acc_dwr
add wave -noupdate -divider {New Divider}
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_du_e/ddr_acc_du/ddr_acc_drw
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_du_e/ddr_acc_du/ddr_acc_dfw
add wave -noupdate -divider DDR_RD_FIFO
add wave -noupdate -divider {byte 0}
add wave -noupdate -format Literal /testbench/nuhs3dsp_e/ddr_du_e/ddr_rd_fifo_b/fifo_bytes_g__0/ddr_fifo__0/addr_i_q
add wave -noupdate -format Literal /testbench/nuhs3dsp_e/ddr_du_e/ddr_rd_fifo_b/fifo_bytes_g__0/addr_o_q
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/ddr_du_e/ddr_rd_fifo_b/ddr_fifo_di(0)
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_du_e/ddr_rd_fifo_b/ddr_fifo_emty(0)
add wave -noupdate -divider {byte 1}
add wave -noupdate -format Literal -radix hexadecimal /testbench/nuhs3dsp_e/ddr_du_e/ddr_rd_fifo_b/ddr_fifo_di(1)
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_du_e/ddr_rd_fifo_b/ddr_fifo_emty(1)
add wave -noupdate -divider DDR_WR_FIFO
add wave -noupdate -divider {byte 0}
add wave -noupdate -format Logic /testbench/nuhs3dsp_e/ddr_du_e/ddr_wr_fifo_e/data_byte_g__0/ena
add wave -noupdate -format Literal /testbench/nuhs3dsp_e/ddr_du_e/ddr_wr_fifo_e/data_byte_g__0/sys_addr_q
add wave -noupdate -format Literal /testbench/nuhs3dsp_e/ddr_du_e/ddr_wr_fifo_e/ddr_addr_q(0)
add wave -noupdate -divider {byte 1}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {398490351 ps} 0} {{Cursor 2} {1418184 ps} 0}
configure wave -namecolwidth 134
configure wave -valuecolwidth 40
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
WaveRestoreZoom {397955818 ps} {399374002 ps}
