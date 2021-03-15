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
use hdl4fpga.ipoepkg.all;

entity icmprply_tx is
	port (
		mii_clk   : in  std_logic;

		pl_frm    : in  std_logic;
		pl_irdy   : in  std_logic;
		pl_trdy   : out  std_logic;
		pl_data   : in  std_logic_vector;

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
	signal icmphdr_trdy : std_logic;
	signal icmphdr_data : std_logic_vector(icmp_data'range);
	signal icmphdr_end  : std_logic;
begin

	icmp_frm <= pl_frm or pl_irdy;

	mux_data  <= icmptype_rply & icmpcode_rply & icmp_cksm & icmp_id & icmp_seq;
	icmphdr_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => mux_data,
        sio_clk  => mii_clk,
		sio_frm  => icmp_frm,
		sio_irdy => icmp_trdy,
        sio_trdy => icmphdr_trdy,
        so_end   => icmphdr_end,
        so_data  => icmphdr_data);

	icmp_irdy <= wirebus(icmphdr_trdy & pl_irdy, not icmphdr_end & icmphdr_end)(0);
	icmp_data <= wirebus(icmphdr_data & pl_data, not icmphdr_end & icmphdr_end);

	pl_trdy  <= icmphdr_end and icmp_trdy;
end;

