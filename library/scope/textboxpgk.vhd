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

	function div  (constant children : tag_vector; constant style : style_t) return tag_vector;
	function text (constant value    : string;     constant sytle : style_t) return tag;

end;

package body textboxpkg is

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
		return tag is
		variable retval : tag;
	begin
		tag.tid := tid_text;
		tag.
	end;
end;
