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
		mii_clk     : in  std_logic;
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

	signal arp_treq  : std_logic :='0';
	signal arp_trdy  : std_logic;
	signal arp_txen  : std_logic;
	signal arp_txd   : std_logic_vector(mii_txd'range);

	signal ip4_txen  : std_logic;
	signal ip4_txd   : std_logic_vector(mii_txd'range);

	signal pl_txen   : std_logic;
	signal pl_txd    : std_logic_vector(mii_txd'range);
	signal mii_trdy  : std_logic;

	signal ip4len_treq : std_logic;
	signal ip4len_trdy : std_logic;
	signal ip4len_txen : std_logic;
	signal ip4len_txd  : std_logic_vector(arp_txd'range);

	signal ip4proto_treq : std_logic;
	signal ip4proto_trdy : std_logic;
	signal ip4proto_txen : std_logic;
	signal ip4proto_txd  : std_logic_vector(arp_txd'range);

	signal ip4da_treq : std_logic;
	signal ip4da_trdy : std_logic;
	signal ip4da_txen : std_logic;
	signal ip4da_txd  : std_logic_vector(arp_txd'range);

	signal ip4sa_treq : std_logic;
	signal ip4sa_trdy : std_logic;
	signal ip4sa_txen : std_logic;
	signal ip4sa_txd  : std_logic_vector(arp_txd'range);

	signal iptxip4sa_treq  : std_logic;
	signal arptxip4sa_treq : std_logic;

	signal display_txen : std_logic;
	signal display_txd  : std_logic_vector(mii_txd'range);

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

	iplen_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => reverse(x"0028",8),
        mii_txc  => mii_txc,
		mii_treq => ip4len_treq,
		mii_trdy => ip4len_trdy,
        mii_txen => ip4len_txen,
        mii_txd  => ip4len_txd);
		
	ip4sa_treq <= iptxip4sa_treq or arptxip4sa_treq;
	ipsa_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => reverse(x"c0_a8_00_0e",8),
        mii_txc  => mii_txc,
		mii_treq => ip4sa_treq,
		mii_trdy => ip4sa_trdy,
        mii_txen => ip4sa_txen,
        mii_txd  => ip4sa_txd);
		
	ipda_e : entity hdl4fpga.mii_mux
	port map (
		--mux_data => reverse(x"c0_a8_00_0e",8),
		mux_data => reverse(x"ff_ff_ff_ff",8),
        mii_txc  => mii_txc,
		mii_treq => ip4da_treq,
		mii_trdy => ip4da_trdy,
        mii_txen => ip4da_txen,
        mii_txd  => ip4da_txd);
		
	arptx_e : entity hdl4fpga.arp_tx
	port map (
		mii_txc   => mii_txc,

		ipsa_treq => arptxip4sa_treq,
		ipsa_trdy => ip4sa_trdy,
		ipsa_txen => ip4sa_txen,
		ipsa_txd  => ip4sa_txd,

		arp_treq  => arp_treq,
		arp_trdy  => arp_trdy,
		arp_txen  => arp_txen,
		arp_txd   => arp_txd);

	ipproto_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => reverse(x"11",8),
        mii_txc  => mii_txc,
		mii_treq => ip4proto_treq,
		mii_trdy => ip4proto_trdy,
        mii_txen => ip4proto_txen,
        mii_txd  => ip4proto_txd);
		
	ip4pl_e : entity hdl4fpga.mii_rom
	generic map (
		mem_data => reverse(x"00000000",8))
	port map (
		mii_txc  => mii_txc,
		mii_treq => mii_treq,
		mii_trdy => mii_trdy,
		mii_txen => pl_txen,
		mii_txd  => pl_txd);

	iptx_e : entity hdl4fpga.ip_tx
	port map (
		mii_txc   => mii_txc,

		pl_txen   => pl_txen,
		pl_txd    => pl_txd,

		ip4len_treq => ip4len_treq,
		ip4len_trdy => ip4len_trdy,
		ip4len_txen => ip4len_txen,
		ip4len_txd  => ip4len_txd,
                                 
--		ip4proto_treq => ip4proto_treq,
--		ip4proto_trdy => ip4proto_trdy,
--		ip4proto_txen => ip4proto_txen,
--		ip4proto_txd  => ip4proto_txd,

		ip4sa_treq  => iptxip4sa_treq,
		ip4sa_trdy  => ip4sa_trdy,
		ip4sa_txen  => ip4sa_txen,
		ip4sa_txd   => ip4sa_txd,
                                 
		ip4da_treq  => ip4da_treq,
		ip4da_trdy  => ip4da_trdy,
		ip4da_txen  => ip4da_txen,
		ip4da_txd   => ip4da_txd,

		ip4_txen    => ip4_txen,
		ip4_txd     => ip4_txd);

	ethtx_e : entity hdl4fpga.eth_tx
	port map (
		mii_txc  => mii_txc,
		pl_txen  => ip4_txen, --arp_txen,
		pl_txd   => ip4_txd, --arp_txd,
		eth_txen => mii_txen,
		eth_txd  => mii_txd);

	txc_sync_b : block
		signal rxc_rxd : std_logic_vector(0 to mii_txd'length);
		signal txc_rxd : std_logic_vector(0 to mii_txd'length);
	begin
		rxc_rxd <= mii_rxd & '0'; --mii_rxdv;

		sync_e : entity hdl4fpga.fifo
		generic map (
			mem_size   => 2,
			out_rgtr   => false, 
			check_sov  => false,
			check_dov  => false,
			gray_code  => false)
		port map (
			src_clk  => mii_rxc,
			src_data => rxc_rxd,
			dst_clk  => mii_txc,
			dst_data => txc_rxd);

		process (mii_txc)
			variable treq : std_logic;
		begin
			if rising_edge(mii_txc) then
				if arp_trdy='1' then
					arp_treq <= '0';
				elsif txc_rxd(mii_rxd'length)='0' then
					if treq='1' then
						arp_treq <= '1';
						arp_treq <= '0';
					end if;
				end if;
				treq := txc_rxd(mii_rxd'length);
			end if;
		end process;

		display_txd  <= wirebus (mii_txd & txc_rxd(mii_rxd'range), mii_txen & txc_rxd(mii_rxd'length));
		display_txen <= mii_txen or txc_rxd(mii_rxd'length);

	end block;

	mii_display_e : entity hdl4fpga.mii_display
	generic map (
		timing_id   => timing_id,
		code_spce   => code_spce, 
		code_digits => code_digits, 
		cga_bitrom  => cga_bitrom)
	port map (
		mii_txc     => mii_txc,
		mii_txen    => display_txen,
		mii_txd     => display_txd,

		video_clk   => video_clk,
		video_dot   => video_dot,
		video_on    => video_on ,
		video_hs    => video_hs,
		video_vs    => video_vs);

end;
