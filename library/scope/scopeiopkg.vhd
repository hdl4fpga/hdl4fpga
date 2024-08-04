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

use std.textio;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.videopkg.all;

package scopeiopkg is

	constant max_pixelsize : natural := 24;

	constant vtaxis_boxid : natural := 0;
	constant grid_boxid   : natural := 1;
	constant text_boxid   : natural := 2;
	constant hzaxis_boxid : natural := 3;

	constant rid_ipaddr   : std_logic_vector := x"1f";
	constant rid_hzaxis   : std_logic_vector := x"10";
	constant rid_palette  : std_logic_vector := x"11";
	constant rid_trigger  : std_logic_vector := x"12";
	constant rid_gain     : std_logic_vector := x"13";
	constant rid_vtaxis   : std_logic_vector := x"14";
	constant rid_focus    : std_logic_vector := x"15";
	constant rid_dmaaddr  : std_logic_vector := x"16";
	constant rid_dmalen   : std_logic_vector := x"17";
	constant rid_dmadata  : std_logic_vector := x"18";

	constant pltid_gridfg    : natural :=  0;
	constant pltid_gridbg    : natural :=  6;
	constant pltid_vtfg      : natural :=  1;
	constant pltid_vtbg      : natural :=  2;
	constant pltid_hzfg      : natural :=  3;
	constant pltid_hzbg      : natural :=  4;
	constant pltid_textfg    : natural :=  9;
	constant pltid_textbg    : natural :=  5;
	constant pltid_sgmntbg   : natural :=  7;
	constant pltid_scopeiobg : natural :=  8;

	constant pltid_order : natural_vector := (
		0 => pltid_vtfg,
		1 => pltid_hzfg,
		2 => pltid_textfg,      
		3 => pltid_gridfg,
		4 => pltid_vtbg,
		5 => pltid_hzbg,
		6 => pltid_textbg,      
		7 => pltid_gridbg,
		8 => pltid_sgmntbg,
		9 => pltid_scopeiobg);

	constant max_inputs     : natural := 32-pltid_order'length;
	constant maxinputs_bits : natural := unsigned_num_bits(max_inputs-1);
	constant chanid_maxsize : natural := unsigned_num_bits(max_inputs-1);

	function bitfield (
		constant bf_rgtr   : std_logic_vector;
		constant bf_id     : natural;
		constant bf_dscptr : natural_vector)
		return   std_logic_vector;

	constant ip4num1_id : natural := 3;
	constant ip4num2_id : natural := 2;
	constant ip4num3_id : natural := 1;
	constant ip4num4_id : natural := 0;

	constant ip4addr_bf : natural_vector := (
		ip4num1_id => 8,
		ip4num2_id => 8,
		ip4num3_id => 8,
		ip4num4_id => 8);

	constant vtoffset_maxsize : natural := 13;
	constant vtoffset_id : natural := 0;
	constant vtchanid_id : natural := 1;
	constant vtoffset_bf : natural_vector := (
		vtoffset_id => vtoffset_maxsize, 
		vtchanid_id => chanid_maxsize);

	constant hzoffset_maxsize : natural := 16;
	constant hzscale_maxsize  : natural :=  4;

	constant hzoffset_id : natural := 0;
	constant hzscale_id  : natural := 1;
	constant hzoffset_bf : natural_vector := (
		hzoffset_id => hzoffset_maxsize, 
		hzscale_id  => hzscale_maxsize);

	constant paletteid_maxsize    : natural := unsigned_num_bits(max_inputs+pltid_order'length-1);
	constant palettecolor_maxsize : natural := 24;

	constant paletteopacityena_id : natural := 0;
	constant palettecolorena_id   : natural := 1;
	constant paletteopacity_id    : natural := 2;
	constant paletteid_id         : natural := 3;
	constant palettecolor_id      : natural := 4;

	constant palette_bf : natural_vector := (
		paletteopacityena_id => 1, 
		palettecolorena_id   => 1, 
		paletteopacity_id    => 1, 
		paletteid_id         => paletteid_maxsize, 
		palettecolor_id      => palettecolor_maxsize);

	constant trigger_freeze_id  : natural := 0;
	constant trigger_slope_id   : natural := 1;
	constant trigger_oneshot_id : natural := 2;
	constant trigger_level_id   : natural := 3;
	constant trigger_chanid_id  : natural := 4;

	constant triggerlevel_maxsize : natural := 9;
	constant trigger_bf : natural_vector := (
		trigger_freeze_id  => 1,
		trigger_slope_id   => 1,
		trigger_oneshot_id => 1,
		trigger_level_id   => triggerlevel_maxsize,
		trigger_chanid_id  => chanid_maxsize);

	constant gainid_maxsize : natural := 4;

	constant gainid_id      : natural := 0;
	constant gainchanid_id  : natural := 1;
	constant gain_bf : natural_vector := (
		gainid_id     => gainid_maxsize,
		gainchanid_id => chanid_maxsize);

	constant focus_maxsize : natural := 11;
	constant focus_id      : natural := 0;

	constant focus_bf : natural_vector := (
		focus_id => focus_maxsize);

	component scopeio_tds
		generic (
			inputs           : natural;
			time_factors     : natural_vector;
			storageword_size : natural);
		port (
			rgtr_clk         : in  std_logic;
			rgtr_dv          : in  std_logic;
			rgtr_id          : in  std_logic_vector(8-1 downto 0);
			rgtr_data        : in  std_logic_vector;

			input_clk        : in  std_logic;
			input_dv         : in  std_logic;
			input_data       : in  std_logic_vector;
			time_scale       : in  std_logic_vector;
			time_offset      : in  std_logic_vector;
			trigger_freeze   : buffer std_logic;
			video_clk        : in  std_logic;
			video_vton       : in  std_logic;
			video_frm        : in  std_logic;
			video_addr       : in  std_logic_vector;
			video_dv         : out std_logic;
			video_data       : out std_logic_vector);
	end component;

	constant var_hzdivid      : natural := 0;
	constant var_hzunitid     : natural := 1;
	constant var_hzoffsetid   : natural := 2;
	constant var_tgrlevelid   : natural := 3;
	constant var_tgrfreezeid  : natural := 4;
	constant var_tgrunitid    : natural := 5;
	constant var_tgredgeid    : natural := 6;
	constant var_vtunitid     : natural := 7;
	constant var_vtoffsetid   : natural := 8;

	function significand (
		constant unit  : real;
		constant debug : boolean := false)
		return string;

	function get_significand1245 (
		constant unit  : real;
		constant debug : boolean := false)
		return natural_vector;

	function get_shr1245 (
		constant unit : real)
		return integer_vector;

	function get_characteristic1245 (
		constant unit : real)
		return integer_vector;

	function get_prefix1235 (
		constant unit : real)
		return string;

	function replace (
		constant word : std_logic_vector;
		constant addr : std_logic_vector;
		constant data : std_logic_vector)
		return std_logic_vector;
end;

package body scopeiopkg is

	function significand (
		constant unit  : real;
		constant debug : boolean := false)
		return string is
		constant tenth   : real := 1.0/10.0;
		constant prefixes: string := " munp";
		variable prefix  : integer;
		variable pfxdec  : integer;
		variable exp10   : integer;
		variable dec10   : integer;
		variable pow10   : real;
		variable sgfc    : real;
		variable unt     : real;
		variable shr     : integer;
		variable pnt     : integer;
		variable rnd     : natural; --Lattice Diamond fix

	begin
		assert unit > 0.0 
			report "unit <= 0.0"
			severity failure;

		unt := unit;
		pfxdec := 1;
		while unt >= 1.0 loop
			unt := unt / 1.0e3;
			pfxdec := pfxdec - 1;
		end loop;

		dec10 := 0;
		pow10 := 1.0;
		sgfc  := unt;
		loop
			if abs(sgfc-round(sgfc)) > 4.0e-9 then
				dec10 := dec10 + 1;
				sgfc  := sgfc  / tenth;
			else
				exit;
			end if;
		end loop;

		exp10 := 0;
		pow10 := 1.0;
		while (1.0-unt) > 4.0e-9 loop
			exp10 := exp10 + 1;
			pow10 := pow10 * tenth;
			unt   := unt   / tenth;
		end loop;

		rnd := natural(round(sgfc)); --Lattice Diamond fix

		prefix := ((3-(exp10 mod 3)) mod 3)+exp10;
		shr    := -2+dec10-exp10;
		pnt    := dec10-prefix;
		-- report CR &
			-- "unit   => " & real'image(unit)      & CR &
			-- "sgfc   => " & integer'image(rnd)    & CR &
			-- "exp10  => " & integer'image(exp10)  & CR &
			-- "dec10  => " & integer'image(dec10)  & CR &
			-- "prefix => " & integer'image(prefix) & CR &
			-- "unit   => " & prefixes(prefix/3+pfxdec)    & CR &
			-- "shr    => " & integer'image(-2+dec10-exp10) & CR &
			-- "pnt    => " & integer'image(dec10-prefix);

		return compact(
			"{ sgfc:" & integer'image(rnd) & "," & 
			"  shr:"  & integer'image(shr) & "," & 
			"  pnt:"  & integer'image(pnt) & "," & 
			"  pfx:"  & '\' & prefixes(prefix/3+pfxdec) & "}");
	end;

	function get_significand1245 (
		constant unit  : real;
		constant debug : boolean := false)
		return natural_vector is
		constant coefs  : real_vector(0 to 4-1) := (1.0, 2.0, 4.0, 5.0);
		variable retval : natural_vector(0 to 4-1);
	begin

		for i in coefs'range loop
			retval(i) := hdo(significand(unit*coefs(i), debug))**".sgfc";
		end loop;
		assert not debug
		report "here"
		severity failure;
		return retval;
	end;

	function get_shr1245 (
		constant unit   : real)
		return integer_vector is
		constant coefs  : real_vector(0 to 4-1) := (1.0, 2.0, 4.0, 5.0);
		variable unit1245 : real;
		variable retval : integer_vector(0 to 4*4-1);
	begin

		unit1245 := unit;
		for i in 0 to 4-1 loop
			for j in coefs'range loop
				retval(4*i+j) := hdo(significand(unit1245*coefs(j)))**".shr";
			end loop;
			unit1245 := unit1245 * 10.0;
		end loop;
		return retval;
	end;

	function get_characteristic1245 (
		constant unit   : real)
		return integer_vector is
		constant coefs  : real_vector(0 to 4-1) := (1.0, 2.0, 4.0, 5.0);
		variable unit1245 : real;
		variable retval : integer_vector(0 to 4*4-1);
	begin
		unit1245 := unit;
		for i in 0 to 4-1 loop
			for j in coefs'range loop
				retval(4*i+j) := hdo(significand(unit1245*coefs(j)))**".pnt";
			end loop;
			unit1245 := unit1245 * 10.0;
		end loop;
		return retval;
	end;

	function get_prefix1235 (
		constant unit : real)
		return string is
		constant coefs  : real_vector(0 to 4-1) := (1.0, 2.0, 4.0, 5.0);
		variable unit1245 : real;
		variable retval : string (1 to 4*4);
	begin
		unit1245 := unit;
		for i in 0 to 4-1 loop
			for j in coefs'range loop
				retval(4*i+j+1) := hdo(significand(unit1245*coefs(j)))**".pfx";
			end loop;
			unit1245 := unit1245 * 10.0;
		end loop;
		return retval;
	end;

	function bitfield (
		constant bf_rgtr   : std_logic_vector;
		constant bf_id     : natural;
		constant bf_dscptr : natural_vector)
		return   std_logic_vector is
		variable retval : unsigned(bf_rgtr'length-1 downto 0);
		variable dscptr : natural_vector(0 to bf_dscptr'length-1);
	begin
		dscptr := bf_dscptr;
		retval := unsigned(bf_rgtr);
		if bf_rgtr'left > bf_rgtr'right then
			for i in bf_dscptr'range loop
				if i=bf_id then
					return std_logic_vector(retval(bf_dscptr(i)-1 downto 0));
				end if;
				retval := retval ror bf_dscptr(i);
			end loop;
		else
			for i in bf_dscptr'range loop
				retval := retval rol bf_dscptr(i);
				if i=bf_id then
					return std_logic_vector(retval(bf_dscptr(i)-1 downto 0));
				end if;
			end loop;
		end if;
		return (0 to 0 => '-');
	end;

	function replace (
		constant word : std_logic_vector;
		constant addr : std_logic_vector;
		constant data : std_logic_vector)
		return std_logic_vector is
		variable retval : unsigned(0 to data'length*((word'length+data'length-1)/data'length)-1);
		-- constant xxx : natural := retval'length/data'length;
	begin
		assert word'length mod data'length=0
		report "replace"
		severity failure;
		retval(0 to word'length-1) := unsigned(word);
		-- retval(xxx*to_integer(unsigned(addr) to xxx*to_integer(unsigned(addr)-1)))= unsigned(data);
		for i in 0 to retval'length/data'length-1 loop
			if to_unsigned(i,addr'length)=unsigned(addr) then
				retval(0 to data'length-1) := unsigned(data);
			end if;
			retval := retval rol data'length;
		end loop;
		return std_logic_vector(retval(0 to word'length-1));
	end;

end;
