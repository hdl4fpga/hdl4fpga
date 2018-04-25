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

architecture miitx_dhcp of ecp3versa is
	signal mii_treq : std_logic;
begin

	process (fpga_gsrn, phy1_txc)
	begin
		if fpga_gsrn='0' then
			mii_treq <= '0';
		elsif rising_edge(phy1_txc) then
			mii_treq <= '1';
		end if;
	end process;

	du : entity hdl4fpga.miitx_dhcp
	port map (
        mii_txc  => phy1_125clk,
		mii_treq => mii_treq,
		mii_txdv => phy1_tx_en,
		mii_txd  => phy1_tx_d);

	phy1_gtxclk <= not phy1_125clk;

	phy1_rst  <= '1'; --fpga_gsrn;
	phy1_mdc  <= '0';
	phy1_mdio <= '0';
end;
