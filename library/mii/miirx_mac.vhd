--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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
use hdl4fpga.std.all;

entity miirx_mac is
    port (
		mii_rxc  : in std_logic;
        mii_rxdv : in std_logic;
        mii_rxd  : in nibble;

		mii_txc  : out std_logic;
		mii_txen : out std_logic;
		mii_txd  : out nibble);
end;

architecture def of miirx_mac is
	signal txen  : std_logic;
	signal dtreq : std_logic;
	signal dtrdy : std_logic;
	signal dtxen : std_logic;
	signal dtxd  : nibble;
begin

	miitx_pre_e : entity hdl4fpga.miirx_pre
	port map (
		mii_rxc  => mii_rxc,
        mii_rxdv => mii_rxdv,
        mii_rxd  => mii_rxd,

		mii_txen => dtreq);

	miitx_dst_e : entity hdl4fpga.miitx_mem
	generic map (
		mem_data => x"00_00_00_01_02_03")
	port map (
		mii_txc  => mii_rxc,
		mii_treq => dtreq,
		mii_trdy => dtrdy,
		mii_txen => dtxen,
		mii_txd  => dtxd);

	process (mii_rxc)
		variable drdy : std_logic;
	begin
		if rising_edge(mii_rxc) then
			if dtreq='0' then
				drdy := '0';
				txen <= '0';
			elsif drdy='0' then
				if dtxen='1' then
					if mii_rxd=dtxd then
						drdy := '0';
						txen <= '1';
					else
						drdy := '1';
						txen <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

	mii_txc  <= mii_rxc;
	mii_txen <= dtrdy and txen;
	mii_txd  <= mii_rxd;
end;
