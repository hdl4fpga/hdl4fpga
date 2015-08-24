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
use ieee.std_logic_textio.all;

library hdl4fpga;

architecture win_sytm of testbench is
	constant n : natural := 11;

	signal video_clk  : std_logic := '0';

	signal vga_don : std_logic;
	signal vga_frm : std_logic;

	signal win_rowid : std_logic_vector(2-1 downto 0);
	signal win_rowpag : std_logic_vector(5-1 downto 0);
    signal win_rowoff : std_logic_vector(6-1 downto 0);
    signal win_colid : std_logic_vector(2-1 downto 0);
    signal win_colpag : std_logic_vector(2-1 downto 0);
    signal win_coloff : std_logic_vector(12-1 downto 0);
begin

	video_clk <= not video_clk after 500 ns/150 ;

	video_vga_e : entity hdl4fpga.video_vga
	generic map (
		n => 12)
	port map (
		clk   => video_clk,
		frm   => vga_frm,
		don   => vga_don);

	win_sytm_e : entity hdl4fpga.win_sytm
	port map (
		win_clk => video_clk,
		win_don => vga_don,
		win_frm => vga_frm,
		win_rowid => win_rowid,
		win_rowpag => win_rowpag,
        win_rowoff => win_rowoff,
        win_colid => win_colid,
        win_colpag => win_colpag,
        win_coloff => win_coloff);

end;
