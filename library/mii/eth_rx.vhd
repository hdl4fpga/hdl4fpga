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

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ethpkg.all;

entity eth_rx is
	generic (
		hwda     : in std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		mii_rxc  : in  std_logic;
		mii_rxd  : in  std_logic_vector;
		mii_rxdv : in  std_logic;
		eth_ptr  : buffer std_logic_vector;
		eth_pre  : buffer std_logic;
		eth_bcst : buffer std_logic;
		eth_hwda : out std_logic;
		pl_rxdv  : out std_logic);
end;

architecture def of eth_rx is
begin

	mii_pre_e : entity hdl4fpga.mii_rxpre 
	port map (
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_rxdv => mii_rxdv,
		mii_rdy  => eth_pre);

	process (mii_rxc)
	begin
		if rising_edge(mii_rxc) then
			if eth_pre='0' then
				eth_ptr <= (eth_ptr'range => '0');
			elsif eth_ptr(eth_ptr'left)='0' then
				eth_ptr <= std_logic_vector(unsigned(eth_ptr) + 1);
			end if;
		end if;
	end process;

	pl_rxdv <= eth_decode(unsigned(eth_ptr), eth_type, eth_frame, mii_rxd'length) and mii_rxdv;

	hwda_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(hwda,8))
	port map (
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_treq => eth_pre,
		mii_equ  => eth_hwda);

	mii_bcst_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(x"ff_ff_ff_ff_ff_ff", 8))
	port map (
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_treq => eth_pre,
		mii_equ  => eth_bcst);

end;

