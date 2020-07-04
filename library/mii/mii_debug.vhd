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
use hdl4fpga.videopkg.all;
use hdl4fpga.cgafonts.all;

entity mii_debug is
	generic (
		font_bitrom : std_logic_vector := psf1cp850x8x16;
		font_width  : natural := 8;
		font_height : natural := 16;

		timing_id   : videotiming_ids;
		code_spce   : std_logic_vector := to_ascii(" ");
		code_digits : std_logic_vector := to_ascii("0123456789abcdef");
		cga_bitrom  : std_logic_vector := (1 to 0 => '-'));
	port (
		mii_rxc     : in  std_logic;
		mii_rxd     : in  std_logic_vector;
		mii_rxdv    : in  std_logic;

		mii_txc     : in  std_logic;
		mii_treq    : in  std_logic;
		mii_txd     : buffer std_logic_vector;
		mii_txen    : buffer std_logic;

		video_clk   : in  std_logic;
		video_dot   : out std_logic;
		video_on    : out std_logic;
		video_hs    : out std_logic;
		video_vs    : out std_logic);
	end;

architecture struct of mii_debug is

	signal eth_ptr   : std_logic_vector(0 to unsigned_num_bits((64*8)/mii_rxd'length-1));
	signal eth_bcst  : std_logic;
	signal eth_hwda  : std_logic;
	signal eth_type  : std_logic;
	signal arp_req   : std_logic;
	signal pl_rxdv   : std_logic;

	signal arp_txen  : std_logic;
	signal arp_txd   : std_logic_vector(mii_txd'range);

	signal pl_txen   : std_logic;
	signal pl_txd    : std_logic_vector(mii_txd'range);

	signal ipsa_treq : std_logic;
	signal ipsa_trdy : std_logic;
	signal ipsa_txen : std_logic;
	signal ipsa_txd  : std_logic_vector(arp_txd'range);

begin

	ethrx_e : entity hdl4fpga.eth_rx
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,
		eth_ptr  => eth_ptr,
		eth_hwda => eth_hwda,
		eth_bcst => eth_bcst,
		pl_rxdv  => pl_rxdv);

	arprx_e : entity hdl4fpga.arp_rx
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => pl_rxdv,
		mii_rxd  => mii_rxd,
		eth_ptr  => eth_ptr,
		eth_bcst => eth_bcst,
		arp_req  => arp_req);

	ethtx_e : entity hdl4fpga.eth_tx
	port map (
		mii_txc  => mii_txc,
		pl_txen  => arp_txen,
		pl_txd   => arp_txd,
		eth_txen => mii_txen,
		eth_txd  => mii_txd);

	ipsa_e : entity hdl4fpga.mii_ram
	generic map (
		mem_data => reverse(x"c0_a8_00_0e",8))
	port map (
		mii_rxc  => mii_rxc,
        mii_rxdv => '0',
        mii_rxd  => mii_rxd,

        mii_txc  => mii_txc,
		mii_treq => ipsa_treq,
		mii_trdy => ipsa_trdy,
        mii_txen => ipsa_txen,
        mii_txd  => ipsa_txd);
		
	arptx_e : entity hdl4fpga.arp_tx
	port map (
		mii_txc   => mii_txc,

		ipsa_treq => ipsa_treq,
		ipsa_trdy => ipsa_trdy,
		ipsa_txen => ipsa_txen,
		ipsa_txd  => ipsa_txd,

		arp_treq  => mii_treq,
		arp_txen  => arp_txen,
		arp_txd   => arp_txd);

	mii_display_e : entity hdl4fpga.mii_display
	generic map (
		timing_id   => timing_id,
		code_spce   => code_spce, 
		code_digits => code_digits, 
		cga_bitrom  => cga_bitrom)
	port map (
--		mii_rxc     => mii_rxc,
--		mii_rxdv    => arp_req,
--		mii_rxd     => mii_rxd,

		mii_rxc     => mii_txc,
		mii_rxdv    => mii_txen,
		mii_rxd     => mii_txd,

		video_clk   => video_clk,
		video_dot   => video_dot,
		video_on    => video_on ,
		video_hs    => video_hs,
		video_vs    => video_vs);

end;
