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
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity mii_ipoe is
	generic (
		default_ipv4a : std_logic_vector(0 to 32-1) := x"00_00_00_00";
		mymac         : std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03");
	port (
		mii_rxc       : in  std_logic;
		mii_rxd       : in  std_logic_vector;
		mii_rxdv      : in  std_logic;

		mii_txc       : in  std_logic;
		mii_txd       : buffer std_logic_vector;
		mii_txen      : buffer std_logic;

		txc_rxd       : buffer std_logic_vector;
		txc_rxdv      : buffer std_logic;
		dll_rxdv      : buffer std_logic;

		dllcrc32_rxdv : buffer std_logic;
		dllcrc32_rxd  : buffer std_logic_vector;
		dllcrc32_equ  : buffer std_logic;
		dllcrc32      : buffer std_logic_vector(0 to 32-1);

		dllhwda_rxdv  : buffer std_logic;
		dllhwsa_rxdv  : buffer std_logic;
		dlltype_rxdv  : buffer std_logic;

		dllhwsa_rx    : buffer std_logic_vector(0 to 48-1);

		ipv4da_rxdv   : buffer std_logic;
		ipv4sa_rxdv   : buffer std_logic;
		ipv4sa_rx     : buffer std_logic_vector(0 to 32-1);

		tx_req    : in std_logic := '0';
		tx_rdy    : out std_logic;
		tx_gnt    : out std_logic;

		dll_hwda      : in std_logic_vector(0 to 48-1) := (others => '-');
		ipv4_da       : in std_logic_vector(0 to 32-1) := (others => '-');

		udpsp_rxdv    : buffer std_logic;
		udpdp_rxdv    : buffer std_logic;
		udplen_rxdv   : buffer std_logic;
		udpcksm_rxdv  : buffer std_logic;
		udpsp_rx      : buffer std_logic_vector(0 to 16-1);
		udpdp_rx      : buffer std_logic_vector(0 to 16-1);

		udppl_len     : in  std_logic_vector(0 to 16-1) := (others => '-');
		udppl_rxdv    : buffer std_logic;
		udppl_txen    : in  std_logic;
		udppl_txd     : in  std_logic_vector;

		udp_cksm      : in  std_logic_vector(0 to 16-1) := (others => '0'); 
		udp_sp        : in  std_logic_vector(0 to 16-1) := (others => '-'); 
		udp_dp        : in  std_logic_vector(0 to 16-1) := (others => '-'); 

		ipv4acfg_req  : in  std_logic;
		myipv4a       : out std_logic_vector(0 to 32-1);
		dhcp_rcvd     : buffer std_logic;
		dhcpipv4a_rxdv : buffer std_logic;

		tp            : buffer std_logic_vector(1 to 4));

end;

architecture def of mii_ipoe is


	signal mii_gnt       : std_logic_vector(0 to 4-1);

	signal mii_req       : std_logic_vector(mii_gnt'range) := (others => '0');
	signal mii_rdy       : std_logic_vector(mii_gnt'range);
	signal dllhwda_equ   : std_logic;


	alias arp_req        : std_logic is mii_req(0);
	alias arp_rdy        : std_logic is mii_rdy(0);
	alias arp_gnt        : std_logic is mii_gnt(0);

	alias icmp_req       : std_logic is mii_req(1);
	alias icmp_rdy       : std_logic is mii_rdy(1);
	alias icmp_gnt       : std_logic is mii_gnt(1);

	alias dhcp_req       : std_logic is mii_req(2);
	alias dhcp_rdy       : std_logic is mii_rdy(2);
	alias dhcp_gnt       : std_logic is mii_gnt(2);

	alias extern_req     : std_logic is mii_req(3);
	alias extern_rdy     : std_logic is mii_rdy(3);
	alias extern_gnt     : std_logic is mii_gnt(3);

	signal ipv4_gnt      : std_logic;

	signal rxfrm_ptr     : std_logic_vector(0 to unsigned_num_bits((128*octect_size)/mii_rxd'length-1));
	signal txfrm_ptr     : std_logic_vector(0 to unsigned_num_bits((512*octect_size)/mii_rxd'length-1));

	signal myip4a_ena    : std_logic;
	signal cfgipv4a      : std_logic_vector(0 to 32-1) := default_ipv4a;

	signal eth_txen      : std_logic;
	signal eth_txd       : std_logic_vector(mii_txd'range);

	signal arptpa_rxdv   : std_logic;

	signal typearp_rcvd  : std_logic;
	signal arp_txen      : std_logic;
	signal arp_txd       : std_logic_vector(mii_txd'range);

	signal typeip4_rcvd  : std_logic;
	signal ip4pl_txen    : std_logic;
	signal ip4pl_txd     : std_logic_vector(mii_txd'range);
	signal ip4_txen      : std_logic := '0';
	signal ip4_txd       : std_logic_vector(mii_txd'range);

	signal myip4a_rcvd   : std_logic;
	signal bcstipv4a_rcvd : std_logic;

	signal ip4pl_rxdv    : std_logic;

	signal txc_eor       : std_logic;

	signal dllhwda_ipv4  : std_logic_vector(0 to 48-1);
	signal dllhwda_icmp  : std_logic_vector(0 to 48-1);

	signal hwda_tx       : std_logic_vector(0 to 48-1);
	signal type_tx       : std_logic_vector(llc_arp'range);

begin

	sync_b : block
		signal rxc_rxbus : std_logic_vector(0 to mii_rxd'length);
		signal txc_rxbus : std_logic_vector(0 to mii_rxd'length);
		signal dst_irdy : std_logic;
		signal dst_trdy : std_logic;
	begin
		rxc_rxbus <= mii_rxd & mii_rxdv;
		rxc2txc_e : entity hdl4fpga.fifo
		generic map (
			max_depth => 4,
			out_rgtr  => false, 
			check_sov => false,
			check_dov => true,
			gray_code => false)
		port map (
			src_clk  => mii_rxc,
			src_data => rxc_rxbus,
			dst_clk  => mii_txc,
			dst_irdy => dst_irdy,
			dst_trdy => dst_trdy,
			dst_data => txc_rxbus);

		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				dst_trdy <= dst_irdy;
			end if;
		end process;

		txc_rxd  <= txc_rxbus(0 to mii_rxd'length-1);
		txc_rxdv <= txc_rxbus(mii_rxd'length);
	end block;

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			txc_eor <= txc_rxdv;
		end if;
	end process;

	extern_req <= tx_req;
	tx_rdy <= extern_rdy;
	tx_gnt <= extern_gnt;

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

	mii_rdy  <= mii_gnt and not (mii_gnt'range => mii_txen);

	miignt_e : entity hdl4fpga.arbiter
	port map (
		clk => mii_txc,
		req => mii_req,
		gnt => mii_gnt);

	eth_txd  <= wirebus(arp_txd & ip4_txd, arp_gnt & ipv4_gnt);
	eth_txen <= setif(mii_gnt/=(mii_gnt'range => '0')) and (arp_txen or ip4_txen);

	ethrx_e : entity hdl4fpga.eth_rx
	port map (
		mii_rxc    => mii_txc,
		mii_rxdv   => txc_rxdv,
		mii_rxd    => txc_rxd,
		eth_ptr    => rxfrm_ptr,
		eth_pre    => dll_rxdv,
		hwda_rxdv  => dllhwda_rxdv,
		hwsa_rxdv  => dllhwsa_rxdv,
		type_rxdv  => dlltype_rxdv,
		crc32_rxdv => dllcrc32_rxdv,
		crc32_rxd  => dllcrc32_rxd,
		crc32_equ  => dllcrc32_equ,
		eth_crc32  => dllcrc32);

	dllhwdacmp_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(mymac,8))
    port map (
        mii_rxc  => mii_txc,
        mii_rxdv => dll_rxdv,
        mii_rxd  => txc_rxd,
        mii_ena  => dllhwda_rxdv,
		mii_equ  => dllhwda_equ);

	dllhwsa_e : entity hdl4fpga.mii_des
	port map (
		mii_rxc  => mii_txc,
		mii_rxdv => dllhwsa_rxdv,
		mii_rxd  => txc_rxd,
		des_data => dllhwsa_rx);

	ip4llccmp_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(llc_ip4,8))
	port map (
		mii_rxc  => mii_txc,
		mii_rxdv => dll_rxdv,
		mii_ena  => dlltype_rxdv,
		mii_rxd  => txc_rxd,
		mii_equ  => typeip4_rcvd);

	arpllccmp_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(llc_arp,8))
	port map (
		mii_rxc  => mii_txc,
		mii_rxdv => dll_rxdv,
		mii_ena  => dlltype_rxdv,
		mii_rxd  => txc_rxd,
		mii_equ  => typearp_rcvd);

	type_tx <= wirebus(llc_arp & llc_ip4, arp_gnt & ipv4_gnt);
	dllhwda_ipv4 <= wirebus(dllhwda_icmp & x"ff_ff_ff_ff_ff_ff" & dll_hwda, icmp_gnt & dhcp_gnt & extern_gnt);
	hwda_tx <= wirebus(x"ff_ff_ff_ff_ff_ff" & dllhwda_ipv4, arp_gnt & ipv4_gnt);
	ethtx_e : entity hdl4fpga.eth_tx
	port map (
		mii_txc   => mii_txc,
		eth_ptr   => txfrm_ptr,
		hwsa      => mymac,
		hwda      => hwda_tx,
		llc       => type_tx,
		pl_txen   => eth_txen,
		eth_rxd   => eth_txd,
		eth_txen  => mii_txen,
		eth_txd   => mii_txd);

	arp_b : block
		signal arp_rcvd : std_logic;
	begin

		arprx_e : entity hdl4fpga.arp_rx
		port map (
			mii_rxc   => mii_txc,
			mii_rxdv  => dll_rxdv,
			mii_rxd   => txc_rxd,
			mii_ptr   => rxfrm_ptr,
			arp_ena   => typearp_rcvd,
			tpa_rxdv  => arptpa_rxdv);

		arptx_e : entity hdl4fpga.arp_tx
		port map (
			mii_txc  => mii_txc,
			mii_txen => arp_gnt,
			arp_frm  => txfrm_ptr,

			sha      => mymac,
			spa      => cfgipv4a,
			tha      => x"ff_ff_ff_ff_ff_ff",
			tpa      => cfgipv4a,

			arp_txen => arp_txen,
			arp_txd  => arp_txd);

		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				if arp_rdy='1' then
					arp_req	<= '0';
				elsif arp_rcvd='1' then
					arp_req <= '1';
				elsif dhcp_rcvd='1' then
					arp_req <= '1';
				end if;
			end if;
		end process;

		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				if dll_rxdv='0' then
					if txc_eor='1' then
						arp_rcvd <= typearp_rcvd and myip4a_rcvd;
					elsif arp_req='1' then
						arp_rcvd <= '0';
					end if;
				end if;
			end if;
		end process;


	end block;

	ip4_b : block

		signal ip4len_rxdv   : std_logic;
		signal ip4proto_rxdv : std_logic;
		signal ip4len_rx     : std_logic_vector(0 to 16-1);
		signal ip4len_tx     : std_logic_vector(0 to 16-1);
		signal ip4proto_tx   : std_logic_vector(0 to ip4hdr_frame(ip4_proto)-1);
		signal ip4sa_tx      : std_logic_vector(0 to 32-1);
		signal ip4da_tx      : std_logic_vector(0 to 32-1);
		signal ip4da         : std_logic_vector(0 to 32-1);

		signal ip4icmp_rcvd  : std_logic;
		signal icmp_txen     : std_logic;
		signal icmp_txd      : std_logic_vector(mii_txd'range);
		signal icmp_ip4da    : std_logic_vector(0 to 32-1);

		signal ipicmp_len    : std_logic_vector(0 to 16-1);
		signal udpip_len     : std_logic_vector(0 to 16-1);

		signal udp_txd   : std_logic_vector(mii_txd'range);
		signal udp_txen  : std_logic;

		signal udpdhcp_len   : std_logic_vector(0 to 16-1);
		signal udpdhcp_txd   : std_logic_vector(mii_txd'range);
		signal udpdhcp_txen  : std_logic;

		signal udpproto_rcvd : std_logic;

	begin

		ip4rx_e : entity hdl4fpga.ipv4_rx
		port map (
			mii_rxc     => mii_txc,
			mii_rxdv    => dll_rxdv,
			mii_rxd     => txc_rxd,
			mii_ptr     => rxfrm_ptr,

			ip4_ena     => typeip4_rcvd,
			ip4len_rxdv => ip4len_rxdv,
			ip4da_rxdv  => ipv4da_rxdv,
			ip4sa_rxdv  => ipv4sa_rxdv,
			ip4proto_rxdv => ip4proto_rxdv,

			ip4pl_rxdv => ip4pl_rxdv);

		myip4a_ena <= arptpa_rxdv or ipv4da_rxdv;
		myip4acmp_e : entity hdl4fpga.mii_muxcmp
		port map (
			mux_data => cfgipv4a,
			mii_rxc  => mii_txc,
			mii_rxdv => dll_rxdv,
			mii_rxd  => txc_rxd,
			mii_ena  => myip4a_ena,
			mii_equ  => myip4a_rcvd);

		bcstipv4a_e : entity hdl4fpga.mii_romcmp
		generic map (
			mem_data => reverse(x"ff_ff_ff_ff",8))
		port map (
			mii_rxc  => mii_txc,
			mii_rxdv => dll_rxdv,
			mii_rxd  => txc_rxd,
			mii_ena  => myip4a_ena,
			mii_equ  => bcstipv4a_rcvd);

		ip4lenrx_e : entity hdl4fpga.mii_des
		port map (
			mii_rxc  => mii_txc,
			mii_rxdv => ip4len_rxdv,
			mii_rxd  => txc_rxd,
			des_data => ip4len_rx);

		ip4sarx_e : entity hdl4fpga.mii_des
		port map (
			mii_rxc  => mii_txc,
			mii_rxdv => ipv4sa_rxdv,
			mii_rxd  => txc_rxd,
			des_data => ipv4sa_rx);

		ipv4_gnt    <= icmp_gnt or dhcp_gnt or extern_gnt;
		ip4sa_tx    <= wirebus(cfgipv4a & x"00_00_00_00", not dhcp_gnt & dhcp_gnt);
		ip4da       <= wirebus(icmp_ip4da & ipv4_da, icmp_gnt & extern_gnt);
		ip4da_tx    <= wirebus(ip4da  & x"ff_ff_ff_ff", not dhcp_gnt & dhcp_gnt);
		ip4len_tx   <= wirebus (ipicmp_len & udpip_len, icmp_gnt & (dhcp_gnt or extern_gnt)); 
		ip4proto_tx <= wirebus(ip4proto_icmp & ip4proto_udp, icmp_gnt & (dhcp_gnt or extern_gnt));
		ip4pl_txen  <= icmp_txen or udpdhcp_txen or udp_txen;
		ip4pl_txd   <= wirebus (icmp_txd & udpdhcp_txd & udp_txd, icmp_txen & udpdhcp_txen & udp_txen);

		ip4tx_e : entity hdl4fpga.ipv4_tx
		port map (
			mii_txc  => mii_txc,

			pl_txen  => ip4pl_txen,
			pl_txd   => ip4pl_txd,

			ip4len   => ip4len_tx,
			ip4sa    => ip4sa_tx,
			ip4da    => ip4da_tx,
			ip4proto => ip4proto_tx,

			ip4_ptr  => txfrm_ptr,
			ip4_txen => ip4_txen,
			ip4_txd  => ip4_txd);

		icmpproto_e : entity hdl4fpga.mii_romcmp
		generic map (
			mem_data => reverse(ip4proto_icmp,8))
		port map (
			mii_rxc  => mii_txc,
			mii_rxdv => dll_rxdv,
			mii_rxd  => txc_rxd,
			mii_ena  => ip4proto_rxdv,
			mii_equ  => ip4icmp_rcvd);

		udpproto_e : entity hdl4fpga.mii_romcmp
		generic map (
			mem_data => reverse(ip4proto_udp,8))
		port map (
			mii_rxc  => mii_txc,
			mii_rxdv => dll_rxdv,
			mii_rxd  => txc_rxd,
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

			signal icmp_rcvd     : std_logic;

			signal icmprqst_ena  : std_logic;

		begin

			icmprqst_ena <= ip4icmp_rcvd and dll_rxdv;
			icmprqstrx_e : entity hdl4fpga.icmprqst_rx
			port map (
				mii_rxc  => mii_txc,
				mii_rxdv => dll_rxdv,
				mii_rxd  => txc_rxd,
				mii_ptr  => rxfrm_ptr,

				icmprqst_ena  => icmprqst_ena,
				icmpid_rxdv   => icmpid_rxdv,
				icmpcksm_rxdv => icmpcksm_rxdv,
				icmpseq_rxdv  => icmpseq_rxdv,
				icmppl_rxdv   => icmppl_rxdv);

			icmpcksm_e : entity hdl4fpga.mii_des
			port map (
				mii_rxc  => mii_txc,
				mii_rxdv => icmpcksm_rxdv,
				mii_rxd  => txc_rxd,
				des_data => icmpcksm_data);

			icmpseq_e : entity hdl4fpga.mii_des
			port map (
				mii_rxc  => mii_txc,
				mii_rxdv => icmpseq_rxdv,
				mii_rxd  => txc_rxd,
				des_data => icmpseq_data);

			icmpid_e : entity hdl4fpga.mii_des
			port map (
				mii_rxc  => mii_txc,
				mii_rxdv => icmpid_rxdv,
				mii_rxd  => txc_rxd,
				des_data => icmpid_data);

			icmpdata_e : entity hdl4fpga.mii_ram
			generic map (
				mem_size => 64*octect_size)
			port map (
				mii_rxc  => mii_txc,
				mii_rxdv => icmppl_rxdv,
				mii_rxd  => txc_rxd,

				mii_txc  => mii_txc,
				mii_txen => icmp_gnt,
				mii_txdv => icmppl_txen,
				mii_txd  => icmppl_txd);

			icmprply_cksm <= oneschecksum(icmpcksm_data & icmptype_rqst & x"00", icmprply_cksm'length);
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

			process (mii_txc)
			begin
				if rising_edge(mii_txc) then
					if icmp_rdy='1' then
						icmp_req <= '0';
					elsif icmp_rcvd='1' then
						icmp_req     <= '1';
						dllhwda_icmp <= dllhwsa_rx;
						icmp_ip4da   <= ipv4sa_rx;
						ipicmp_len   <= ip4len_rx;
					end if;
				end if;
			end process;

			process (mii_txc)
			begin
				if rising_edge(mii_txc) then
					if dll_rxdv='0' then
						if txc_eor='1' then
							icmp_rcvd <= ip4icmp_rcvd and myip4a_rcvd;
						elsif icmp_req='1' then
							icmp_rcvd <= '0';
						end if;
					end if;
				end if;
			end process;

--			tp(1) <= (typearp_rcvd or ip4icmp_rcvd) and myip4a_rcvd and txc_rxdv;
--			tp(1) <= (typearp_rcvd) and myip4a_rcvd and txc_rxdv;
		end block;

		udp_b : block
			signal udp_ena : std_logic;
			signal udp_len   : std_logic_vector(0 to 16-1);
			signal udplen_rx : std_logic_vector(0 to 16-1);
			signal udplen_tx : std_logic_vector(0 to 16-1);
			signal pl_rxdv   : std_logic;
			signal cntr      : unsigned(0 to 16+unsigned_num_bits(octect_size/txc_rxd'length)-1);

		begin
			udp_ena <= udpproto_rcvd and (myip4a_rcvd or bcstipv4a_rcvd);
			udprx_e : entity hdl4fpga.udp_rx
			port map (
				mii_rxc    => mii_txc,
				mii_rxdv   => dll_rxdv,
				mii_rxd    => txc_rxd,
				mii_ptr    => rxfrm_ptr,

				udp_ena      => udpproto_rcvd,
				udpsp_rxdv   => udpsp_rxdv,
				udpdp_rxdv   => udpdp_rxdv,
				udplen_rxdv  => udplen_rxdv,
				udpcksm_rxdv => udpcksm_rxdv,
				udppl_rxdv   => pl_rxdv);

			udpdp_e : entity hdl4fpga.mii_des
			port map (
				mii_rxc  => mii_txc,
				mii_rxdv => udpdp_rxdv,
				mii_rxd  => txc_rxd,
				des_data => udpdp_rx);

			udpsp_e : entity hdl4fpga.mii_des
			port map (
				mii_rxc  => mii_txc,
				mii_rxdv => udpsp_rxdv,
				mii_rxd  => txc_rxd,
				des_data => udpsp_rx);

			udplen_e : entity hdl4fpga.mii_des
			port map (
				mii_rxc  => mii_txc,
				mii_rxdv => udplen_rxdv,
				mii_rxd  => txc_rxd,
				des_data => udplen_rx);

			process(mii_txc)
			begin
				if rising_edge(mii_txc) then
					if udpcksm_rxdv='1' then
						cntr <= resize(shift_left(unsigned(udplen_rx)-summation(udp4hdr_frame)/octect_size, unsigned_num_bits(octect_size/txc_rxd'length)-1), cntr'length)-1;
					elsif udppl_rxdv='1' then
						if cntr(0)='0' then
							cntr <= cntr - 1;
						end if;
					end if;
				end if;
			end process;
			udppl_rxdv <= not cntr(0) and pl_rxdv;

			udplen_tx <= wirebus(udpdhcp_len & udp_len , dhcp_gnt & extern_gnt);
			udpip_len <= std_logic_vector(unsigned(udplen_tx) + (summation(ip4hdr_frame))/octect_size);

			udp_tx : entity hdl4fpga.udp_tx
			port map (
				mii_txc    => mii_txc,
				udp_ptr    => txfrm_ptr,
				udppl_txen => udppl_txen,
				udppl_txd  => udppl_txd,
				udppl_len  => udppl_len,
				udp_cksm   => udp_cksm,
				udp_len    => udp_len,
				udp_sp     => udp_sp,
				udp_dp     => udp_dp,

				udp_txen   => udp_txen,
				udp_txd    => udp_txd);

			dhcp_b : block
				constant dhcp_clntp : std_logic_vector := x"0044";
				constant dhcp_srvp  : std_logic_vector := x"0043";

				signal udpports_rxdv : std_logic;
				signal udpports_rcvd : std_logic;
				signal dhcpop_rxdv   : std_logic;
				signal dhcpchaddr6_rxdv   : std_logic;
				signal dhcpchaddr6_equ   : std_logic;
				signal dhcpoffer_rcvd : std_logic;
				signal dhcpyia_rxdv  : std_logic;

				signal dscb_req      : std_logic := '0';
				signal dhcpipv4a : std_logic_vector(cfgipv4a'range);
			begin

				process (mii_txc)
					variable req : std_logic;
				begin
					if rising_edge(mii_txc) then
						if dhcp_rdy='1' then
							dhcp_req <= '0';
						elsif dscb_req='1' then
							if mii_txen='1' then
								dscb_req <= '0';
							end if;
						elsif req='0' and ipv4acfg_req='1' then
							dscb_req <= '1';
							dhcp_req <= '1';
						end if;
						req := ipv4acfg_req;
					end if;
				end process;

				dhcp_dscb_e : entity hdl4fpga.dhcp_dscb
				generic map (
					dhcp_sp => dhcp_clntp,
					dhcp_dp => dhcp_srvp )
				port map (
					mii_txc   => mii_txc,
					mii_txen  => dhcp_gnt,
					udpdhcp_ptr  => txfrm_ptr,
					udpdhcp_len  => udpdhcp_len,
					udpdhcp_txen => udpdhcp_txen,
					udpdhcp_txd  => udpdhcp_txd);

				udpports_rxdv <= udpsp_rxdv or udpdp_rxdv;
				dhcpport_e : entity hdl4fpga.mii_romcmp
				generic map (
					mem_data => reverse(dhcp_srvp  & dhcp_clntp,8))
				port map (
					mii_rxc  => mii_txc,
					mii_rxdv => dll_rxdv,
					mii_rxd  => txc_rxd,
					mii_ena  => udpports_rxdv,
					mii_equ  => udpports_rcvd);

				dhcprx_e : entity hdl4fpga.dhcp_rx
				port map (
					mii_rxc  => mii_txc,
					mii_rxdv => dll_rxdv,
					mii_rxd  => txc_rxd,
					mii_ptr  => rxfrm_ptr,

					dhcp_ena => udpports_rcvd,
					dhcpop_rxdv  => dhcpop_rxdv,
					dhcpchaddr6_rxdv  => dhcpchaddr6_rxdv,
					dhcpyia_rxdv => dhcpyia_rxdv);

				dhcpoffer_e : entity hdl4fpga.mii_romcmp
				generic map (
					mem_data => reverse(dhcp4_offer,8))
				port map (
					mii_rxc  => mii_txc,
					mii_rxdv => dll_rxdv,
					mii_rxd  => txc_rxd,
					mii_ena  => dhcpop_rxdv,
					mii_equ  => dhcpoffer_rcvd);

				dhcpchaddr_e : entity hdl4fpga.mii_romcmp
				generic map (
					mem_data => reverse(mymac,8))
				port map (
					mii_rxc  => mii_txc,
					mii_rxdv => dll_rxdv,
					mii_rxd  => txc_rxd,
					mii_ena  => dhcpchaddr6_rxdv,
					mii_equ  => dhcpchaddr6_equ);

				dhcpipv4a_rxdv <= dhcpoffer_rcvd and dhcpyia_rxdv;
				tp(1) <= dhcpchaddr6_rxdv and dll_rxdv;
				dchp_yia_e : entity hdl4fpga.mii_des
				generic map (
					init_data => reverse(default_ipv4a,8))
				port map (
					mii_rxc  => mii_txc,
					mii_rxdv => dhcpipv4a_rxdv,
					mii_rxd  => txc_rxd,
					des_data => dhcpipv4a);

				process (mii_txc)
				begin
					if rising_edge(mii_txc) then
						if dll_rxdv='0' then
							if txc_eor='1' then
								dhcp_rcvd <= udpproto_rcvd and udpports_rcvd;
								if dhcpoffer_rcvd='1' then
									if dhcpchaddr6_equ='1' then 
										cfgipv4a <= dhcpipv4a;
									end if;
								end if;
							else
								dhcp_rcvd <= '0';
							end if;
						end if;
					end if;
				end process;

			end block;

			myipv4a <= cfgipv4a;
		end block;
	end block;

end;
