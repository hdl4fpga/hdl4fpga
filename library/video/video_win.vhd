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
		b"011_1000_0000" & b"100_0000_0000" &
		b"011_1000_0000" & b"100_0000_0000");

	constant ytab : unsigned := (
		b"000_0000_0000" & b"010_0000_0000" &
		b"010_0000_0000" & b"010_0000_0000");

	function init_data (
		constant tab  : std_logic_vector;
		variable size : natural)
		return std_logic_vector is
		variable x      : natural;
		variable width  : natural;
		variable aux    : unsigned(tab'range);
		variable retval : std_logic_vector(0 to 2**size*win_id'length-1) := (others => '0');
	begin
		aux := tab;
		for i in win_id'range loop
			x     := to_integer(aux(0 to size-1));
			aux   := aux sll size;
			width := to_integer(aux(0 to size-1));
			aux   := aux sll size;
			for j in x to x+width-1 loop
					retval(j*2**win_id'length+i) := '1';
				end loop;
			end loop;
		end loop;
		return retval;
	end;

begin

	x_e : entity hdl4fpga.rom
	generic map (
		bitrom => init_data(xtab, video_x'length))
	port map (
		clk    => video_clk,
		addr   => video_x,
		data   => data);

	y_e : entity hdl4fpga.rom
	generic map (
		bitrom =>  init_data(ytab, video_y'length))
	port map (
		clk    => video_clk,
		addr   => video_y,
		data   => data);

end;
