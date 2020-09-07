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

		dhcp_req    : in  std_logic;
		mii_txc     : in  std_logic;
		mii_txd     : buffer std_logic_vector;
		mii_txen    : buffer std_logic;

		video_clk   : in  std_logic;
		video_dot   : out std_logic;
		video_on    : out std_logic;
		video_hs    : out std_logic;
		video_vs    : out std_logic;

		tp1 : buffer std_logic;
		tp2 : buffer std_logic;
		tp3 : buffer std_logic;
		tp4 : buffer std_logic);

	end;

architecture struct of mii_debug is

	constant mymac       : std_logic_vector := x"00_40_00_01_02_03";
	constant myip4a      : std_logic_vector := x"c0_a8_00_0e";
	signal   ip4da       : std_logic_vector(0 to 32-1);
	signal   ip4len_rx   : std_logic_vector(0 to 16-1);
	signal   ip4len_tx   : std_logic_vector(0 to 16-1);

	signal mii_gnt       : std_logic_vector(0 to 3-1);
	signal mii_trdy      : std_logic_vector(mii_gnt'range);

	signal mii_req       : std_logic_vector(mii_gnt'range);
	signal mii_rdy       : std_logic_vector(mii_gnt'range);

	alias arp_req        : std_logic is mii_req(0);
	alias arp_rdy        : std_logic is mii_rdy(0);
	alias arp_gnt        : std_logic is mii_gnt(0);
	alias icmp_req       : std_logic is mii_req(1);
	alias icmp_rdy       : std_logic is mii_rdy(1);
	alias icmp_gnt       : std_logic is mii_gnt(1);
	alias dscb_req       : std_logic is mii_req(2);
	alias dscb_rdy       : std_logic is mii_rdy(2);
	alias dscb_gnt       : std_logic is mii_gnt(2);
	signal dscb_rcvd     : std_logic;
	signal udp_gnt       : std_logic;
	signal ip4_gnt       : std_logic;


	signal rxfrm_ptr     : std_logic_vector(0 to unsigned_num_bits((128*octect_size)/mii_rxd'length-1));
	signal txfrm_ptr     : std_logic_vector(0 to unsigned_num_bits((512*octect_size)/mii_rxd'length-1));

	signal ethhwda_ena   : std_logic;
	signal ethhwsa_ena   : std_logic;
	signal ethtype_ena   : std_logic;
	signal myip4a_ena    : std_logic;
	signal myip4a_rcvd   : std_logic;

	signal eth_txen      : std_logic;
	signal eth_txd       : std_logic_vector(mii_txd'range);

	signal arptpa_rxdv   : std_logic;

	signal sha_txen      : std_logic;
	signal spa_txen      : std_logic;
	signal tha_txen      : std_logic;
	signal tpa_txen      : std_logic;

	signal typearp_rcvd  : std_logic;
	signal arp_txen      : std_logic;
	signal arp_txd       : std_logic_vector(mii_txd'range);
	signal arp_rcvd      : std_logic;

	signal typeip4_rcvd  : std_logic;
	signal ip4pl_txen    : std_logic;
	signal ip4pl_txd     : std_logic_vector(mii_txd'range);
	signal ip4_txen      : std_logic := '0';
	signal ip4_txd       : std_logic_vector(mii_txd'range);

	signal ip4da_rxdv    : std_logic;
	signal ip4sa_tx      : std_logic_vector(0 to 32-1);
	signal ip4sa_rxdv    : std_logic;
	signal ip4len_rxdv   : std_logic;
	signal ip4proto_rxdv : std_logic;
	signal ip4proto_tx   : std_logic_vector(0 to ip4hdr_frame(ip4_proto)-1);
	signal ip4icmp_rcvd  : std_logic;
	signal ip4pl_rxdv    : std_logic;

	signal icmp_txen     : std_logic;
	signal icmp_txd      : std_logic_vector(mii_txd'range);
	signal udpdhcp_len   : std_logic_vector(0 to 16-1);
	signal udp_len       : std_logic_vector(0 to 16-1);
	signal udpip_len     : std_logic_vector(0 to 16-1);

	signal udpdhcp_txd   : std_logic_vector(mii_txd'range);
	signal udpdhcp_txen  : std_logic;

	signal udpproto_rcvd : std_logic;
	signal udpsp_rxdv    : std_logic;
	signal udpdp_rxdv    : std_logic;
	signal udplen_rxdv   : std_logic;
	signal udpcksm_rxdv  : std_logic;
	signal udppl_rxdv    : std_logic;

	signal icmp_rcvd     : std_logic;
	signal txc_rxd       : std_logic_vector(0 to mii_txd'length+2);
	signal rxc_txd       : std_logic_vector(0 to mii_txd'length+2);

	signal display_txen  : std_logic;
	signal display_txd   : std_logic_vector(mii_txd'range);

	signal llc           : std_logic_vector(llc_arp'range);

begin

	ethrx_e : entity hdl4fpga.eth_rx
	port map (
		mii_rxc   => mii_rxc,
		mii_rxdv  => mii_rxdv,
		mii_rxd   => mii_rxd,
		eth_ptr   => rxfrm_ptr,
		hwda_rxdv => ethhwda_ena,
		hwsa_rxdv => ethhwsa_ena,
		type_rxdv => ethtype_ena);

	ip4llccmp_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(llc_ip4,8))
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_ena  => ethtype_ena ,
		mii_rxd  => mii_rxd,
		mii_equ  => typeip4_rcvd);

	arpllccmp_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(llc_arp,8))
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_ena  => ethtype_ena ,
		mii_rxd  => mii_rxd,
		mii_equ  => typearp_rcvd);

	arp_b : block
	begin

		arprx_e : entity hdl4fpga.arp_rx
		port map (
			mii_rxc   => mii_rxc,
			mii_rxdv  => mii_rxdv,
			mii_rxd   => mii_rxd,
			mii_ptr   => rxfrm_ptr,
			arp_ena   => typearp_rcvd,
			tpa_rxdv  => arptpa_rxdv);

		arptx_e : entity hdl4fpga.arp_tx
		port map (
			mii_txc  => mii_txc,
			mii_txen => arp_gnt,
			arp_frm  => txfrm_ptr,

			sha      => mymac,
			spa      => myip4a,
			tha      => x"ff_ff_ff_ff_ff_ff",
			tpa      => myip4a,

			arp_txen => arp_txen,
			arp_txd  => arp_txd);

	end block;

	ip4_b : block
	begin
		ip4rx_e : entity hdl4fpga.ip4_rx
		port map (
			mii_rxc    => mii_rxc,
			mii_rxdv   => mii_rxdv,
			mii_rxd    => mii_rxd,
			mii_ptr    => rxfrm_ptr,

			ip4_ena    => typeip4_rcvd,
			ip4len_rxdv => ip4len_rxdv,
			ip4da_rxdv => ip4da_rxdv,
			ip4sa_rxdv => ip4sa_rxdv,
			ip4proto_rxdv => ip4proto_rxdv,

			ip4pl_rxdv => ip4pl_rxdv);

		icmpproto_e : entity hdl4fpga.mii_romcmp
		generic map (
			mem_data => reverse(ip4proto_icmp,8))
		port map (
			mii_rxc  => mii_rxc,
			mii_rxdv => mii_rxdv,
			mii_rxd  => mii_rxd,
			mii_ena  => ip4proto_rxdv,
			mii_equ  => ip4icmp_rcvd);

		udpproto_e : entity hdl4fpga.mii_romcmp
		generic map (
			mem_data => reverse(ip4proto_udp,8))
		port map (
			mii_rxc  => mii_rxc,
			mii_rxdv => mii_rxdv,
			mii_rxd  => mii_rxd,
			mii_ena  => ip4proto_rxdv,
			mii_equ  => udpproto_rcvd);

		icmp_b : block

			signal icmpid_rxdv   : std_logic;
			signal icmpid_data   : std_logic_vector(0 to 16-1);
			signal icmpseq_rxdv  : std_logic;
			signal icmpseq_data  : std_logic_vector(0 to 16-1);
			signal icmpcksm_rxdv : std_logic;
			signal icmpcksm_data : std_logic_vector(0 to 16-1);
			signal icmprply_cksm : std_logic_vector(0 to 16-1);

			signal icmppl_rxdv   : std_logic;
			signal icmppl_txen   : std_logic;
			signal icmppl_txd    : std_logic_vector(mii_txd'range);

		begin

			icmprqstrx_e : entity hdl4fpga.icmprqst_rx
			port map (
				mii_rxc  => mii_rxc,
				mii_rxdv => mii_rxdv,
				mii_rxd  => mii_rxd,
				mii_ptr  => rxfrm_ptr,

				icmprqst_ena  => ip4icmp_rcvd,
				icmpid_rxdv   => icmpid_rxdv,
				icmpcksm_rxdv => icmpcksm_rxdv,
				icmpseq_rxdv  => icmpseq_rxdv,
				icmppl_rxdv   => icmppl_rxdv);

			icmpcksm_e : entity hdl4fpga.mii_des
			port map (
				mii_rxc  => mii_rxc,
				mii_rxdv => icmpcksm_rxdv,
				mii_rxd  => mii_rxd,
				des_data => icmpcksm_data);

			icmpseq_e : entity hdl4fpga.mii_des
			port map (
				mii_rxc  => mii_rxc,
				mii_rxdv => icmpseq_rxdv,
				mii_rxd  => mii_rxd,
				des_data => icmpseq_data);

			icmpid_e : entity hdl4fpga.mii_des
			port map (
				mii_rxc  => mii_rxc,
				mii_rxdv => icmpid_rxdv,
				mii_rxd  => mii_rxd,
				des_data => icmpid_data);

			icmpdata_e : entity hdl4fpga.mii_ram
			generic map (
				mem_size => 64*octect_size)
			port map (
				mii_rxc  => mii_rxc,
				mii_rxdv => icmppl_rxdv,
				mii_rxd  => mii_rxd,

				mii_txc  => mii_txc,
				mii_txen => icmp_gnt,
				mii_txdv => icmppl_txen,
				mii_txd  => icmppl_txd);

			icmprply_cksm <= oneschecksum(icmpcksm_data & icmptype_rqst, icmprply_cksm'length);
			icmprply_e : entity hdl4fpga.icmprply_tx
			port map (
				mii_txc   => mii_txc,

				pl_txen   => icmppl_txen,
				pl_txd    => icmppl_txd,

				icmp_ptr  => txfrm_ptr,
				icmp_cksm => icmprply_cksm,
				icmp_id   => icmpid_data,
				icmp_seq  => icmpseq_data,
				icmp_txen => icmp_txen,
				icmp_txd  => icmp_txd);

		end block;

		dhcp_b : block
			constant dhcp_cp : std_logic_vector := x"0044";
			constant dhcp_sp : std_logic_vector := x"0043";

			signal myip4a        : std_logic_vector(0 to 32-1) := x"c0_a8_00_0e";
			signal udpports_rxdv : std_logic;
			signal udpports_rcvd : std_logic;
			signal dhcpyia_rxdv  : std_logic;

			signal ip4a_req      : std_logic := '0';

		begin

			process (mii_txc)
				variable req : std_logic;
			begin
				if rising_edge(mii_txc) then
					if dscb_rdy='1' then
						dscb_req <= '0';
					elsif ip4a_req='1' then
						if mii_txen='1' then
							ip4a_req <= '0';
						end if;
					elsif req='0' and dhcp_req='1' then
						ip4a_req <= '1';
						dscb_req <= '1';
					end if;
					req := dhcp_req;
				end if;
			end process;

			dhcp_dscb_e : entity hdl4fpga.dhcp_dscb
			generic map (
				dhcp_sp => dhcp_cp,
				dhcp_dp => dhcp_sp)
			port map (
				mii_txc   => mii_txc,
				mii_txen  => dscb_gnt,
				udpdhcp_ptr  => txfrm_ptr,
				udpdhcp_len  => udpdhcp_len,
				udpdhcp_txen => udpdhcp_txen,
				udpdhcp_txd  => udpdhcp_txd);

			udpports_rxdv <= udpsp_rxdv or udpdp_rxdv;
			dhcpport_e : entity hdl4fpga.mii_romcmp
			generic map (
				mem_data => reverse(dhcp_sp & dhcp_cp,8))
			port map (
				mii_rxc  => mii_rxc,
				mii_rxdv => mii_rxdv,
				mii_rxd  => mii_rxd,
				mii_ena  => udpports_rxdv,
				mii_equ  => udpports_rcvd);

			tp1 <= udpports_rcvd;
			dhcp_offer_e : entity hdl4fpga.dhcp_offer
			port map (
				mii_rxc  => mii_rxc,
				mii_rxdv => mii_rxdv,
				mii_rxd  => mii_rxd,
				mii_ptr  => rxfrm_ptr,

				dhcp_ena => udpports_rcvd,
				dhcpyia_rxdv => dhcpyia_rxdv);

			dchp_yia_e : entity hdl4fpga.mii_des
			port map (
				mii_rxc  => mii_rxc,
				mii_rxdv => dhcpyia_rxdv,
				mii_rxd  => mii_rxd,
				des_data => myip4a);

		end block;

		udp_b : block
		begin
		end block;
	end block;

	ip4pl_txen <= icmp_txen or udpdhcp_txen;
	ip4pl_txd  <= wirebus (icmp_txd & udpdhcp_txd, icmp_txen & udpdhcp_txen);

	udp4rx_e : entity hdl4fpga.udp_rx
	port map (
		mii_rxc    => mii_rxc,
		mii_rxdv   => mii_rxdv,
		mii_rxd    => mii_rxd,
		mii_ptr    => rxfrm_ptr,

		udp_ena      => udpproto_rcvd,
		udpsp_rxdv   => udpsp_rxdv,
		udpdp_rxdv   => udpdp_rxdv,
		udplen_rxdv  => udplen_rxdv,
		udpcksm_rxdv => udpcksm_rxdv,
		udppl_rxdv   => udppl_rxdv);

	ctlr_b : block

	begin

		myip4a_ena <= arptpa_rxdv or ip4da_rxdv;
		myip4acmp_e : entity hdl4fpga.mii_romcmp
		generic map (
			mem_data => reverse(myip4a,8))
		port map (
			mii_rxc  => mii_rxc,
			mii_rxdv => mii_rxdv,
			mii_rxd  => mii_rxd,
			mii_ena  => myip4a_ena,
			mii_equ  => myip4a_rcvd);

		ip4lenrx_e : entity hdl4fpga.mii_des
		port map (
			mii_rxc  => mii_rxc,
			mii_rxdv => ip4len_rxdv,
			mii_rxd  => mii_rxd,
			des_data => ip4len_rx);

		ip4darx_e : entity hdl4fpga.mii_des
		port map (
			mii_rxc  => mii_rxc,
			mii_rxdv => ip4sa_rxdv,
			mii_rxd  => mii_rxd,
			des_data => ip4da);

		process (mii_rxc)
			variable rxdv : std_logic;
		begin
			if rising_edge(mii_rxc) then
				if mii_rxdv='0' then
					if rxdv='1' then
						arp_rcvd  <= (typearp_rcvd and myip4a_rcvd);
						icmp_rcvd <= ip4icmp_rcvd and myip4a_rcvd;
					else
						arp_rcvd  <= '0';
						icmp_rcvd <= '0';
					end if;
				end if;
				rxdv := mii_rxdv;
			end if;
		end process;
--		tp1 <= arp_rcvd;

		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				if mii_gnt=(mii_gnt'range => '0') then
					txfrm_ptr <= (others => '0');
				elsif txfrm_ptr(0)='0' then
					txfrm_ptr <= std_logic_vector(unsigned(txfrm_ptr) + 1);
				end if;
			end if;
		end process;

	end block;

	mii_gnt_b : block
	begin
		mii_rdy  <= mii_gnt and not (mii_gnt'range => mii_txen);
		mii_trdy <= mii_gnt and not (mii_gnt'range => mii_txen);

		miignt_e : entity hdl4fpga.arbiter
		port map (
			clk => mii_txc,
			req => mii_req,
			gnt => mii_gnt);

		eth_txd  <= wirebus(arp_txd & ip4_txd, arp_gnt & ip4_gnt);
		eth_txen <= setif(mii_gnt/=(mii_gnt'range => '0')) and (arp_txen or ip4_txen);
	end block;

	udp_len   <= wirebus(udpdhcp_len, "1");
	udp_gnt   <= dscb_gnt;

	udpip_len <= std_logic_vector(unsigned(udp_len) + (summation(ip4hdr_frame))/octect_size);
	ip4len_tx <= wirebus (ip4len_rx & udpip_len, icmp_gnt & udp_gnt); 
	ip4_gnt   <= icmp_gnt or udp_gnt;
	ip4proto_tx <= wirebus(ip4proto_icmp & ip4proto_udp, icmp_gnt & udp_gnt);

	ip4sa_tx <= wirebus(myip4a & x"00_00_00_00", not dscb_gnt & dscb_gnt);
	ip4_e : entity hdl4fpga.ip4_tx
	port map (
		mii_txc  => mii_txc,

		pl_txen  => ip4pl_txen,
		pl_txd   => ip4pl_txd,

		ip4len   => ip4len_tx,
		ip4sa    => ip4sa_tx, --myip4a,
		ip4da    => x"ff_ff_ff_ff", --ip4da,
		ip4proto => ip4proto_tx,

		ip4_ptr  => txfrm_ptr,
		ip4_txen => ip4_txen,
		ip4_txd  => ip4_txd);

	llc <= wirebus(llc_arp & llc_ip4, arp_gnt & ip4_gnt);
	ethtx_e : entity hdl4fpga.eth_tx
	port map (
		mii_txc  => mii_txc,
		eth_ptr  => txfrm_ptr,
		hwsa     => mymac,
		hwda     => x"ff_ff_ff_ff_ff_ff",
		llc      => llc,
		pl_txen  => eth_txen,
		pl_txd   => eth_txd,
		eth_txen => mii_txen,
		eth_txd  => mii_txd);

	txc_sync_b : block

		signal rxc_rxd      : std_logic_vector(0 to mii_txd'length+2);
		signal txc_txd      : std_logic_vector(0 to mii_txd'length+2);

		alias  txc_rxdv     : std_logic is txc_rxd(mii_rxd'length);
		alias  txc_arprcvd  : std_logic is txc_rxd(mii_rxd'length+1);
		alias  txc_icmprcvd : std_logic is txc_rxd(mii_rxd'length+2);

	begin

		rxc_rxd <= mii_rxd & mii_rxdv & arp_rcvd & icmp_rcvd;

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
				elsif txc_arprcvd='1' then
					arp_req <= '1';
				end if;
			end if;
		end process;
		tp2 <= arp_req;

		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				if icmp_rdy='1' then
					icmp_req	<= '0';
				elsif txc_icmprcvd='1' then
					icmp_req <= '1';
				end if;
			end if;
		end process;

		txc_txd <= mii_txd & mii_txen & '0' & '0';
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
		display_txen <= mii_txen or '0'; --txc_rxd(mii_rxd'length+1);

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
