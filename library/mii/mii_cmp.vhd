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
use hdl4fpga.std.all;

entity mii_cmp is
	generic (
		mem_data : std_logic_vector);
    port (
        mii_txc  : in  std_logic;
		mii_treq : in  std_logic;
		mii_tena : in  std_logic := '1';
		mii_trdy : out std_logic;
        mii_rxdv : in  std_logic;
        mii_rxd  : in  std_logic_vector);
end;

architecture def of mii_rom is
	signal txd  : std_logic_vector(txd'range);
	signal txdv : std_logic;
begin

	mii_dhcp_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => mem_data)
	port map (
		mii_txc  => mii_rxc,
		mii_treq => mii_req,
		mii_tena => mii_tena;
		mii_trdy => mii_rdy,
		mii_txdv => txdv,
		mii_txd  => txd);

	process (mii_txc, miiip_rdy)
		variable cy : std_logic;
	begin
		if rising_edge(mii_txc) then
			if mac_vld='0' then
				cy  := '1';
			elsif mii_rxdv='1' then
				if cy='1' then
					if miiip_rxd/=mii_rxd then
						cy := '0';
					end if;
				end if;
			end if;
		end if;
		ip_vld <= miiip_rdy and cy;
	end process;

end;
