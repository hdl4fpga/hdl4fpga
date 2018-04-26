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
use ieee.std_logic_textio.all;

library hdl4fpga;

architecture crc of testbench is
	constant n : natural := 8;
	signal clk : std_logic := '0';
	signal txiv : std_logic;
	signal txi  : std_logic_vector(0 to 8-1) := x"01";
	signal txd  : std_logic_vector(txi'range);
	signal rst  : std_logic;
begin
	clk <= not clk after 5 ns;
	rst <= '1', '0' after 20 ns;

	process (clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				txiv <= '0';
			else
				txiv <= '1';
			end if;
		end if;
	end process;


	du : entity hdl4fpga.miitx_crc32
	port map (
        mii_txc  => clk,
		mii_txiv => txiv,
		mii_txi  => txi,
		mii_txen => open,
		mii_txd  => txd);
end;
