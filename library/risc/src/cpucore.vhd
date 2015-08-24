--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.aux_parts.all;
use work.aux_functions.all;
use work.cpu_parts.all;
use work.isa.all;

entity cpucore is
 	generic (
 		dwidth : natural := 32;
 		cwidth : natural := 16);
 	port (
 		rst   : in  std_ulogic;
 		clk   : in  std_ulogic;
 		caddr : out std_ulogic_vector(dwidth-1 downto 0);
 		code  : in  std_ulogic_vector(0 to cwidth-1));

end;

architecture pipeLine of cpuCore is
	subtype dword is std_ulogic_vector(dwidth-1   downto 0);
	subtype hhalf is std_ulogic_vector(dwidth-1   downto dwidth/2);
	subtype lhalf is std_ulogic_vector(dwidth/2-1 downto 0);

 	-----------------------------
 	-- Instrunction Registers  --
 	-----------------------------

	signal instrFch : std_ulogic_vector(code'range);
 	signal instrDec : std_ulogic_vector(code'range);
 	signal instrExe : std_ulogic_vector(code'range);
 	signal instrMem : std_ulogic_vector(code'range);
 	signal instrWbk : std_ulogic_vector(code'range);

	-- Fetch Stage --

	signal ift_null_q : std_ulogic;
 	signal isJal  : std_ulogic;
 	signal isJimm : std_ulogic;
 	signal isJcnd : std_ulogic;

	signal ip_load_d : std_ulogic;
	signal ip_ena_d : std_ulogic := '1';

	signal selDisp12 : std_ulogic;
	
	signal pcdisp_high_ena_q : std_ulogic;
	signal pctrgt_high_ena_q : std_ulogic;
	signal pctrgt_low_cout_q : std_ulogic;
	signal pctrgt_high_cin_d : std_ulogic;
	signal pctrgt_high_inc_q : std_ulogic;
	signal pcdisp_high_to_0_d : std_ulogic;
	
	-- Decode Stage --

	signal dec_null_q : std_ulogic;
	signal dec_t_bit_rd_d : std_ulogic;
	signal dec_t_bit_wr_d : std_ulogic;
	signal dec_reg_ena_d : std_ulogic;
	signal dec_flg_ena_d : std_ulogic;

	constant alu_integer_add  : std_ulogic_vector(1 downto 0) := "00";
	constant alu_integer_sub  : std_ulogic_vector(1 downto 0) := "01";
	constant alu_integer_addi : std_ulogic_vector(1 downto 0) := "10";

	-- Execute Stage --

	signal exe_null_q : std_ulogic;

	constant aluout_integer : std_ulogic_vector(1 downto 0) := "00";
	constant aluout_logic   : std_ulogic_vector(1 downto 0) := "01";
	constant aluout_shtrot  : std_ulogic_vector(1 downto 0) := "10";
	constant aluout_rs2val  : std_ulogic_vector(1 downto 0) := "11";

	constant rdval_aluout : std_ulogic_vector(0 downto 0) := "0";
	constant rdval_load   : std_ulogic_vector(0 downto 0) := "1";

	constant logic_or  : std_ulogic_vector := "00";
	constant logic_and : std_ulogic_vector := "01";
	constant logic_xor : std_ulogic_vector := "11";

	signal exe_sel_logic_op_q : std_ulogic_vector(1 downto 0);

	constant logic_rr : std_ulogic := '1';
	constant logic_ri : std_ulogic := '0';

	signal exe_sel_alu_integer_q : std_ulogic_vector(1 downto 0);
	signal exe_sel_logic_reg_imm_q : std_ulogic;
	signal exe_sel_arth_sht_q : std_ulogic;
	signal exe_sht_disp_q : std_ulogic_vector(5 downto 0);

	-- Memory Stage --

	signal mem_null_q : std_ulogic;
	signal mem_sel_rdval_q  : std_ulogic_vector(0 downto 0);
	signal mem_sel_aluout_q : std_ulogic_vector(1 downto 0);
	signal mem_data_rw_d : std_ulogic;

	signal mem_data_size_q : std_ulogic_vector(1 downto 0);
	
begin
 	stages: block
 		signal ip : std_ulogic_vector (caddr'range);

		signal dec_sign_extn_d : dword;
		signal dec_rs1val_d : dword;
		signal dec_rs2val_d : dword;
		signal dec_rdval_d : dword;

		signal exe_t_bit_q : std_ulogic;
		signal exe_sign_extn_q : dword;
		signal exe_rs1val_q : dword;
		signal exe_rs2val_q : dword;
		signal exe_alu_logic_d : dword;
		signal exe_alu_logic_t_bit_d : std_ulogic;
		signal exe_alu_shtrot_d : dword;
		signal exe_dataout_d : dword;

		signal exe_alu_integer_lhalf_d : lhalf;
		signal exe_alu_integer_hhalf_c0_d : hhalf;
		signal exe_alu_integer_hhalf_c1_d : hhalf;
		signal exe_alu_integer_co_d : std_ulogic;
		signal exe_alu_integer_c0_d : std_ulogic;
		signal exe_alu_integer_c1_d : std_ulogic;

		signal exe_addr_lhalf_d : lhalf;
		signal exe_addr_lhalf_co_d : std_ulogic;

		signal mem_t_bit_q : std_ulogic;
		signal mem_alu_logic_q : dword;
		signal mem_alu_logic_t_bit_q : std_ulogic;
		signal mem_alu_shtrot_q : dword;

		signal mem_rs2val_q : dword;
		signal mem_addr_lhalf_q : lhalf;
		signal mem_addr_lhalf_co_q : std_ulogic;

		signal mem_alu_integer_lhalf_q : lhalf;
		signal mem_alu_integer_hhalf_c0_q : hhalf;
		signal mem_alu_integer_hhalf_c1_q : hhalf;
		signal mem_alu_integer_co_q : std_ulogic;
		signal mem_alu_integer_c0_q : std_ulogic;
		signal mem_alu_integer_c1_q : std_ulogic;

		
 	begin
		caddr <= ip;

		fetch: block
			function extn_sign (val : std_ulogic_vector; n : natural)
				return std_ulogic_vector is
			begin
				return (0 to n-val'length-1 => val(val'left));
			end;
			
			alias imm8  : std_ulogic_vector(7 downto 0) is instrDec(im8Fld);
			alias imm12 : std_ulogic_vector(11 downto 0) is instrDec(im12Fld);
			signal pcdisp_hhalf_q : hhalf;
			signal pctrgt_low_cy : std_ulogic;
			signal pctrgt_d : dword;
			
			signal pctrgt_q : dword;

			signal pctrgt_low_cout_d : std_ulogic;
		begin
			pc : pc32
				generic map (N => dwidth, M => 1)
				port map (rst, clk,
					ena => ip_ena_d,
					enaSel => ip_ena_d,
					selData(0) => ip_load_d,
					data   => pctrgt_q,
					datap2 => pctrgt_q,
					q => ip);

			with selDisp12 select
				dec_sign_extn_d <= 
					extn_sign(imm12, dec_sign_extn_d'length) & imm12 when '1',
		 			extn_sign(imm8, dec_sign_extn_d'length) & imm8 when others;

			pctrgt_low_ffd : unsigned_adder
				port map (pctrgt_d(lhalf'range), ip(lhalf'range), dec_sign_extn_d(lhalf'range), cout => pctrgt_low_cout_d);

			pctrgt_high_ffd : unsigned_adder
				port map (pctrgt_d(hhalf'range), ip(hhalf'range), pcdisp_hhalf_q, cin => pctrgt_high_cin_d);

			registers: process (clk)
			begin
				if rising_edge(clk) then
					if pcdisp_high_ena_q='1' then
						case pcdisp_high_to_0_d is
						when '0' => 
							pcdisp_hhalf_q <= dec_sign_extn_d(hhalf'range);
						when '1' =>
							pcdisp_hhalf_q <= (others => '0');
						when others =>
							pcdisp_hhalf_q <= (others => '-');
						end case;
					end if;

					pctrgt_low_cout_q <= pctrgt_low_cout_d;

					pctrgt_q(lhalf'range) <= pctrgt_d(lhalf'range);
					if pctrgt_high_ena_q='1' then
						pctrgt_q(hhalf'range) <= pctrgt_d(hhalf'range);
					end if;
				end if;
			end process;
			pctrgt_high_cin_d <= pctrgt_low_cout_q or pctrgt_high_inc_q;

			ip_load_d <= SetIf((isJal='1' or (isJcnd='1'and dec_t_bit_rd_d='1')) and pcdisp_high_ena_q='1');
			pcdisp_high_to_0_d <= not ((isJimm or isJcnd) and pcdisp_high_ena_q) and pctrgt_high_inc_q;
			process (rst,clk)
			begin
				if rst='1' then
					pcdisp_high_ena_q  <= '1';
					pctrgt_high_ena_q  <= '0';
					pctrgt_high_inc_q  <= '1';
					pctrgt_low_cy <= '0';
				elsif rising_edge(clk) then
					if ip_load_d='1' and ip_ena_d='1' then
						pctrgt_low_cy <= '0';
						pcdisp_high_ena_q  <= '0';
						pctrgt_high_ena_q  <= '1';
						pctrgt_high_inc_q  <= '0';
					else
						if pctrgt_high_inc_q='0' then
							pctrgt_high_inc_q <= '1';
							pctrgt_low_cy <= pctrgt_low_cout_q;
						end if;
						if pctrgt_high_inc_q='0' then
							pctrgt_high_inc_q <= '1';
						end if;
						if pctrgt_high_inc_q='1' then
							pcdisp_high_ena_q <= '1';
							if pctrgt_low_cy='0' then
								pctrgt_high_ena_q <= '0';
							end if;
						end if;
						if pcdisp_high_ena_q='1' then
							pctrgt_high_ena_q <= '0';
						end if;
					end if;
				end if;				
			end process;

		end block;

 		decode: block
			signal t_flg_we : std_ulogic;
			signal t_flg_rs : std_ulogic_vector(ridFld);
			signal t_flg_rd : std_ulogic_vector(ridFld);
			signal t_bit_din : std_ulogic;
			signal t_bit_dout : std_ulogic;
 		begin
		
			t_flg_we <= dec_flg_ena_d;
			t_flg_rs <= instrDec(rs1Fld);
			t_flg_rd <= instrMem(rdFld);
			t_bit_din <= dec_t_bit_wr_d;
			dec_t_bit_rd_d <= t_bit_dout;

			flagFile : block
				signal t_storage : std_ulogic_vector (0 to 15) 
					:= (15 => '1', others => '0');
			begin
				process (rst,clk)
				begin
					if rising_edge(clk) then
						if t_flg_we='1' then
							t_storage(to_integer(unsigned(t_flg_rd))) <= t_bit_din;
						end if;
					end if;
				end process;
				t_bit_dout <= t_storage(to_integer(unsigned(t_flg_rs)));
			end block;

			registerFile1 : dpram
				generic map (ridLen, dword'length)
				port map (
					clk   => clk,
					we    => dec_reg_ena_d,
					wAddr => instrMem(rdFld),
					din   => dec_rdval_d,
					rAddr => instrDec(rs1Fld),
					dout  => dec_rs1val_d);

			registerFile2 : dpram 
				generic map (ridLen, dword'length)
				port map (
					clk   => clk,
					we    => dec_reg_ena_d,
					wAddr => instrMem(rdFld),
					din   => dec_rdval_d,
					rAddr => instrDec(rs2Fld),
					dout  => dec_rs2val_d);

		end block;

		dec_exe_register: process (clk)
		begin
			if rising_edge(clk) then
				exe_sign_extn_q <= dec_sign_extn_d;
				exe_t_bit_q <= dec_t_bit_rd_d;
				exe_rs1val_q <= dec_rs1val_d;
				exe_rs2val_q <= dec_rs2val_d;
			end if;
		end process;
			
		execute: block
			alias exe_addr_imm_q is instrExe(funFld);

			signal rs1_val_d : dword;
			signal rs2_val_d : dword;

			signal logic_reg_reg_d : dword;
			signal logic_reg_imm_d : dword;

			signal add_reg_reg_lhalf_d : hhalf;
			signal sub_reg_reg_lhalf_d : hhalf;
			signal add_reg_imm_lhalf_d : hhalf;

			signal add_reg_reg_hhalf_c0_d : hhalf;
			signal sub_reg_reg_hhalf_b0_d : hhalf;
			signal add_reg_imm_hhalf_c0_d : hhalf;

			signal add_reg_reg_hhalf_c1_d : hhalf;
			signal sub_reg_reg_hhalf_b1_d : hhalf;
			signal add_reg_imm_hhalf_c1_d : hhalf;

			signal add_reg_reg_co_d : std_ulogic;
			signal sub_reg_reg_bo_d : std_ulogic;
			signal add_reg_imm_co_d : std_ulogic;

			signal add_reg_reg_c0_d : std_ulogic;
			signal sub_reg_reg_b0_d : std_ulogic;
			signal add_reg_imm_c0_d : std_ulogic;

			signal add_reg_reg_c1_d : std_ulogic;
			signal sub_reg_reg_b1_d : std_ulogic;
			signal add_reg_imm_c1_d : std_ulogic;

		begin

			rs1_val_d <= exe_rs1val_q;
			rs2_val_d <= exe_rs2val_q;

			exe_dataout_d <= exe_rs1val_q;
			with exe_sel_logic_reg_imm_q select
				exe_alu_logic_d <=
					logic_reg_reg_d when logic_rr,
					logic_reg_imm_d when logic_ri,
					(others => '-') when others;

			exe_alu_logic_t_bit_d <= '1' when exe_alu_logic_d=(exe_alu_logic_d'range => '0') else '0';

			with exe_sel_logic_op_q select
				logic_reg_reg_d <= 
					exe_rs1val_q or  exe_rs2val_q when logic_or,
					exe_rs1val_q and exe_rs2val_q when logic_and,
					exe_rs1val_q xor exe_rs2val_q when logic_xor,
					(others => '-') when others;

			with exe_sel_logic_op_q select
				logic_reg_imm_d <= 
					exe_rs1val_q or  exe_sign_extn_q when logic_or,
					exe_rs1val_q and exe_sign_extn_q when logic_and,
					exe_rs1val_q xor exe_sign_extn_q when logic_xor,
					(others => '-') when others;

			alu_shtrot: shtrot
				generic map (dword'length, 6) -- log2(dword'length)+1);
				port map ('0', exe_sel_arth_sht_q, exe_sht_disp_q, exe_rs1val_q, exe_alu_shtrot_d);

			alu_mem_lhalf : unsigned_adder
				port map (exe_addr_lhalf_d(lhalf'range), exe_rs2val_q(lhalf'range), exe_addr_imm_q, exe_addr_lhalf_co_d);

			with exe_sel_alu_integer_q select
			exe_alu_integer_lhalf_d <= 
				add_reg_reg_lhalf_d when alu_integer_add,
				sub_reg_reg_lhalf_d when alu_integer_sub,
				add_reg_imm_lhalf_d when alu_integer_addi,
				(others => '-') when others;
 
			with exe_sel_alu_integer_q select
			exe_alu_integer_hhalf_c0_d <= 
				add_reg_reg_hhalf_c0_d when alu_integer_add,
				sub_reg_reg_hhalf_b0_d when alu_integer_sub,
				add_reg_imm_hhalf_c0_d when alu_integer_addi,
				(others => '-') when others;
 
			with exe_sel_alu_integer_q select
			exe_alu_integer_hhalf_c1_d <= 
				add_reg_reg_hhalf_c1_d when alu_integer_add,
				sub_reg_reg_hhalf_b1_d when alu_integer_sub,
				add_reg_imm_hhalf_c1_d when alu_integer_addi,
				(others => '-') when others;
 
			with exe_sel_alu_integer_q select
			exe_alu_integer_co_d <= 
				add_reg_reg_co_d when alu_integer_add,
				sub_reg_reg_bo_d when alu_integer_sub,
				add_reg_imm_co_d when alu_integer_addi,
				'-' when others;
 
			with exe_sel_alu_integer_q select
			exe_alu_integer_c0_d <= 
				add_reg_reg_c0_d when alu_integer_add,
				sub_reg_reg_b0_d when alu_integer_sub,
				add_reg_imm_c0_d when alu_integer_addi,
				'-' when others;
 
			with exe_sel_alu_integer_q select
			exe_alu_integer_c1_d <= 
				add_reg_reg_c1_d when alu_integer_add,
				sub_reg_reg_b1_d when alu_integer_sub,
				add_reg_imm_c1_d when alu_integer_addi,
				'-' when others;
 
			alu_add_reg_imm_lhalf : unsigned_adder
				port map (add_reg_imm_lhalf_d, rs1_val_d(lhalf'range), exe_sign_extn_q(lhalf'range), add_reg_imm_co_d);
			alu_add_reg_imm_hhalf_c0 : unsigned_adder
				port map (add_reg_imm_hhalf_c0_d, rs1_val_d(hhalf'range), exe_sign_extn_q(hhalf'range), add_reg_imm_c0_d, cin => '0');
			alu_add_reg_imm_hhalf_c1: unsigned_adder
				port map (add_reg_imm_hhalf_c1_d, rs1_val_d(hhalf'range), exe_sign_extn_q(hhalf'range), add_reg_imm_c1_d, cin => '1');

			alu_add_reg_reg_lhalf : unsigned_adder
				port map (add_reg_reg_lhalf_d, rs1_val_d(lhalf'range), rs2_val_d(lhalf'range), add_reg_reg_co_d);
			alu_add_reg_reg_hhalf_c0 : unsigned_adder
				port map (add_reg_reg_hhalf_c0_d, rs1_val_d(hhalf'range), rs2_val_d(hhalf'range), add_reg_reg_c0_d, cin => '0');
			alu_add_reg_reg_hhalf_c1: unsigned_adder
				port map (add_reg_reg_hhalf_c1_d, rs1_val_d(hhalf'range), rs2_val_d(hhalf'range), add_reg_reg_c1_d, cin => '1');

			alu_sub_reg_reg_lhalf: unsigned_subtracter
				port map (sub_reg_reg_lhalf_d, rs1_val_d(lhalf'range), rs2_val_d(lhalf'range), sub_reg_reg_bo_d);
			alu_sub_hhalf_c0: unsigned_subtracter
				port map (sub_reg_reg_hhalf_b0_d, rs1_val_d(hhalf'range), rs2_val_d(hhalf'range), sub_reg_reg_b0_d, bin => '0');
			alu_sub_hhalf_c1 : unsigned_subtracter
				port map (sub_reg_reg_hhalf_b1_d, rs1_val_d(hhalf'range), rs2_val_d(hhalf'range), sub_reg_reg_b1_d, bin => '1');

		end block;


		exe_mem_register: process (clk)
		begin
			if rising_edge(clk) then
				mem_t_bit_q <= exe_t_bit_q;
				mem_alu_logic_q <= exe_alu_logic_d;
				mem_alu_shtrot_q <= exe_alu_shtrot_d;
				mem_alu_logic_t_bit_q <= exe_alu_logic_t_bit_d;
				mem_rs2val_q<= exe_rs2val_q;
				mem_addr_lhalf_q <= exe_addr_lhalf_d;
				mem_addr_lhalf_co_q <= exe_addr_lhalf_co_d;

				mem_alu_integer_lhalf_q <= exe_alu_integer_lhalf_d;
				mem_alu_integer_hhalf_c0_q <= exe_alu_integer_hhalf_c0_d;
				mem_alu_integer_hhalf_c1_q <= exe_alu_integer_hhalf_c1_d;
				mem_alu_integer_co_q <= exe_alu_integer_co_d;
				mem_alu_integer_c0_q <= exe_alu_integer_c0_d;
				mem_alu_integer_c1_q <= exe_alu_integer_c1_d;
			end if;
		end process;

		mem : block
			signal datain_d : dword;
			signal aluout_d : dword;

			signal sel_aluout_lhalf : std_ulogic_vector(1 downto 0);
			signal sel_aluout_hhalf : std_ulogic_vector(1 downto 0);
			signal sel_aluout_t_bit : std_ulogic_vector(1 downto 0);

			signal alu_integer_hhalf_d : hhalf;
			signal alu_integer_cout_d : std_ulogic;
			signal alu_integer_t_bit_d : std_ulogic;

		begin
			sel_aluout_lhalf <= mem_sel_aluout_q;
			sel_aluout_hhalf <= mem_sel_aluout_q;
			sel_aluout_t_bit <= mem_sel_aluout_q;

			with mem_sel_rdval_q select
			dec_rdval_d <=
				datain_d when rdval_load,
				aluout_d when rdval_aluout,
				(others => '-') when others;
				
			with sel_aluout_lhalf select
			aluout_d(lhalf'range) <= 
				mem_alu_integer_lhalf_q when aluout_integer,
				mem_alu_logic_q(lhalf'range) when aluout_logic,
				mem_alu_shtrot_q(lhalf'range) when aluout_shtrot,
				mem_rs2val_q(lhalf'range) when aluout_rs2val,
				(others => '-') when others;

			with sel_aluout_hhalf select
			aluout_d(hhalf'range) <= 
				alu_integer_hhalf_d when aluout_integer,
				mem_alu_logic_q(hhalf'range) when aluout_logic,
				mem_alu_shtrot_q(hhalf'range) when aluout_shtrot,
				mem_rs2val_q(hhalf'range) when aluout_rs2val,
				(others => '-') when others;

			with mem_alu_integer_co_q select
			alu_integer_hhalf_d <=
				mem_alu_integer_hhalf_c1_q when '1',
				mem_alu_integer_hhalf_c0_q when '0',
				(others => '-') when others;

			with mem_alu_integer_co_q select
			alu_integer_cout_d <=
				mem_alu_integer_c1_q when '1',
				mem_alu_integer_c0_q when '0',
				'-' when others;

			with sel_aluout_t_bit select
			dec_t_bit_wr_d <= 
				alu_integer_t_bit_d when aluout_integer,
				mem_t_bit_q  when aluout_rs2val,
				mem_alu_logic_t_bit_q when aluout_logic,
				'-' when others;

			datamem : spram
				generic map (10, dword'length, TRUE)
				port map (
					clk  => clk,
					we   => mem_data_rw_d,
					addr => mem_addr_lhalf_q(9 downto 0),
					dout => datain_d,
					din  => exe_dataout_d);

		end block;

		write_back: block 
		begin

		end block;

 	end block;

 	ctrlUnit: block
		signal jmp_taken_d : std_ulogic;

		signal ift_null_d : std_ulogic;


		signal dec_ena_d : std_ulogic;
		signal dec_opc_hzrd_d : std_ulogic;
 		alias  dec_rs1_q is instrDec(rs1Fld);
 		alias  dec_rs2_q is instrDec(rs2Fld);
 		alias  dec_opc_q is instrDec(opcFld);
 		alias  dec_fun_q is instrDec(funFld);
		signal dec_null_d : std_ulogic;
		signal dec_imm_hzrd_d : std_ulogic;
		signal dec_alu_imm_hzrd_d : std_ulogic;
		
 		alias  exe_rd_q is instrExe(rdFld);

		signal exe_opc_hzrd_q : std_ulogic;
		signal exe_nop_q : std_ulogic;
		signal exe_null_d : std_ulogic;
		signal exe_rs1_hzrd_d : std_ulogic;
		signal exe_rs2_hzrd_d : std_ulogic;

 		alias  mem_rd_q is instrMem(rdFld);
		signal mem_hzrd_d : std_ulogic;
		signal mem_hzrd_q : std_ulogic;
		signal mem_opc_hzrd_q : std_ulogic;
		signal mem_reg_ena_q : std_ulogic;
		signal mem_flg_ena_q : std_ulogic;
		signal mem_null_d : std_ulogic;

		signal mem_rs1_hzrd_d : std_ulogic;
		signal mem_rs2_hzrd_d : std_ulogic;
		signal mem_rs1_hzrd_q : std_ulogic;
		signal mem_rs2_hzrd_q : std_ulogic;

		signal wbk_hzrd_d : std_ulogic;
		signal wbk_opc_hzrd_q : std_ulogic;
		signal wbk_rs1_hzrd_q : std_ulogic;
		signal wbk_rs2_hzrd_q : std_ulogic;

 	begin

		instrFch <= code;

		with dec_opc_q select
			dec_imm_hzrd_d <=
				dec_alu_imm_hzrd_d when alu,
				'1' when cpi|addi|ori|li,
				'0' when others;
		with dec_fun_q select
			dec_alu_imm_hzrd_d <=
				'1' when alu_asri|alu_lsri|alu_lsli,
				'0' when others;
				
		with dec_opc_q select
		dec_opc_hzrd_d <=
			'1' when alu|st|addi|ori|brt,
			'0' when others;

		exe_rs1_hzrd_d <= SetIf(dec_rs1_q=exe_rd_q) and dec_opc_hzrd_d and not mem_null_d;
		exe_rs2_hzrd_d <= SetIf(dec_rs2_q=exe_rd_q) and dec_opc_hzrd_d and not mem_null_d and not dec_imm_hzrd_d; 
		mem_rs1_hzrd_d <= SetIf(dec_rs1_q=mem_rd_q) and dec_opc_hzrd_d and not mem_null_q;
		mem_rs2_hzrd_d <= SetIf(dec_rs2_q=mem_rd_q) and dec_opc_hzrd_d and not mem_null_q and not dec_imm_hzrd_d;
		process (clk)
		begin
			if rising_edge(clk) then 
				mem_rs1_hzrd_q <= exe_rs1_hzrd_d;
				mem_rs2_hzrd_q <= exe_rs2_hzrd_d;
				wbk_rs1_hzrd_q <= mem_rs1_hzrd_d;
				wbk_rs2_hzrd_q <= mem_rs2_hzrd_d;
			end if;
		end process;

		mem_hzrd_d <= mem_rs1_hzrd_q or mem_rs2_hzrd_q;
		wbk_hzrd_d <= wbk_rs1_hzrd_q or wbk_rs2_hzrd_q;
		jmp_taken_d <= pcdisp_high_ena_q and (isJal or (isJcnd and dec_t_bit_rd_d));

		exe_null_d <= dec_null_q or  (isJimm or (not ip_load_d and not pcdisp_high_ena_q));
		mem_null_d <= exe_null_q or exe_nop_q;

		process(rst,clk)
		begin
			if rst='1' then
				dec_null_q <= '1';
				exe_null_q <= '1';
				mem_null_q <= '1';
			elsif rising_edge(clk) then
				dec_null_q <= '0';
				exe_null_q <= exe_null_d;
				mem_null_q <= mem_null_d or mem_hzrd_q or mem_hzrd_d;
			end if;
		end process;

		ip_ena_d  <= not (mem_hzrd_d or mem_hzrd_q);
		dec_ena_d <= not jmp_taken_d;

		process(clk)
		begin
			if rising_edge(clk) then
				mem_hzrd_q <= mem_hzrd_d;
				instr_dec_lbl: if dec_ena_d='1' then
					case mem_hzrd_d or mem_hzrd_q is
					when '1' =>
						instrDec <= instrExe;
					when '0' =>
						if jmp_taken_d='0' then
							instrDec <= instrFch;
						end if;
					when others =>
						instrDec <= (others => '-');
					end case;
				end if;

				instr_exe_lbl: instrExe <= instrDec;
				instr_mem_lbl: instrMem <= instrExe;
			end if;
		end process;

 		dec: block
 			alias opc is instrDec(opcFld);
 			alias rs1 is instrDec(rs1Fld);
 			alias rs2 is instrDec(rs2Fld);
 			alias fun is instrDec(funFld);

 		begin

			isJimm <= SetIf(opc=jal or opc=brt);
 			isJal  <= SetIf(opc=jal);
			isJcnd <= SetIf(opc=brt);

			selDisp12 <= SetIf(isJal='1');
					
			process (clk)
			begin
				if rising_edge(clk) then
					exe_nop_q <= SetIf(
				  		opc=(opc'range =>'0') and
						rs1=(rs1'range =>'0') and
						rs2=(rs2'range =>'0') and
						fun=(fun'range =>'0'));

					case opc is
					when alu =>
						case fun is
						when alu_add =>
							exe_sel_alu_integer_q <= alu_integer_add;
						when alu_sub =>
							exe_sel_alu_integer_q <= alu_integer_sub;
						when others =>
							exe_sel_alu_integer_q <= (others => '-');
						end case;
					when addi =>
						exe_sel_alu_integer_q <= alu_integer_addi;
					when others =>
						exe_sel_alu_integer_q <= (others => '-');
					end case;

					case opc is
					when alu =>
						case fun is
						when alu_or  =>
							exe_sel_logic_reg_imm_q <= logic_rr;
							exe_sel_logic_op_q <= logic_or;
						when alu_and =>
							exe_sel_logic_reg_imm_q <= logic_rr;
							exe_sel_logic_op_q <= logic_and;
						when alu_xor =>
							exe_sel_logic_reg_imm_q <= logic_rr;
							exe_sel_logic_op_q <= logic_xor;
						when others  =>
							exe_sel_logic_reg_imm_q <= '-';
							exe_sel_logic_op_q <= (others => '-');
						end case;
					when ori  =>
						exe_sel_logic_reg_imm_q <= logic_ri;
						exe_sel_logic_op_q <= logic_or;
					when others =>
						exe_sel_logic_reg_imm_q <= '-';
						exe_sel_logic_op_q <= (others => '-');
					end case;
				end if;
			end process;

		end block;
		
		exe: block
 			alias opc is instrExe(opcFld);
 			alias rs1 is instrExe(rs1Fld);
 			alias rs2 is instrExe(rs2Fld);
 			alias fun is instrExe(funFld);
		begin
			exe_sel_arth_sht_q <= fun(alu_arth_sht_bit_num);
			exe_sht_disp_q <= fun(alu_dirn_sht_bit_num ) & fun(alu_dirn_sht_bit_num) & rs2;

			with opc select
				mem_data_rw_d <=
					SetIf(exe_null_q='1') when st,
					'0' when others;

			process (clk)
			begin
				if rising_edge(clk) then
					case opc is
					when alu|addi|ld =>
						mem_flg_ena_q <= '1';
					when others =>
						mem_flg_ena_q <= '0';
					end case;

					case opc is
					when alu|addi|ld =>
						mem_reg_ena_q <= '1';
					when others =>
						mem_reg_ena_q <= '0';
					end case;

					case opc is
					when alu|addi =>
						mem_sel_rdval_q <= rdval_aluout;
					when ld =>
						mem_sel_rdval_q <= rdval_load;
					when others =>
						mem_sel_rdval_q <= (others => '-');
					end case;

					case opc is
					when alu =>
						case fun is
						when alu_mov =>
							mem_sel_aluout_q <= aluout_rs2val;
						when alu_add|alu_sub =>
							mem_sel_aluout_q <= aluout_integer;
						when alu_or|alu_and|alu_xor =>
							mem_sel_aluout_q <= aluout_logic;
						when alu_asri|alu_lsri|alu_lsli =>
							mem_sel_aluout_q <= aluout_shtrot;
						when others =>
							mem_sel_aluout_q <= (others => '-');
						end case;
					when addi =>
						mem_sel_aluout_q <= aluout_integer;
					when others =>
						mem_sel_aluout_q <= (others => '-');
					end case;

				end if;
			end process;
 		end block;

		mem: block
 			alias opc is instrMem(opcFld);
 			alias fun is instrMem(funFld);
		begin
			dec_reg_ena_d <= SetIf(mem_null_q/='1' and mem_reg_ena_q='1');
			dec_flg_ena_d <= SetIf(mem_null_q/='1' and mem_flg_ena_q='1');
		end block;
 	end block;
end;
