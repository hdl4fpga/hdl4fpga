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

library unisim;
use unisim.vcomponents.all;

architecture miitx_dhcp of arty is
	signal mii_treq       : std_logic;
	signal eth_txclk_bufg : std_logic;
	signal eth_txclk      : std_logic;
begin

	eth_tx_clk_ibufg : ibufg
	port map (
		I => eth_tx_clk,
		O => eth_txclk_bufg);
	eth_txclk <= not eth_txclk_bufg;

	process (btn(0), eth_txclk)
	begin
		if btn(0)='1' then
			mii_treq <= '0';
		elsif rising_edge(eth_txclk) then
			mii_treq <= '1';
		end if;
	end process;

	du : entity hdl4fpga.miitx_dhcp
	port map (
        mii_txc  => eth_txclk_bufg,
		mii_treq => mii_treq,
		mii_trdy => led(0),
		mii_txdv => eth_tx_en,
		mii_txd  => eth_txd);

end;
