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
use hdl4fpga.ipoepkg.all;

entity udp_tx is
	port (
		mii_txc    : in  std_logic;

		udppl_txen : in  std_logic;
		udppl_txd  : in  std_logic_vector;
		udppl_len  : in  std_logic_vector(16-1 downto 0);

		udp_ptr    : in  std_logic_vector;
		udp_cksm   : in  std_logic_vector(0 to 16-1) := x"0000";
		udp_sp     : in  std_logic_vector(0 to 16-1);
		udp_dp     : in  std_logic_vector(0 to 16-1);
		udp_len    : buffer std_logic_vector(16-1 downto 0);
		udp_txen   : buffer std_logic;
		udp_txd    : out std_logic_vector;
		tp         : out std_logic_vector(1 to 32));
end;

architecture def of udp_tx is

	signal udp_hdr  : std_logic_vector(0 to summation(udp4hdr_frame)-1);

	signal pllat_txen  : std_logic;
	signal pllat_txd   : std_logic_vector(udp_txd'range);
	signal udphdr_txd : std_logic_vector(udp_txd'range);

begin

	process (udppl_txen, pllat_txen, mii_txc)
		variable txen : std_logic := '0';
	begin
		if rising_edge(mii_txc) then
			if udppl_txen='1' then
				txen := '1';
			elsif txen='1' then
				if pllat_txen='1' then
					txen := '0';
				end if;
			end if;
		end if;
		udp_txen <= udppl_txen or txen or pllat_txen;
	end process;

	udp_len <= std_logic_vector(unsigned(udppl_len) + (summation(udp4hdr_frame)/octect_size));
	udp_hdr <= udp_sp & udp_dp & udp_len & udp_cksm;

	udphdr_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => udp_hdr,
		mii_txc  => mii_txc,
		mii_txdv => udp_txen,
		mii_txd  => udphdr_txd);

	ipalat_e : entity hdl4fpga.mii_latency
	generic map (
		latency => summation(udp4hdr_frame))
	port map (
		mii_txc  => mii_txc,
		lat_txen => udppl_txen,
		lat_txd  => udppl_txd,
		mii_txen => pllat_txen,
		mii_txd  => pllat_txd);
		
	udp_txd  <= wirebus(udphdr_txd & pllat_txd, not pllat_txen & pllat_txen);

end;

