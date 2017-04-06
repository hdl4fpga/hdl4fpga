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
	port(
		video_clk : in  std_logic;
		video_x   : in  std_logic;
		video_y   : in  std_logic;
		video_frm : in  std_logic;
		video_don : in  std_logic;
		win_id    : out std_logic_vector;
		win_x     : out std_logic_vector;
		win_y     : out std_logic_vector);

end;

architecture def of video_win is

	subtype is natural range 0                         to win_x'length-1;
	subtype is natural range win_x'length              to win_x'length+win_y'length-1;
	subtype is natural range win_x'length+win_y'length to win_x'length+win_y'length+win_id'length;

begin

	bram_e : entity hdl4fpga.bram
	generic (
		data  : std_logic_vector := (0 to 0 => '-'));
	port (
		clka  => video_clk,
		addra : in  std_logic_vector;
		enaa  : in  std_logic := '1';
		wea   => '0',
		dia   : in  std_logic_vector;
		doa   : out std_logic_vector;

		clkb  : in  std_logic;
		addrb : in  std_logic_vector;
		enab  : in  std_logic := '1';
		web   : in  std_logic := '0';
		dib   : in  std_logic_vector;
		dob   : out std_logic_vector);


end;
