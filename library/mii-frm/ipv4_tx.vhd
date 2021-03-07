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

		ipv4len   : in  std_logic_vector(0 to 16-1);
		ipv4sa    : in  std_logic_vector(0 to 32-1);
		ipv4da    : in  std_logic_vector(0 to 32-1);
		ipv4proto : in  std_logic_vector(0 to 8-1);

		ipv4_ptr  : in  std_logic_vector;
		ipv4_frm  : buffer std_logic;
		ipv4_data : out std_logic_vector);
end;

architecture def of ipv4_tx is

	signal pllat_frm     : std_logic;
	signal pllat_irdy    : std_logic;
	signal pllat_trdy    : std_logic;
	signal pllat_data    : std_logic_vector(pl_data'range);

	signal cksm_frm      : std_logic;
	signal cksm_irdy     : std_logic;
	signal cksm_data     : std_logic_vector(ipv4_txd'range);
	signal chksum        : std_logic_vector(ipv4_txd'range);

	signal ipv4shdr_frm  : std_logic;
	signal ipv4shdr_irdy : std_logic;
	signal ipv4shdr_trdy : std_logic_vector(ipv4_txd'range);
	signal ipv4shdr_data : std_logic_vector(0 to ipv4_shdr'length+ipv4hdr_frame(ipv4_proto)-1);

	signal ipv4a_frm     : std_logic;
	signal ipv4a_irdy    : std_logic_vector(ipv4_txd'range);
	signal ipv4a_data    : std_logic;
	signal ipv4a_txd     : std_logic_vector(ipv4_txd'range);
	signal ipv4len_txen  : std_logic;
	signal ipv4len_txd   : std_logic_vector(ipv4_txd'range);

	constant myipv4_len  : natural :=  0;
	constant myipv4_sa   : natural :=  1;
	constant myipv4_da   : natural :=  2;

begin

	pl_e : entity hdl4fpga.fifo
	generic map (
		fifo_depth => 
		latency   => 0,
		check_sov => true,
		check_dov => true,
		gray_code => false)
	port map (
		src_clk   => mii_clk,
		src_irdy  => pl_irdy,
		src_trdy  => pl_trdy,
		src_data  => pl_data,
		dst_clk   => mii_clk,
		dst_irdy  => pllat_irdy,
		dst_trdy  => pllat_trdy,
		dst_data  => pllat_data);

	ipv4shdr_irdy <= frame_decode(ipv4_ptr, ipv4hdr_frame, ipv4_txd'length, ipv4_proto, gt);
	ipv4shdr_data <= ipv4_hdr1 & ipv4_len & ipv4_hdr2 & ipv4proto;
	ipv4shdr_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => ipv4shdr_data,
        sio_clk  => mii_clk,
        sio_frm  => ipv4_frm,
        sio_irdy => ipv4hdr_irdy,
        sio_trdy => ipv4hdr_trdy,
        so_end   => ipv4hdr_end;
        so_data  => ipv4hdr_data);

	ipv4a_itrdy <= 
		frame_decode(ipv4_ptr, myipv4hdr_frame, ipv4_txd'length, myipv4_da) or 
		frame_decode(ipv4_ptr, myipv4hdr_frame, ipv4_txd'length, myipv4_sa);
	ipv4a_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => ipv4a,
        sio_clk  => mii_clk,
        sio_frm  => ipv4_frm,
        sio_irdy => ipv4a_irdy,
        sio_trdy => ipv4a_trdy,
        so_end   => ipv4a_end;
        so_data  => ipv4a_data);

	cksmd_irdy <= (ipv4a_irdy and ipv4a_trdy) and (ipv4misc_irdy and ipv4misc_trdy); 
	mii_1cksm_e : entity hdl4fpga.mii_1cksm
	generic map (
		cksm_init =>  oneschecksum(not (ipv4_shdr & x"00"), cksm_init'length))
	port map (
		mii_clk  => mii_clk,
		mii_frm  => ipv4_frm,
		mii_irdy => cksm_irdy,
		mii_data => cksm_data,
		mii_cksm => chksum);

end;
