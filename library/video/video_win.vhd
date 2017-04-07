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

entity video_win is
	port (
		video_clk : in  std_logic;
		video_x   : in  std_logic;
		video_y   : in  std_logic;
		win_id    : out std_logic_vector);
end;

architecture def of video_win is

	constant xtab : unsigned := (
		b"011_1000_0000" & b"000_0000_0000" & b"100_0000_0000" & b"001_0000_0000" &
		b"011_1000_0000" & b"001_0000_0000" & b"100_0000_0000" & b"001_0000_0000");

	subtype x      is 0*video_x'length to 1*video_x'length-1;
	subtype y      is 1*video_x'length to 2*video_x'length-1;
	subtype width  is 2*video_x'length to 3*video_x'length-1;
	subtype height is 3*video_x'length to 4*video_x'length-1;

	function init_data (
		constant wintab : std_logic_vector);
		return std_logic_vector is
		variable x      : natural;
		variable width  : natural;
		variable aux    : unsigned(wintab'range);
		variable retval : std_logic_vector(0 to 2**'length*win_id'length-1) := (others => '0');
	begin
		aux := wintab;
		for i in win_id'range loop
			x     := to_integer(aux(x));
			width := to_integer(aux(width));
			for j in x to x+width-1 loop
					retval(j*2**win_id'length+i) := '1';
				end loop;
			end loop;
			aux := aux sll width'right+1;
		end loop;
		return 
	end;

begin

	x_e : entity hdl4fpga.rom
	generic map (
		bitrom => bittab)
	port map (
		clk    => video_clk,
		addr   => video_x,
		data   => data);

	y_e : entity hdl4fpga.rom
	generic map (
		bitrom => bittab)
	port map (
		clk    => video_clk,
		addr   => video_y,
		data   => data);

end;
