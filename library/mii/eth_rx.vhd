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
use hdl4fpga.ipoepkg.all;

entity eth_rx is
	generic (
		mac       : in std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		mii_rxc   : in  std_logic;
		mii_rxd   : in  std_logic_vector;
		mii_rxdv  : in  std_logic;
		eth_pre   : buffer std_logic;
		eth_bcst  : buffer std_logic;
		eth_macd  : out std_logic;
		ethtype_ena : buffer std_logic;
		arp_req   : out std_logic);
end;

architecture def of eth_rx is

	signal eth_ptr   : unsigned(0 to unsigned_num_bits(64*8/mii_rxd'length-1));
	signal eth_field : std_logic_vector(eth_frame'range);
	signal eth_treq  : std_logic;

begin

	mii_pre_e : entity hdl4fpga.miirx_pre 
	port map (
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_rxdv => mii_rxdv,
		mii_rdy  => eth_pre);

	process (mii_rxc)
	begin
		if rising_edge(mii_rxc) then
			if eth_pre='0' then
				eth_ptr <= (others => '0');
			elsif eth_ptr(0)='0' then
				eth_ptr <= eth_ptr + 1;
			end if;
		end if;
	end process;

	eth_treq <= eth_pre and not eth_ptr(0);

	mymac_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(mac,8))
	port map (
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_treq => eth_treq,
		mii_equ  => eth_macd);

	mii_bcst_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(x"ff_ff_ff_ff_ff_ff", 8))
	port map (
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_treq => eth_treq,
		mii_equ  => eth_bcst);

	eth_field <= mii_decode(eth_ptr, eth_frame, mii_rxd'length) and (eth_field'range => eth_pre);

	arprx_e : entity hdl4fpga.arp_rx
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => eth_treq,
		mii_rxd  => mii_rxd,
		eth_ptr  => std_logic_vector(eth_ptr),
		eth_bcst => eth_bcst,
		eth_type => eth_field(eth_type),
		arp_req  => arp_req);

	ethtype_ena <= eth_field(eth_type);

end;

