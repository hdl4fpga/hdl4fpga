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

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ddr_db.all;

package ddr_param is

	subtype ddrmr_id is std_logic_vector(3-1 downto 0);
	constant ddr_mrx : ddrmr_id := (others => '1');
	constant ddr_mr0 : ddrmr_id := "000";
	constant ddr_mr1 : ddrmr_id := "001";
	constant ddr_mr2 : ddrmr_id := "010";
	constant ddr_mr3 : ddrmr_id := "011";

	subtype ddrmr_addr is std_logic_vector(3-1 downto 0);

	constant ddrmr_mrx     : ddrmr_addr := (others => '1');

	constant ddr0mr_setmr   : ddrmr_addr := "100";

	constant ddr1mr_setemr  : ddrmr_addr := "000";
	constant ddr1mr_rstdll  : ddrmr_addr := "010";
	constant ddr1mr_preall  : ddrmr_addr := "011";
	constant ddr1mr_setmr   : ddrmr_addr := "100";

	constant ddr2mr_setemr2 : ddrmr_addr := "001";
	constant ddr2mr_setemr3 : ddrmr_addr := "110";
	constant ddr2mr_enadll  : ddrmr_addr := "111";
	constant ddr2mr_rstdll  : ddrmr_addr := "101";
	constant ddr2mr_preall  : ddrmr_addr := "100";
	constant ddr2mr_setmr   : ddrmr_addr := "000";
	constant ddr2mr_seteOCD : ddrmr_addr := "010";
	constant ddr2mr_setdOCD : ddrmr_addr := "011";

	constant ddr3mr_setmr0  : ddrmr_addr := "000";
	constant ddr3mr_setmr1  : ddrmr_addr := "001";
	constant ddr3mr_setmr2  : ddrmr_addr := "010";
	constant ddr3mr_setmr3  : ddrmr_addr := "011";
	constant ddr3mr_zqc     : ddrmr_addr := "100";
	constant ddr3mr_enawl   : ddrmr_addr := "101";

	type ddrmr_vector is array (natural range <>) of ddrmr_addr;

	type ddr_cmd is record
		cs  : std_logic;
		ras : std_logic;
		cas : std_logic;
		we  : std_logic;
	end record;

	constant ddr_nop : ddr_cmd := (cs => '0', ras => '1', cas => '1', we => '1');
	constant ddr_mrs : ddr_cmd := (cs => '0', ras => '0', cas => '0', we => '0');
	constant ddr_pre : ddr_cmd := (cs => '0', ras => '0', cas => '1', we => '0');
	constant ddr_ref : ddr_cmd := (cs => '0', ras => '0', cas => '0', we => '1');
	constant ddr_zqc : ddr_cmd := (cs => '0', ras => '1', cas => '1', we => '0');

	--------------
	-- DDR init --
	--------------

	constant TMR_SIZE : natural := 16;
	constant TMR_RST  : natural := 0;

	subtype s_code is std_logic_vector(0 to 4-1);

	type s_out is record
		rst     : std_logic;
		cke     : std_logic;
		rdy     : std_logic;
		wlq		: std_logic;
		odt     : std_logic;
	end record;

	type s_row is record
		state   : s_code;
		state_n : s_code;
		mask    : std_logic_vector(0 to 1-1);
		input   : std_logic_vector(0 to 1-1);
		output  : std_logic_vector(0 to 5-1);
		cmd     : ddr_cmd;
		mr      : ddrmr_addr;
		bnk     : ddrmr_id;
		tid     : unsigned(TMR_SIZE-1 downto 0);
	end record;

	type s_table is array (natural range <>) of s_row;

	constant sc_rst  : s_code := "0000";
	constant sc_ref  : s_code := "1000";

	function to_sout (
		constant output : std_logic_vector(0 to 5-1))
		return s_out;

	impure function choose_pgm (
		constant ddr_stdr : natural)
		return s_table;


	constant TMR1_CKE : natural := 1;
	constant TMR1_MRD : natural := 2;
	constant TMR1_RPA : natural := 3;
	constant TMR1_RFC : natural := 4;
	constant TMR1_DLL : natural := 5;
	constant TMR1_REF : natural := 6;

	constant TMR2_CKE : natural := 1;
	constant TMR2_MRD : natural := 2;
	constant TMR2_RPA : natural := 3;
	constant TMR2_RFC : natural := 4;
	constant TMR2_DLL : natural := 5;
	constant TMR2_REF : natural := 6;

	constant TMR3_WLC     : natural := 1;
	constant TMR3_WLDQSEN : natural := 2;
	constant TMR3_RRDY    : natural := 3;
	constant TMR3_CKE     : natural := 4;
	constant TMR3_MRD     : natural := 5;
	constant TMR3_MOD     : natural := 6;
	constant TMR3_DLL     : natural := 7;
	constant TMR3_ZQINIT  : natural := 8;
	constant TMR3_REF     : natural := 9;

	function ddr_timers (
		constant tCP  : natural;
		constant mark : natural;
		constant gear : natural := 2)
		return natural_vector;

	function ddr_rotval (
		constant LINE_SIZE : natural;
		constant WORD_SIZE : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector)
		return std_logic_vector;

	function ddr_task (
		constant clk_phases : natural;
		constant gear : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector;
		constant lat_sch : std_logic_vector;
		constant lat_ext : natural := 0;
		constant lat_wid : natural := 1)
		return std_logic_vector;

	impure function ddr0_mrfile (
		constant ddr_mr_addr : ddrmr_addr;
		constant ddr_mr_bl   : std_logic_vector;
		constant ddr_mr_bt   : std_logic_vector;
		constant ddr_mr_cl   : std_logic_vector;
		constant ddr_mr_wb   : std_logic_vector)
		return std_logic_vector;

	impure function ddr1_mrfile (
		constant ddr_mr_addr : ddrmr_addr;
		constant ddr_mr_bl   : std_logic_vector;
		constant ddr_mr_bt   : std_logic_vector;
		constant ddr_mr_cl   : std_logic_vector;
		constant ddr_mr_ods  : std_logic_vector)
		return std_logic_vector;

	impure function ddr_mrfile(
		constant ddr_stdr : natural;
		constant ddr_mr_addr : ddrmr_addr;
		constant ddr_mr_srt  : std_logic_vector;
		constant ddr_mr_bl   : std_logic_vector;
		constant ddr_mr_bt   : std_logic_vector;
		constant ddr_mr_cl   : std_logic_vector;
		constant ddr_mr_wb   : std_logic_vector;
		constant ddr_mr_wr   : std_logic_vector;
		constant ddr_mr_ods  : std_logic_vector;
		constant ddr_mr_rtt  : std_logic_vector;
		constant ddr_mr_al   : std_logic_vector;
		constant ddr_mr_ocd  : std_logic_vector;
		constant ddr_mr_tdqs : std_logic_vector;
		constant ddr_mr_rdqs : std_logic_vector;
		constant ddr_mr_qoff : std_logic_vector;
		constant ddr_mr_drtt : std_logic_vector;
		constant ddr_mr_mprrf : std_logic_vector;
		constant ddr_mr_mpr  : std_logic_vector;
		constant ddr_mr_asr  : std_logic_vector;
		constant ddr_mr_pd   : std_logic_vector;
		constant ddr_mr_cwl  : std_logic_vector)
		return std_logic_vector;

	-------------------------
	-- DDR Memory Register --
	-------------------------

	-- Mode Register Field Descriptor --
	------------------------------------

	type fd is record	-- Field Descritpor
		sz  : natural;	-- Size
		off : natural;	-- Offset
	end record;

	type fd_vector is array (natural range <>) of fd;
		
	function mr_field (
		constant mask : fd_vector;
		constant src  : std_logic_vector;
		constant size : natural)
		return std_logic_vector;

	type ddr3_ccmd is record
		cmd  : std_logic_vector( 3 downto 0);
		bank : std_logic_vector( 2 downto 0);
		addr : natural_vector(13 downto 0);
	end record;

	constant ddr_a_max : natural := 16;

	type mr_row is record
		mr   : ddrmr_addr;
		data : std_logic_vector(ddr_a_max-1 downto 0);
	end record;

	type mr_vector is array (natural range <>) of mr_row;

	-- DDR0 Mode Register --
	------------------------

	constant ddr0_wb   : fd_vector(0 to 0) := (0 => (off =>  9, sz => 1));

	-- DDR1 Mode Register --
	------------------------

	constant ddr1_bl   : fd_vector(0 to 0) := (0 => (off =>  0, sz => 3));
	constant ddr1_bt   : fd_vector(0 to 0) := (0 => (off =>  3, sz => 1));
	constant ddr1_cl   : fd_vector(0 to 0) := (0 => (off =>  4, sz => 3));
	constant ddr1_rdll : fd_vector(0 to 0) := (0 => (off =>  8, sz => 1));

	-- DDR1 Extended Mode Register --
	---------------------------------

	constant ddr1_edll : fd_vector(0 to 0) := (0 => (off => 0, sz => 1));
	constant ddr1_ods  : fd_vector(0 to 0) := (0 => (off => 1, sz => 1));

	-- A10 --
	---------

	constant ddr1_preall : fd_vector(0 to 0) := (0 => (off => 10, sz => 1));

	-- DDR2 Mode Register --
	------------------------

	constant ddr2_bl   : fd_vector(0 to 0) := (0 => (off =>  0, sz => 3));
	constant ddr2_bt   : fd_vector(0 to 0) := (0 => (off =>  3, sz => 1));
	constant ddr2_cl   : fd_vector(0 to 0) := (0 => (off =>  4, sz => 3));
	constant ddr2_rdll : fd_vector(0 to 0) := (0 => (off =>  8, sz => 1));
	constant ddr2_wr   : fd_vector(0 to 0) := (0 => (off =>  9, sz => 3));
	constant ddr2_pd   : fd_vector(0 to 0) := (0 => (off => 12, sz => 1));

	-- DDR2 Extended Mode Register --
	---------------------------------

	constant ddr2_edll : fd_vector(0 to 0) := (0 => (off => 0, sz => 1));
	constant ddr2_ods  : fd_vector(0 to 0) := (0 => (off => 1, sz => 1));
	constant ddr2_rtt  : fd_vector(0 to 1) := (
		0 => (off => 2, sz => 1),
		1 => (off => 6, sz => 1));
	constant ddr2_al   : fd_vector(0 to 0) := (0 => (off =>  3, sz => 3));
	constant ddr2_ocd  : fd_vector(0 to 0) := (0 => (off =>  7, sz => 3));
	constant ddr2_ddqs : fd_vector(0 to 0) := (0 => (off => 10, sz => 1));
	constant ddr2_rdqs : fd_vector(0 to 0) := (0 => (off => 11, sz => 1));
	constant ddr2_out  : fd_vector(0 to 0) := (0 => (off => 12, sz => 1));

	-- DDR2 Extended Mode Register 2 --
	-----------------------------------

	constant ddr2_srt  : fd_vector(0 to 0) := (0 => (off => 7, sz => 1));

	-- A10 --
	---------

	constant ddr2_preall : fd_vector(0 to 0) := (0 => (off => 10, sz => 1));

	--------------------------
	-- DDR3 Mode Register 0 --
	--------------------------

	constant ddr3_bl   : fd_vector(0 to 0) := (0 => (off =>  0, sz => 3));
	constant ddr3_bt   : fd_vector(0 to 0) := (0 => (off =>  3, sz => 1));
	constant ddr3_cl   : fd_vector(0 to 0) := (0 => (off =>  4, sz => 3));
	constant ddr3_rdll : fd_vector(0 to 0) := (0 => (off =>  8, sz => 1));
	constant ddr3_wr   : fd_vector(0 to 0) := (0 => (off =>  9, sz => 3));
	constant ddr3_pd   : fd_vector(0 to 0) := (0 => (off => 12, sz => 1));

	-- DDR3 Mode Register 1 --
	--------------------------

	constant ddr3_edll : fd_vector(0 to 0) := (0 => (off => 0, sz => 1));
	constant ddr3_ods  : fd_vector(0 to 1) := (
		0 => (off => 1, sz => 1), 
		1 => (off => 5, sz => 1));
	constant ddr3_rtt  : fd_vector(0 to 2) := (
		0 => (off => 2, sz => 1),
		1 => (off => 6, sz => 1),
		2 => (off => 9, sz => 1));
	constant ddr3_al   : fd_vector(0 to 0) := (0 => (off =>  3, sz => 2));
	constant ddr3_wl   : fd_vector(0 to 0) := (0 => (off =>  7, sz => 1));
	constant ddr3_tdqs : fd_vector(0 to 0) := (0 => (off => 11, sz => 1));
	constant ddr3_qoff : fd_vector(0 to 0) := (0 => (off => 12, sz => 1));

	-- DDR3 Mode Register 2 --
	--------------------------

	constant ddr3_cwl  : fd_vector(0 to 0) := (0 => (off => 3, sz => 3));
	constant ddr3_asr  : fd_vector(0 to 0) := (0 => (off => 6, sz => 1));
	constant ddr3_srt  : fd_vector(0 to 0) := (0 => (off => 7, sz => 1));
	constant ddr3_drtt : fd_vector(0 to 0) := (0 => (off => 9, sz => 2));

	-- DDR3 Mode Register 3 --
	--------------------------

	constant ddr3_mprrf : fd_vector(0 to 0) := (0 => (off => 0, sz => 2));
	constant ddr3_mpr   : fd_vector(0 to 0) := (0 => (off => 2, sz => 1));

	constant ddr3_zqc   : fd_vector(0 to 0) := (0 => (off => 10, sz => 1));

end package;

library hdl4fpga;
use hdl4fpga.std.all;

package body ddr_param is

	function ddr_rotval (
		constant LINE_SIZE : natural;
		constant WORD_SIZE : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector)
		return std_logic_vector is

		subtype word is std_logic_vector(unsigned_num_bits(LINE_SIZE/WORD_SIZE-1)-1 downto 0);
		type word_vector is array(natural range <>) of word;
		
		subtype latword is std_logic_vector(0 to lat_val'length-1);
		type latword_vector is array (natural range <>) of latword;

		constant algn : natural := unsigned_num_bits(WORD_SIZE-1);
		
		function to_latwordvector(
			constant arg : std_logic_vector)
			return latword_vector is
			variable aux : unsigned(0 to arg'length-1);
			variable val : latword_vector(0 to arg'length/latword'length-1);
		begin
			aux := unsigned(arg);
			for i in val'range loop
				val(i) := std_logic_vector(aux(latword'range));
				aux := aux sll latword'length;
			end loop;
			return val;
		end;

		function select_lat (
			constant lat_val : std_logic_vector;
			constant lat_cod : latword_vector;
			constant lat_sch : word_vector)
			return std_logic_vector is
			variable val : word;
		begin
			val := (others => '-');
			for i in 0 to lat_tab'length-1 loop
				if lat_val = lat_cod(i) then
					for j in word'range loop
						val(j) := lat_sch(i)(j);
					end loop;
				end if;
			end loop;
			return val;
		end;
		
		constant lc   : latword_vector := to_latwordvector(lat_cod);
		
		variable sel_sch : word_vector(lc'range);
		variable val : unsigned(unsigned_num_bits(LINE_SIZE-1)-1 downto 0) := (others => '0');
		variable disp : natural;

	begin

		setup_l : for i in 0 to lat_tab'length-1 loop
			sel_sch(i) := std_logic_vector(to_unsigned(lat_tab(i) mod (LINE_SIZE/WORD_SIZE), word'length));
		end loop;
		
		val(word'range) := unsigned(select_lat(lat_val, lc, sel_sch));
		val := val sll algn;
		return std_logic_vector(val);
	end;

	function ddr_task (
		constant clk_phases : natural;
		constant gear : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector;
		constant lat_sch : std_logic_vector;
		constant lat_ext : natural := 0;
		constant lat_wid : natural := 1)
		return std_logic_vector is

		subtype word is std_logic_vector(0 to gear-1);
		type word_vector is array (natural range <>) of word;

		subtype latword is std_logic_vector(0 to lat_val'length-1);
		type latword_vector is array (natural range <>) of latword;

		function to_latwordvector(
			constant arg : std_logic_vector)
			return latword_vector is
			variable aux : unsigned(0 to arg'length-1);
			variable val : latword_vector(0 to arg'length/latword'length-1);
		begin
			aux := unsigned(arg);
			for i in val'range loop
				val(i) := std_logic_vector(aux(latword'range));
				aux := aux sll latword'length;
			end loop;
			return val;
		end;

		function select_lat (
			constant lat_val : std_logic_vector;
			constant lat_cod : latword_vector;
			constant lat_sch : word_vector)
			return std_logic_vector is
			variable val : word;
		begin
			val := (others => '-');
			for i in 0 to lat_tab'length-1 loop
				if lat_val = lat_cod(i) then
					for j in word'range loop
						val(j) := lat_sch(i)(j);
					end loop;
				end if;
			end loop;
			return val;
		end;

		constant lat_cod1 : latword_vector := to_latwordvector(lat_cod);
		variable sel_sch : word_vector(lat_cod1'range);

	begin
		sel_sch := (others => (others => '-'));
		for i in 0 to lat_tab'length-1 loop
			sel_sch(i) := pulse_delay (
				clk_phases => clk_phases,
				phase     => lat_sch,
				latency   => lat_tab(i),
				WORD_SIZE => word'length,
				extension => lat_ext,
				width     => lat_wid);
		end loop;
		return select_lat(lat_val, lat_cod1, sel_sch);
	end;

	--------------
	-- DDR init --
	--------------

	constant sc1_cke  : s_code := "0001";
	constant sc1_pre1 : s_code := "0011";
	constant sc1_lm1  : s_code := "0010";
	constant sc1_lm2  : s_code := "0110";
	constant sc1_pre2 : s_code := "0111";
	constant sc1_ref1 : s_code := "0101";
	constant sc1_ref2 : s_code := "0100";
	constant sc1_lm3  : s_code := "1100";
	constant sc1_wai  : s_code := "1101";

	constant ddr0_pgm : s_table := (
		(sc_rst,   sc1_cke,  "0", "0", "11000", ddr_nop, ddrmr_mrx,     ddr_mrx, to_unsigned(TMR1_CKE, TMR_SIZE)), 
		(sc1_cke,  sc1_pre1, "0", "0", "11000", ddr_pre, ddr1mr_preall, ddr_mrx, to_unsigned(TMR1_RPA, TMR_SIZE)), 
		(sc1_pre1, sc1_ref1, "0", "0", "11000", ddr_ref, ddrmr_mrx,     ddr_mrx, to_unsigned(TMR1_RFC, TMR_SIZE)), 
		(sc1_ref1, sc1_ref2, "0", "0", "11000", ddr_ref, ddrmr_mrx,     ddr_mrx, to_unsigned(TMR1_RFC, TMR_SIZE)), 
		(sc1_ref2, sc1_lm1,  "0", "0", "11001", ddr_mrs, ddr1mr_setmr,  ddr_mr0, to_unsigned(TMR1_MRD, TMR_SIZE)),  
		(sc1_lm1,  sc_ref,   "0", "0", "11110", ddr_nop, ddrmr_mrx,     ddr_mrx, to_unsigned(TMR1_REF, TMR_SIZE)),
		(sc_ref,   sc_ref,   "0", "0", "11110", ddr_nop, ddrmr_mrx,     ddr_mrx, to_unsigned(TMR1_REF, TMR_SIZE)));

	constant ddr1_pgm : s_table := (
		(sc_rst,   sc1_cke,  "0", "0", "11000", ddr_nop, ddrmr_mrx,     ddr_mrx, to_unsigned(TMR1_CKE, TMR_SIZE)), 
		(sc1_cke,  sc1_pre1, "0", "0", "11000", ddr_pre, ddr1mr_preall, ddr_mrx, to_unsigned(TMR1_RPA, TMR_SIZE)), 
		(sc1_pre1, sc1_lm1,  "0", "0", "11000", ddr_mrs, ddr1mr_setemr, ddr_mr1, to_unsigned(TMR1_MRD, TMR_SIZE)), 
		(sc1_lm1,  sc1_lm2,  "0", "0", "11000", ddr_mrs, ddr1mr_rstdll, ddr_mr0, to_unsigned(TMR1_MRD, TMR_SIZE)), 
		(sc1_lm2,  sc1_pre2, "0", "0", "11000", ddr_pre, ddr1mr_preall, ddr_mrx, to_unsigned(TMR1_RPA, TMR_SIZE)), 
		(sc1_pre2, sc1_ref1, "0", "0", "11000", ddr_ref, ddrmr_mrx,     ddr_mrx, to_unsigned(TMR1_RFC, TMR_SIZE)), 
		(sc1_ref1, sc1_ref2, "0", "0", "11000", ddr_ref, ddrmr_mrx,     ddr_mrx, to_unsigned(TMR1_RFC, TMR_SIZE)), 
		(sc1_ref2, sc1_lm3,  "0", "0", "11001", ddr_mrs, ddr1mr_setmr,  ddr_mr0, to_unsigned(TMR1_MRD, TMR_SIZE)),  
		(sc1_lm3,  sc1_wai,  "0", "0", "11010", ddr_nop, ddrmr_mrx,     ddr_mrx, to_unsigned(TMR1_DLL, TMR_SIZE)),  
		(sc1_wai,  sc_ref,   "0", "0", "11110", ddr_nop, ddrmr_mrx,     ddr_mrx, to_unsigned(TMR1_REF, TMR_SIZE)),  
		(sc_ref,   sc_ref,   "0", "0", "11110", ddr_nop, ddrmr_mrx,     ddr_mrx, to_unsigned(TMR1_REF, TMR_SIZE)));

	constant sc2_cke  : s_code := "0001";
	constant sc2_pre1 : s_code := "0011";
	constant sc2_lm1  : s_code := "0010";
	constant sc2_lm2  : s_code := "0110";
	constant sc2_lm3  : s_code := "0111";
	constant sc2_lm4  : s_code := "0101";
	constant sc2_pre2 : s_code := "0100";
	constant sc2_ref1 : s_code := "1100";
	constant sc2_ref2 : s_code := "1101";
	constant sc2_lm5  : s_code := "1111";
	constant sc2_lm6  : s_code := "1110";
	constant sc2_lm7  : s_code := "1010";
	constant sc2_wai  : s_code := "1011";


	                              --    +------< rst
	                              --    |+-----< cke
	                              --    ||+----< rdy
	                              --    |||+---< wlq
	                              --    ||||+--< odt
	                              --    |||||
                                  --    vvvvv
	constant ddr2_pgm : s_table := (
		(sc_rst,   sc2_cke,  "0", "0", "11000", ddr_nop, ddrmr_mrx,      ddr_mrx, to_unsigned(TMR2_CKE, TMR_SIZE)), 
		(sc2_cke,  sc2_pre1, "0", "0", "11000", ddr_pre, ddr2mr_preall,  ddr_mrx, to_unsigned(TMR2_RPA, TMR_SIZE)), 
		(sc2_pre1, sc2_lm1,  "0", "0", "11000", ddr_mrs, ddr2mr_setemr2, ddr_mr2, to_unsigned(TMR2_MRD, TMR_SIZE)), 
		(sc2_lm1,  sc2_lm2,  "0", "0", "11000", ddr_mrs, ddr2mr_setemr3, ddr_mr3, to_unsigned(TMR2_MRD, TMR_SIZE)), 
		(sc2_lm2,  sc2_lm3,  "0", "0", "11000", ddr_mrs, ddr2mr_enadll,  ddr_mr1, to_unsigned(TMR2_MRD, TMR_SIZE)), 
		(sc2_lm3,  sc2_lm4,  "0", "0", "11000", ddr_mrs, ddr2mr_rstdll,  ddr_mr0, to_unsigned(TMR2_MRD, TMR_SIZE)), 
		(sc2_lm4,  sc2_pre2, "0", "0", "11000", ddr_pre, ddr2mr_preall,  ddr_mrx, to_unsigned(TMR2_RPA, TMR_SIZE)),
		(sc2_pre2, sc2_ref1, "0", "0", "11000", ddr_ref, ddrmr_mrx,      ddr_mrx, to_unsigned(TMR2_RFC, TMR_SIZE)), 
		(sc2_ref1, sc2_ref2, "0", "0", "11000", ddr_ref, ddrmr_mrx,      ddr_mrx, to_unsigned(TMR2_RFC, TMR_SIZE)), 
		(sc2_ref2, sc2_lm5,  "0", "0", "11000", ddr_mrs, ddr2mr_setmr,   ddr_mr0, to_unsigned(TMR2_MRD, TMR_SIZE)),  
		(sc2_lm5,  sc2_lm6,  "0", "0", "11000", ddr_mrs, ddr2mr_seteOCD, ddr_mr1, to_unsigned(TMR2_MRD, TMR_SIZE)),  
		(sc2_lm6,  sc2_lm7,  "0", "0", "11000", ddr_mrs, ddr2mr_setdOCD, ddr_mr1, to_unsigned(TMR2_MRD, TMR_SIZE)),  
		(sc2_lm7,  sc2_wai,  "0", "0", "11000", ddr_nop, ddrmr_mrx,      ddr_mrx, to_unsigned(TMR2_DLL, TMR_SIZE)),  
 		(sc2_wai,  sc_ref,   "0", "0", "11111", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR2_REF, TMR_SIZE)),
		(sc_ref,   sc_ref,   "0", "0", "11100", ddr_nop, ddrmr_mrx,      ddr_mrx, to_unsigned(TMR2_REF, TMR_SIZE)));

 	constant sc3_rrdy : s_code := "0001";
 	constant sc3_cke  : s_code := "0011";
 	constant sc3_lmr2 : s_code := "0010";
 	constant sc3_lmr3 : s_code := "0110";

 	constant sc3_lmr1 : s_code := "0111";
 	constant sc3_lmr0 : s_code := "0101";
 	constant sc3_zqi  : s_code := "0100";
 	constant sc3_wle  : s_code := "1100";

 	constant sc3_wls  : s_code := "1101";
 	constant sc3_wlc  : s_code := "1111";
 	constant sc3_wlo  : s_code := "1110";
 	constant sc3_wlf  : s_code := "1010";

 	constant sc3_wai  : s_code := "1011";
 
	                              --    +------< rst
	                              --    |+-----< cke
	                              --    ||+----< rdy
	                              --    |||+---< wlq
	                              --    ||||+--< odt
	                              --    |||||
                                  --    vvvvv
 	constant ddr3_pgm : s_table := (          
 		(sc_rst,   sc3_rrdy, "0", "0", "10000", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR3_RRDY, TMR_SIZE)),
 		(sc3_rrdy, sc3_cke,  "0", "0", "11000", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR3_CKE, TMR_SIZE)), 
 		(sc3_cke,  sc3_lmr2, "0", "0", "11000", ddr_mrs, ddr3mr_setmr2, ddr_mr2, to_unsigned(TMR3_MRD, TMR_SIZE)), 
 		(sc3_lmr2, sc3_lmr3, "0", "0", "11000", ddr_mrs, ddr3mr_setmr3, ddr_mr3, to_unsigned(TMR3_MRD, TMR_SIZE)), 
 		(sc3_lmr3, sc3_lmr1, "0", "0", "11000", ddr_mrs, ddr3mr_setmr1, ddr_mr1, to_unsigned(TMR3_MRD, TMR_SIZE)), 
 		(sc3_lmr1, sc3_lmr0, "0", "0", "11000", ddr_mrs, ddr3mr_setmr0, ddr_mr0, to_unsigned(TMR3_MOD, TMR_SIZE)), 
 		(sc3_lmr0, sc3_zqi,  "0", "0", "11000", ddr_zqc, ddr3mr_zqc, ddr_mrx,    to_unsigned(TMR3_ZQINIT, TMR_SIZE)),
 		(sc3_zqi,  sc3_wle,  "0", "0", "11000", ddr_mrs, ddr3mr_enawl, ddr_mr1, to_unsigned(TMR3_MOD, TMR_SIZE)), 
 		(sc3_wle,  sc3_wls,  "0", "0", "11001", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR3_WLDQSEN, TMR_SIZE)),  
 		(sc3_wls,  sc3_wlc,  "0", "0", "11011", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR3_WLC, TMR_SIZE)),  
 		(sc3_wlc,  sc3_wlc,  "1", "0", "11011", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR3_WLC, TMR_SIZE)),  
 		(sc3_wlc,  sc3_wlo,  "1", "1", "11010", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR3_MRD, TMR_SIZE)),  
 		(sc3_wlo,  sc3_wlf,  "0", "0", "11010", ddr_mrs, ddr3mr_setmr1, ddr_mr1, to_unsigned(TMR3_MOD, TMR_SIZE)),  
 		(sc3_wlf,  sc3_wai,  "0", "0", "11110", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR3_DLL, TMR_SIZE)),
 		(sc3_wai,  sc_ref,   "0", "0", "11110", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR3_REF, TMR_SIZE)),
 		(sc_ref,   sc_ref,   "0", "0", "11110", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR3_REF, TMR_SIZE)));
 
	function to_sout (
		constant output : std_logic_vector(0 to 5-1))
		return s_out is
	begin
		return (
			rst => output(0),
			cke => output(1),
			rdy => output(2),
			wlq => output(3),
			odt => output(4));
	end;

	impure function choose_pgm (
		constant ddr_stdr : natural)
		return s_table is
	begin
		case ddr_stdr is
		when DDR0 =>
			return ddr0_pgm;
		when DDR1 =>
			return ddr1_pgm;
		when DDR2 =>
			return ddr2_pgm;
		when DDR3 =>
			return ddr3_pgm;
		when others =>
			return ddr3_pgm;
		end case;
	end;

	function ddr_timers (
		constant tCP  : natural;
		constant mark : natural;
		constant gear : natural := 2)
		return natural_vector  is
		constant stdr : natural := ddr_stdr(mark);

		constant ddr1_timer : natural_vector := (
				TMR_RST  => to_ddrlatency(tCP, mark, tPreRST),
				TMR1_CKE => to_ddrlatency(tCP, mark, tXPR),
				TMR1_MRD => to_ddrlatency(tCP, mark, tMRD),
				TMR1_RPA => to_ddrlatency(tCP, mark, tRP),
				TMR1_RFC => to_ddrlatency(tCP, mark, tRFC),
				TMR1_DLL => 200, --to_ddrlatency(tCP, mark, tMRD),
				TMR1_REF => to_ddrlatency(tCP, mark, tREFI));

		constant ddr2_timer : natural_vector := (
				TMR_RST  => to_ddrlatency(tCP, mark, tPreRST),
				TMR2_CKE => to_ddrlatency(tCP, mark, tXPR),
				TMR2_MRD => ddr_latency(stdr, MRD),
				TMR2_RPA => to_ddrlatency(tCP, mark, tRPA),
				TMR2_RFC => to_ddrlatency(tCP, mark, tRFC),
				TMR2_DLL => 200, --ddr_latency(stdr, MRD),
				TMR2_REF => to_ddrlatency(tCP, mark, tREFI));

		constant ddr3_timer : natural_vector := (
				TMR_RST  => to_ddrlatency(tCP, mark, tPreRST),
				TMR3_RRDY => to_ddrlatency(tCP, mark, tPstRST),
				TMR3_WLC => ddr_latency(stdr, MODu),
				TMR3_WLDQSEN => 25,
				TMR3_CKE => to_ddrlatency(tCP, mark, tXPR),
				TMR3_MRD => to_ddrlatency(tCP, mark, tMRD),
				TMR3_MOD => ddr_latency(stdr, MODu),
				TMR3_DLL => ddr_latency(stdr, cDLL),
				TMR3_ZQINIT => ddr_latency(DDR3, ZQINIT),
				TMR3_REF => to_ddrlatency(tCP, mark, tREFI));
	begin
		case stdr is 
		when DDR0|DDR1 =>
			return ddr1_timer;
		when DDR2 =>
			return ddr2_timer;
		when others =>
			return ddr3_timer;
		end case;
	end;
		
	function mr_field (
		constant mask : fd_vector;
		constant src  : std_logic_vector;
		constant size : natural)
		return std_logic_vector is
		variable aux : unsigned(src'range) := unsigned(src);
		variable fld : unsigned(size-1 downto 0) := (others => '0');
		variable val : unsigned(fld'range) := (others => '0');
	begin
		for i in mask'reverse_range loop
			fld := (others => '0');
			for j in 1 to mask(i).sz loop
				fld := fld sll 1;
				fld(0) := aux(aux'left);
				aux := aux sll 1;
			end loop;
			fld := fld sll mask(i).off;
			val := val or  fld;
		end loop;
		return std_logic_vector(val);
	end;


	impure function mr_field (
		constant mask : fd_vector;
		constant src  : std_logic_vector)
		return std_logic_vector is
	begin
		return mr_field(mask, src, ddr_a_max);
	end;

	impure function ddrmr_data (
		constant mr_file : mr_vector;
		constant mr_addr : ddrmr_addr)
		return std_logic_vector is
		variable val : std_logic_vector(0 to ddr_a_max-1);
	begin
		val := (others => '1');
		for i in mr_file'range loop
			if mr_addr=mr_file(i).mr then
				val := mr_file(i).data;
			end if;
		end loop;
		return val;
	end;

	impure function ddr0_mrfile (
		constant ddr_mr_addr : ddrmr_addr;
		constant ddr_mr_bl   : std_logic_vector;
		constant ddr_mr_bt   : std_logic_vector;
		constant ddr_mr_cl   : std_logic_vector;
		constant ddr_mr_wb   : std_logic_vector)
		return std_logic_vector is
	begin

		case ddr_mr_addr is
		when ddr1mr_preall =>
			return mr_field(mask => ddr1_preall, src => "1", size => ddr_a_max);
		when ddr0mr_setmr =>
			return
				mr_field(mask => ddr1_bl, src => ddr_mr_bl, size => ddr_a_max) or
				mr_field(mask => ddr1_bt, src => ddr_mr_bt, size => ddr_a_max) or
				mr_field(mask => ddr1_cl, src => ddr_mr_cl, size => ddr_a_max) or
				mr_field(mask => ddr0_wb, src => ddr_mr_wb, size => ddr_a_max);
		when others =>
			return (0 to ddr_a_max-1 => '1');
		end case;
	end;

	impure function ddr1_mrfile (
		constant ddr_mr_addr : ddrmr_addr;
		constant ddr_mr_bl   : std_logic_vector;
		constant ddr_mr_bt   : std_logic_vector;
		constant ddr_mr_cl   : std_logic_vector;
		constant ddr_mr_ods  : std_logic_vector)
		return std_logic_vector is
	begin


		case ddr_mr_addr is
		when ddr1mr_setemr =>
			return
				mr_field(mask => ddr1_edll, src => "0", size => ddr_a_max) or
				mr_field(mask => ddr1_ods,  src => "0", size => ddr_a_max);
		when ddr1mr_preall =>
			return mr_field(mask => ddr1_preall, src => "1", size => ddr_a_max);
		when ddr1mr_rstdll =>
			return 
				mr_field(mask => ddr1_bl,   src => ddr_mr_bl, size => ddr_a_max) or
				mr_field(mask => ddr1_bt,   src => ddr_mr_bt, size => ddr_a_max) or
				mr_field(mask => ddr1_cl,   src => ddr_mr_cl, size => ddr_a_max) or
				mr_field(mask => ddr1_rdll, src => "1",       size => ddr_a_max);
		when ddr1mr_setmr =>
			return mr_field(mask => ddr1_bl,   src => ddr_mr_bl, size => ddr_a_max) or
				mr_field(mask => ddr1_bt,   src => ddr_mr_bt, size => ddr_a_max) or
				mr_field(mask => ddr1_cl,   src => ddr_mr_cl, size => ddr_a_max) or
				mr_field(mask => ddr1_rdll, src => "0", size => ddr_a_max);
		when others =>
			return (0 to ddr_a_max-1 => '1');
		end case;
	end;

	impure function ddr2_mrfile (
		constant ddr_mr_addr : ddrmr_addr;
		constant ddr_mr_srt  : std_logic_vector;
		constant ddr_mr_bl   : std_logic_vector;
		constant ddr_mr_bt   : std_logic_vector;
		constant ddr_mr_cl   : std_logic_vector;
		constant ddr_mr_wr   : std_logic_vector;
		constant ddr_mr_ods  : std_logic_vector;
		constant ddr_mr_rtt  : std_logic_vector;
		constant ddr_mr_al   : std_logic_vector;
		constant ddr_mr_ocd  : std_logic_vector;
		constant ddr_mr_tdqs : std_logic_vector;
		constant ddr_mr_rdqs : std_logic_vector)
		return std_logic_vector is
	begin
		case ddr_mr_addr is
		when ddr2mr_setemr2 =>
			return mr_field(mask => ddr2_srt, src => ddr_mr_srt);
		when ddr2mr_setemr3 =>
			return (0 to ddr_a_max-1 => '0');
		when ddr2mr_rstdll =>
			return mr_field(mask => ddr2_rdll, src => "1");
		when ddr2mr_enadll =>
			return mr_field(mask => ddr2_edll, src => "0");
		when ddr2mr_setmr =>
			return
				mr_field(mask => ddr2_bl,   src => ddr_mr_bl) or
				mr_field(mask => ddr2_bt,   src => ddr_mr_bt) or
				mr_field(mask => ddr2_cl,   src => ddr_mr_cl) or
				mr_field(mask => ddr2_wr,   src => ddr_mr_wr) or
				mr_field(mask => ddr2_rdll, src => "0");
		when ddr2mr_seteOCD =>
			return
				mr_field(mask => ddr2_edll, src => "0") or
				mr_field(mask => ddr2_ods,  src => ddr_mr_ods)  or
				mr_field(mask => ddr2_rtt,  src => ddr_mr_rtt)  or
				mr_field(mask => ddr2_al,   src => ddr_mr_al)   or
				mr_field(mask => ddr2_ocd,  src => ddr_mr_ocd)  or
				mr_field(mask => ddr2_ddqs, src => ddr_mr_tdqs) or
				mr_field(mask => ddr2_rdqs, src => ddr_mr_rdqs) or
				mr_field(mask => ddr2_out,  src => "0");
		when ddr2mr_setdOCD =>
			return
				mr_field(mask => ddr2_edll, src => "0") or
				mr_field(mask => ddr2_ods,  src => ddr_mr_ods)  or
				mr_field(mask => ddr2_rtt,  src => ddr_mr_rtt)  or
				mr_field(mask => ddr2_al,   src => ddr_mr_al)   or
				mr_field(mask => ddr2_ocd,  src => "000")  or
				mr_field(mask => ddr2_ddqs, src => ddr_mr_tdqs) or
				mr_field(mask => ddr2_rdqs, src => ddr_mr_rdqs) or
				mr_field(mask => ddr2_out,  src => "0");
		when ddr2mr_preall =>
			return
				mr_field(mask => ddr2_preall, src => "1");
		when others =>
			return (0 to ddr_a_max-1 => '1');
		end case;
	end;

	impure function ddr3_mrfile (
		constant ddr_mr_addr : ddrmr_addr;
		constant ddr_mr_srt  : std_logic_vector;
		constant ddr_mr_bl   : std_logic_vector;
		constant ddr_mr_bt   : std_logic_vector;
		constant ddr_mr_cl   : std_logic_vector;
		constant ddr_mr_wr   : std_logic_vector;
		constant ddr_mr_ods  : std_logic_vector;
		constant ddr_mr_rtt  : std_logic_vector;
		constant ddr_mr_al   : std_logic_vector;
		constant ddr_mr_tdqs : std_logic_vector;
		constant ddr_mr_qoff : std_logic_vector;
		constant ddr_mr_drtt : std_logic_vector;
		constant ddr_mr_mprrf : std_logic_vector;
		constant ddr_mr_mpr  : std_logic_vector;
		constant ddr_mr_asr  : std_logic_vector;
		constant ddr_mr_pd   : std_logic_vector;
		constant ddr_mr_cwl  : std_logic_vector)
		return std_logic_vector is
	begin
		case ddr_mr_addr is
		when ddr3mr_setmr0 =>
			 return
				mr_field(mask => ddr3_bl, src => ddr_mr_bl) or
				mr_field(mask => ddr3_bt, src => ddr_mr_bt) or
				mr_field(mask => ddr3_cl, src => ddr_mr_cl) or
				mr_field(mask => ddr3_pd, src => ddr_mr_pd) or
				mr_field(mask => ddr3_rdll, src => "1") or
				mr_field(mask => ddr3_wr, src => ddr_mr_wr);
		when ddr3mr_enawl =>
			 return
				mr_field(mask => ddr3_al,   src => ddr_mr_al) or
				mr_field(mask => ddr3_edll, src => "0") or
				mr_field(mask => ddr3_ods,  src => ddr_mr_ods) or
				mr_field(mask => ddr3_qoff, src => "0") or
				mr_field(mask => ddr3_rtt,  src => ddr_mr_rtt) or
				mr_field(mask => ddr3_tdqs, src => ddr_mr_tdqs) or
				mr_field(mask => ddr3_wl,   src => "1");

		when ddr3mr_setmr1 =>
			 return
				mr_field(mask => ddr3_al,   src => ddr_mr_al) or
				mr_field(mask => ddr3_edll, src => "0") or
				mr_field(mask => ddr3_ods,  src => ddr_mr_ods) or
				mr_field(mask => ddr3_qoff, src => "0") or
				mr_field(mask => ddr3_rtt,  src => ddr_mr_rtt) or
				mr_field(mask => ddr3_tdqs, src => ddr_mr_tdqs) or
				mr_field(mask => ddr3_wl,   src => "0");

		when ddr3mr_setmr2 =>
			 return
				mr_field(mask => ddr3_asr,  src => ddr_mr_asr) or
				mr_field(mask => ddr3_cwl,  src => ddr_mr_cwl) or
				mr_field(mask => ddr3_drtt, src => ddr_mr_drtt) or
				mr_field(mask => ddr3_srt,  src => ddr_mr_srt);

		when ddr3mr_setmr3 =>
			 return
				mr_field(mask => ddr3_mprrf, src => ddr_mr_mprrf) or
				mr_field(mask => ddr3_mpr,   src => ddr_mr_mpr);

		when ddr3mr_zqc =>
			 return
				mr_field(mask => ddr3_zqc,   src => "1");
		when others =>
			return (0 to ddr_a_max-1 => '1');
		end case;
	end;

	impure function ddr_mrfile(
		constant ddr_stdr : natural;

		constant ddr_mr_addr : ddrmr_addr;
		constant ddr_mr_srt  : std_logic_vector;
		constant ddr_mr_bl   : std_logic_vector;
		constant ddr_mr_bt   : std_logic_vector;
		constant ddr_mr_cl   : std_logic_vector;
		constant ddr_mr_wb   : std_logic_vector;
		constant ddr_mr_wr   : std_logic_vector;
		constant ddr_mr_ods  : std_logic_vector;
		constant ddr_mr_rtt  : std_logic_vector;
		constant ddr_mr_al   : std_logic_vector;
		constant ddr_mr_ocd  : std_logic_vector;
		constant ddr_mr_tdqs : std_logic_vector;
		constant ddr_mr_rdqs : std_logic_vector;
		constant ddr_mr_qoff : std_logic_vector;
		constant ddr_mr_drtt : std_logic_vector;
		constant ddr_mr_mprrf : std_logic_vector;
		constant ddr_mr_mpr  : std_logic_vector;
		constant ddr_mr_asr  : std_logic_vector;
		constant ddr_mr_pd   : std_logic_vector;
		constant ddr_mr_cwl  : std_logic_vector)
		return std_logic_vector is
	begin
		case ddr_stdr is
		when DDR0 =>
			return ddr0_mrfile(
				ddr_mr_addr => ddr_mr_addr,
				ddr_mr_bl   => ddr_mr_bl,
				ddr_mr_bt   => ddr_mr_bt,
				ddr_mr_cl   => ddr_mr_cl,
				ddr_mr_wb   => ddr_mr_wb);

		when DDR1 =>
			return ddr1_mrfile(
				ddr_mr_addr => ddr_mr_addr,
				ddr_mr_bl   => ddr_mr_bl,
				ddr_mr_bt   => ddr_mr_bt,
				ddr_mr_cl   => ddr_mr_cl,
				ddr_mr_ods  => ddr_mr_ods);

		when DDR2 =>
			return ddr2_mrfile(
				ddr_mr_addr => ddr_mr_addr,
				ddr_mr_srt  => ddr_mr_srt,
				ddr_mr_bl   => ddr_mr_bl,
				ddr_mr_bt   => ddr_mr_bt,
				ddr_mr_cl   => ddr_mr_cl,
				ddr_mr_wr   => ddr_mr_wr,
				ddr_mr_ods  => ddr_mr_ods,
				ddr_mr_rtt  => ddr_mr_rtt,
				ddr_mr_al   => ddr_mr_al,
				ddr_mr_ocd  => ddr_mr_ocd,
				ddr_mr_tdqs => ddr_mr_tdqs,
				ddr_mr_rdqs => ddr_mr_rdqs);

		when others =>
			return ddr3_mrfile(
				ddr_mr_addr  => ddr_mr_addr,
				ddr_mr_srt   => ddr_mr_srt,
				ddr_mr_bl    => ddr_mr_bl,
				ddr_mr_bt    => ddr_mr_bt,
				ddr_mr_cl    => ddr_mr_cl,
				ddr_mr_wr    => ddr_mr_wr,
				ddr_mr_ods   => ddr_mr_ods,
				ddr_mr_rtt   => ddr_mr_rtt,
				ddr_mr_al    => ddr_mr_al,
				ddr_mr_qoff  => ddr_mr_qoff,
				ddr_mr_tdqs  => ddr_mr_tdqs,
				ddr_mr_drtt  => ddr_mr_drtt,
				ddr_mr_mprrf => ddr_mr_mprrf,
				ddr_mr_mpr   => ddr_mr_mpr,
				ddr_mr_asr   => ddr_mr_asr,
				ddr_mr_pd    => ddr_mr_pd,
				ddr_mr_cwl   => ddr_mr_cwl);
		end case;
	end;

end package body;
