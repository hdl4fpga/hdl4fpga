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

	type ddr3_ccmd is record
		cmd  : std_logic_vector( 3 downto 0);
		bank : std_logic_vector( 2 downto 0);
		addr : natural_vector(13 downto 0);
	end record;

	subtype ddrmr_id is std_logic_vector(3-1 downto 0);
	constant ddr_mrx : ddrmr_id := (others => '1');
	constant ddr_mr0 : ddrmr_id := "000";
	constant ddr_mr1 : ddrmr_id := "001";
	constant ddr_mr2 : ddrmr_id := "010";
	constant ddr_mr3 : ddrmr_id := "011";

	subtype ddrmr_addr is std_logic_vector(3-1 downto 0);
	constant ddr2mr_mrx     : ddrmr_addr := (others => '1');
	constant ddr2mr_setemr2 : ddrmr_addr := "001";
	constant ddr2mr_setemr3 : ddrmr_addr := "110";
	constant ddr2mr_enadll  : ddrmr_addr := "111";
	constant ddr2mr_rstdll  : ddrmr_addr := "101";
	constant ddr2mr_preall  : ddrmr_addr := "100";
	constant ddr2mr_setmr   : ddrmr_addr := "000";
	constant ddr2mr_seteOCD : ddrmr_addr := "010";
	constant ddr2mr_setdOCD : ddrmr_addr := "011";

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

	constant TMR_RST : natural := 0;

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

	-- DDR init

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

	function ddr_timers (
		constant tCP  : natural;
		constant mark : natural;
		constant gear : natural := 2)
		return natural_vector  is
		constant stdr : natural := xdr_stdr(mark);

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
		if stdr=DDR1 then
			return ddr2_timer;
		elsif stdr=DDR2 then
			return ddr2_timer;
		elsif stdr=DDR3 then
			return ddr3_timer;
		end if;
		return natural_vector'(1 to 0 => 0);
	end;
		
end package body;
