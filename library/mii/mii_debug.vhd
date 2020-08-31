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

	constant mymac       : std_logic_vector := x"00_40_00_01_02_03";
	constant myip4a      : std_logic_vector := x"c0_a8_00_0e";
	signal   ip4da       : std_logic_vector(0 to 32-1);
	signal   ip4len      : std_logic_vector(0 to 16-1);

	signal mii_gnt       : std_logic_vector(0 to 2-1);
	signal mii_trdy      : std_logic_vector(mii_gnt'range);

	signal mii_req       : std_logic_vector(mii_gnt'range);
	signal mii_rdy       : std_logic_vector(mii_gnt'range);

	alias arp_req        : std_logic is mii_req(0);
	alias arp_rdy        : std_logic is mii_rdy(0);
	alias icmp_req       : std_logic is mii_req(1);
	alias dscb_req       : std_logic is mii_req(1);
	alias dscb_rdy       : std_logic is mii_rdy(1);
	alias icmp_rdy       : std_logic is mii_rdy(1);
	alias dscb_gnt       : std_logic is mii_gnt(1);
	alias icmp_gnt       : std_logic is mii_gnt(1);
	signal ip4_req       : std_logic := '0';

	signal rxfrm_ptr     : std_logic_vector(0 to unsigned_num_bits((64*8)/mii_rxd'length-1));
	signal txfrm_ptr     : std_logic_vector(0 to unsigned_num_bits((64*8)/mii_rxd'length-1));

	signal ethhwda_ena   : std_logic;
	signal ethhwsa_ena   : std_logic;
	signal ethtype_ena   : std_logic;
	signal myip4a_ena    : std_logic;
	signal myip4a_rcvd   : std_logic;

	signal eth_txen      : std_logic;
	signal eth_txd       : std_logic_vector(mii_txd'range);
	alias  arp_gnt       : std_logic is mii_gnt(0);

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
	signal ip4pl_txen    : std_logic := '0';
	signal ip4pl_txd     : std_logic_vector(mii_txd'range);
	signal ip4_txen      : std_logic := '0';
	signal ip4_txd       : std_logic_vector(mii_txd'range);

	signal ip4da_rxdv    : std_logic;
	signal ip4sa_rxdv    : std_logic;
	signal ip4len_rxdv   : std_logic;
	signal ip4proto_rxdv : std_logic;
	signal ip4icmp_rcvd  : std_logic;
	signal ip4pl_rxdv    : std_logic;

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

	arprx_e : entity hdl4fpga.arp_rx
	port map (
		mii_rxc   => mii_rxc,
		mii_rxdv  => mii_rxdv,
		mii_rxd   => mii_rxd,
		mii_ptr   => rxfrm_ptr,
		arp_ena   => typearp_rcvd,
		tpa_rxdv  => arptpa_rxdv);

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

	icmp_b : block

		signal icmpid_rxdv   : std_logic;
		signal icmpid_data   : std_logic_vector(0 to 16-1);
		signal icmpseq_rxdv  : std_logic;
		signal icmpseq_data  : std_logic_vector(0 to 16-1);
		signal icmpcksm_rxdv : std_logic;
		signal icmpcksm_data : std_logic_vector(0 to 16-1);
		signal icmprply_cksm : std_logic_vector(0 to 16-1);

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
			icmpchsm_rxdv => icmpid_rxdv,
			icmpseq_rxdv  => icmpseq_rxdv);

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
			mem_size => 64*octect)
		port map (
			mii_rxc  => mii_rxc,
			mii_rxdv => icmppl_rxdv,
			mii_rxd  => mii_rxd,

			mii_txc  => mii_txc,
			mii_txen => icmp_gnt;
			mii_txdv => icmppl_txen,
			mii_txd  => icmppl_txd);

		icmprlpy_cksm <= onechksum(icmpcksm_data & icmptype_rqst);
		icmprply_e : entity hdl4fpga.icmprply_tx
		port map (
			mii_txc   => mii_txc,

			pl_txen   => icmppl_txen, --icmp_gnt,
			pl_txd    => icmppl_txd, --x"0",

			icmp_ptr  => txfrm_ptr,
			icmp_cksm => icmprply_cksm,
			icmp_id   => icmpid_data,
			icmp_seq  => icmpseq_data,
			icmp_txen => ip4pl_txen,
			icmp_txd  => ip4pl_txd);

	end block;


	ctlr_b : block

		signal ethmymac_rcvd : std_logic;
		signal ethbcst_rcvd  : std_logic;

	begin

		ethmac_e : entity hdl4fpga.mii_romcmp
		generic map (
			mem_data => reverse(mymac, 8))
		port map (
			mii_rxc  => mii_rxc,
			mii_rxdv => mii_rxdv,
			mii_ena  => ethhwda_ena,
			mii_rxd  => mii_rxd,
			mii_equ  => ethmymac_rcvd);

		ethbcst_rx_e : entity hdl4fpga.mii_romcmp
		generic map (
			mem_data => reverse(x"ff_ff_ff_ff_ff_ff", 8))
		port map (
			mii_rxc  => mii_rxc,
			mii_rxdv => mii_rxdv,
			mii_ena  => ethhwda_ena,
			mii_rxd  => mii_rxd,
			mii_equ  => ethbcst_rcvd);

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
			des_data => ip4len);

		ip4darx_e : entity hdl4fpga.mii_des
		port map (
			mii_rxc  => mii_rxc,
			mii_rxdv => ip4sa_rxdv,
			mii_rxd  => mii_rxd,
			des_data => ip4da);

		icmpproto_e : entity hdl4fpga.mii_romcmp
		generic map (
			mem_data => reverse(ip4proto_icmp,8))
		port map (
			mii_rxc  => mii_rxc,
			mii_rxdv => mii_rxdv,
			mii_rxd  => mii_rxd,
			mii_ena  => ip4proto_rxdv,
			mii_equ  => ip4icmp_rcvd);

		process (mii_rxc)
			variable rxdv : std_logic;
		begin
			if rising_edge(mii_rxc) then
				if mii_rxdv='0' then
					if rxdv='1' then
						arp_rcvd  <= typearp_rcvd and myip4a_rcvd;
						icmp_rcvd <= ip4icmp_rcvd and myip4a_rcvd;
					else
						arp_rcvd  <= '0';
						icmp_rcvd <= '0';
					end if;
				end if;
				rxdv := mii_rxdv;
			end if;
		end process;
		tp1 <= arp_rcvd;

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

		eth_txd  <= wirebus(arp_txd & ip4_txd, mii_gnt);
		eth_txen <= setif(mii_gnt/=(mii_gnt'range => '0')) and (arp_txen or ip4_txen);
	end block;

--	pkt_len <= std_logic_vector(unsigned(pl_len) + (summation(ip4hdr_frame))/octect_size);
	ip4_e : entity hdl4fpga.ip4_tx
	port map (
		mii_txc  => mii_txc,

		pl_txen  => ip4pl_txen,
		pl_txd   => ip4pl_txd,

		ip4len   => ip4len,
		ip4sa    => myip4a,
		ip4da    => ip4da,
		ip4proto => x"01",

		ip4_ptr  => txfrm_ptr,
		ip4_txen => ip4_txen,
		ip4_txd  => ip4_txd);

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

	llc <= wirebus(llc_arp & llc_ip4, mii_gnt);
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

--		process (mii_txc)
--			variable req : std_logic;
--		begin
--			if rising_edge(mii_txc) then
--				if dscb_rdy='1' then
--					dscb_req <= '0';
--				elsif ip4_req='1' then
--					if mii_txen='1' then
--						ip4_req  <= '0';
--					end if;
--				elsif req='0' and pkt_req='1' then
--					ip4_req  <= '1';
--					dscb_req <= '1';
--				end if;
--				req := pkt_req;
--			end if;
--		end process;

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
