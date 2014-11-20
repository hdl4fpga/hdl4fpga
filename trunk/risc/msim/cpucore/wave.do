onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -label rst /testbench/rsts
add wave -noupdate -format Literal -label clknum /testbench/clknums
add wave -noupdate -format Logic -label clk /testbench/clks
add wave -noupdate -divider {INSTRUCTION REGISTERS}
add wave -noupdate -format Literal -label Nemonic /testbench/opcs
add wave -noupdate -color Blue -format Literal -itemcolor Blue -label {Fetch Register} -radix hexadecimal /testbench/codes
add wave -noupdate -divider <NULL>
add wave -noupdate -color Gold -format Literal -itemcolor Gold -label {Decode  Register} -radix hexadecimal /testbench/dut/instrdec
add wave -noupdate -color Gold -format Logic -itemcolor Gold -label dec_null_q /testbench/dut/dec_null_q
add wave -noupdate -color Gold -format Logic -itemcolor Gold -label dec_ena_d /testbench/dut/ctrlunit/dec_ena_d
add wave -noupdate -color Gold -format Logic -itemcolor Gold -label hzrd_d /testbench/dut/ctrlunit/hzrd_d
add wave -noupdate -divider {INSTRUCTION REGISTERS}
add wave -noupdate -format Literal -label Nemonic /testbench/opcs
add wave -noupdate -color Cyan -format Literal -itemcolor Cyan -label {Execute  Register} -radix hexadecimal /testbench/dut/instrexe
add wave -noupdate -color Cyan -format Logic -itemcolor Cyan -label exe_null_q /testbench/dut/exe_null_q
add wave -noupdate -color Cyan -format Logic -itemcolor Cyan -label exa_ena_d /testbench/dut/ctrlunit/exe_ena_d
add wave -noupdate -divider {INSTRUCTION REGISTERS}
add wave -noupdate -format Literal -label Nemonic /testbench/opcs
add wave -noupdate -color Green -format Literal -itemcolor Green -label {Memory  Register} -radix hexadecimal /testbench/dut/instrmem
add wave -noupdate -color Green -format Logic -itemcolor Green -label mem_null_q /testbench/dut/mem_null_q
add wave -noupdate -divider <NULL>
add wave -noupdate -color Green -format Logic -itemcolor Green -label mem_hzrd_d /testbench/dut/ctrlunit/mem_hzrd_d
add wave -noupdate -divider {INSTRUCTION REGISTERS}
add wave -noupdate -format Literal -label Nemonic /testbench/opcs
add wave -noupdate -color Tan -format Logic -itemcolor Tan -label wbk_hzrd_d /testbench/dut/ctrlunit/wbk_hzrd_d
add wave -noupdate -color Tan -format Logic -itemcolor Tan -label wbk_rs1_hzrd_q /testbench/dut/ctrlunit/wbk_rs1_hzrd_q
add wave -noupdate -color Tan -format Logic -itemcolor Tan -label wbk_rs2_hzrd_q /testbench/dut/ctrlunit/wbk_rs2_hzrd_q
add wave -noupdate -divider {FETCH STAGE}
add wave -noupdate -divider {PC control}
add wave -noupdate -color Magenta -format Logic -itemcolor Magenta -label ip_ena_d /testbench/dut/ip_ena_d
add wave -noupdate -color Red -format Logic -itemcolor Red -label ip_load /testbench/dut/ip_load_d
add wave -noupdate -color Gold -format Logic -itemcolor Gold -label pcdisp_high_ena /testbench/dut/pcdisp_high_ena_q
add wave -noupdate -format Logic -label pcdisp_high_to_0 /testbench/dut/pcdisp_high_to_0_d
add wave -noupdate -format Logic -label pctrgt_high_ena /testbench/dut/pctrgt_high_ena_q
add wave -noupdate -format Logic -label pctrgt_high_inc /testbench/dut/pctrgt_high_inc_q
add wave -noupdate -format Logic -label pctrgt_low_cout_q /testbench/dut/pctrgt_low_cout_q
add wave -noupdate -format Logic -label pctrgt_low_cy /testbench/dut/stages/fetch/pctrgt_low_cy
add wave -noupdate -format Literal -label pcdisp_hhalf_q -radix hexadecimal /testbench/dut/stages/fetch/pcdisp_hhalf_q
add wave -noupdate -format Literal -label pctrgt_d -radix hexadecimal /testbench/dut/stages/fetch/pctrgt_d
add wave -noupdate -format Literal -label pctrgt_q -radix hexadecimal /testbench/dut/stages/fetch/pctrgt_q
add wave -noupdate -divider {DECODE STAGE}
add wave -noupdate -format Logic -label ip_ena_d /testbench/dut/ip_ena_d
add wave -noupdate -format Logic -label dec_ena_d /testbench/dut/ctrlunit/dec_ena_d
add wave -noupdate -format Logic -label dec_imm_hzrd_d /testbench/dut/ctrlunit/dec_imm_hzrd_d
add wave -noupdate -format Logic -label exe_nop_q /testbench/dut/ctrlunit/exe_nop_q
add wave -noupdate -format Logic -label exe_opc_hzrd_q /testbench/dut/ctrlunit/exe_opc_hzrd_q
add wave -noupdate -format Logic -label exe_rs1_hzrd_d /testbench/dut/ctrlunit/exe_rs1_hzrd_d
add wave -noupdate -format Logic -label exe_rs2_hzrd_d /testbench/dut/ctrlunit/exe_rs2_hzrd_d
add wave -noupdate -format Logic -label mem_opc_hzrd_q /testbench/dut/ctrlunit/mem_opc_hzrd_q
add wave -noupdate -divider {Register file}
add wave -noupdate -format Logic -label dec_reg_ena_d /testbench/dut/dec_reg_ena_d
add wave -noupdate -format Literal -label dec_rdval_d -radix hexadecimal /testbench/dut/stages/dec_rdval_d
add wave -noupdate -divider {Register flag}
add wave -noupdate -format Literal -label t_flg_rs -radix unsigned /testbench/dut/stages/decode/t_flg_rs
add wave -noupdate -format Literal -label t_flg_rd -radix unsigned /testbench/dut/stages/decode/t_flg_rd
add wave -noupdate -format Logic -label dec_t_bit_wr_d /testbench/dut/dec_t_bit_wr_d
add wave -noupdate -format Logic -label dec_t_bit_rd_d /testbench/dut/dec_t_bit_rd_d
add wave -noupdate -format Literal -label T_register -radix hexadecimal /testbench/dut/stages/decode/flagfile/t_storage
add wave -noupdate -divider {EXECUTE STAGE}
add wave -noupdate -format Literal -label immediate -radix hexadecimal /testbench/dut/stages/exe_sign_extn_q
add wave -noupdate -format Literal -label rs1val -radix hexadecimal /testbench/dut/stages/exe_rs1val_q
add wave -noupdate -format Literal -label rs2val -radix hexadecimal /testbench/dut/stages/exe_rs2val_q
add wave -noupdate -format Literal -label exe_sht_disp_q -radix decimal /testbench/dut/exe_sht_disp_q
add wave -noupdate -divider {MEMORY STAGE}
add wave -noupdate -format Literal -label addi_lhalf -radix hexadecimal /testbench/dut/stages/mem_addi_lhalf_q
add wave -noupdate -format Literal -label addi_hhalf_c0 -radix hexadecimal /testbench/dut/stages/mem_addi_hhalf_c0_q
add wave -noupdate -format Literal -label addi_hhalf_c0 -radix hexadecimal /testbench/dut/stages/mem_addi_hhalf_c1_q
add wave -noupdate -format Literal -label mem_alu_shtrot_q -radix hexadecimal /testbench/dut/stages/mem_alu_shtrot_q
add wave -noupdate -format Logic -label exe_sel_arth_sht_q /testbench/dut/exe_sel_arth_sht_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {332 ns} 0}
configure wave -namecolwidth 162
configure wave -valuecolwidth 76
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {201 ns} {411 ns}
