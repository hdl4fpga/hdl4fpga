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

library corelib;

use work.aux_parts.all;
use work.aux_functions.all;
use work.cpu_parts.all;
use work.isa.all;

entity cpucore is
 	generic (
 		dwidth : natural := 32;
 		cwidth : natural := 16);
 	port (

	-------------------------------------------
	-- Xilinx/Digilent SPARTAN-3 Starter Kit --
	-- Digilent/NEXYS2 SPARTAN-3E Kit        --
	-------------------------------------------

		s3s_anodes     : out std_ulogic_vector(3 downto 0);
		s3s_segment_a  : out std_ulogic;
		s3s_segment_b  : out std_ulogic;
		s3s_segment_c  : out std_ulogic;
		s3s_segment_d  : out std_ulogic;
		s3s_segment_e  : out std_ulogic;
		s3s_segment_f  : out std_ulogic;
		s3s_segment_g  : out std_ulogic;
		s3s_segment_dp : out std_ulogic;

	------------------------------
	-- Altera/Terasic DE2 Board --
	------------------------------

	--	de2_segment_a  : out std_ulogic_vector(7 downto 0);
	--	de2_segment_b  : out std_ulogic_vector(7 downto 0);
	--	de2_segment_c  : out std_ulogic_vector(7 downto 0);
	--	de2_segment_d  : out std_ulogic_vector(7 downto 0);
	--	de2_segment_e  : out std_ulogic_vector(7 downto 0);
	--	de2_segment_f  : out std_ulogic_vector(7 downto 0);
	--	de2_segment_g  : out std_ulogic_vector(7 downto 0);
	--	de2_segment_dp : out std_ulogic_vector(7 downto 0);

	---------
	-- End --
	---------

		switches : in  std_ulogic_vector(7 downto 0);
		buttons  : in  std_ulogic_vector(3 downto 0);
		leds     : out std_ulogic_vector(7 downto 0);

 		xtal  : in  std_ulogic);	
	
	--------------------
	-- Altera/Quartus --
	--------------------

--	attribute chip_pin : string;

	------------------------------
	-- Altera/Terasic DE2 Board --
	------------------------------

--	attribute chip_pin of xtal : signal is "N2";
--	attribute chip_pin of leds : signal is "AC21 AD21 AD23 AD22 AC22 AB21 AF23 AE23";
--	attribute chip_pin of buttons : signal is "W26 P23 N23 G26";
--	attribute chip_pin of switches : signal is "B13 C13 AC13 AD13 AF14 AE14 P25 N26 N25";
--	attribute chip_pin of de2_segment_a : signal is "L3 R2 T2 U9 Y23  AB23 V20  AF10";
--	attribute chip_pin of de2_segment_b : signal is "L2 P4 P6 U1 AA25 V22  V21  AB12";
--	attribute chip_pin of de2_segment_c : signal is "L9 P3 P7 U2 AA26 AC25 W21  AC12";
--	attribute chip_pin of de2_segment_d : signal is "L6 M2 T9 T4 Y26  AC26 Y22  AD11";
--	attribute chip_pin of de2_segment_e : signal is "L7 M3 R5 R7 Y25  AB26 AA24 AE11";
--	attribute chip_pin of de2_segment_f : signal is "P9 M5 R4 R6 U22  AB25 AA23 V14";
--	attribute chip_pin of de2_segment_g : signal is "N9 M4 R3 T3 W24  Y24  AB24 V13";

	-----------------
	 -- Xilinx ISE --
	-----------------

	attribute loc : string;
	
	-------------------------------------------
	-- Xilinx/Digilent SPARTAN-3 Starter Kit --
	-------------------------------------------

	attribute loc of xtal : signal is "T9";
	attribute loc of leds : signal is "P11 P12 N12 P13 N14 L12 P14 K12";
	attribute loc of buttons : signal is "L14 L13 M14 M13";
	attribute loc of switches : signal is "K13 K14 J13 J14 H13 H14 G12 F12";

	attribute loc of s3s_anodes     : signal is "E13 F14 G14 D14";
	attribute loc of s3s_segment_a  : signal is "E14";
	attribute loc of s3s_segment_b  : signal is "G13";
	attribute loc of s3s_segment_c  : signal is "N15";
	attribute loc of s3s_segment_d  : signal is "P15";
	attribute loc of s3s_segment_e  : signal is "R16";
	attribute loc of s3s_segment_f  : signal is "F13";
	attribute loc of s3s_segment_g  : signal is "N16";
	attribute loc of s3s_segment_dp : signal is "P16";

	------------------------------------
	-- Digilent/NEXYS2 SPARTAN-3E Kit --
	------------------------------------

--	attribute loc of xtal : signal is "B8";
--	attribute loc of leds : signal is "P4 E4 P16 E16 K14 K15 J15 J14";
--	attribute loc of buttons : signal is "B18 D18 E18 H13";
--	attribute loc of switches : signal is "R17 N17 L13 L14 K17 K18 H18 G18";
--	attribute loc of s3s_anodes     : signal is  "F15 C18 H17 F17";
--	attribute loc of s3s_segment_a  : signal is "L18";
--	attribute loc of s3s_segment_b  : signal is "F18";
--	attribute loc of s3s_segment_c  : signal is "D17";
--	attribute loc of s3s_segment_d  : signal is "D16";
--	attribute loc of s3s_segment_e  : signal is "G14";
--	attribute loc of s3s_segment_f  : signal is "J17";
--	attribute loc of s3s_segment_g  : signal is "H14";
--	attribute loc of s3s_segment_dp : signal is "C17";
	
end;

architecture pipeLine of cpuCore is

	-----------------------------
	-- BEGIN DEBUG DECLARATION --
	-----------------------------
	signal DEBUG_ip_q : std_ulogic_vector(dwidth-1 downto 0);
	signal DEBUG_pcdisp_sel_d  : std_ulogic;
	signal DEBUG_pcdisp_d : std_ulogic_vector(dwidth-1 downto 0);
	signal DEBUG_mem_t_bit_d : std_ulogic;
	signal DEBUG_logic_reg_imm_d : std_ulogic_vector(dwidth-1 downto 0);
	signal DEBUG_exe_alu_logic_d : std_ulogic_vector(dwidth-1 downto 0);
	---------------------------
	-- END DEBUG DECLARATION --
	---------------------------
	
	signal rst  : std_ulogic;
	signal step : std_ulogic;
	signal code : std_ulogic_vector(0 to cwidth-1);
	signal clk  : std_ulogic;
	
	signal display_data : std_ulogic_vector(0 to 15);
	
	subtype dword is std_ulogic_vector(dwidth-1   downto 0);
	subtype hhalf is std_ulogic_vector(dwidth-1   downto dwidth/2);
	subtype lhalf is std_ulogic_vector(dwidth/2-1 downto 0);

 	-----------------------------
 	-- Instrunction Registers  --
 	-----------------------------

	signal instrIft : std_ulogic_vector(code'range);
 	signal instrDec : std_ulogic_vector(code'range);
 	signal instrExe : std_ulogic_vector(code'range);
 	signal instrMem : std_ulogic_vector(code'range);

	-- Fetch Stage --

	signal ift_null_q : std_ulogic;
 	signal isJal  : std_ulogic;
 	signal isJral  : std_ulogic;
 	signal isJimm : std_ulogic;
 	signal isJcnd : std_ulogic;

	signal ip_ena_d : std_ulogic;

	signal selDisp12 : std_ulogic;
	signal pc_disp_sel_d : std_ulogic;
	signal pc_reg_sel_d : std_ulogic;
	signal pc_cond_d : std_ulogic;
	-- Decode Stage --

	signal dec_null_q : std_ulogic;
	signal dec_t_bit_rd_d : std_ulogic;
	signal dec_reg_ena_d : std_ulogic;
	signal dec_flg_ena_d : std_ulogic;
	signal dec_rs1_q : std_ulogic_vector(ridFld);
	signal dec_rs2_q : std_ulogic_vector(ridFld);

	constant alu_integer_add  : std_ulogic_vector(1 downto 0) := "00";
	constant alu_integer_sub  : std_ulogic_vector(1 downto 0) := "01";
	constant alu_integer_addi : std_ulogic_vector(1 downto 0) := "10";

	-- Execute Stage --

	signal exe_sel_alu_integer_q : std_ulogic_vector(1 downto 0);
	signal exe_sht_disp_rs2_q : std_ulogic;
	signal exe_null_q : std_ulogic;

	constant aluout_add : std_ulogic_vector(2 downto 0) := "000";
	constant aluout_sub : std_ulogic_vector(2 downto 0) := "101";
	constant aluout_addi : std_ulogic_vector(2 downto 0) := "110";
	constant aluout_logic : std_ulogic_vector(2 downto 0) := "001";
	constant aluout_shift : std_ulogic_vector(2 downto 0) := "010";
	constant aluout_rs2val : std_ulogic_vector(2 downto 0) := "011";
	constant aluout_rrf : std_ulogic_vector(2 downto 0) := "100";

	constant rdval_aluout : std_ulogic_vector(1 downto 0) := "00";
	constant rdval_load   : std_ulogic_vector(1 downto 0) := "01";
	constant rdval_jal    : std_ulogic_vector(1 downto 0) := "10";

	constant logic_or  : std_ulogic_vector := "00";
	constant logic_and : std_ulogic_vector := "01";
	constant logic_xor : std_ulogic_vector := "11";

	signal exe_sel_logic_op_q : std_ulogic_vector(1 downto 0);

	constant logic_rr : std_ulogic := '1';
	constant logic_ri : std_ulogic := '0';

	signal exe_sel_logic_reg_imm_q : std_ulogic;
	signal exe_sel_arth_sht_q : std_ulogic;

	signal exe_rs1_val_fwd_q : std_ulogic;
	signal exe_rs2_val_fwd_q : std_ulogic;
	signal mem_rs1_val_fwd_q : std_ulogic;
	signal mem_rs2_val_fwd_q : std_ulogic;

	-- Memory Stage --

	signal mem_null_q : std_ulogic;
	signal mem_sel_rdval_q  : std_ulogic_vector(1 downto 0);
	signal mem_sel_aluout_q : std_ulogic_vector(2 downto 0);
	signal mem_data_rw_d : std_ulogic;
	signal mem_rrf_ena_d : std_ulogic;
	signal mem_rd_q : std_ulogic_vector(ridFld);

begin
	rst  <= buttons(3);
	step <= buttons(2);
--	clk <= xtal;

	process (xtal)
		variable charge : natural range 0 to 2**16-1;
	begin
		if rising_edge(xtal) then
			if step='1' then
				if charge < 2**16-1 then
					charge := charge + 1;
				else 
					clk <= '1';
				end if;
			else
				if charge > 0 then
					charge := charge - 1;
				else 
					clk <= '0';
				end if;
			end if;
		end if;
	end process;
	
	-------------------------------------------
	-- Xilinx/Digilent SPARTAN-3 Starter Kit --
	-- Digilent/NEXYS2 SPARTAN-3E Kit        --
	-------------------------------------------

	s3s_display: entity corelib.iodev_bcd
		port map (
			clock => xtal,
			data  => display_data,
			segment_a  => s3s_segment_a,
			segment_b  => s3s_segment_b,
			segment_c  => s3s_segment_c,
			segment_d  => s3s_segment_d,
			segment_e  => s3s_segment_e,
			segment_f  => s3s_segment_f,
			segment_g  => s3s_segment_g,
			segment_dp => s3s_segment_dp,
			display_turnon => s3s_anodes);

	------------------------------
	-- Altera/Terasic DE2 Board --
	------------------------------

--	de2_display: for i in 3 downto 0 generate
--		digit: entity corelib.bcd27seg
--		port map (
--			code  => display_data(i*4 to i*4+4-1),
--			segment_a  => de2_segment_a(i),
--			segment_b  => de2_segment_b(i),
--			segment_c  => de2_segment_c(i),
--			segment_d  => de2_segment_d(i),
--			segment_e  => de2_segment_e(i),
--			segment_f  => de2_segment_f(i),
--			segment_g  => de2_segment_g(i),
--			segment_dp => open);
--	end generate;

 	stages: block
		signal dec_sign_extn_d : dword;
		signal dec_npc_q : dword;
		signal dec_rs1val_d : dword;
		signal dec_rs2val_d : dword;
		signal dec_tyv_word_dout_d : std_ulogic_vector(0 to 2**ridlen-1);

		signal exe_npc_q : dword;
		signal exe_t_bit_q : std_ulogic;
		signal exe_tyv_word_dout_q : std_ulogic_vector(0 to 2**ridlen-1);
		signal exe_sign_extn_q : dword;
		signal exe_rs1val_q : dword;
		signal exe_rs2val_q : dword;
		signal exe_rs2val_d : dword;
		signal exe_alu_logic_d : dword;
		signal exe_alu_logic_t_bit_d : std_ulogic;
		signal exe_alu_rotate_d : dword;
		signal exe_alu_sht_mask_d : dword;
		signal exe_alu_sht_sign_d : std_ulogic;
		signal exe_alu_sht_dir_d : std_ulogic;
		signal exe_dataout_d : dword;

		signal exe_add_reg_reg_dword_d : dword;
		signal exe_sub_reg_reg_dword_d : dword;
		signal exe_add_reg_imm_dword_d : dword;

		signal exe_addr_lhalf_d : lhalf;
		signal exe_addr_lhalf_co_d : std_ulogic;

		signal exe_add_reg_reg_co_d : std_ulogic;
		signal exe_sub_reg_reg_bo_d : std_ulogic;
		signal exe_add_reg_imm_co_d : std_ulogic;

		signal mem_npc_q : dword;
		signal mem_t_bit_q : std_ulogic;
		signal mem_tyv_word_dout_q : std_ulogic_vector(0 to 2**ridlen-1);
		signal mem_t_bit_d : std_ulogic;
		signal mem_tyv_word_din_d : std_ulogic_vector(0 to 2**ridlen-1);
		signal mem_alu_logic_q : dword;
		signal mem_alu_logic_t_bit_q : std_ulogic;
		signal mem_alu_shift_d : dword;
		signal mem_alu_rotate_q : dword;
		signal mem_alu_sht_sign_q : std_ulogic;
		signal mem_alu_sht_mask_q : dword;
		signal mem_alu_sht_dir_q : std_ulogic;

		signal mem_add_reg_reg_dword_q : dword;
		signal mem_sub_reg_reg_dword_q : dword;
		signal mem_add_reg_imm_dword_q : dword;

		signal mem_add_reg_reg_co_q : std_ulogic;
		signal mem_sub_reg_reg_bo_q : std_ulogic;
		signal mem_add_reg_imm_co_q : std_ulogic;

		signal mem_rdval_d : dword;
		signal mem_rdval_q : dword;
		signal mem_rs2val_q : dword;

		signal mem_aluout_d : dword;

		signal mem_datain_d : dword;
		
 	begin

		DEBUG: block
		
			function mux_half (arg1 : dword; arg2 : std_ulogic) 
				return lhalf is
			begin
				case arg2 is
				when '1' =>
					return arg1(hhalf'range);
				when others =>
					return arg1(lhalf'range);
				end case;
			end;
			signal mux_sel : std_ulogic;
		begin
			mux_sel <= switches(7) xor buttons(0);
			with switches(4 downto 0) select
				display_data <=
					instrDec when "00001",
					instrExe when "00010",
					instrMem when "00011",
					mux_half(DEBUG_ip_q,   mux_sel) when "00100",
					mux_half(DEBUG_pcdisp_d,   mux_sel) when "01000",
					
					mux_half(exe_rs1val_q, mux_sel) when "00110",
					mux_half(exe_rs2val_q, mux_sel) when "01010",
					mux_half(DEBUG_logic_reg_imm_d, mux_sel) when "01110",
					mux_half(DEBUG_exe_alu_logic_d, mux_sel) when "11110",
					mux_half(mem_aluout_d, mux_sel) when "00111",
					mux_half(mem_rdval_d,  mux_sel) when "01011",
					(others => '-') when others;
					
			with switches(3 downto 0) select
				leds(0) <= 
					'0'     when "0000"|"0001"|"0010"|"0011",
					mux_sel when others;
			
		end block;
			
		fetch: block
			function extn_sign (val : std_ulogic_vector; n : natural)
				return std_ulogic_vector is
			begin
				return (0 to n-val'length-1 => val(val'left)) & val;
			end;
			
			alias imm8  : std_ulogic_vector(7 downto 0) is instrDec(im8Fld);
			alias imm12 : std_ulogic_vector(11 downto 0) is instrDec(im12Fld);

 			signal ip_q : dword;
	 		signal ip_d : dword;
	 		signal pc_disp_d : dword;
	 		signal pc_rel_d : dword;

		begin
			with selDisp12 select
			dec_sign_extn_d <= 
				extn_sign(imm12, dec_sign_extn_d'length) when '1',
	 			extn_sign(imm8,  dec_sign_extn_d'length) when others;

			pc_cond_d <= SetIf(mem_t_bit_d='1');
			with pc_disp_sel_d select
			pc_disp_d <=
				dec_sign_extn_d when '1',
				(others => '0') when others;
			
			with isJral select
			ip_d <= 
				dec_rs1val_d when '1',
				pc_rel_d when others;
				
			pc: unsigned_adder 
			port map (pc_rel_d, ip_q, pc_disp_d, cin => '1');

			process (rst,clk)
			begin
				if rst='1' then
					ip_q <= (others => '0');
				elsif rising_edge(clk) then
					if ip_ena_d='1' then
						ip_q <= ip_d;
					end if;
				end if;				
			end process;
			dec_npc_q <= ip_q;

			DEBUG_pcdisp_d <= pc_disp_d;
			DEBUG_pcdisp_sel_d <= pc_disp_sel_d;
			DEBUG_ip_q <= ip_q;

			instr : spram
			generic map (M => 10, N => 16, SYNC_ADDRESS => FALSE)
			port map (
				clk  => clk,
				addr => ip_d(9 downto 0),
				dout => code);

		end block;

 		decode: block
			signal tyv_word_ena : std_ulogic;
			signal tyv_word_rs : std_ulogic_vector(ridFld);
			signal tyv_word_dout : std_ulogic_vector(0 to 2**ridlen-1);
			signal tyv_word_rd : std_ulogic_vector(ridFld);
			signal tyv_word_din : std_ulogic_vector(0 to 2**ridlen-1);
			signal tyv_bit_rd : std_ulogic_vector(ridFld);

			signal t_bit_ena : std_ulogic;
			signal t_bit_din : std_ulogic;
			signal t_bit_dout : std_ulogic;

			signal y_bit_ena : std_ulogic;
			signal y_bit_din : std_ulogic;
			signal y_bit_dout : std_ulogic;

			signal v_bit_ena : std_ulogic;
			signal v_bit_din : std_ulogic;
			signal v_bit_dout : std_ulogic;
 		begin
		
			tyv_word_rs <= dec_rs2_q;
			tyv_word_rd <= mem_rd_q;
			tyv_word_din <= mem_tyv_word_din_d;
			tyv_word_ena <= mem_rrf_ena_d;

			tyv_bit_rd <= mem_rd_q;
			t_bit_ena <= dec_flg_ena_d;
			t_bit_din <= mem_t_bit_d;

			flagFile : block
				signal t_storage : std_ulogic_vector (0 to 15);
				signal y_storage : std_ulogic_vector (0 to 15);
				signal v_storage : std_ulogic_vector (0 to 15);
			begin
				process (clk)
				begin
					if rising_edge(clk) then
						if tyv_word_ena='1' then
							case tyv_word_rd is
							when t_register =>
								t_storage <= tyv_word_din;
							when y_register =>
								y_storage <= tyv_word_din;
							when v_register =>
								v_storage <= tyv_word_din;
							when others =>
								null;
							end case;
						else 
							if t_bit_ena='1' then
								t_storage(to_integer(unsigned(tyv_bit_rd))) <= t_bit_din;
							end if;
							if y_bit_ena='1' then
								y_storage(to_integer(unsigned(tyv_bit_rd))) <= y_bit_din;
							end if;
							if v_bit_ena='1' then
								v_storage(to_integer(unsigned(tyv_bit_rd))) <= v_bit_din;
							end if;
						end if;
					end if;
				end process;
				t_bit_dout <= t_storage(to_integer(unsigned(tyv_bit_rd)));
				tyv_word_dout <= t_storage;
			end block;
			
			dec_t_bit_rd_d <= t_bit_dout;
			dec_tyv_word_dout_d <= tyv_word_dout;

			registerFile1 : dpram
			generic map (ridLen, dword'length)
			port map (
				clk   => clk,
				we    => dec_reg_ena_d,
				wAddr => mem_rd_q,
				din   => mem_rdval_d,
				rAddr => dec_rs1_q,
				dout  => dec_rs1val_d);

			registerFile2 : dpram 
			generic map (ridLen, dword'length)
			port map (
				clk   => clk,
				we    => dec_reg_ena_d,
				wAddr => mem_rd_q,
				din   => mem_rdval_d,
				rAddr => dec_rs2_q,
				dout  => dec_rs2val_d);

		end block;

		dec_exe_register: process (clk)
		begin
			if rising_edge(clk) then
				exe_npc_q <= std_ulogic_vector(unsigned(dec_npc_q) + 1);
				exe_sign_extn_q <= dec_sign_extn_d;
				exe_t_bit_q <= dec_t_bit_rd_d;
				exe_tyv_word_dout_q <= dec_tyv_word_dout_d;
				exe_rs1val_q <= dec_rs1val_d;
				exe_rs2val_q <= dec_rs2val_d;
			end if;
		end process;
			
		execute: block
			alias exe_addr_imm_q is instrExe(funFld);
			alias imm8 is instrExe(im8Fld);

			signal rs1_val_d : dword;
			signal rs2_val_d : dword;

			signal logic_reg_reg_d : dword;
			signal logic_reg_imm_d : dword;

			signal sht_disp_d : std_ulogic_vector(5 downto 0);
			signal sht_extn_d : std_ulogic;

		begin

			rs1_val_d <= 
				mem_rdval_d when exe_rs1_val_fwd_q='1' else
				mem_rdval_q when mem_rs1_val_fwd_q='1' else
				exe_rs1val_q;

			rs2_val_d <= 
				mem_rdval_d when exe_rs2_val_fwd_q='1' else
				mem_rdval_q when mem_rs2_val_fwd_q='1' else
				exe_rs2val_q;
			exe_rs2val_d <= rs2_val_d;
			
			with exe_sht_disp_rs2_q select
			sht_disp_d <= 
				rs2_val_d(5 downto 0)  when '1',
				InstrExe(funFld)(alu_dirn_sht_bit_num) &
				InstrExe(funFld)(alu_dirn_sht_bit_num) &
				InstrExe(rs2Fld) when '0',
				(others => '-') when others;
			exe_alu_sht_dir_d <= sht_disp_d(sht_disp_d'left);

			exe_dataout_d <= rs1_val_d;

			DEBUG_exe_alu_logic_d <= exe_alu_logic_d;
			with exe_sel_logic_reg_imm_q select
			exe_alu_logic_d <=
				logic_reg_reg_d when logic_rr,
				logic_reg_imm_d when logic_ri,
				(others => '-') when others;

			exe_alu_logic_t_bit_d <= '1' when exe_alu_logic_d=(exe_alu_logic_d'range => '0') else '0';

			with exe_sel_logic_op_q select
			logic_reg_reg_d <= 
				rs1_val_d or  rs2_val_d when logic_or,
				rs1_val_d and rs2_val_d when logic_and,
				rs1_val_d xor rs2_val_d when logic_xor,
				(others => '-') when others;
				
			DEBUG_logic_reg_imm_d <= logic_reg_imm_d;
			with exe_sel_logic_op_q select
			logic_reg_imm_d <= 
				rs1_val_d or  (0 to 23 => '0') & imm8 when logic_or,
				rs1_val_d and (0 to 23 => '0') & imm8 when logic_and,
				rs1_val_d xor (0 to 23 => '0') & imm8 when logic_xor,
				(others => '-') when others;

			alu_rotate: barrel
			generic map (dword'length, 5) -- log2(dword'length);
			port map (
				sht => sht_disp_d(sht_disp_d'left-1 downto 0), 
				din => rs1_val_d, 
				dout => exe_alu_rotate_d);

			with exe_sel_arth_sht_q  select
			exe_alu_sht_sign_d <= 
				sht_extn_d and sht_disp_d(sht_disp_d'left) when '1',
				'0' when others;

			sht_extn_d <= rs1_val_d(rs1_val_d'left);

--			with select
--			shift_extension <=
--				rs1_val_d(rs1_val_d'left-BYTE_LENGHT*0) when "00",
--				rs1_val_d(rs1_val_d'left-BYTE_LENGHT*1) when "01",
--				rs1_val_d(rs1_val_d'left-BYTE_LENGHT*2) when "10",
--				rs1_val_d(rs1_val_d'left-BYTE_LENGHT*3) when "11";

			alu_shift_mask: shift_mask
			generic map (dword'length, 6) -- log2(dword'length)+1
			port map (
				sht  => sht_disp_d,
				mout => exe_alu_sht_mask_d);

			alu_mem_lhalf : unsigned_adder
			port map (
				exe_addr_lhalf_d(lhalf'range),
				rs2_val_d(lhalf'range),
				exe_addr_imm_q, exe_addr_lhalf_co_d);

			alu_add_reg_imm_dword : unsigned_adder
			port map (
				exe_add_reg_imm_dword_d,
				rs1_val_d,
				exe_sign_extn_q,
				exe_add_reg_imm_co_d);

			alu_add_reg_reg_dword : unsigned_adder
			port map (
				exe_add_reg_reg_dword_d,
				rs1_val_d,
				rs2_val_d,
				exe_add_reg_reg_co_d);

			alu_sub_reg_reg_dword: unsigned_subtracter
			port map (
				exe_sub_reg_reg_dword_d,
				rs1_val_d,
				rs2_val_d,
				exe_sub_reg_reg_bo_d);

		end block;

		exe_mem_register: process (clk)
		begin
			if rising_edge(clk) then
				mem_rs2val_q <= exe_rs2val_d;
				mem_npc_q <= exe_npc_q;

				mem_t_bit_q <= exe_t_bit_q;
				mem_tyv_word_dout_q <= mem_tyv_word_dout_q;

				mem_alu_logic_q <= exe_alu_logic_d;
				mem_alu_logic_t_bit_q <= exe_alu_logic_t_bit_d;

				mem_alu_rotate_q <= exe_alu_rotate_d;
				mem_alu_sht_mask_q <= exe_alu_sht_mask_d;
				mem_alu_sht_sign_q <= exe_alu_sht_sign_d;
				mem_alu_sht_dir_q <= exe_alu_sht_dir_d;

				mem_add_reg_reg_dword_q <= exe_add_reg_reg_dword_d;
				mem_sub_reg_reg_dword_q <= exe_sub_reg_reg_dword_d;
				mem_add_reg_imm_dword_q <= exe_add_reg_imm_dword_d;

				mem_add_reg_reg_co_q <= exe_add_reg_reg_co_d;
				mem_sub_reg_reg_bo_q <= exe_sub_reg_reg_bo_d;
				mem_add_reg_imm_co_q <= exe_add_reg_imm_co_d;

			end if;
		end process;

		mem : block
			signal alu_sht_bit_d : std_ulogic;
		begin

			mem_tyv_word_din_d <= mem_rs2val_q(lhalf'range);
			DEBUG_mem_t_bit_d <= mem_t_bit_d;
			
			with mem_sel_rdval_q select
			mem_rdval_d <=
				mem_datain_d when rdval_load,
				mem_aluout_d when rdval_aluout,
				mem_npc_q    when rdval_jal,
				(others => '-') when others;
				
			process (clk)
			begin
				if rising_edge(clk) then
					mem_rdval_q <= mem_rdval_d;
				end if;
			end process;
			
			with mem_sel_aluout_q select
			mem_aluout_d <= 
				mem_add_reg_reg_dword_q when aluout_add,
				mem_sub_reg_reg_dword_q when aluout_sub,
				mem_add_reg_imm_dword_q when aluout_addi,
				mem_alu_logic_q when aluout_logic,
				mem_alu_shift_d when aluout_shift,
				mem_rs2val_q when aluout_rs2val,
				(0 to 15 => '-') & mem_tyv_word_dout_q  when aluout_rrf,
				(others => '-') when others;

			alu_shift: for i in mem_alu_shift_d'range generate
				with mem_alu_sht_mask_q(i) select
				mem_alu_shift_d(i) <= 
					mem_alu_rotate_q(i)  when '1',
					mem_alu_sht_sign_q   when '0',
					'-' when others;
			end generate;

			with mem_sel_aluout_q select
			mem_t_bit_d <= 
				mem_add_reg_reg_co_q when aluout_add,
				mem_sub_reg_reg_bo_q when aluout_sub,
				mem_add_reg_imm_co_q when aluout_addi,
				mem_t_bit_q when aluout_rs2val,
				alu_sht_bit_d when aluout_shift,
				mem_alu_logic_t_bit_q when aluout_logic,
				'-' when others;

			with mem_alu_sht_dir_q select
			alu_sht_bit_d <=
				mem_alu_rotate_q(mem_alu_rotate_q'left) when '1',
				mem_alu_rotate_q(mem_alu_rotate_q'right) when '0',
				'-' when others;

			datamem : spram
			generic map (
				M => 10, 
				N => dword'length, 
				READ_FIRST => FALSE)
			port map (
				clk  => clk,
				we   => mem_data_rw_d,
				addr => exe_addr_lhalf_d(9 downto 0),
				dout => mem_datain_d,
				din  => exe_dataout_d);

		end block;

 	end block;

 	ctrlUnit: block
-- 		alias  dec_rs1_q is instrDec(rs1Fld);
-- 		alias  dec_rs2_q is instrDec(rs2Fld);
 		alias  dec_opc_q is instrDec(opcFld);
 		alias  dec_fun_q is instrDec(funFld);
		signal dec_null_d : std_ulogic;
		signal dec_jal_d : std_ulogic;

		signal dec_opc_rs1_hzrd_d : std_ulogic;
		signal dec_opc_rs2_hzrd_d : std_ulogic;
		signal dec_alu_imm_hzrd_d : std_ulogic;
 		signal exe_rd_q : std_ulogic_vector(ridFld);

		signal exe_rrf_q : std_ulogic;
		signal exe_opc_hzrd_q : std_ulogic;
		signal exe_rs1_hzrd_d : std_ulogic;
		signal exe_rs2_hzrd_d : std_ulogic;
		signal exe_nop_q : std_ulogic;
		signal exe_null_d : std_ulogic;

		signal mem_rrf_q : std_ulogic;
		signal mem_opc_hzrd_q : std_ulogic;
		signal mem_rs1_hzrd_d : std_ulogic;
		signal mem_rs2_hzrd_d : std_ulogic;
		signal mem_reg_ena_q : std_ulogic;
		signal mem_flg_ena_q : std_ulogic;
		signal mem_null_d : std_ulogic;
		signal mem_jal_q : std_ulogic;
		
 	begin
		DEBUG: block
		begin
--			leds(0 downto 0) <= (others => '0');
			with switches(3 downto 0) select
				leds(7) <=
					ip_ena_d   when "0000",
					dec_null_q when "0001",
					exe_null_q when "0010",
					mem_null_q when "0011",
					'0' when others;

			with switches(3 downto 0) select
				leds(6) <=
					DEBUG_pcdisp_sel_d when "0000",
					exe_opc_hzrd_q     when "0010",
					'0' when others;

			with switches(3 downto 0) select
				leds(5) <=
					dec_opc_rs1_hzrd_d when "0001",
				    exe_rs1_hzrd_d     when "0010",
					mem_rs1_hzrd_d     when "0011",
					'0' when others;
					
			with switches(3 downto 0) select
				leds(4) <=
					dec_opc_rs2_hzrd_d when "0001",
				    exe_rs2_hzrd_d     when "0010",
					mem_rs2_hzrd_d     when "0011",
				    '0' when others;
					
			with switches(3 downto 0) select
				leds(3) <=
				    exe_rs1_val_fwd_q when "0010",
				    mem_rs1_val_fwd_q when "0011",
					'0' when others;
					
			with switches(3 downto 0) select
				leds(2) <=
				    exe_rs2_val_fwd_q when "0010",
				    mem_rs2_val_fwd_q when "0011",
					'0' when others;
					
			with switches(3 downto 0) select
				leds(1) <=
				    DEBUG_mem_t_bit_d when "0011",
					'0' when others;
		end block;

		---------------------
		-- Fowarding logic --
		---------------------

		with dec_opc_q select
			dec_opc_rs1_hzrd_d <=
				'1' when alu|jral|cpi|addi|ori|li|st,
				'0' when others;
				
		with dec_opc_q select
			dec_opc_rs2_hzrd_d <=
				dec_alu_imm_hzrd_d when alu,
				'1' when ld|st,
				'0' when others;
				
		with dec_fun_q select
			dec_alu_imm_hzrd_d <=
				'0' when alu_asri|alu_lsri|alu_lsli,
				'1' when others;

		exe_rs1_hzrd_d <= SetIf(dec_rs1_q=exe_rd_q);
		exe_rs2_hzrd_d <= SetIf(dec_rs2_q=exe_rd_q);
		mem_rs1_hzrd_d <= SetIf(dec_rs1_q=mem_rd_q);
		mem_rs2_hzrd_d <= SetIf(dec_rs2_q=mem_rd_q);

		process (clk)
		begin
			if rising_edge(clk) then 
				case dec_opc_q is
				when alu|ld|addi|jal|ori|brt =>
					exe_opc_hzrd_q <= '1';
				when others =>
					exe_opc_hzrd_q <= '0';
				end case;
				mem_opc_hzrd_q <= exe_opc_hzrd_q;
				
		
				mem_rs1_val_fwd_q <= mem_rs1_hzrd_d and not mem_null_q and mem_opc_hzrd_q and dec_opc_rs1_hzrd_d;
				mem_rs2_val_fwd_q <= mem_rs2_hzrd_d and not mem_null_q and mem_opc_hzrd_q and dec_opc_rs2_hzrd_d;

				exe_rs1_val_fwd_q <= exe_rs1_hzrd_d and not exe_nop_q and not exe_null_q and exe_opc_hzrd_q and dec_opc_rs1_hzrd_d;
				exe_rs2_val_fwd_q <= exe_rs2_hzrd_d and not exe_nop_q and not exe_null_q and exe_opc_hzrd_q and dec_opc_rs2_hzrd_d;
			end if;
		end process;

		-------------------------
		-- End Fowarding logic --
		-------------------------

		ip_ena_d <= SetIf(not (isJcnd='1' and exe_rs1_hzrd_d='1' and not exe_null_q='1'));
		dec_null_d <= '0';
		exe_null_d <= SetIf(dec_null_q='1' or isJcnd='1');
		mem_null_d <= SetIf(exe_null_q='1' or exe_nop_q='1');

		process(rst,clk)
		begin
			if rst='1' then
				dec_null_q <= '1';
				exe_null_q <= '1';
				mem_null_q <= '1';
			elsif rising_edge(clk) then
				dec_null_q <= dec_null_d;
				exe_null_q <= exe_null_d;
				mem_null_q <= mem_null_d;
			end if;
		end process;
		
		dec_rs1_q <= instrDec(rs1Fld);
		dec_rs2_q <= instrDec(rs2Fld);

		instrIft <= code;
		process(clk)
		begin
			if rising_edge(clk) then
				if ip_ena_d='1' then
					instrDec <= instrIft;
				end if;
				instrExe <= instrDec;
				instrMem <= instrExe;

				case dec_jal_d is
				when '1' =>
					exe_rd_q <= "1111";
				when others =>
					exe_rd_q <= instrDec(rdFld);
				end case;
				mem_rd_q <= exe_rd_q;
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
			isJral <= SetIf(opc=jral);
			isJcnd <= SetIf(opc=brt);

			selDisp12 <= SetIf(isJal='1');
			pc_disp_sel_d <= SetIf(isJal='1' or (isJcnd='1' and pc_cond_d='1'));
			pc_reg_sel_d <= SetIf(isJral='1');

			dec_jal_d <= SetIf(opc=jal or opc=jral);
			
			process (clk)
			begin
				if rising_edge(clk) then
					exe_nop_q <= SetIf(
				  		opc=(opc'range =>'0') and
						rs1=(rs1'range =>'0') and
						rs2=(rs2'range =>'0') and
						fun=(fun'range =>'0'));

					
					case fun is
					when alu_lsht|alu_asht =>
						exe_sht_disp_rs2_q <= '1';
					when others =>
						exe_sht_disp_rs2_q <= '0';
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

					case opc is
					when rrf =>
						exe_rrf_q <= '1';
					when others =>
						exe_rrf_q <= '0';
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

			with opc select
				mem_data_rw_d <=
					SetIf(exe_null_q='0' and exe_nop_q='0') when st,
					'0' when others;

			process (clk)
			begin
				if rising_edge(clk) then
					case opc is
					when alu|addi|ori|ld =>
						mem_flg_ena_q <= '1';
					when others =>
						mem_flg_ena_q <= '0';
					end case;

					case opc is
					when alu|addi|ori|jal|jral|ld =>
						mem_reg_ena_q <= '1';
					when others =>
						mem_reg_ena_q <= '0';
					end case;

					case opc is
					when alu|addi|ori =>
						mem_sel_rdval_q <= rdval_aluout;
					when jal|jral =>
						mem_sel_rdval_q <= rdval_jal;
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
						when alu_add=>
							mem_sel_aluout_q <= aluout_add;
						when alu_sub =>
							mem_sel_aluout_q <= aluout_sub;
						when alu_or|alu_and|alu_xor =>
							mem_sel_aluout_q <= aluout_logic;
						when alu_asri|alu_lsri|alu_lsli =>
							mem_sel_aluout_q <= aluout_shift;
						when others =>
							mem_sel_aluout_q <= (others => '-');
						end case;
					when addi =>
						mem_sel_aluout_q <= aluout_addi;
					when ori =>
						mem_sel_aluout_q <= aluout_logic;
					when rrf =>
						mem_sel_aluout_q <= aluout_rrf;
					when others =>
						mem_sel_aluout_q <= (others => '-');
					end case;

					mem_rrf_q <= exe_rrf_q and fun(rrf_rw_bit_num);
				end if;
			end process;
 		end block;

		mem: block
 			alias opc is instrMem(opcFld);
 			alias fun is instrMem(funFld);
		begin
			dec_reg_ena_d <= not mem_null_q and mem_reg_ena_q;
			dec_flg_ena_d <= not mem_null_q and mem_flg_ena_q;
			mem_rrf_ena_d <= not mem_null_q and mem_rrf_q;
		end block;
 	end block;
end;
