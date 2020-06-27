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

entity mii_romcmp is
	generic (
		mem_data : std_logic_vector);
    port (
        mii_rxc  : in  std_logic;
        mii_rxd  : in  std_logic_vector;
		mii_ena  : in  std_logic := '1';
		mii_treq : in  std_logic;
		mii_equ  : out std_logic);
end;

architecture def of mii_romcmp is
	signal mii_txd  : std_logic_vector(mii_rxd'range);
	signal mii_trdy : std_logic;
begin

	mii_data_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => mem_data)
	port map (
		mii_txc  => mii_rxc,
		mii_tena => mii_ena,
		mii_treq => mii_treq,
		mii_trdy => mii_trdy,
		mii_txdv => open,
		mii_txd  => mii_txd);

	process (mii_rxc, mii_trdy)
		variable cy : std_logic;
	begin
		if rising_edge(mii_rxc) then
			if mii_treq='0' then
				cy  := '1';
			elsif mii_trdy='0' then
				if mii_ena='1' then
					cy := cy and setif(mii_txd=mii_rxd);
				end if;
			end if;
		end if;
		mii_equ <= mii_trdy and cy;
	end process;

end;
