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

entity scopeio_miitx is
	port (
		mii_rxc   : in  std_logic;
		mii_rxdv  : in  std_logic;
		mii_rxd   : in  std_logic_vector;

		pall_data : out std_logic_vector
		mem_req   : out std_logic;
		mem_rdy   : in  std_logic;
		mem_ena   : in  std_logic;
		mem_dat   : in  std_logic_vector);

end;

architecture mix of scopeio_miitx is
begin

	miirxpre_e : entity hdl4fpga.miirx_pre
	port map (
		mii_rxc  => mii_rxc,
		mii_rxv  => mii_rxv,
		mii_rxdv => mii_rxdv,
		mii_rrdy => pre_rdy);

	process(mii_rxc)
		variable data : unsigned(0 to pall_data'length-1);
		variable cntr : unsigned(0 to unsigned_nun_bits(pall_data'length/mii_rxd'length-1));
	begin
		if rising_edge(mii_rxc) then
			if pre_rdy='0' then
			elsif pre_rdy='1' then
				data(mii_rxd'range) := mii_rxd;
				data := data srl mii_rxd'length;
			end if;
		end if;
	end process;

end;
