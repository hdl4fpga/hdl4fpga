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
		mii_clk  : in  std_logic;

		pl_frm   : in  std_logic;
		pl_irdy  : in  std_logic;
		pl_trdy  : out std_logic;
		pl_len   : in  std_logic_vector(16-1 downto 0);
		pl_data  : in  std_logic_vector;

		udp_cksm : in  std_logic_vector(0 to 16-1) := x"0000";
		udp_sp   : in  std_logic_vector(0 to 16-1);
		udp_dp   : in  std_logic_vector(0 to 16-1);

		udp_frm  : buffer std_logic;
		udp_irdy : out std_logic;
		udp_trdy : in  std_logic;
		udp_len  : buffer std_logic_vector(16-1 downto 0);
		udp_data : out std_logic_vector;
		udp_end  : out std_logic;
		tp       : out std_logic_vector(1 to 32));
end;

architecture def of udp_tx is

	signal mux_udphdr  : std_logic_vector(0 to summation(udp4hdr_frame)-1);
	signal udphdr_data : std_logic_vector(pl_data'range);
	signal udphdr_trdy : std_logic;
	signal udphdr_end  : std_logic;

begin

	udp_len <= std_logic_vector(unsigned(udp_len) + (summation(udp4hdr_frame)/octect_size));
	mux_udphdr <= udp_sp & udp_dp & udp_len & udp_cksm;

	udphdr_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => mux_udphdr,
		sio_clk  => mii_clk,
		sio_frm  => udp_frm,
		sio_irdy => udp_trdy,
		sio_trdy => udphdr_trdy,
		so_end   => udphdr_end,
		so_data  => udphdr_data);

	udp_irdy <= primux(udphdr_trdy & pl_irdy, not udphdr_end & '1')(0);
	udp_data <= primux(udphdr_data & pl_data, not udphdr_end & '1');

	pl_trdy  <= udphdr_end and udp_trdy;
end;

