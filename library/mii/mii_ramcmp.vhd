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

library hdl4fpga;
use hdl4fpga.std.all;

entity mii_ramcmp is
	generic (
		mem_size : natural;
		mem_data : std_logic_vector := (0 to 0 => '-'));
    port (
        mii_rxc  : in  std_logic;
		mii_rxdv : in  std_logic := '0';
        mii_rxd  : in  std_logic_vector;

		mii_treq : in  std_logic;
		mii_tena : in  std_logic := '1';
		mii_trdy : buffer std_logic;
		mii_equ  : out std_logic);
end;

architecture def of mii_ramcmp is

	signal mii_txd  : std_logic_vector(mii_rxd'range);
	signal cy       : std_logic;

begin

	miiram_e : entity hdl4fpga.mii_ram
	generic map (
		mem_size => mem_size,
		mem_data => mem_data)
	port map (
		mii_rxc  => mii_rxc,
        mii_rxdv => mii_rxdv,
        mii_rxd  => mii_rxd,

		mii_txc  => mii_rxc,
		mii_treq => mii_treq,
		mii_tena => mii_tena,
		mii_trdy => mii_trdy,
		mii_txen => open,
		mii_txd  => mii_txd);

	process (mii_rxc)
	begin
		if rising_edge(mii_rxc) then
			if mii_treq='0' then
				cy <= '1';
			elsif mii_trdy='0' then
				if mii_tena='1' then
					cy <= cy and setif(mii_txd=mii_rxd);
				end if;
			end if;
		end if;
	end process;
	mii_equ <= mii_treq and mii_trdy and cy;

end;
