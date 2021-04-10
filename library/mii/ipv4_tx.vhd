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

entity ipv4_tx is
	port (
		mii_clk  : in  std_logic;

		pl_frm   : in  std_logic;
		pl_irdy  : in  std_logic;
		pl_trdy  : out std_logic;
		pl_data  : in  std_logic_vector;

		ipv4_len   : in  std_logic_vector(0 to 16-1);
		ipv4_sa    : in  std_logic_vector(0 to 32-1);
		ipv4_da    : in  std_logic_vector(0 to 32-1);
		ipv4_proto : in  std_logic_vector(0 to 8-1);

		ipv4_frm  : buffer std_logic;
		ipv4_irdy : buffer std_logic;
		ipv4_trdy : in  std_logic;
		ipv4_data : out std_logic_vector);
end;

architecture def of ipv4_tx is

	signal cksm_frm      : std_logic;
	signal cksm_irdy     : std_logic;
	signal cksm_data     : std_logic_vector(ipv4_data'range);
	signal chksum        : std_logic_vector(16-1 downto 0);

	signal ipv4hdr_irdy  : std_logic;
	signal ipv4hdr_trdy  : std_logic;
	signal ipv4hdr_end   : std_logic;
	signal ipv4hdr_mux   : std_logic_vector(0 to summation(
		ipv4hdr_frame(hdl4fpga.ipoepkg.ipv4_verihl to hdl4fpga.ipoepkg.ipv4_proto))-1);
	signal ipv4hdr_data  : std_logic_vector(ipv4_data'range);

	signal ipv4a_mux     : std_logic_vector(0 to ipv4_sa'length+ipv4_da'length-1);
	signal ipv4a_irdy    : std_logic;
	signal xxx_irdy      : std_logic;
	signal ipv4a_trdy    : std_logic;
	signal ipv4a_end     : std_logic;
	signal ipv4a_data    : std_logic_vector(ipv4_data'range);
	signal ipv4abuf_irdy : std_logic;
	signal ipv4abuf_trdy : std_logic;
	signal ipv4abuf_data : std_logic_vector(pl_data'range);

	signal ipv4cksm_irdy : std_logic;
	signal ipv4cksm_trdy : std_logic;
	signal ipv4cksm_end  : std_logic;
	signal ipv4cksm_data : std_logic_vector(ipv4_data'range);

	signal lenproto_mux : std_logic_vector(0 to ipv4_len'length+8+ipv4_proto'length-1);
	signal lenproto_end : std_logic;
	signal lenproto_data : std_logic_vector(ipv4_data'range);

begin

	pl_trdy <= to_stdulogic(to_bit(ipv4_trdy and ipv4a_end and not ipv4abuf_irdy)); 
	ipv4_frm <= pl_frm;

	ipv4hdr_mux <=
		x"4500"    &   -- Version, TOS
		ipv4_len   &   -- Length
		x"0000"    &   -- Identification
		x"0000"    &   -- Fragmentation
		x"05"      &   -- Time To Live
		ipv4_proto;

	ipv4hdr_b : block 
		signal hdr_trdy  : std_logic;
		signal hdr_end   : std_logic;
		signal hdr_data  : std_logic_vector(ipv4_data'range);
	begin
		ipv4hdr_e : entity hdl4fpga.sio_mux
		port map (
			mux_data => ipv4hdr_mux,
			sio_clk  => mii_clk,
			sio_frm  => ipv4_frm,
			sio_irdy => ipv4_trdy,
			sio_trdy => hdr_trdy,
			so_end   => hdr_end,
			so_data  => hdr_data);

		data_e : entity hdl4fpga.align
		generic map (
			n => pl_data'length,
			d => (0 to pl_data'length-1 =>16/pl_data'length))
		port map (
			ena => ipv4_trdy,
			clk   => mii_clk,
			di  => hdr_data,
			do  => ipv4hdr_data);

		end_e : entity hdl4fpga.align
		generic map (
			n => 1,
			i => (0 to 1-1 => '0'),
			d => (0 to 1-1 => 16/pl_data'length))
		port map (
			ena   => ipv4_trdy,
			clk   => mii_clk,
			di(0) => hdr_end,
			do(0) => ipv4hdr_end);

		trdy_e : entity hdl4fpga.align
		generic map (
			n => 1,
			i => (0 to 1-1 => '0'),
			d => (0 to 1-1 => 16/pl_data'length))
		port map (
			ena   => ipv4_trdy,
			clk   => mii_clk,
			di(0) => hdr_trdy,
			do(0) => ipv4hdr_trdy);
	end block;

	lenproto_mux <= ipv4_len & x"00" & ipv4_proto;
	lenproto_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => lenproto_mux,
        sio_clk  => mii_clk,
        sio_frm  => ipv4_frm,
        sio_irdy => ipv4_trdy,
        so_end   => lenproto_end,
        so_data  => lenproto_data);

	ipv4a_mux  <= ipv4_sa & ipv4_da;
	ipv4a_irdy <= lenproto_end;
	ipv4a_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => ipv4a_mux,
        sio_clk  => mii_clk,
        sio_frm  => ipv4_frm,
        sio_irdy => ipv4a_irdy,
        sio_trdy => ipv4a_trdy,
        so_end   => ipv4a_end,
        so_data  => ipv4a_data);

	ipv4abuf_trdy <= ipv4cksm_end and ipv4_trdy;
	xxx_irdy <= not ipv4a_end and ipv4a_irdy;
	ipv4afifo_e : entity hdl4fpga.fifo
	generic map (
		max_depth => (ipv4_sa'length+ipv4_da'length)/pl_data'length,
		latency   => 1,
		check_sov => true,
		check_dov => true,
		gray_code => false)
	port map (
		src_clk   => mii_clk,
		src_irdy  => xxx_irdy,
		src_trdy  => open,
		src_data  => ipv4a_data,
		dst_clk   => mii_clk,
		dst_irdy  => ipv4abuf_irdy,
		dst_trdy  => ipv4abuf_trdy,
		dst_data  => ipv4abuf_data);

	cksm_data <= wirebus(lenproto_data & ipv4a_data, not lenproto_end & (lenproto_end and not ipv4a_end));
	cksm_irdy <= ipv4_trdy and (not lenproto_end or not ipv4a_end);
	mii_1cksm_e : entity hdl4fpga.mii_1cksm
	generic map (
		cksm_init => oneschecksum(not (
			x"4500" &   -- Version, TOS
			x"0500"),   -- Time To Live
			ipv4hdr_frame(hdl4fpga.ipoepkg.ipv4_len)))
	port map (
		mii_clk  => mii_clk,
		mii_frm  => ipv4_frm,
		mii_irdy => cksm_irdy,
		mii_data => cksm_data,
		mii_cksm => chksum);

	ipv4cksm_irdy <= ipv4_trdy and ipv4hdr_end;
	ipv4chsm_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => chksum,
        sio_clk  => mii_clk,
        sio_frm  => ipv4_frm,
        sio_irdy => ipv4cksm_irdy,
        sio_trdy => ipv4cksm_trdy,
        so_end   => ipv4cksm_end,
        so_data  => ipv4cksm_data);

	ipv4_irdy <= primux(
		ipv4hdr_trdy    & ipv4cksm_trdy    & ipv4abuf_irdy & pl_irdy,
		not ipv4hdr_end & not ipv4cksm_end & ipv4abuf_irdy & pl_irdy)(0);
	ipv4_data <= wirebus(
		ipv4hdr_data & ipv4cksm_data & ipv4abuf_data & pl_data,
		not ipv4hdr_end                     & 
		(not ipv4cksm_end and ipv4hdr_end)  & 
		(ipv4abuf_irdy    and ipv4cksm_end) & 
		(pl_irdy       and not ipv4abuf_irdy and ipv4cksm_end));
end;
