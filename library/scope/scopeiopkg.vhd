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
use hdl4fpga.jso.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.textboxpkg.all;

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
	constant rid_pointer  : std_logic_vector := x"15";
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

	constant pointerx_maxsize : natural := 11;
	constant pointery_maxsize : natural := 11;
	constant pointerx_id      : natural := 0;
	constant pointery_id      : natural := 1;

	constant pointer_bf : natural_vector := (
		pointery_id => pointery_maxsize, 
		pointerx_id => pointerx_maxsize);

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
		constant unit : real)
		return string;

	function get_significand1245 (
		constant unit : real)
		return natural_vector;

	function get_shr1245 (
		constant unit : real)
		return integer_vector;

	function get_characteristic1245 (
		constant unit : real)
		return integer_vector;

end;

package body scopeiopkg is

	function significand (
		constant unit : real)
		return string is
		constant tenth  : real := 1.0/10.0;
		constant scales : string := "munp";
		variable scale  : integer;
		variable exp10  : integer;
		variable dec10  : integer;
		variable pow10  : real;
		variable sgfc   : real;
		variable unt   : real;
		variable shr    : integer;
		variable pnt    : integer;
		variable rnd    : natural; --Lattice Diamond fix
	begin
		assert unit > 0.0 
			report "unit <= 0.0"
			severity failure;

		unt := unit;
		while unt >= 1.0 loop
			unt := unt / 1.0e3;
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
			unt   := unt / tenth;
		end loop;

		rnd := natural(round(sgfc)); --Lattice Diamond fix

		scale := ((3-(exp10 mod 3)) mod 3)+exp10;
		shr   := -2+dec10-exp10;
		pnt   := dec10-scale;
		-- report CR &
			-- "sgfc  => " & integer'image(rnd)   & CR &
			-- "exp10 => " & integer'image(exp10) & CR &
			-- "dec10 => " & integer'image(dec10) & CR &
			-- "scale => " & integer'image(scale) & CR &
			-- "unit  => " & scales((((3-(exp10 mod 3)) mod 3)+exp10)/3) & CR &
			-- "shr   => " & integer'image(-2+dec10-exp10) & CR &
			-- "pnt   => " & integer'image(dec10-scale);

		return 
			"{ sgfc:" & integer'image(rnd) & "," & 
			"  shr:"  & integer'image(shr) & "," & 
			"  pnt:"  & integer'image(pnt) & "}";
	end;

	function get_significand1245 (
		constant unit   : real)
		return natural_vector is
		constant coefs  : real_vector(0 to 4-1) := (1.0, 2.0, 4.0, 5.0);
		variable retval : natural_vector(0 to 4-1);
	begin

		for i in coefs'range loop
			retval(i) :=(jso(significand(unit*coefs(i)))**".sgfc");
		end loop;
		return retval;
	end;

	function get_shr1245 (
		constant unit   : real)
		return integer_vector is
		constant coefs  : real_vector(0 to 4-1) := (1.0, 2.0, 4.0, 5.0);
		variable xxx : real;
		variable retval : integer_vector(0 to 4*4-1);
	begin

		xxx := unit;
		for i in 0 to 4-1 loop
			for j in coefs'range loop
				retval(4*i+j) := (jso(significand(xxx*coefs(j)))**".shr");
			end loop;
			xxx := xxx * 10.0;
		end loop;
		return retval;
	end;

	function get_characteristic1245 (
		constant unit   : real)
		return integer_vector is
		constant coefs  : real_vector(0 to 4-1) := (1.0, 2.0, 4.0, 5.0);
		variable xxx : real;
		variable retval : integer_vector(0 to 4*4-1);
	begin

		xxx := unit;
		for i in 0 to 4-1 loop
			for j in coefs'range loop
				retval(4*i+j) := (jso(significand(xxx*coefs(j)))**".pnt");
			end loop;
			xxx := xxx * 10.0;
		end loop;
		return retval;
	end;

	function pos(
		constant val : natural)
		return natural is
	begin
		if val > 0 then
			return 1;
		end if;
		return 0;
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

	function scale_1245 (
		constant val   : signed;
		constant scale : std_logic_vector)
		return signed is
		variable sel  : std_logic_vector(scale'length-1 downto 0);
		variable by1  : signed(val'range);
		variable by2  : signed(val'range);
		variable by4  : signed(val'range);
		variable rval : signed(val'range);
	begin
		by1 := shift_left(val, 0);
		by2 := shift_left(val, 1);
		by4 := shift_left(val, 2);
		sel := scale;
		case sel(2-1 downto 0) is
		when "00" =>
			rval := by1;
		when "01" =>
			rval := by2;
		when "10" =>
			rval := by4;
		when "11" =>
			rval := by4 + by1;
		when others =>
			rval := (others => '-');
		end case;
		return rval;
	end;
		
	function scale_1245 (
		constant val   : unsigned;
		constant scale : std_logic_vector)
		return unsigned is
		variable sel  : std_logic_vector(scale'length-1 downto 0);
		variable by1  : unsigned(val'range);
		variable by2  : unsigned(val'range);
		variable by4  : unsigned(val'range);
		variable rval : unsigned(val'range);
	begin
		by1 := shift_left(val, 0);
		by2 := shift_left(val, 1);
		by4 := shift_left(val, 2);
		sel := scale;
		case sel(2-1 downto 0) is
		when "00" =>
			rval := by1;
		when "01" =>
			rval := by2;
		when "10" =>
			rval := by4;
		when "11" =>
			rval := by4 + by1;
		when others =>
			rval := (others => '1');
		end case;
		return rval;
	end;
		
end;
