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

entity video_win is
	port (
		video_clk  : in  std_logic;
		video_x    : in  std_logic_vector;
		video_y    : in  std_logic_vector;
		video_frm  : in  std_logic;
		video_don  : in  std_logic;
		video_mask : out std_logic_vector);
end;

architecture def of video_win is

	constant xtab : std_logic_vector := (
		b"011_1000_0000" & b"100_0000_0000" &
		b"011_1000_0000" & b"100_0000_0000");

	constant ytab : std_logic_vector := (
		b"000_0000_0000" & b"010_0000_0000" &
		b"010_0000_0000" & b"010_0000_0000");

	function init_data (
		constant tab    : std_logic_vector;
		constant size   : natural)
		return            std_logic_vector is
		variable x      : natural;
		variable width  : natural;
		variable aux    : unsigned(0 to tab'length);
		variable retval : std_logic_vector(0 to 2**size*video_mask'length-1) := (others => '0');
	begin
		aux := unsigned(tab);
		for i in video_mask'range loop
			x     := to_integer(aux(0 to size-1));
			aux   := aux sll size;
			width := to_integer(aux(0 to size-1));
			aux   := aux sll size;
			for j in x to x+width-1 loop
				retval(2**video_mask'length*j+i) := '1';
			end loop;
		end loop;
		return retval;
	end;

	signal mask_y : std_logic_vector(video_mask'range);
	signal mask_x : std_logic_vector(video_mask'range);
begin

	x_e : entity hdl4fpga.rom
	generic map (
		bitrom => init_data(xtab, video_x'length))
	port map (
		clk    => video_clk,
		addr   => video_x,
		data   => mask_x);

	y_e : entity hdl4fpga.rom
	generic map (
		bitrom =>  init_data(ytab, video_y'length))
	port map (
		clk    => video_clk,
		addr   => video_y,
		data   => mask_y);

	video_mask <= mask_y and mask_x and (video_mask'range => video_frm and video_don);

end;
