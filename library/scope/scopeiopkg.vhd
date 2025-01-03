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

	constant wid_time       : natural := 0;
	constant wid_trigger    : natural := 1;
	constant wid_tmposition : natural := 2;
	constant wid_tmscale    : natural := 3;
	constant wid_tgchannel  : natural := 4;
	constant wid_tgposition : natural := 5;
	constant wid_tgslope    : natural := 6;
	constant wid_tgmode     : natural := 7;
	constant wid_input      : natural := 8;
	constant wid_inposition : natural := 9;
	constant wid_inscale    : natural := 10;
	constant wid_static     : natural := wid_inscale;

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
		constant rgtr  : std_logic_vector;
		constant field : string)
		return std_logic;

	function bitfield (
		constant rgtr  : std_logic_vector;
		constant field : string)
		return   std_logic_vector;

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
	constant trigger_oneshot_id : natural := 1;
	constant trigger_slope_id   : natural := 2;
	constant trigger_level_id   : natural := 3;
	constant trigger_chanid_id  : natural := 4;

	constant trigger_fields : string := compact(
		"{" &
		"    freeze  : {offset :  0, length :  1}," &
		"    oneshot : {offset :  1, length :  1}," &
		"    slope   : {offset :  2, length :  1}," &
		"    level   : {offset :  3, length : 16}," &
		"    chanid  : {offset : 19, length : " & natural'image(chanid_maxsize) & "}"  &
		"}");

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
		constant unit : real)
		return string;

	function get_significand1245 (
		constant unit  : real)
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

	function max_textlength(
		constant labels : string;
		constant length : natural) 
		return natural;

	constant dflt_hzscale : string := compact( 
			"[" &
				natural'image(2**(0+0)*5**(0+0)) & "," & -- [0]
				natural'image(2**(1+0)*5**(0+0)) & "," & -- [1]
				natural'image(2**(2+0)*5**(0+0)) & "," & -- [2]
				natural'image(2**(0+0)*5**(1+0)) & "," & -- [3]
				natural'image(2**(0+1)*5**(0+1)) & "," & -- [4]
				natural'image(2**(1+1)*5**(0+1)) & "," & -- [5]  
				natural'image(2**(2+1)*5**(0+1)) & "," & -- [6]  
				natural'image(2**(0+1)*5**(1+1)) & "," & -- [7]  
				natural'image(2**(0+2)*5**(0+2)) & "," & -- [8]  
				natural'image(2**(1+2)*5**(0+2)) & "," & -- [9]  
				natural'image(2**(2+2)*5**(0+2)) & "," & -- [10] 
				natural'image(2**(0+2)*5**(1+2)) & "," & -- [11] 
				natural'image(2**(0+3)*5**(0+3)) & "," & -- [12]
				natural'image(2**(1+3)*5**(0+3)) & "," & -- [13]
				natural'image(2**(2+3)*5**(0+3)) & "," & -- [14]
				natural'image(2**(0+3)*5**(1+3)) & "," & -- [15]
				"length : 16].");

	constant dlft_vtscale : string := compact(
			"[" &
				natural'image(2**17/(2**(0+0)*5**(0+0))) & "," & -- [0]
				natural'image(2**17/(2**(1+0)*5**(0+0))) & "," & -- [1]
				natural'image(2**17/(2**(2+0)*5**(0+0))) & "," & -- [2]
				natural'image(2**17/(2**(0+0)*5**(1+0))) & "," & -- [3]
				natural'image(2**17/(2**(0+1)*5**(0+1))) & "," & -- [4]
				natural'image(2**17/(2**(1+1)*5**(0+1))) & "," & -- [5]
				natural'image(2**17/(2**(2+1)*5**(0+1))) & "," & -- [6]
				natural'image(2**17/(2**(0+1)*5**(1+1))) & "," & -- [7]
				natural'image(2**17/(2**(0+2)*5**(0+2))) & "," & -- [8]
				natural'image(2**17/(2**(1+2)*5**(0+2))) & "," & -- [9]
				natural'image(2**17/(2**(2+2)*5**(0+2))) & "," & -- [10]
				natural'image(2**17/(2**(0+2)*5**(1+2))) & "," & -- [11]
				natural'image(2**17/(2**(0+3)*5**(0+3))) & "," & -- [12]
				natural'image(2**17/(2**(1+3)*5**(0+3))) & "," & -- [13]
				natural'image(2**17/(2**(2+3)*5**(0+3))) & "," & -- [14]
				natural'image(2**17/(2**(0+3)*5**(1+3))) & "," & -- [15]
				"length : 16].");
end;

package body scopeiopkg is

	function significand (
		constant unit : real)
		return string is
		variable sgfc : real;
		variable exp  : integer;
		variable len  : natural;
	begin
		assert unit > 0.0 
			report "unit <= 0.0"
			severity failure;

		exp := 0;
		sgfc := unit;
		while sgfc >= 1.0 loop
			sgfc := sgfc / 10.0;
			exp  := exp + 1;
		end loop;

		len := 0;
		for j in 0 to 10-1 loop
			if abs((sgfc-round(sgfc))/sgfc) > 4.0e-9 then
				exp := exp - 1;
				sgfc  := sgfc  * 10.0;
				if sgfc >= 1.0 then
					len := len + 1;
				end if;
				if len >= 4 then
					exit;
				end if;
			else
				exit;
			end if;
		end loop;
		return compact(
			"{ sfgc : " &  natural'image(natural(round(sgfc))) & "," &
			"  exp  : " &  integer'image(exp) & "," &
			"  len  : " &  integer'image(len) & "}");

	end;

	function sht (
		constant exp  : integer;
		constant len  : natural;
		constant pfx  : integer;
		constant prc  : natural)
		return integer is
	begin
		return (exp+len+1)-pfx+len-(prc-1);
	end;

	function dec (
		constant exp : integer;
		constant pfx : integer;
		constant prc : natural)
		return integer is
	begin
		return -exp-pfx;
	end;

	function get_significand1245 (
		constant unit  : real)
		return natural_vector is
		constant coefs  : real_vector(0 to 4-1) := (1.0, 2.0, 4.0, 5.0);
		variable retval : natural_vector(0 to 4-1);
	begin

		for i in coefs'range loop
			retval(i) := hdo(significand(unit*coefs(i)))**".sgfc";
		end loop;
		return retval;
	end;

	function get_explen1245 (
		constant unit   : real)
		return integer_vector is
		constant coefs  : real_vector(0 to 4-1) := (1.0, 2.0, 4.0, 5.0);
		variable unit1245 : real;
		variable retval : integer_vector(0 to 4*4-1);
	begin

		unit1245 := unit;
		for i in 0 to 4-1 loop
			for j in coefs'range loop
				retval(4*i+j) := hdo(significand(unit1245*coefs(j)))**".len";
			end loop;
			unit1245 := unit1245 * 10.0;
		end loop;
		return retval;
	end;

	function get_exp1245 (
		constant unit   : real)
		return integer_vector is
		constant coefs  : real_vector(0 to 4-1) := (1.0, 2.0, 4.0, 5.0);
		variable unit1245 : real;
		variable retval : integer_vector(0 to 4*4-1);
	begin
		unit1245 := unit;
		for i in 0 to 4-1 loop
			for j in coefs'range loop
				retval(4*i+j) := hdo(significand(unit1245*coefs(j)))**".dec";
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
		constant rgtr  : std_logic_vector;
		constant field : string)
		return   std_logic_vector is
		constant offset : natural := hdo(field)**".offset";
		constant length : natural := hdo(field)**".length";
	begin
		if rgtr'ascending then
			return rgtr(offset to offset+length-1);
		else
			return rgtr(offset+length-1 downto offset);
		end if;
	end;

	function bitfield (
		constant rgtr  : std_logic_vector;
		constant field : string)
		return   std_logic is
		constant offset : natural := hdo(field)**".offset";
	begin
		return rgtr(offset);
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
	begin
		assert word'length mod data'length=0
		report "replace"
		severity failure;
		retval(0 to word'length-1) := unsigned(word);
		for i in 0 to retval'length/data'length-1 loop
			if to_unsigned(i,addr'length)=unsigned(addr) then
				retval(0 to data'length-1) := unsigned(data);
			end if;
			retval := retval rol data'length;
		end loop;
		return std_logic_vector(retval(0 to word'length-1));
	end;

	function max_textlength(
		constant labels : string;
		constant length : natural) 
		return natural is
		function text_length (
			constant i : natural)
			return natural is
			constant retval : string := escaped(hdo(labels)**("["&natural'image(i)&"].text"));
		begin
			return retval'length;
		end;
		variable max_length   : natural;
		variable label_length : natural;
	begin
		max_length := 0;
		for i in 0 to length-1 loop
			label_length := text_length(i);
			if max_length < text_length(i) then
				max_length := label_length;
			end if;
		end loop;
		return max_length;
	end;

end;
