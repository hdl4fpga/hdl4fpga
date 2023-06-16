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
use hdl4fpga.base.all;

entity usbcrcglue is
	port (
		clk      : in  std_logic;
		cken     : in  std_logic;
		bitstff  : buffer std_logic;

		crcdv    : out std_logic;
		crcact   : in  std_logic;
		crcen    : out std_logic;
		crcd     : in  std_logic;

		txen     : in  std_logic;
		txbs     : out std_logic;
		txd      : in  std_logic;

		phy_txen : out std_logic;
		phy_txbs : in  std_logic;
		phy_txd  : out std_logic;

		rxdv     : out std_logic;
		rxbs     : out std_logic;
		rxd      : out std_logic;

		phy_rxdv : in  std_logic;
		phy_rxbs : in  std_logic;
		phy_rxd  : in  std_logic);
end;

architecture def of usbcrcglue is
begin

	mealy_p : process (phy_txbs, txen, phy_rxbs, phy_rxdv, crcact, clk)
		type states is (s_idle, s_tx, s_rx);
		variable state : states;
	begin
		memory : if rising_edge(clk) then
			if cken='1' then
				case state is
				when s_idle =>
					if txen='1' then
						state := s_tx;
					elsif phy_rxdv='1' then
						state := s_rx;
					end if;
				when s_tx =>
					if (txen or crcact)='0' then
						if phy_rxdv='0' then
							state := s_idle;
						end if;
					end if;
				when s_rx =>
					if phy_rxdv='0' then
						if phy_rxdv='0' then
							state := s_idle;
						end if;
					end if;
				end case;
			end if;
		end if;

		combimatorial : case state is
		when s_idle =>
			phy_txen <= txen;
			bitstff  <= phy_txbs or phy_rxbs;
			crcdv    <= '0';
			rxdv     <= phy_rxdv and not txen;
		when s_tx =>
			phy_txen <= txen or crcact;
			bitstff  <= phy_txbs;
			crcdv    <= crcact and txen;
			rxdv     <= '0';
		when s_rx =>
			phy_txen <= '0';
			bitstff  <= phy_rxbs;
			crcdv    <= phy_rxdv;
			rxdv     <= phy_rxdv;
		end case;

	end process;

	rxbs     <= phy_rxbs;
	rxd      <= phy_rxd;
	phy_txd  <= txd when txen='1' else not crcd;
	txbs     <= phy_txbs;
	crcen    <= cken and not bitstff when crcact='1' else '0';

end;