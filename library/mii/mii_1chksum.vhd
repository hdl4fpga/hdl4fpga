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

entity mii_1chksum is
	generic (
		chksum_size : natural;
		chksum_init : natural := 0);
	port (
		mii_rxc   : in  std_logic;
		cksm_rxdv : in  std_logic;
		cksm_rxd  : in  std_logic_vector;

		mii_txc   : in  std_logic;
		cksm_treq : in  std_logic;
		cksm_trdy : out std_logic;
		cksm_txen : out std_logic;
		cksm_txd  : out std_logic_vector);
end;

architecture beh of mii_1chksum is
	signal chksum : unsigned(0 to chksum_size-1);
begin

	process (mii_rxc)
		variable cy  : unsigned(0 to 0);
		variable add : unsigned(0 to cksm_rxd'length);
		variable acc : unsigned(chksum'range);
	begin
		if rising_edge(mii_rxc) then
			if cksm_rxdv='0' then
				acc := to_unsigned(chksum_init, chksum_size);
				cy  := (others => '0');
			else
				acc := chksum;
				add := unsigned'('0' & unsigned(cksm_rxd)) + unsigned'('0' & acc(cksm_rxd'reverse_range));
				cy  := add(0 to 0);
				acc(cksm_rxd'range) := add(1 to cksm_rxd'length);
				acc := acc ror cksm_rxd'length;
				acc := acc(cksm_rxd'reverse_range) + cy;
			end if;
			chksum <= acc;
		end if;
	end process;

	mux_e : entity hdl4fpga.mii_mux
    port map (
		mux_data => std_logic_vector(chksum),
        mii_txc  => mii_txc,
		mii_treq => cksm_treq,
		mii_trdy => cksm_trdy,
        mii_txen => cksm_txen,
        mii_txd  => cksm_txd);

end;
