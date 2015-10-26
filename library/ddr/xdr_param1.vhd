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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.xdr_db.all;

package xdr_param is
	component xdr_cfg is
		generic (
			cRP  : natural := 10;
			cMRD : natural := 11;
		    cRFC : natural := 13;
		    cMOD : natural := 13;

			a  : natural := 13;
			ba : natural := 2);
		port (
			xdr_cfg_ods : in  std_logic := '0';
			xdr_cfg_rtt : in  std_logic_vector(1 downto 0) := "01";
			xdr_cfg_bl  : in  std_logic_vector(0 to 2);
			xdr_cfg_cl  : in  std_logic_vector(0 to 2);
			xdr_cfg_wr  : in  std_logic_vector(0 to 2) := (others => '0');
			xdr_cfg_cwl : in  std_logic_vector(0 to 2) := (others => '0');
			xdr_cfg_pl  : in  std_logic_vector(0 to 2) := (others => '0');
			xdr_cfg_dqsn : in std_logic := '0';

			xdr_cfg_clk : in  std_logic;
			xdr_cfg_req : in  std_logic;
			xdr_cfg_rdy : out std_logic := '1';
			xdr_cfg_dll : out std_logic := '1';
			xdr_cfg_odt : out std_logic := '0';
			xdr_cfg_ras : out std_logic := '1';
			xdr_cfg_cas : out std_logic := '1';
			xdr_cfg_we  : out std_logic := '1';
			xdr_cfg_a   : out std_logic_vector( a-1 downto 0) := (others => '1');
			xdr_cfg_b   : out std_logic_vector(ba-1 downto 0) := (others => '1'));
	end component;

	type field_desc is record
		dbase : natural;
		sbase : natural;
		size  : natural;
	end record;

	type fielddesc_vector is array (natural range <>) of field_desc;

	function xdr_rotval (
		constant line_size : natural;
		constant word_size : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector)
		return std_logic_vector;

	function xdr_task (
		constant line_size : natural;
		constant word_size : natural;
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

	subtype ddr_mr is std_logic_vector(3-1 downto 0);
	constant mrx : ddr_mr := (others => '1');
	constant mr0 : ddr_mr := "000";
	constant mr1 : ddr_mr := "001";
	constant mr2 : ddr_mr := "010";
	constant mr3 : ddr_mr := "011";
	constant mrz : ddr_mr := "100";

	type ddrmr_vector is array (natural range <>) of ddr_mr;

	type ddr_cmd is record
		cs  : std_logic;
		ras : std_logic;
		cas : std_logic;
		we  : std_logic;
	end record;

	type ddr_tid is (TMR_RST, TMR_WLC, TMR_WLDQSEN, TMR_RRDY, TMR_CKE, TMR_MRD, TMR_MOD, TMR_DLL, TMR_ZQINIT, TMR_REF);
	type ddrtid_vector is array (ddr_tid) of natural;

	constant ddr_nop : ddr_cmd := (cs => '0', ras => '1', cas => '1', we => '1');
	constant ddr_mrs : ddr_cmd := (cs => '0', ras => '0', cas => '0', we => '0');
	constant ddr_zqc : ddr_cmd := (cs => '0', ras => '1', cas => '1', we => '0');

	function round_lat (
		constant dly : natural;
		constant clk : natural) 
		return natural;

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
		variable msg : line;

	begin

		setup_l : for i in 0 to lat_tab'length-1 loop
			sel_sch(i) := to_unsigned(lat_tab(i) mod (line_size/word_size), word'length);
		end loop;
		
		val(word'range) := select_lat(lat_val, lc, sel_sch);
		val := std_logic_vector'(unsigned(val) sll algn);
		return val;
	end;

	function xdr_task (
		constant line_size : natural;
		constant word_size : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector;
		constant lat_sch : std_logic_vector;
		constant lat_ext : natural := 0;
		constant lat_wid : natural := 1)
		return std_logic_vector is

		subtype word is std_logic_vector(0 to line_size/word_size-1);
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
				phase     => lat_sch,
				latency   => lat_tab(i),
				word_size => word'length,
				extension => lat_ext,
				width     => lat_wid);
		end loop;
		return select_lat(lat_val, lat_cod1, sel_sch);
	end;

	-- DDR init

	function mov (
		constant desc : field_desc)
		return natural_vector is
		variable tab : natural_vector(13 downto 0) := (others => 0);
	begin
		for j in 0 to desc.size-1 loop
			tab(desc.dbase+j) := desc.sbase+j;
		end loop;
		return tab;
	end function;

	function max (
		constant desc : fielddesc_vector)
		return natural is
		variable val : natural := 0;
	begin
		for i in desc'range loop
			if desc(i).dbase > val then
				val := desc(i).dbase;
			end if;
		end loop;
		return val;
	end;

	function min (
		constant desc : fielddesc_vector)
		return natural is
		variable val : natural := 0;
	begin
		for i in desc'range loop
			if desc(i).dbase < val then
				val := desc(i).dbase;
			end if;
		end loop;
		return val;
	end;

	function mov (
		constant desc : fielddesc_vector)
		return natural_vector is
		variable val : natural_vector(13 downto 0) := (others => 0);
		variable aux : natural_vector(val'range) := (others => 0);
		variable msg : line;
	begin
		for i in desc'range loop
			aux := mov(desc(i));
			for j in aux'range loop
				if aux(j) > 1 then
					val(j) := aux(j);
				end if;
			end loop;
		end loop;
		return val;
	end function;

	function round_lat (
		constant dly : natural;
		constant clk : natural) 
		return natural is
	begin
		return (dly+clk-1)/clk;
	end;

end package body;
