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
		icmp_cksm : in  std_logic_vector(0 to 16-1);
		icmp_id   : in  std_logic_vector(0 to 16-1);
		icmp_seq  : in  std_logic_vector(0 to 16-1);

		icmp_frm  : out std_logic := '0';
		icmp_data : out std_logic_vector);
end;

architecture def of icmprply_tx is
	signal icmp_frm     : std_logic;
	signal icmp_data    : std_logic_vector(0 to 64-1);
	signal icmphdr_txen : std_logic;
	signal icmphdr_data : std_logic_vector(icmp_data'range);
	signal pllat_txen   : std_logic;
	signal pllat_txd    : std_logic_vector(icmp_data'range);
begin

	process (pl_txen, pllat_txen, mii_txc)
		variable txen : std_logic := '0';
	begin
		if rising_edge(mii_txc) then
			if pl_txen='1' then
				txen := '1';
			elsif txen='1' then
				if pllat_txen='1' then
					txen := '0';
				end if;
			end if;
		end if;
		icmp_frm <= pl_txen or txen or pllat_txen;
	end process;

	pllat_e : entity hdl4fpga.mii_latency
	generic map (
		latency => (summation(icmphdr_frame & icmprqst_frame)))
	port map (
		mii_txc  => mii_txc,
		lat_txen => pl_txen,
		lat_txd  => pl_txd,
		mii_txen => pllat_txen,
		mii_txd  => pllat_txd);
		
	icmp_data <= icmptype_rply & icmpcode_rply & icmp_cksm & icmp_id & icmp_seq;
	icmp_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => icmp_data,
        sio_clk  => mii_txc,
		si_frm   => icmp_frm,
		so_irdy  => '1',
        so_trdy  => icmphdr_txen,
        so_end   => icmphdr_txen,
        so_data  => icmphdr_data);

	icmp_data <= wirebus(icmphdr_data & pllat_txd, icmphdr_txen & pllat_txen);

end;

