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
use hdl4fpga.std.all;

architecture miitx_dhcp of testbench is
	signal rst  : std_logic := '1';
	signal clk  : std_logic := '1';
	signal txd  : std_logic_vector(0 to 4-1);
	signal txrd : std_logic_vector(0 to 4-1);
	signal txdv : std_logic;
	signal treq : std_logic;
begin
	clk <= not clk after 5 ns;
	rst <= '1', '0' after 20 ns;

	process (clk)
	begin
		if rising_edge(clk) then
			treq <= '1';
			if rst='1' then
				treq <= '0';
			end if;
		end if;
	end process;


	du : entity hdl4fpga.miitx_dhcp
	port map (
        mii_txc  => clk,
		mii_treq => treq,
		mii_txdv => txdv,
		mii_txd  => txd);
	txrd <= reverse(txd);
end;
