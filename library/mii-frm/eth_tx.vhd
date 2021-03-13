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

entity eth_tx is
	port (
		mii_clk  : in  std_logic;

		pl_frm   : in  std_logic;
		pl_irdy  : in  std_logic;
		pl_trdy  : out std_logic;
		pl_data  : in  std_logic_vector;

		hwsa     : in  std_logic_vector;
		hwda     : in  std_logic_vector;
		llc      : in  std_logic_vector;

		eth_frm  : buffer std_logic;
		eth_irdy : buffer std_logic;
		eth_trdy : in  std_logic;
		eth_data : out std_logic_vector);

end;

architecture def of eth_tx is

	signal plbuf_irdy    : std_logic;
	signal plbuf_trdy    : std_logic;
	signal plbuf_data    : std_logic_vector(pl_data'range);

	constant lat_length : natural := summation(eth_frame)/eth_txd'length;
	signal lat_txen  : std_logic;
	signal lat_txd   : std_logic_vector(eth_txd'range);

	signal padd_txen  : std_logic;
	signal padd_txd   : std_logic_vector(eth_txd'range);

	signal dll_txen  : std_logic;
	signal dll_txd   : std_logic_vector(eth_txd'range);


begin

	plbuf_trdy <= to_stdulogic(to_bit(eth_trdy and ipv4a_end and not ipv4abuf_irdy)); 
	pl_e : entity hdl4fpga.fifo
	generic map (
		max_depth => 2**(unsigned_num_bits(summation(ipv4hdr_frame)/pl_data'length-1)),
		latency   => 1,
		check_sov => true,
		check_dov => true,
		gray_code => false)
	port map (
		src_clk   => mii_clk,
		src_irdy  => pl_irdy,
		src_trdy  => pl_trdy,
		src_data  => pl_data,
		dst_clk   => mii_clk,
		dst_irdy  => plbuf_irdy,
		dst_trdy  => plbuf_trdy,
		dst_data  => plbuf_data);

	process (pl_frm, plbuf_irdy, mii_clk)
		variable q : std_logic;
	begin
		if rising_edge(mii_clk) then
			q := pl_frm and pl_irdy;
		end if;
		eth_frm <= pl_frm or q or plbuf_irdy;
	end process;

	dll_mux <= hwda & hwsa & llc;
	dll_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => dlc_mux,
		sio_clk  => mii_clk,
		sio_frm  => eth_frm,
		sio_irdy => eth_trdy,
		sio_trdy => dll_trdy,
		so_end   => dll_end,
		so_data  => dll_data);

	fcs_txd  <= wirebus (dll_data & plbuf_data, );
	dll_txen <= padd_txen or lat_txen;

	fcs_e : entity hdl4fpga.ethfcs_tx
	port map (
		mii_txc  => mii_txc,
		dll_frm  => eth_frm,
		dll_irdy => ,
		dll_data => dll_data,
		mii_txen => eth_txen,
		mii_txd  => eth_txd);

end;

