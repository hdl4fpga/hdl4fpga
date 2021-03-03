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
		mii_clk   : in  std_logic;

		pl_frm   : in  std_logic;
		pl_irdy   : in  std_logic;
		pl_data    : in  std_logic_vector;

		icmp_ptr  : in  std_logic_vector;
		icmp_cksm : in  std_logic_vector(0 to 16-1);
		icmp_id   : in  std_logic_vector(0 to 16-1);
		icmp_seq  : in  std_logic_vector(0 to 16-1);

		icmp_frm  : buffer std_logic;
		icmp_irdy : out std_logic;
		icmp_trdy : in  std_logic;
		icmp_data : out std_logic_vector);
end;

architecture def of icmprply_tx is
	signal mux_data     : std_logic_vector(0 to 64-1);
	signal icmphdr_frm  : std_logic;
	signal icmphdr_data : std_logic_vector(icmp_data'range);
	signal pllat_frm    : std_logic;
	signal pllat_data   : std_logic_vector(icmp_data'range);
begin

	process (pl_frm, pllat_frm, mii_clk)
		variable frm : std_logic := '0';
	begin
		if rising_edge(mii_clk) then
			if pl_frm='1' then
				frm := '1';
			elsif frm='1' then
				if pllat_frm='1' then
					frm := '0';
				end if;
			end if;
		end if;
		icmp_frm <= pl_frm or frm or pllat_frm;
	end process;

	pllat_e : entity hdl4fpga.mii_latency
	generic map (
		latency => (summation(icmphdr_frame & icmprqst_frame)))
	port map (
		mii_clk  => mii_clk,
		mii_frm  => pl_frm,
		mii_irdy => pl_irdy,
		mii_trdy => pl_trdy,
		mii_data => pl_data,
		lat_frm  => pllat_frm,
		lat_irdy => pllat_irdy,
		lat_trdy => icmp_trdy,
		lat_txd  => pllat_txd);
		
	icmp_irdy <= wirebus (pl_irdy & '1', pl_frm & pllat_frm);
	mux_data  <= icmptype_rply & icmpcode_rply & icmp_cksm & icmp_id & icmp_seq;
	icmp_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => mux_data,
        sio_clk  => mii_clk,
		si_frm   => icmp_frm,
		so_irdy  => icmp_irdy,
        so_trdy  => icmphdr_txen,
        so_end   => icmphdr_txen,
        so_data  => icmphdr_data);

	icmp_data <= wirebus(icmphdr_data & pllat_txd, icmphdr_txen & pllat_txen);

end;

