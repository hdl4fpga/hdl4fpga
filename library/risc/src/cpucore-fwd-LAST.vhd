--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
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
 		xtal  : in  std_ulogic;

		switches : in std_ulogic_vector(7 downto 0);
		buttons : in std_ulogic_vector(3 downto 0);
		leds : out std_ulogic_vector(7 downto 0);
		anodes : out std_ulogic_vector(3 downto 0);
		segment_a : out std_ulogic;
		segment_b : out std_ulogic;
		segment_c : out std_ulogic;
		segment_d : out std_ulogic;
		segment_e : out std_ulogic;
		segment_f : out std_ulogic;
		segment_g : out std_ulogic;
		segment_dp : out std_ulogic);	

	attribute loc : string;

	-------------------------------------------
	-- Xilinx/Digilent SPARTAN-3 Starter Kit --
	-------------------------------------------

	attribute loc of xtal : signal is "T9";

	attribute loc of switches : signal is "K13 K14 J13 J14 H13 H14 G12 F12";
	attribute loc of buttons : signal is "L14 L13 M14 M13";
	attribute loc of leds : signal is  "P11 P12 N12 P13 N14 L12 P14 K12";
	attribute loc of anodes : signal is  "E13 F14 G14 D14";
	attribute loc of segment_a : signal is "E14";
	attribute loc of segment_b : signal is "G13";
	attribute loc of segment_c : signal is "N15";
	attribute loc of segment_d : signal is "P15";
	attribute loc of segment_e : signal is "R16";
	attribute loc of segment_f : signal is "F13";
	attribute loc of segment_g : signal is "N16";
	attribute loc of segment_dp : signal is "P16";

	------------------------------------
	-- Digilent/NEXYS2 SPARTAN-3E Kit --
	------------------------------------

--	attribute loc of rst : signal is "H13";
--	attribute loc of xtal : signal is "B8";
--	attribute loc of step : signal is "E18";
--
--	attribute loc of switches : signal is "R17 N17 L13 L14 K17 K18 H18 G18";
--	attribute loc of buttons : signal is "B18 D18 E18 H13";
--	attribute loc of leds : signal is  "P4 E4 P16 E16 K14 K15 J15 J14";
--	attribute loc of anodes : signal is  "F15 C18 H17 F17";
--	attribute loc of segment_a : signal is "L18";
--	attribute loc of segment_b : signal is "F18";
--	attribute loc of segment_c : signal is "D17";
--	attribute loc of segment_d : signal is "D16";
--	attribute loc of segment_e : signal is "G14";
--	attribute loc of segment_f : signal is "J17";
--	attribute loc of segment_g : signal is "H14";
--	attribute loc of segment_dp : signal is "C17";
	
end;

architecture pipeLine of cpuCore is

	-----------------------------
	-- BEGIN DEBUG DECLARATION --
	-----------------------------
	signal DEBUG_ip_q : std_ulogic_vector(dwidth-1 downto 0);

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
 	signal isJimm : std_ulogic;
 	signal isJcnd : std_ulogic;

	signal ip_load_d : std_ulogic;
	signal ip_ena_d : std_ulogic := '1';

	signal selDisp12 : std_ulogic;
	
	-- Decode Stage --

	signal dec_null_q : std_ulogic;
	signal dec_t_bit_rd_d : std_ulogic;
	signal dec_reg_ena_d : std_ulogic;
	signal dec_flg_ena_d : std_ulogic;

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

	constant rdval_aluout : std_ulogic_vector(0 downto 0) := "0";
	constant rdval_load   : std_ulogic_vector(0 downto 0) := "1";

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
	signal mem_sel_rdval_q  : std_ulogic_vector(0 downto 0);
	signal mem_sel_aluout_q : std_ulogic_vector(2 downto 0);
	signal mem_data_rw_d : std_ulogic;
	signal mem_rrf_ena_d : std_ulogic;

begin
	rst  <= buttons(3);
	step <= buttons(2);
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
	
	display: entity corelib.iodev_bcd
		port map (
			clock => xtal,
			data  => display_data,
			segment_a  => segment_a,
			segment_b  => segment_b,
			segment_c  => segment_c,
			segment_d  => segment_d,
			segment_e  => segment_e,
			segment_f  => segment_f,
			segment_g  => segment_g,
			segment_dp => segment_dp,
			display_turnon => anodes);

 	stages: block
		signal dec_sign_extn_d : dword;
		signal dec_rs1val_d : dword;
		signal dec_rs2val_d : dword;
		signal dec_tyv_word_dout_d : std_ulogic_vector(0 to 2**ridlen-1);

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
			with switches(3 downto 0) select
				display_data <=
--					instrIft when "0000",
					instrDec when "0001",
					instrExe when "0010",
					instrMem when "0011",
					mux_half(DEBUG_ip_q,   mux_sel) when "0100",
					mux_half(exe_rs1val_q, mux_sel) when "0110",
					mux_half(exe_rs2val_q, mux_sel) when "1010",			
					mux_half(mem_aluout_d, mux_sel) when "0111",
					mux_half(mem_rdval_d,  mux_sel) when "1011",
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
				return (0 to n-val'length-1 => val(val'left));
			end;
			
			alias imm8  : std_ulogic_vector(7 downto 0) is instrDec(im8Fld);
			alias imm12 : std_ulogic_vector(11 downto 0) is instrDec(im12Fld);

 			signal ip_q : dword;
	 		signal ip_d : dword;
	 		signal pcdisp_d : dword;
			signal pcdisp_sel_d : std_ulogic;

		begin
			with selDisp12 select
			dec_sign_extn_d <= 
				extn_sign(imm12, dec_sign_extn_d'length) & imm12 when '1',
	 			extn_sign(imm8,  dec_sign_extn_d'length) & imm8  when others;

			pcdisp_sel_d <= SetIf(isJal='1' or isJcnd='1');
			with pcdisp_sel_d select
			pcdisp_d <=
				dec_sign_extn_d when '1',
				extn_sign("01", pcdisp_d'length) when others;

			DEBUG_ip_q <= ip_q;
			pc: unsigned_adder port map (ip_d, ip_q, pcdisp_d);

			process (rst,clk)
			begin
				if rst='1' then
					ip_q <= (others => '0');
				elsif rising_edge(clk) then
					if ip_load_d='1' then
						ip_q <= ip_d;
					end if;
				end if;				
			end process;

			instr : spram
			generic map (M => 10, N => 16, SYNC_ADDRESS => FALSE)
			port map (
				clk  => clk,
				addr => ip_q(9 downto 0),
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
		
			tyv_word_rs <= instrDec(rs2Fld);
			tyv_word_rd <= instrMem(rdFld);
			tyv_word_din <= mem_tyv_word_din_d;
			tyv_word_ena <= mem_rrf_ena_d;

			tyv_bit_rd <= instrMem(rdFld);
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
				wAddr => instrMem(rdFld),
				din   => mem_rdval_d,
				rAddr => instrDec(rs1Fld),
				dout  => dec_rs1val_d);

			registerFile2 : dpram 
			generic map (ridLen, dword'length)
			port map (
				clk   => clk,
				we    => dec_reg_ena_d,
				wAddr => instrMem(rdFld),
				din   => mem_rdval_d,
				rAddr => instrDec(rs2Fld),
				dout  => dec_rs2val_d);

		end block;

		dec_exe_register: process (clk)
		begin
			if rising_edge(clk) then
				exe_sign_extn_q <= dec_sign_extn_d;
				exe_t_bit_q <= dec_t_bit_rd_d;
				exe_tyv_word_dout_q <= dec_tyv_word_dout_d;
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

			with exe_sel_logic_op_q select
			logic_reg_imm_d <= 
				rs1_val_d or  exe_sign_extn_q when logic_or,
				rs1_val_d and exe_sign_extn_q when logic_and,
				rs1_val_d xor exe_sign_extn_q when logic_xor,
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

			with mem_sel_rdval_q select
			mem_rdval_d <=
				mem_datain_d when rdval_load,
				mem_aluout_d when rdval_aluout,
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
				mem_tyv_word_dout_q  when aluout_rrf,
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
		signal ift_null_d : std_ulogic;

 		alias  dec_rs1_q is instrDec(rs1Fld);
 		alias  dec_rs2_q is instrDec(rs2Fld);
 		alias  dec_opc_q is instrDec(opcFld);
 		alias  dec_fun_q is instrDec(funFld);
		signal dec_null_d : std_ulogic;

		signal dec_opc_rs1_hzrd_d : std_ulogic;
		signal dec_opc_rs2_hzrd_d : std_ulogic;
		signal dec_alu_imm_hzrd_d : std_ulogic;
		
 		alias  exe_rd_q is instrExe(rdFld);

		signal exe_rrf_q : std_ulogic;
		signal exe_opc_hzrd_q : std_ulogic;
		signal exe_rs1_hzrd_d : std_ulogic;
		signal exe_rs2_hzrd_d : std_ulogic;
		signal exe_nop_q : std_ulogic;
		signal exe_null_d : std_ulogic;

		signal mem_rrf_q : std_ulogic;
 		alias  mem_rd_q is instrMem(rdFld);
		signal mem_opc_hzrd_q : std_ulogic;
		signal mem_rs1_hzrd_d : std_ulogic;
		signal mem_rs2_hzrd_d : std_ulogic;
		signal mem_reg_ena_q : std_ulogic;
		signal mem_flg_ena_q : std_ulogic;
		signal mem_null_d : std_ulogic;
 	begin
		DEBUG: block
		begin
			leds(1 downto 1) <= (others => '0');
			with switches(3 downto 0) select
				leds(7) <=
					dec_null_q when "0001",
					exe_null_q when "0010",
					mem_null_q when "0011",
					'0' when others;

			with switches(3 downto 0) select
				leds(6) <=
--					dec_opc_rs1_hzrd_d when "0001",
					exe_opc_hzrd_q     when "0010",
					'0' when others;

			with switches(3 downto 0) select
				leds(5) <=
					dec_opc_rs1_hzrd_d when "0001",
				    exe_rs1_hzrd_d when "0010",
					mem_rs1_hzrd_d when "0011",
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
				when alu|ld|addi|ori|brt =>
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

		ip_ena_d <= '1';

		ip_load_d  <= SetIf(isJal='1'); -- or (isJcnd='1'and dec_t_bit_rd_d='1'));
		exe_null_d <= SetIf(dec_null_q='1' or isJimm='1');-- or ip_load_d='0');
		mem_null_d <= SetIf(exe_null_q='1' or exe_nop_q='1');

		process(rst,clk)
		begin
			if rst='1' then
				dec_null_q <= '1';
				exe_null_q <= '1';
				mem_null_q <= '1';
			elsif rising_edge(clk) then
				dec_null_q <= '0';
				exe_null_q <= exe_null_d;
				mem_null_q <= mem_null_d;
			end if;
		end process;
		
		instrIft <= code;
		process(clk)
		begin
			if rising_edge(clk) then
				if not (isJal='1' or (isJcnd='1'and dec_t_bit_rd_d='1')) and ip_ena_d='1' then
					instrDec <= instrIft;
				end if;
				instrExe <= instrDec;
				instrMem <= instrExe;
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
