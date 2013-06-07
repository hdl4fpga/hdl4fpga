onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /testbench/clk0
add wave -noupdate -format Logic /testbench/clk90
add wave -noupdate -format Logic /testbench/clk180
add wave -noupdate -format Logic /testbench/clk270
add wave -noupdate -divider Command
add wave -noupdate -format Logic /testbench/ddr_rst
add wave -noupdate -format Logic /testbench/ddr_as
add wave -noupdate -divider Timer
add wave -noupdate -format Logic /testbench/ddr_timer_sel
add wave -noupdate -format Logic /testbench/ddr_timer_req
add wave -noupdate -format Logic /testbench/ddr_timer_200u
add wave -noupdate -format Logic /testbench/ddr_timer_dll
add wave -noupdate -format Logic /testbench/ddr_timer_ref
add wave -noupdate -divider init
add wave -noupdate -format Logic /testbench/ddr_init_req
add wave -noupdate -format Logic /testbench/ddr_init_rdy
add wave -noupdate -divider Access
add wave -noupdate -format Logic /testbench/ddr_acc_ras
add wave -noupdate -format Logic /testbench/ddr_acc_cas
add wave -noupdate -format Logic /testbench/ddr_acc_we
add wave -noupdate -color Gold -format Logic /testbench/ddr_acc_du/ddr_acc_col
add wave -noupdate -format Logic /testbench/ddr_acc_du/ac_rdy
add wave -noupdate -format Logic /testbench/ddr_acc_du/cl_rdy
add wave -noupdate -format Logic /testbench/ddr_acc_du/bl_rdy
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_acc_du/state_p/ac_timer
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_acc_du/state_p/cl_timer
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_acc_du/state_p/bl_timer
add wave -noupdate -divider ddr_fifo
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_r_e/ddr_fifo_clki
add wave -noupdate -format Logic -radix binary /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_r_e/ddr_fifo_enai
add wave -noupdate -format Logic /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_dqs_r
add wave -noupdate -format Logic /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_dqs_f
add wave -noupdate -format Logic /testbench/ddr_acc_du/ddr_acc_dqw
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_r_e/addr_i
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_r_e/addr_o
add wave -noupdate -divider {rising dqs}
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_r_e/ram(0)
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_r_e/ram(1)
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_r_e/ram(3)
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_r_e/ram(2)
add wave -noupdate -divider {falling dqs}
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_f_e/ram(0)
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_f_e/ram(1)
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_f_e/ram(3)
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_f_e/ram(2)
add wave -noupdate -divider mt46v16m16
add wave -noupdate -format Logic /testbench/cke
add wave -noupdate -format Logic /testbench/cs_n
add wave -noupdate -format Logic /testbench/ras_n
add wave -noupdate -format Logic /testbench/cas_n
add wave -noupdate -format Logic /testbench/we_n
add wave -noupdate -format Literal /testbench/ba
add wave -noupdate -format Literal -radix hexadecimal /testbench/addr
add wave -noupdate -format Literal -expand /testbench/dqs
add wave -noupdate -format Literal -radix hexadecimal /testbench/dq
add wave -noupdate -format Literal /testbench/dm
add wave -noupdate -format Literal -radix hexadecimal /testbench/genpat_du/col_a
add wave -noupdate -format Logic /testbench/ddr_acc_du/ddr_acc_dqz
add wave -noupdate -format Logic /testbench/clk0
add wave -noupdate -format Logic /testbench/clk90
add wave -noupdate -format Logic /testbench/clk180
add wave -noupdate -format Logic /testbench/clk270
add wave -noupdate -divider Command
add wave -noupdate -format Logic /testbench/ddr_rst
add wave -noupdate -format Logic /testbench/ddr_as
add wave -noupdate -divider Timer
add wave -noupdate -format Logic /testbench/ddr_timer_sel
add wave -noupdate -format Logic /testbench/ddr_timer_req
add wave -noupdate -format Logic /testbench/ddr_timer_200u
add wave -noupdate -format Logic /testbench/ddr_timer_dll
add wave -noupdate -format Logic /testbench/ddr_timer_ref
add wave -noupdate -divider init
add wave -noupdate -format Logic /testbench/ddr_init_req
add wave -noupdate -format Logic /testbench/ddr_init_rdy
add wave -noupdate -divider Access
add wave -noupdate -format Logic /testbench/ddr_acc_ras
add wave -noupdate -format Logic /testbench/ddr_acc_cas
add wave -noupdate -format Logic /testbench/ddr_acc_we
add wave -noupdate -color Gold -format Logic /testbench/ddr_acc_du/ddr_acc_col
add wave -noupdate -format Logic /testbench/ddr_acc_du/ac_rdy
add wave -noupdate -format Logic /testbench/ddr_acc_du/cl_rdy
add wave -noupdate -format Logic /testbench/ddr_acc_du/bl_rdy
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_acc_du/state_p/ac_timer
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_acc_du/state_p/cl_timer
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_acc_du/state_p/bl_timer
add wave -noupdate -divider ddr_fifo
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_r_e/ddr_fifo_clki
add wave -noupdate -format Logic -radix binary /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_r_e/ddr_fifo_enai
add wave -noupdate -format Logic /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_dqs_r
add wave -noupdate -format Logic /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_dqs_f
add wave -noupdate -format Logic /testbench/ddr_acc_du/ddr_acc_dqw
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_r_e/addr_i
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_r_e/addr_o
add wave -noupdate -divider {rising dqs}
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_r_e/ram(0)
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_r_e/ram(1)
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_r_e/ram(3)
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_r_e/ram(2)
add wave -noupdate -divider {falling dqs}
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_f_e/ram(0)
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_f_e/ram(1)
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_f_e/ram(3)
add wave -noupdate -format Literal -radix hexadecimal /testbench/ddr_fifo_b/fifo_bytes_g__0/ddr_fifo_f_e/ram(2)
add wave -noupdate -divider mt46v16m16
add wave -noupdate -format Logic /testbench/cke
add wave -noupdate -format Logic /testbench/cs_n
add wave -noupdate -format Logic /testbench/ras_n
add wave -noupdate -format Logic /testbench/cas_n
add wave -noupdate -format Logic /testbench/we_n
add wave -noupdate -format Literal /testbench/ba
add wave -noupdate -format Literal -radix hexadecimal /testbench/addr
add wave -noupdate -format Literal -expand /testbench/dqs
add wave -noupdate -format Literal -radix hexadecimal /testbench/dq
add wave -noupdate -format Literal /testbench/dm
add wave -noupdate -format Literal -radix hexadecimal /testbench/genpat_du/col_a
add wave -noupdate -format Logic /testbench/ddr_acc_du/ddr_acc_dqz
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4687737 ps} 0}
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
WaveRestoreZoom {4456928 ps} {4902235 ps}
