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

		pkt_req    : in  std_logic;
		mii_txc     : in  std_logic;
		mii_txd     : buffer std_logic_vector;
		mii_txen    : buffer std_logic;

		tp1 : out std_logic;
		tp2 : out std_logic;
		tp3 : out std_logic;
		tp4 : out std_logic;

		video_clk   : in  std_logic;
		video_dot   : out std_logic;
		video_on    : out std_logic;
		video_hs    : out std_logic;
		video_vs    : out std_logic);
	end;

architecture struct of mii_debug is

	constant myip4   : std_logic_vector := x"c0_a8_00_0e";

	signal mii_gnt  : std_logic_vector(0 to 2-1);
	signal mii_treq : std_logic_vector(mii_gnt'range);
	signal mii_trdy : std_logic_vector(mii_gnt'range);

	signal mii_req  : std_logic_vector(mii_gnt'range);
	signal mii_rdy  : std_logic_vector(mii_gnt'range);

	alias arp_req   : std_logic is mii_req(0);
	alias arp_rdy   : std_logic is mii_rdy(0);
	alias dscb_req  : std_logic is mii_req(1);
	alias dscb_rdy  : std_logic is mii_rdy(1);
	alias dscb_treq : std_logic is mii_treq(1);

	signal eth_ptr   : std_logic_vector(0 to unsigned_num_bits((64*8)/mii_rxd'length-1));
	signal eth_bcst  : std_logic;
	signal eth_hwda  : std_logic;
	signal eth_type  : std_logic;
	signal arp_rcvd  : std_logic;
	signal pl_rxdv   : std_logic;

	signal eth_txen  : std_logic;
	signal eth_txd   : std_logic_vector(mii_txd'range);


	signal arp_treq  : std_logic :='0';
	signal arp_trdy  : std_logic;
	signal arp_txen  : std_logic;
	signal arp_txd   : std_logic_vector(mii_txd'range);

	signal ip4_txen  : std_logic;
	signal ip4_txd   : std_logic_vector(mii_txd'range);

	signal pl_txen   : std_logic;
	signal pl_txd    : std_logic_vector(mii_txd'range);

	signal ip4len_treq : std_logic;
	signal ip4len_trdy : std_logic;
	signal ip4len_txen : std_logic;
	signal ip4len_txd  : std_logic_vector(arp_txd'range);

	signal ip4da_treq : std_logic;
	signal ip4da_trdy : std_logic;
	signal ip4da_txen : std_logic;
	signal ip4da_txd  : std_logic_vector(arp_txd'range);

	signal udp4pl_len : std_logic_vector(16-1 downto 0);
	signal udp4_sp    : std_logic_vector(16-1 downto 0);
	signal udp4_dp    : std_logic_vector(16-1 downto 0);
	signal udp4_len   : std_logic_vector(16-1 downto 0);
	signal udp4_cksm  : std_logic_vector(16-1 downto 0);
	signal udp4_txen  : std_logic;
	signal udp4_txd   : std_logic_vector(arp_txd'range);

	signal ip4sa_treq : std_logic;
	signal ip4sa_trdy : std_logic;
	signal ip4sa_txen : std_logic;
	signal ip4sa_txd  : std_logic_vector(arp_txd'range);

	signal ip4saiptx_treq  : std_logic;
	signal ip4saarptx_treq : std_logic;

	signal dscb_trdy  : std_logic;
	signal dscb_cksm  : std_logic_vector(16-1 downto 0);
	signal dscb_len   : std_logic_vector(16-1 downto 0);

	signal txc_rxd : std_logic_vector(0 to mii_txd'length+1);
	signal rxc_txd : std_logic_vector(0 to mii_txd'length+1);

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
	generic map (
		myip4 => myip4)
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => pl_rxdv,
		mii_rxd  => mii_rxd,
		eth_ptr  => eth_ptr,
		eth_bcst => eth_bcst,
		arp_rcvd => arp_rcvd);

	ip4sa_treq <= ip4saiptx_treq or ip4saarptx_treq;
	ipsa_e : entity hdl4fpga.mii_mux
	port map (
		mux_data => reverse(myip4,8),
        mii_txc  => mii_txc,
		mii_treq => ip4sa_treq,
		mii_trdy => ip4sa_trdy,
        mii_txen => ip4sa_txen,
        mii_txd  => ip4sa_txd);
		
	ipda_e : entity hdl4fpga.mii_mux
	port map (
		--mux_data => reverse(myip4,8),
		mux_data => reverse(x"ff_ff_ff_ff",8),
        mii_txc  => mii_txc,
		mii_treq => ip4da_treq,
		mii_trdy => ip4da_trdy,
        mii_txen => ip4da_txen,
        mii_txd  => ip4da_txd);
		
	arptx_e : entity hdl4fpga.arp_tx
	port map (
		mii_txc   => mii_txc,

		ipsa_treq => ip4saarptx_treq,
		ipsa_trdy => ip4sa_trdy,
		ipsa_txen => ip4sa_txen,
		ipsa_txd  => ip4sa_txd,

		arp_treq  => arp_treq,
		arp_trdy  => open,
		arp_txen  => arp_txen,
		arp_txd   => arp_txd);

	dhcp_dscb_e : entity hdl4fpga.dhcp_dscb
	generic map (
		dhcp_ip4  => myip4)
	port map (
		mii_txc   => mii_txc,
		dscb_treq => dscb_treq,
		dscb_trdy => dscb_trdy,
		dscb_cksm => dscb_cksm,
		dscb_len  => dscb_len,
		dscb_txen => pl_txen,
		dscb_txd  => pl_txd);

	udp4_sp    <= x"0044";
	udp4_dp    <= x"0043";
	udp4pl_len <= dscb_len;
	udp4_cksm  <= dscb_cksm;
	udp4tx_e : entity hdl4fpga.udp4_tx
	port map (
		mii_txc   => mii_txc,

		pl_len    => udp4pl_len,
		pl_txen   => pl_txen,
		pl_txd    => pl_txd,

		udp4_sp   => udp4_sp,
		udp4_dp   => udp4_dp,
		udp4_cksm => udp4_cksm,
		udp4_len  => udp4_len,
		udp4_txen => udp4_txen,
		udp4_txd  => udp4_txd);

	iptx_e : entity hdl4fpga.ip_tx
	port map (
		mii_txc    => mii_txc,

		pl_len     => udp4_len,
		pl_txen    => udp4_txen,
		pl_txd     => udp4_txd,

		ip4sa_treq => ip4saiptx_treq,
		ip4sa_trdy => ip4sa_trdy,
		ip4sa_txen => ip4sa_txen,
		ip4sa_txd  => ip4sa_txd,
                                
		ip4da_treq => ip4da_treq,
		ip4da_trdy => ip4da_trdy,
		ip4da_txen => ip4da_txen,
		ip4da_txd  => ip4da_txd,

		ip4_txen   => ip4_txen,
		ip4_txd    => ip4_txd);

	mii_gnt_b : block
	begin
		mii_treq <= mii_gnt;
		mii_rdy  <= mii_gnt and not (mii_gnt'range => mii_txen);
		mii_trdy <= mii_gnt and not (mii_gnt'range => mii_txen);

		miignt_e : entity hdl4fpga.arbiter
		port map (
			clk => mii_txc,
			req => mii_req,
			gnt => mii_gnt);

		eth_txd  <= wirebus(arp_txd & ip4_txd, mii_gnt);
		eth_txen <= setif(mii_gnt/=(mii_gnt'range => '0')) and (arp_txen or ip4_txen);
	end block;

	ethtx_e : entity hdl4fpga.eth_tx
	port map (
		mii_txc  => mii_txc,
		pl_txen  => eth_txen,
		pl_txd   => eth_txd,
		eth_txen => mii_txen,
		eth_txd  => mii_txd);

	txc_sync_b : block

		signal rxc_rxd : std_logic_vector(0 to mii_txd'length+1);
		signal txc_txd : std_logic_vector(0 to mii_txd'length+1);

		alias  txc_rxdv    : std_logic is txc_rxd(mii_rxd'length);
		alias  txc_arprcvd : std_logic is txc_rxd(mii_rxd'length+1);

	begin
		rxc_rxd <= mii_rxd & mii_rxdv & arp_rcvd;

		rxc2txc_e : entity hdl4fpga.fifo
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
		begin
			if rising_edge(mii_txc) then
				if arp_rdy='1' then
					arp_req	<= '0';
				elsif txc_rxdv='0' then
					if txc_arprcvd='1' then
						arp_req <= '1';
					end if;
				end if;
			end if;
		end process;
		tp2 <=arp_req;
		tp1 <=arp_req;

		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				if dscb_rdy='1' then
					dscb_req <= '0';
				elsif pkt_req='1' then
					dscb_req <= '1';
				end if;
			end if;
		end process;

		txc_txd <= mii_txd & mii_txen & '0';
		txc2rxc_e : entity hdl4fpga.fifo
		generic map (
			mem_size   => 2,
			out_rgtr   => false, 
			check_sov  => false,
			check_dov  => false,
			gray_code  => false)
		port map (
			src_clk  => mii_txc,
			src_data => txc_txd,
			dst_clk  => mii_rxc,
			dst_data => rxc_txd);

		display_txd  <= wirebus (mii_txd & txc_rxd(mii_rxd'range), mii_txen & txc_rxd(mii_rxd'length));
		display_txen <= mii_txen or '0'; --txc_rxd(mii_rxd'length);

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
