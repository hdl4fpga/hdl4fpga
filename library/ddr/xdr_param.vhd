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
use hdl4fpga.xdr_db.all;

package xdr_param is

	subtype ddrmr_id is std_logic_vector(3-1 downto 0);
	constant ddr_mrx : ddrmr_id := (others => '1');
	constant ddr_mr0 : ddrmr_id := "000";
	constant ddr_mr1 : ddrmr_id := "001";
	constant ddr_mr2 : ddrmr_id := "010";
	constant ddr_mr3 : ddrmr_id := "011";

	subtype ddrmr_addr is std_logic_vector(3-1 downto 0);

	constant ddrmr_mrx     : ddrmr_addr := (others => '1');

	constant ddr1mr_setemr  : ddrmr_addr := "000";
	constant ddr1mr_enadll  : ddrmr_addr := "001";
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
		wlr		: std_logic;
		wlq		: std_logic;
		odt     : std_logic;
	end record;

	type s_row is record
		state   : s_code;
		state_n : s_code;
		mask    : std_logic_vector(0 to 1-1);
		input   : std_logic_vector(0 to 1-1);
		output  : std_logic_vector(0 to 6-1);
		cmd     : ddr_cmd;
		mr      : ddrmr_addr;
		bnk     : ddrmr_id;
		tid     : unsigned(TMR_SIZE-1 downto 0);
	end record;

	type s_table is array (natural range <>) of s_row;

	constant sc_rst  : s_code := "0000";
	constant sc_ref  : s_code := "1000";

	function to_sout (
		constant output : std_logic_vector(0 to 6-1))
		return s_out;

	impure function choose_pgm (
		constant xdr_stdr : natural)
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

	function xdr_rotval (
		constant line_size : natural;
		constant word_size : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector)
		return std_logic_vector;

	function xdr_task (
		constant clk_phases : natural;
		constant gear : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector;
		constant lat_sch : std_logic_vector;
		constant lat_ext : natural := 0;
		constant lat_wid : natural := 1)
		return std_logic_vector;

	function ddr_mrfile(
		constant xdr_stdr : natural;
		constant xdr_mr_addr : std_logic_vector;
		constant xdr_mr_srt  : std_logic_vector;
		constant xdr_mr_bl   : std_logic_vector;
		constant xdr_mr_bt   : std_logic_vector;
		constant xdr_mr_cl   : std_logic_vector;
		constant xdr_mr_wr   : std_logic_vector;
		constant xdr_mr_ods  : std_logic_vector;
		constant xdr_mr_rtt  : std_logic_vector;
		constant xdr_mr_al   : std_logic_vector;
		constant xdr_mr_ocd  : std_logic_vector;
		constant xdr_mr_tdqs : std_logic_vector;
		constant xdr_mr_rdqs : std_logic_vector;
		constant xdr_mr_wl   : std_logic_vector;
		constant xdr_mr_qoff : std_logic_vector;
		constant xdr_mr_drtt : std_logic_vector;
		constant xdr_mr_mprrf : std_logic_vector;
		constant xdr_mr_mpr  : std_logic_vector;
		constant xdr_mr_zqc  : std_logic_vector;
		constant xdr_mr_asr  : std_logic_vector;
		constant xdr_mr_pd   : std_logic_vector;
		constant xdr_mr_cwl  : std_logic_vector)
		return std_logic_vector;

end package;

library hdl4fpga;
use hdl4fpga.std.all;

package body xdr_param is

	function xdr_rotval (
		constant line_size : natural;
		constant word_size : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector)
		return std_logic_vector is

		subtype word is std_logic_vector(unsigned_num_bits(line_size/word_size-1)-1 downto 0);
		type word_vector is array(natural range <>) of word;
		
		subtype latword is std_logic_vector(0 to lat_val'length-1);
		type latword_vector is array (natural range <>) of latword;

		constant algn : natural := unsigned_num_bits(word_size-1);
		
		function to_latwordvector(
			constant arg : std_logic_vector)
			return latword_vector is
			variable aux : std_logic_vector(0 to arg'length-1) := arg;
			variable val : latword_vector(0 to arg'length/latword'length-1);
		begin
			for i in val'range loop
				val(i) := aux(latword'range);
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
		variable val : std_logic_vector(unsigned_num_bits(line_size-1)-1 downto 0) := (others => '0');
		variable disp : natural;

	begin

		setup_l : for i in 0 to lat_tab'length-1 loop
			sel_sch(i) := to_unsigned(lat_tab(i) mod (line_size/word_size), word'length);
		end loop;
		
		val(word'range) := select_lat(lat_val, lc, sel_sch);
		val := std_logic_vector'(unsigned(val) sll algn);
		return val;
	end;

	function xdr_task (
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
			variable aux : std_logic_vector(0 to arg'length-1) := arg;
			variable val : latword_vector(0 to arg'length/latword'length-1);
		begin
			for i in val'range loop
				val(i) := aux(latword'range);
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
				word_size => word'length,
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

	constant ddr1_pgm : s_table := (
		(sc_rst,   sc1_cke,  "0", "0", "110000", ddr_nop, ddrmr_mrx,     ddr_mrx, to_unsigned(TMR1_CKE, TMR_SIZE)), 
		(sc1_cke,  sc1_pre1, "0", "0", "110000", ddr_pre, ddr1mr_preall, ddr_mrx, to_unsigned(TMR1_RPA, TMR_SIZE)), 
		(sc1_pre1, sc1_lm1,  "0", "0", "110000", ddr_mrs, ddr1mr_setemr, ddr_mr1, to_unsigned(TMR1_MRD, TMR_SIZE)), 
		(sc1_lm1,  sc1_lm2,  "0", "0", "110000", ddr_mrs, ddr1mr_rstdll, ddr_mr0, to_unsigned(TMR1_MRD, TMR_SIZE)), 
		(sc1_lm2,  sc1_pre2, "0", "0", "110000", ddr_pre, ddr1mr_preall, ddr_mrx, to_unsigned(TMR1_RPA, TMR_SIZE)), 
		(sc1_pre2, sc1_ref1, "0", "0", "110001", ddr_ref, ddrmr_mrx,     ddr_mrx, to_unsigned(TMR1_RFC, TMR_SIZE)), 
		(sc1_ref1, sc1_ref2, "0", "0", "110001", ddr_ref, ddrmr_mrx,     ddr_mrx, to_unsigned(TMR1_RFC, TMR_SIZE)), 
		(sc1_ref2, sc1_lm3,  "0", "0", "110011", ddr_mrs, ddr1mr_setmr,  ddr_mr0, to_unsigned(TMR1_MRD, TMR_SIZE)),  
		(sc1_lm3,  sc_ref,   "0", "0", "111100", ddr_nop, ddrmr_mrx,     ddr_mrx, to_unsigned(TMR1_REF, TMR_SIZE)),  
		(sc_ref,   sc_ref,   "0", "0", "111100", ddr_nop, ddrmr_mrx,     ddr_mrx, to_unsigned(TMR1_REF, TMR_SIZE)));

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


	                            --    +------< rst
	                            --    |+-----< cke
	                            --    ||+----< rdy
	                            --    |||+---< wlq
	                            --    ||||+--< wlr
	                            --    |||||+-< odt
	                            --    ||||||
                                --    vvvvvv
	constant ddr2_pgm : s_table := (
		(sc_rst,   sc2_cke,  "0", "0", "110000", ddr_nop, ddrmr_mrx,      ddr_mrx, to_unsigned(TMR2_CKE, TMR_SIZE)), 
		(sc2_cke,  sc2_pre1, "0", "0", "110000", ddr_pre, ddr2mr_preall,  ddr_mrx, to_unsigned(TMR2_RPA, TMR_SIZE)), 
		(sc2_pre1, sc2_lm1,  "0", "0", "110000", ddr_mrs, ddr2mr_setemr2, ddr_mr2, to_unsigned(TMR2_MRD, TMR_SIZE)), 
		(sc2_lm1,  sc2_lm2,  "0", "0", "110000", ddr_mrs, ddr2mr_setemr3, ddr_mr3, to_unsigned(TMR2_MRD, TMR_SIZE)), 
		(sc2_lm2,  sc2_lm3,  "0", "0", "110000", ddr_mrs, ddr2mr_enadll,  ddr_mr1, to_unsigned(TMR2_MRD, TMR_SIZE)), 
		(sc2_lm3,  sc2_lm4,  "0", "0", "110000", ddr_mrs, ddr2mr_rstdll,  ddr_mr0, to_unsigned(TMR2_MRD, TMR_SIZE)), 
		(sc2_lm4,  sc2_pre2, "0", "0", "110000", ddr_pre, ddr2mr_preall,  ddr_mrx, to_unsigned(TMR2_RPA, TMR_SIZE)),
		(sc2_pre2, sc2_ref1, "0", "0", "110001", ddr_ref, ddrmr_mrx,      ddr_mrx, to_unsigned(TMR2_RFC, TMR_SIZE)), 
		(sc2_ref1, sc2_ref2, "0", "0", "110001", ddr_ref, ddrmr_mrx,      ddr_mrx, to_unsigned(TMR2_RFC, TMR_SIZE)), 
		(sc2_ref2, sc2_lm5,  "0", "0", "110011", ddr_mrs, ddr2mr_setmr,   ddr_mr0, to_unsigned(TMR2_MRD, TMR_SIZE)),  
		(sc2_lm5,  sc2_lm6,  "0", "0", "110111", ddr_mrs, ddr2mr_seteOCD, ddr_mr1, to_unsigned(TMR2_MRD, TMR_SIZE)),  
		(sc2_lm6,  sc2_lm7,  "0", "0", "110111", ddr_mrs, ddr2mr_setdOCD, ddr_mr1, to_unsigned(TMR2_MRD, TMR_SIZE)),  
		(sc2_lm7,  sc_ref,   "0", "0", "111100", ddr_nop, ddrmr_mrx,      ddr_mrx, to_unsigned(TMR2_REF, TMR_SIZE)),  
		(sc_ref,   sc_ref,   "0", "0", "111100", ddr_nop, ddrmr_mrx,      ddr_mrx, to_unsigned(TMR2_REF, TMR_SIZE)));

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
 
 	constant ddr3_pgm : s_table := (
 		(sc_rst,   sc3_rrdy, "0", "0", "100000", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR3_RRDY, TMR_SIZE)),
 		(sc3_rrdy, sc3_cke,  "0", "0", "110000", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR3_CKE, TMR_SIZE)), 
 		(sc3_cke,  sc3_lmr2, "0", "0", "110000", ddr_mrs, ddr3mr_setmr2, ddr_mr2, to_unsigned(TMR3_MRD, TMR_SIZE)), 
 		(sc3_lmr2, sc3_lmr3, "0", "0", "110000", ddr_mrs, ddr3mr_setmr3, ddr_mr3, to_unsigned(TMR3_MRD, TMR_SIZE)), 
 		(sc3_lmr3, sc3_lmr1, "0", "0", "110000", ddr_mrs, ddr3mr_setmr1, ddr_mr1, to_unsigned(TMR3_MRD, TMR_SIZE)), 
 		(sc3_lmr1, sc3_lmr0, "0", "0", "110000", ddr_mrs, ddr3mr_setmr0, ddr_mr0, to_unsigned(TMR3_MOD, TMR_SIZE)), 
 		(sc3_lmr0, sc3_zqi,  "0", "0", "110000", ddr_zqc, ddr3mr_zqc, ddr_mrx,    to_unsigned(TMR3_ZQINIT, TMR_SIZE)),
 		(sc3_zqi,  sc3_wle,  "0", "0", "110001", ddr_mrs, ddr3mr_setmr1, ddr_mr1, to_unsigned(TMR3_MOD, TMR_SIZE)), 
 		(sc3_wle,  sc3_wls,  "0", "0", "110011", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR3_WLDQSEN, TMR_SIZE)),  
 		(sc3_wls,  sc3_wlc,  "0", "0", "110111", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR3_WLC, TMR_SIZE)),  
 		(sc3_wlc,  sc3_wlc,  "1", "0", "110111", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR3_WLC, TMR_SIZE)),  
 		(sc3_wlc,  sc3_wlo,  "1", "1", "110100", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR3_MRD, TMR_SIZE)),  
 		(sc3_wlo,  sc3_wlf,  "0", "0", "110100", ddr_mrs, ddr3mr_setmr1, ddr_mr1, to_unsigned(TMR3_MOD, TMR_SIZE)),  
 		(sc3_wlf,  sc_ref,   "0", "0", "111100", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR3_REF, TMR_SIZE)),
 		(sc_ref,   sc_ref,   "0", "0", "111100", ddr_nop, ddrmr_mrx, ddr_mrx,     to_unsigned(TMR3_REF, TMR_SIZE)));
 
	function to_sout (
		constant output : std_logic_vector(0 to 6-1))
		return s_out is
	begin
		return (
			rst => output(0),
			cke => output(1),
			rdy => output(2),
			wlq => output(3),
			wlr => output(5),
			odt => output(4));
	end;

	impure function choose_pgm (
		constant xdr_stdr : natural)
		return s_table is
	begin
		case xdr_stdr is
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
		constant stdr : natural := xdr_stdr(mark);

		constant ddr1_timer : natural_vector := (
				TMR_RST  => to_xdrlatency(tCP, mark, tPreRST),
				TMR1_CKE => to_xdrlatency(tCP, mark, tXPR),
				TMR1_MRD => to_xdrlatency(tCP, mark, tMRD),
				TMR1_RPA => to_xdrlatency(tCP, mark, tRP),
				TMR1_RFC => to_xdrlatency(tCP, mark, tRFC),
				TMR1_DLL => to_xdrlatency(tCP, mark, tMRD),
				TMR1_REF => to_xdrlatency(tCP, mark, tREFI));

		constant ddr2_timer : natural_vector := (
				TMR_RST  => to_xdrlatency(tCP, mark, tPreRST),
				TMR2_CKE => to_xdrlatency(tCP, mark, tXPR),
				TMR2_MRD => xdr_latency(stdr, MRD),
				TMR2_RPA => to_xdrlatency(tCP, mark, tRPA),
				TMR2_RFC => to_xdrlatency(tCP, mark, tRFC),
				TMR2_DLL => xdr_latency(stdr, MRD),
				TMR2_REF => to_xdrlatency(tCP, mark, tREFI));

		constant ddr3_timer : natural_vector := (
				TMR_RST  => to_xdrlatency(tCP, mark, tPreRST),
				TMR3_RRDY => to_xdrlatency(tCP, mark, tPstRST),
				TMR3_WLC => xdr_latency(stdr, MODu),
				TMR3_WLDQSEN => 25,
				TMR3_CKE => to_xdrlatency(tCP, mark, tXPR),
				TMR3_MRD => to_xdrlatency(tCP, mark, tMRD),
				TMR3_MOD => xdr_latency(stdr, MODu),
				TMR3_DLL => xdr_latency(stdr, cDLL),
				TMR3_ZQINIT => xdr_latency(DDR3, ZQINIT),
				TMR3_REF => to_xdrlatency(tCP, mark, tREFI));
	begin
		case stdr is 
		when DDR1 =>
			return ddr1_timer;
		when DDR2 =>
			return ddr2_timer;
		when others =>
			return ddr3_timer;
		end case;
		return natural_vector'(1 to 0 => 0);
	end;
		
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

	type ddr3_ccmd is record
		cmd  : std_logic_vector( 3 downto 0);
		bank : std_logic_vector( 2 downto 0);
		addr : natural_vector(13 downto 0);
	end record;

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

	constant xdr_a_max : natural := 16;

	function mr_field (
		constant mask : fd_vector;
		constant src  : std_logic_vector)
		return std_logic_vector is
	begin
		return mr_field(mask, src, xdr_a_max);
	end;

	type mr_row is record
		mr   : ddrmr_addr;
		data : std_logic_vector(xdr_a_max-1 downto 0);
	end record;

	type mr_vector is array (natural range <>) of mr_row;

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

	function ddrmr_data (
		constant mr_file : mr_vector;
		constant mr_addr : std_logic_vector)
		return std_logic_vector is
	begin
		for i in mr_file'range loop
			if mr_addr=mr_file(i).mr then
				return mr_file(i).data;
			end if;
		end loop;
		return (0 to xdr_a_max-1 => '0');
	end;

	function ddr1_mrfile (
		constant xdr_mr_addr : std_logic_vector;
		constant xdr_mr_bl   : std_logic_vector;
		constant xdr_mr_bt   : std_logic_vector;
		constant xdr_mr_cl   : std_logic_vector;
		constant xdr_mr_ods  : std_logic_vector)
		return std_logic_vector is
		variable mr_file : mr_vector(0 to 4-1);
	begin
		mr_file := (
			(mr   => ddr2mr_enadll, 
			 data => (
				mr_field(mask => ddr2_edll, src => "0") or
				mr_field(mask => ddr2_ods,  src => xdr_mr_ods))),

			(mr   => ddr2mr_rstdll, 
			 data => (
				mr_field(mask => ddr2_bl,   src => xdr_mr_bl) or
				mr_field(mask => ddr2_bt,   src => xdr_mr_bt) or
				mr_field(mask => ddr2_cl,   src => xdr_mr_cl) or
				mr_field(mask => ddr2_rdll, src => "1"))),

			(mr   => ddr2mr_setmr, 
			 data => (
				mr_field(mask => ddr2_bl,   src => xdr_mr_bl) or
				mr_field(mask => ddr2_bt,   src => xdr_mr_bt) or
				mr_field(mask => ddr2_cl,   src => xdr_mr_cl) or
				mr_field(mask => ddr2_rdll, src => "0"))),

			(mr   => ddr2mr_preall, 
			 data => (
				mr_field(mask => ddr2_preall, src => "1"))));

		return ddrmr_data(
			mr_addr => xdr_mr_addr,
			mr_file => mr_file);
	end;

	function ddr2_mrfile (
		constant xdr_mr_addr : std_logic_vector;
		constant xdr_mr_srt  : std_logic_vector;
		constant xdr_mr_bl   : std_logic_vector;
		constant xdr_mr_bt   : std_logic_vector;
		constant xdr_mr_cl   : std_logic_vector;
		constant xdr_mr_wr   : std_logic_vector;
		constant xdr_mr_ods  : std_logic_vector;
		constant xdr_mr_rtt  : std_logic_vector;
		constant xdr_mr_al   : std_logic_vector;
		constant xdr_mr_ocd  : std_logic_vector;
		constant xdr_mr_tdqs : std_logic_vector;
		constant xdr_mr_rdqs : std_logic_vector;
		constant xdr_mr_wl   : std_logic_vector)
		return std_logic_vector is
		variable mr_file : mr_vector(0 to 8-1);
	begin
		mr_file := (
			(mr   => ddr2mr_setemr2, 
			 data => (
			 	mr_field(mask => ddr2_srt, src => xdr_mr_srt))),

			(mr   => ddr2mr_setemr3, 
			 data => (others => '0')),
			(mr   => ddr2mr_rstdll, 
			 data => (
				mr_field(mask => ddr2_rdll, src => "1"))),
			(mr   => ddr2mr_enadll, 
			 data => (
				mr_field(mask => ddr2_edll, src => "0"))),

			(mr   => ddr2mr_setmr, 
			 data => (
				mr_field(mask => ddr2_bl,   src => xdr_mr_bl) or
				mr_field(mask => ddr2_bt,   src => xdr_mr_bt) or
				mr_field(mask => ddr2_cl,   src => xdr_mr_cl) or
				mr_field(mask => ddr2_wr,   src => xdr_mr_wr) or
				mr_field(mask => ddr2_rdll, src => "0"))),
			(mr   => ddr2mr_seteOCD, 
			 data => (
				mr_field(mask => ddr2_edll, src => "0") or
				mr_field(mask => ddr2_ods,  src => xdr_mr_ods)  or
				mr_field(mask => ddr2_rtt,  src => xdr_mr_rtt)  or
				mr_field(mask => ddr2_al,   src => xdr_mr_al)   or
				mr_field(mask => ddr2_ocd,  src => xdr_mr_ocd)  or
				mr_field(mask => ddr2_ddqs, src => xdr_mr_tdqs) or
				mr_field(mask => ddr2_rdqs, src => xdr_mr_rdqs) or
				mr_field(mask => ddr2_out,  src => "0"))),
			(mr   => ddr2mr_setdOCD, 
			 data => (
				mr_field(mask => ddr2_edll, src => "0") or
				mr_field(mask => ddr2_ods,  src => xdr_mr_ods)  or
				mr_field(mask => ddr2_rtt,  src => xdr_mr_rtt)  or
				mr_field(mask => ddr2_al,   src => xdr_mr_al)   or
				mr_field(mask => ddr2_ocd,  src => "000")  or
				mr_field(mask => ddr2_ddqs, src => xdr_mr_tdqs) or
				mr_field(mask => ddr2_rdqs, src => xdr_mr_rdqs) or
				mr_field(mask => ddr2_out,  src => "0"))),
			(mr   => ddr2mr_preall, 
			 data => (
				mr_field(mask => ddr2_preall, src => "1"))));

		return ddrmr_data(
			mr_addr => xdr_mr_addr,
			mr_file => mr_file);
	end;

	function ddr3_mrfile (
		constant xdr_mr_addr : std_logic_vector;
		constant xdr_mr_srt  : std_logic_vector;
		constant xdr_mr_bl   : std_logic_vector;
		constant xdr_mr_bt   : std_logic_vector;
		constant xdr_mr_cl   : std_logic_vector;
		constant xdr_mr_wr   : std_logic_vector;
		constant xdr_mr_ods  : std_logic_vector;
		constant xdr_mr_rtt  : std_logic_vector;
		constant xdr_mr_al   : std_logic_vector;
		constant xdr_mr_tdqs : std_logic_vector;
		constant xdr_mr_wl   : std_logic_vector;
		constant xdr_mr_qoff : std_logic_vector;
		constant xdr_mr_drtt : std_logic_vector;
		constant xdr_mr_mprrf : std_logic_vector;
		constant xdr_mr_mpr  : std_logic_vector;
		constant xdr_mr_zqc  : std_logic_vector;
		constant xdr_mr_asr  : std_logic_vector;
		constant xdr_mr_pd   : std_logic_vector;
		constant xdr_mr_cwl  : std_logic_vector)
		return std_logic_vector is
		variable mr_file : mr_vector(0 to 5-1);
	begin
		mr_file := (
			(mr   => ddr3mr_setmr0,
			 data => (
				mr_field(mask => ddr3_bl, src => xdr_mr_bl) or
				mr_field(mask => ddr3_bt, src => xdr_mr_bt) or
				mr_field(mask => ddr3_cl, src => xdr_mr_cl) or
				mr_field(mask => ddr3_pd, src => xdr_mr_pd) or
				mr_field(mask => ddr3_rdll, src => "1") or
				mr_field(mask => ddr3_wr, src => xdr_mr_wr))),
			(mr   => ddr3mr_setmr1,
			 data => (
				mr_field(mask => ddr3_al,   src => xdr_mr_al) or
				mr_field(mask => ddr3_edll, src => "0") or
				mr_field(mask => ddr3_ods,  src => xdr_mr_ods) or
				mr_field(mask => ddr3_qoff, src => xdr_mr_qoff) or
				mr_field(mask => ddr3_rtt,  src => xdr_mr_rtt) or
				mr_field(mask => ddr3_tdqs, src => xdr_mr_tdqs) or
				mr_field(mask => ddr3_wl,   src => xdr_mr_wl))),

			(mr   => ddr3mr_setmr2,
			 data => (
				mr_field(mask => ddr3_asr,  src => xdr_mr_asr) or
				mr_field(mask => ddr3_cwl,  src => xdr_mr_cwl) or
				mr_field(mask => ddr3_drtt, src => xdr_mr_drtt) or
				mr_field(mask => ddr3_srt,  src => xdr_mr_srt))),

			(mr   => ddr3mr_setmr3,
			 data => (
				mr_field(mask => ddr3_mprrf, src => xdr_mr_mprrf) or
				mr_field(mask => ddr3_mpr,   src => xdr_mr_mpr))),

			(mr   => ddr3mr_zqc,
			 data => (
				mr_field(mask => ddr3_zqc,   src => xdr_mr_zqc))));

		return ddrmr_data (
			mr_addr => xdr_mr_addr,
			mr_file => mr_file);
	end;

	function ddr_mrfile(
		constant xdr_stdr : natural;

		constant xdr_mr_addr : std_logic_vector;
		constant xdr_mr_srt  : std_logic_vector;
		constant xdr_mr_bl   : std_logic_vector;
		constant xdr_mr_bt   : std_logic_vector;
		constant xdr_mr_cl   : std_logic_vector;
		constant xdr_mr_wr   : std_logic_vector;
		constant xdr_mr_ods  : std_logic_vector;
		constant xdr_mr_rtt  : std_logic_vector;
		constant xdr_mr_al   : std_logic_vector;
		constant xdr_mr_ocd  : std_logic_vector;
		constant xdr_mr_tdqs : std_logic_vector;
		constant xdr_mr_rdqs : std_logic_vector;
		constant xdr_mr_wl   : std_logic_vector;
		constant xdr_mr_qoff : std_logic_vector;
		constant xdr_mr_drtt : std_logic_vector;
		constant xdr_mr_mprrf : std_logic_vector;
		constant xdr_mr_mpr  : std_logic_vector;
		constant xdr_mr_zqc  : std_logic_vector;
		constant xdr_mr_asr  : std_logic_vector;
		constant xdr_mr_pd   : std_logic_vector;
		constant xdr_mr_cwl  : std_logic_vector)
		return std_logic_vector is
	begin
		case xdr_stdr is
		when DDR1 =>
			return ddr1_mrfile(
				xdr_mr_addr => xdr_mr_addr,
				xdr_mr_bl   => xdr_mr_bl,
				xdr_mr_bt   => xdr_mr_bt,
				xdr_mr_cl   => xdr_mr_cl,
				xdr_mr_ods  => xdr_mr_ods);

		when DDR2 =>
			return ddr2_mrfile(
				xdr_mr_addr => xdr_mr_addr,
				xdr_mr_srt  => xdr_mr_srt,
				xdr_mr_bl   => xdr_mr_bl,
				xdr_mr_bt   => xdr_mr_bt,
				xdr_mr_cl   => xdr_mr_cl,
				xdr_mr_wr   => xdr_mr_wr,
				xdr_mr_ods  => xdr_mr_ods,
				xdr_mr_rtt  => xdr_mr_rtt,
				xdr_mr_al   => xdr_mr_al,
				xdr_mr_ocd  => xdr_mr_ocd,
				xdr_mr_tdqs => xdr_mr_tdqs,
				xdr_mr_rdqs => xdr_mr_rdqs,
				xdr_mr_wl   => xdr_mr_wl);

		when others =>
			return ddr3_mrfile(
				xdr_mr_addr  => xdr_mr_addr,
				xdr_mr_srt   => xdr_mr_srt,
				xdr_mr_bl    => xdr_mr_bl,
				xdr_mr_bt    => xdr_mr_bt,
				xdr_mr_cl    => xdr_mr_cl,
				xdr_mr_wr    => xdr_mr_wr,
				xdr_mr_ods   => xdr_mr_ods,
				xdr_mr_rtt   => xdr_mr_rtt,
				xdr_mr_al    => xdr_mr_al,
				xdr_mr_qoff  => xdr_mr_qoff,
				xdr_mr_tdqs  => xdr_mr_tdqs,
				xdr_mr_drtt  => xdr_mr_drtt,
				xdr_mr_mprrf => xdr_mr_mprrf,
				xdr_mr_mpr   => xdr_mr_mpr,
				xdr_mr_zqc   => xdr_mr_zqc,
				xdr_mr_asr   => xdr_mr_asr,
				xdr_mr_pd    => xdr_mr_pd,
				xdr_mr_cwl   => xdr_mr_cwl,
				xdr_mr_wl    => xdr_mr_wl);
		end case;
		return (1 to 0 => '-');
	end;

end package body;
