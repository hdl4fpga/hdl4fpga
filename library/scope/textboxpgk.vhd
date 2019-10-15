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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

package textboxpkg is

	type style_keys   is (width, alignment, text_color, background_color);
	type style_t      is array (style_keys) of natural;
	type style_vector is array (natural range <>) of style_t;

	constant left_alignment   : natural := 0;
	constant right_alignment  : natural := 1;
	constant center_alignment : natural := 2;

	function alignment        (constant value  : natural) return style_t; 
	function text_color       (constant value  : natural) return style_t; 
	function background_color (constant value  : natural) return style_t;
	function width            (constant value  : natural) return style_t; 


	function styles           (constant value  : style_t) return style_t;
	function styles           (constant values : style_vector) return style_t;

	constant tid_end  : natural := 0;
	constant tid_text : natural := 1;
	constant tid_div  : natural := 2;

	type tag is record 
		tid   : natural;
		style : style_t;
		ref   : natural;
	end record;

	type tag_vector is array (natural range <>) of tag;

	constant domain : string := "hola";
	function div  (constant children : tag_vector; constant style : style_t) return tag_vector;
	function text (constant value    : string;     constant style : style_t) return tag_vector;

	constant layout :  tag_vector := div (
		style    => styles(background_color(0)),
		children => 
			text(
				style => styles(background_color(0)),
				value => "hola"));

end;

package body textboxpkg is

	procedure strcmp (
		variable sucess : inout boolean;
		variable index  : inout natural;
		constant key    : in    string;
		constant domain : in    string)
	is
	begin
		sucess := false;
		for i in key'range loop
			if index < domain'length then
				if key(i)/=domain(index) then
					return;
				else
					index := index + 1;
				end if;
			elsif key(i)=NUL then
				sucess := true;
				return;
			else
				return;
			end if;
		end loop;
		if index < domain'length then
			if domain(index)=NUL then
				sucess := true;
				return;
			else
				return;
			end if;
		else
			sucess := true;
			return;
		end if;
	end;

	function strstr(
		constant key    : string;
		constant domain : string)
		return natural is
		variable sucess : boolean;
		variable index  : natural;
		variable ref    : natural;
	begin
		ref   := 0;
		index := domain'left;
		while index < domain'right loop
			strcmp(sucess, index, key, domain);
			if sucess then
				return ref;
			end if;
			while domain(index) /= NUL loop
				index := index + 1;
			end loop;
			index := index + 1;
		end loop;
	end;

	function alignment (
		constant value : natural)
		return style_t is
		variable retval : style_t;
	begin
		retval(alignment) := value;
		return retval;
	end;

	function background_color (
		constant value : natural)
		return style_t is
		variable retval : style_t;
	begin
		retval(background_color) := value;
		return retval;
	end;

	function text_color (
		constant value : natural)
		return style_t is
		variable retval : style_t;
	begin
		retval(text_color) := value;
		return retval;
	end;

	function width (
		constant value : natural)
		return style_t is
		variable retval : style_t;
	begin
		retval(width) := value;
		return retval;
	end;

	function styles (
		constant value  : style_t)
		return style_t is
	begin
		return value;
	end;

	function styles (
		constant values : style_vector)
		return style_t is
		variable retval : style_t;
	begin
		for i in values'reverse_range loop
			for j in style_t'range loop
				if values(i)(j)/=0 then
					retval(j) := values(i)(j);
				end if;
			end loop;
		end loop;
		return retval;
	end;

	function endtag 
		return tag is
		variable retval : tag;
	begin
		retval.tid := tid_end;
		return retval;
	end;

	function div (
		constant children : tag_vector;
		constant style    : style_t)
		return tag_vector is
		variable div : tag;
	begin
		div.tid   := tid_div;
		div.style := style;
		return div & children & endtag;
	end;

	function text (
		constant value : string;
		constant style : style_t)
		return tag_vector is
		variable retval : tag_vector(0 to 0);
	begin
		retval(0).tid := tid_text;
		retval(0).ref := strstr(value, domain);
		return retval;
	end;

end;
