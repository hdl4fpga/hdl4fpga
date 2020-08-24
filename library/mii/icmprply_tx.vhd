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
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity icmprply_tx is
	port (
		mii_txc   : in  std_logic;

		pl_txen   : in  std_logic;
		pl_txd    : in  std_logic_vector;

		icmp_ptr  : in  std_logic_vector;
		icmp_id   : in  std_logic_vector;
		icmp_seq  : in  std_logic_vector;
		icmp_txen : buffer std_logic := '0';
		icmp_txd  : out std_logic_vector);
end;

architecture def of icmprply_tx is
	signal icmp_txdv : std_logic;
begin

	process (pl_txen, icmp_txen, mii_txc)
		variable txen : std_logic := '0';
	begin
		if rising_edge(mii_txc) then
			if pl_txen='1' then
				txen := '1';
			elsif txen='1' then
				if icmp_txen='0' then
					txen := '0';
				end if;
			end if;
		end if;
		icmp_txdv <= pl_txen or txen;
	end process;


	icmp_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => x"00_00_ffff_0000_0000",
        mii_txc  => mii_txc,
		mii_txdv => icmp_txdv,
        mii_txen => icmp_txen,
        mii_txd  => icmp_txd);
end;

