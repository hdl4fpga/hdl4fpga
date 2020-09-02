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

entity udp4_tx is
	port (
		mii_txc   : in  std_logic;

		udp_len    : in  std_logic_vector(16-1 downto 0);
		udp_txen   : in  std_logic;
		udp_txd    : in  std_logic_vector;

		udp4_ptr  : in  std_logic_vector;
		udp4_cksm : in  std_logic_vector(0 to 16-1) := x"0000";
		udp4_sp   : in  std_logic_vector(0 to 16-1);
		udp4_dp   : in  std_logic_vector(0 to 16-1);
		udp4_len  : buffer std_logic_vector(16-1 downto 0);
		udp4_txen : buffer std_logic;
		udp4_txd  : out std_logic_vector);
end;

architecture def of udp4_tx is

	signal udp4_hdr  : std_logic_vector(0 to summation(udp4hdr_frame)-1);

	signal pllat_txen  : std_logic;
	signal pllat_txd   : std_logic_vector(udp4_txd'range);
	signal udp4hdr_txd : std_logic_vector(udp4_txd'range);

begin

	process (udp_txen, pllat_txen, mii_txc)
		variable txen : std_logic := '0';
	begin
		if rising_edge(mii_txc) then
			if udp_txen='1' then
				txen := '1';
			elsif txen='1' then
				if pllat_txen='1' then
					txen := '0';
				end if;
			end if;
		end if;
		udp4_txen <= udp_txen or txen or pllat_txen;
	end process;


	udp4_len <= std_logic_vector(unsigned(udp_len) + (summation(udp4hdr_frame)/octect_size));
	udp4_hdr <= reverse(udp4_sp,8) & reverse(udp4_dp,8) & reverse(udp4_len,8) & udp4_cksm;

	udp4hdr_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => udp4_hdr,
		mii_txc  => mii_txc,
		mii_txdv => udp4_txen,
		mii_txd  => udp4hdr_txd);

	ipalat_e : entity hdl4fpga.mii_latency
	generic map (
		latency => summation(udp4hdr_frame))
	port map (
		mii_txc  => mii_txc,
		lat_txen => udp_txen,
		lat_txd  => udp_txd,
		mii_txen => pllat_txen,
		mii_txd  => pllat_txd);
		

	udp4_txd  <= wirebus(udp4hdr_txd & pllat_txd, not pllat_txen & pllat_txen);

end;

