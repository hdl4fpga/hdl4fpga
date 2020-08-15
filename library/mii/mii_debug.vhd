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
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

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

		tp1 : buffer std_logic;
		tp2 : buffer std_logic;
		tp3 : buffer std_logic;
		tp4 : buffer std_logic;

		video_clk   : in  std_logic;
		video_dot   : out std_logic;
		video_on    : out std_logic;
		video_hs    : out std_logic;
		video_vs    : out std_logic);
	end;

architecture struct of mii_debug is

	constant mymac   : std_logic_vector := x"00_40_00_01_02_03";
	constant myip4a  : std_logic_vector := x"c0_a8_00_0e";

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

	signal rxfrm_ptr : std_logic_vector(0 to unsigned_num_bits((64*8)/mii_rxd'length-1));
	signal txfrm_ptr : std_logic_vector(0 to unsigned_num_bits((64*8)/mii_rxd'length-1));

	signal ethhwda_rxdv : std_logic;
	signal ethhwsa_rxdv : std_logic;
	signal ethtype_rxdv : std_logic;
	signal myip4a_rxdv : std_logic;
	signal myip4a_equ  : std_logic;
	signal myip4a_rcvd  : std_logic;

	signal eth_txen  : std_logic;
	signal eth_txd   : std_logic_vector(mii_txd'range);
	alias  arp_treq  : std_logic is mii_treq(0);

	signal arptpa_rxdv : std_logic;

	signal sha_txen : std_logic;
	signal spa_txen : std_logic;
	signal tha_txen : std_logic;
	signal tpa_txen : std_logic;

	signal arp_txen     : std_logic;
	signal arp_txd      : std_logic_vector(mii_txd'range);
	signal arp_rcvd     : std_logic;

	signal ip4_txen  : std_logic := '0';
	signal ip4_txd   : std_logic_vector(mii_txd'range);

	signal txc_rxd : std_logic_vector(0 to mii_txd'length+1);
	signal rxc_txd : std_logic_vector(0 to mii_txd'length+1);

	signal display_txen : std_logic;
	signal display_txd  : std_logic_vector(mii_txd'range);

begin

	ethrx_e : entity hdl4fpga.eth_rx
	port map (
		mii_rxc   => mii_rxc,
		mii_rxdv  => mii_rxdv,
		mii_rxd   => mii_rxd,
		eth_ptr   => rxfrm_ptr,
		hwda_rxdv => ethhwda_rxdv,
		hwsa_rxdv => ethhwsa_rxdv,
		type_rxdv => ethtype_rxdv);

	arprx_e : entity hdl4fpga.arp_rx
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,
		eth_ptr  => rxfrm_ptr,
		tpa_rxdv => arptpa_rxdv);

	ctlr_b : block

		signal ethmymac_equ : std_logic;
		signal ethbcst_equ  : std_logic;

		signal typearp_equ  : std_logic;
		signal typeip4_equ  : std_logic;

		signal type_arp  : std_logic;
		signal type_ip4  : std_logic;

		signal arptpa_equ : std_logic;
		signal arp_tpa    : std_logic;
	begin

		ethmac_e : entity hdl4fpga.mii_romcmp
		generic map (
			mem_data => reverse(mymac, 8))
		port map (
			mii_rxc  => mii_rxc,
			mii_rxdv => ethhwda_rxdv,
			mii_rxd  => mii_rxd,
			mii_equ  => ethmymac_equ);

		ethbcst_rx_e : entity hdl4fpga.mii_romcmp
		generic map (
			mem_data => reverse(x"ff_ff_ff_ff_ff_ff", 8))
		port map (
			mii_rxc  => mii_rxc,
			mii_rxdv => ethhwda_rxdv,
			mii_rxd  => mii_rxd,
			mii_equ  => ethbcst_equ);

		ip4llccmp_e : entity hdl4fpga.mii_romcmp
		generic map (
			mem_data => reverse(llc_ip4,8))
		port map (
			mii_rxc  => mii_rxc,
			mii_rxdv => ethtype_rxdv,
			mii_rxd  => mii_rxd,
			mii_equ  => typeip4_equ);

		arpllccmp_e : entity hdl4fpga.mii_romcmp
		generic map (
			mem_data => reverse(llc_arp,8))
		port map (
			mii_rxc  => mii_rxc,
			mii_rxdv => ethtype_rxdv,
			mii_rxd  => mii_rxd,
			mii_equ  => typearp_equ);

		myip4a_rxdv <= arptpa_rxdv;
		myip4acmp_e : entity hdl4fpga.mii_romcmp
		generic map (
			mem_data => reverse(myip4a,8))
		port map (
			mii_rxc  => mii_rxc,
			mii_rxdv => myip4a_rxdv,
			mii_rxd  => mii_rxd,
			mii_equ  => myip4a_equ);

		process (mii_rxc)
		begin
			if rising_edge(mii_rxc) then
				if mii_rxdv='0' then
					type_ip4 <= '0';
					type_arp <= '0';
				elsif ethtype_rxdv='1' then
					type_ip4 <= typeip4_equ;
					type_arp <= typearp_equ;
				end if;
			end if;
		end process;

		process (mii_rxc)
		begin
			if rising_edge(mii_rxc) then
				if mii_rxdv='0' then
					myip4a_rcvd  <= '0';
				elsif myip4a_rxdv='1' then
					myip4a_rcvd <= myip4a_equ;
				end if;
			end if;
		end process;

		process (mii_rxc)
			variable x : std_logic;
		begin
			if rising_edge(mii_rxc) then
				if mii_rxdv='0' then
					arp_tpa  <= '0';
					x := '1';
				elsif arptpa_rxdv='1' then
					x := x and arp_rcvd and myip4a_equ and type_arp;
				else
					arp_tpa <= x;
					x := '0';
				end if;
			end if;
		end process;

		process (mii_rxc)
		begin
			if rising_edge(mii_rxc) then
				if mii_rxdv='0' then
					arp_rcvd <= '0';
				elsif ethhwda_rxdv='1' then
					arp_rcvd <= ethbcst_equ; --ethmymac_equ;
				end if;
			end if;
		end process;

		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				if pkt_req='0' then
					txfrm_ptr <= (others => '0');
				elsif txfrm_ptr(0)='0' then
					txfrm_ptr <= std_logic_vector(unsigned(txfrm_ptr) + 1);
				end if;
			end if;
		end process;


		tp1 <= arp_tpa;
	end block;


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

		eth_txd  <= arp_txd; --wirebus(arp_txd & ip4_txd, mii_gnt);
		eth_txen <= arp_txen; --setif(mii_gnt/=(mii_gnt'range => '0')) and (arp_txen or ip4_txen);
	end block;

	arptx_e : entity hdl4fpga.arp_tx
	port map (
		mii_txc  => mii_txc,
		mii_txen => pkt_req,
		arp_frm  => txfrm_ptr,

		sha      => mymac,
		spa      => myip4a,
		tha      => x"ff_ff_ff_ff_ff_ff",
		tpa      => myip4a,

		arp_txen => arp_txen,
		arp_txd  => arp_txd);

	ethtx_e : entity hdl4fpga.eth_tx
	port map (
		mii_txc  => mii_txc,
		eth_ptr  => txfrm_ptr,
		hwsa     => mymac,
		hwda     => x"ff_ff_ff_ff_ff_ff",
		llc      => llc_arp,
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
		rxc_rxd <= mii_rxd & mii_rxdv & tp1;

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
			variable rcvd : std_logic;
		begin
			if rising_edge(mii_txc) then
				if arp_rdy='1' then
					arp_req	<= '0';
				elsif txc_rxdv='0' then
					if rcvd='1' then
						arp_req <= '1';
					end if;
				end if;
				rcvd := txc_arprcvd;
			end if;
		end process;
		tp2 <=arp_req;

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

		display_txd  <= wirebus (mii_txd & txc_rxd(mii_rxd'range), mii_txen & txc_rxd(mii_rxd'length+1));
		display_txen <= mii_txen or txc_rxd(mii_rxd'length+1);

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
