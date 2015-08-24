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

library iocore;
library ieee;
use ieee.std_logic_1164.all;
    
entity testbench is
end;

architecture def of testbench is
    signal clk : std_logic := '1';
    signal mode : std_logic_vector(0 downto 0);
	signal disp : std_logic;
	signal hsync : std_logic;
	signal vsync : std_logic;
	signal row : std_logic_vector(5-1 downto 0);
	signal col : std_logic_vector(5-1 downto 0);
 begin
    du : entity iocore.video_vga_sync
    generic map (
        n => 5,
        m => 1)
    port map (
        clk => clk,
        mode => "0",
        disp => disp,
        hsync => hsync,
        vsync => vsync,
        row => row,
        col => col);
    clk <= not clk after 5 ns;


end;
