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

entity eth_rx is
	generic (
		mac          : in std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		mii_rxc       : in  std_logic;
		mii_rxd       : in  std_logic_vector;
		mii_rxdv      : in  std_logic;

		mii_req       : in  std_logic;
		mii_txc       : in  std_logic;
		mii_txd       : out std_logic_vector;
		mii_txdv      : out std_logic;

		mymac_vld     : out std_logic;
		myipcfg_vld   : buffer std_logic;
		udpdports_val : in  std_logic_vector;
		udpdports_vld : out std_logic_vector;
		udpddata_vld  : out std_logic);
end;

architecture def of eth_rx is

	function wor (
		constant arg : std_logic_vector)
		return std_logic is
	begin
		for i in arg'range loop
			if arg(i)='1' then
				return '1';
			end if;
		end loop;
		return '0';
	end;

	constant ipproto   : std_logic_vector := x"0800";
	constant arpproto  : std_logic_vector := x"0806";


	constant miiptr_size : natural := unsigned_num_bits(to_miisize(64*8));
	signal mii_ptr       : unsigned(0 to miiptr_size-1); -- := (others => '0');

	constant eth_pfx : natural_vector := (
		mac_d => 6*8,
		mac_s => 6*8,
		eth_t => 2*8);

	signal ptr : std_logic_vector;

begin

	mii_pre_e : entity hdl4fpga.miirx_pre 
	port map (
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_rxdv => mii_rxdv,
		mii_rdy  => pre_vld);

	process (mii_rxc)
	begin
		if rising_edge(mii_rxc) then
			if pre_vld='0' then
				mii_ptr <= (others => '0');
			elsif mii_ptr(0)='0' then
				mii_ptr <= mii_ptr + 1;
			end if;
		end if;
	end process;

	mymac_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(mac,8))
	port map (
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_treq => pre_vld,
		mii_pktv => ethdmac_vld);

	mii_bcst_e : entity hdl4fpga.mii_romcmp
	generic map (
		mem_data => reverse(x"ff_ff_ff_ff_ff_ff", 8))
	port map (
		mii_rxc  => mii_rxc,
		mii_rxd  => mii_rxd,
		mii_treq => pre_vld,
		mii_pktv => ethdbcst_vld);

	ethdbucst_vld <= ethdmac_vld or  ethdbcst_vld;
	ethsmac_vld   <= ethdmac_vld and ethsmac_ena;

	mii_ip_e : entity hdl4fpga.ethtype
	generic map (
		protos => ipproto & arpproto)
	port map (
		mii_rxc => mii_rxc,
		mii_rxd => mii_rxd,
		frame   => ethdmac_vld,
		field   => ethty_ena,
		proto   => ipproto_vld);

	arp_b : block
			constant arprxptr_size : natural := unsigned_num_bits(to_miisize(32*8));
			signal arp_rxptr : unsigned(0 to arprxptr_size-1);

			signal requ_rcv : std_logic;
			signal rply_req : std_logic;

			signal spa_rdy  : std_logic;
			signal spa_req  : std_logic;
			signal spa_rxdv : std_logic;
			signal spa_rxd  : std_logic_vector(mii_txd'range);

		begin

			process (mii_rxc)
			begin
				if rising_edge(mii_rxc) then
					if arpproto_vld='0' then
						arp_rxptr <= (others => '0');
					elsif arp_rxptr(0)='0' then
						arp_rxptr <= arp_rxptr + 1;
					end if;
				end if;
			end process;

			request_b : block
				constant arp_sha : field := (ethertype.offset+ethertype.size+ 8, 6);
				constant arp_tpa : field := (ethertype.offset+ethertype.size+24, 4);
				signal   sha_ena : std_logic;
				signal   tpa_ena : std_logic;
				signal   cmp_equ : std_logic;

			begin

				sha_ena <= lookup((0 => arp_sha), std_logic_vector(mii_ptr));
				tpa_ena <= lookup((0 => arp_tpa), std_logic_vector(mii_ptr));

				mii_tpacmp : entity hdl4fpga.mii_cmp
				port map (
					mii_req  => arpproto_vld,
					mii_rxc  => mii_rxc,
					mii_ena  => tpa_ena,
					mii_rdy  => ipsaddr_rrdy,
					mii_rxd1 => mii_rxd,
					mii_rxd2 => ipsaddr_rtxd,
					mii_equ  => cmp_equ);

				process(mii_rxc)
				begin
					if rising_edge(mii_rxc) then
						if ipsaddr_rrdy='1' then
							requ_rcv <= cmp_equ;
						elsif arpproto_vld='0' then
							requ_rcv <= cmp_equ;
						end if;
					end if;
				end process;

				ethsmac_vld  <= arpproto_vld and sha_ena;
				ipsaddr_rreq <= arpproto_vld;
				ipsaddr_rena <= tpa_ena;
			end block;

			reply_b : block
				signal rply_rdy    : std_logic;

				signal arphdr_rdy  : std_logic;
				signal arphdr_req  : std_logic;
				signal arphdr_rxdv : std_logic;
				signal arphdr_rxd  : std_logic_vector(mii_txd'range);

				signal tha_rdy     : std_logic;
				signal tha_req     : std_logic;
				signal tha_rxdv    : std_logic;
				signal tha_rxd     : std_logic_vector(mii_txd'range);

				signal tpa_rdy     : std_logic;
				signal tpa_req     : std_logic;
				signal tpa_rxdv    : std_logic;
				signal tpa_rxd     : std_logic_vector(mii_txd'range);

				signal miicat_trdy : std_logic_vector(0 to 4-1);
				signal miicat_treq : std_logic_vector(0 to 4-1);
				signal miicat_rxdv : std_logic_vector(0 to 4-1);
				signal miicat_rxd  : std_logic_vector(0 to 4*mii_txd'length-1);

				signal spacpy_rdy  : std_logic;

				signal txdv        : std_logic;
				signal txd         : std_logic_vector(mii_txd'range);
				signal requ_set    : std_logic;
			begin
				
				process (mii_rxc)
					variable edge : std_logic;
				begin
					if rising_edge(mii_rxc) then
						if rply_req='0' then
							if edge='0' and requ_rcv='1' then
								requ_set <= '1';
							end if;
						else
							requ_set <= '0';
						end if;
						edge := requ_rcv;
					end if;
				end process;

				process (mii_txc)
				begin
					if rising_edge(mii_txc) then
						if rply_rdy='1' then
							rply_req <= '0';
						elsif rply_req='0' then
							rply_req <= requ_set;
						end if;
--						rply_req <= btn;
					end if;
				end process;

				mii_ethhdr_e : entity hdl4fpga.mii_rom
				generic map (
					mem_data => reverse(x"0001_0800_0604_0002" & mac, 8))
				port map (
					mii_txc  => mii_txc,
					mii_treq => arphdr_req,
					mii_trdy => arphdr_rdy,
					mii_txdv => arphdr_rxdv,
					mii_txd  => arphdr_rxd);

				mii_tha_e : entity hdl4fpga.mii_rom
				generic map (
					mem_data => reverse( x"ff_ff_ff_ff_ff_ff", 8))
				port map (
					mii_txc  => mii_txc,
					mii_treq => tha_req,
					mii_trdy => tha_rdy,
					mii_txdv => tha_rxdv,
					mii_txd  => tha_rxd);

				spa_rxdv <= ipsaddr_ttxdv;
				spa_rxd  <= ipsaddr_ttxd;
				process (mii_txc)
				begin
					if rising_edge(mii_txc) then
						if rply_req='0' then
							spacpy_rdy <= '0';
						elsif ipsaddr_teoc='1' then
							spacpy_rdy <= '1';
						end if;
					end if;
				end process;
				spa_rdy      <= rply_req and (ipsaddr_teoc or spacpy_rdy);
				ipsaddr_treq <= spa_req  when spacpy_rdy='0' else tpa_req;
				ipsaddr_tena <= spa_req  when spacpy_rdy='0' else tpa_req;

				tpa_rdy  <= tpa_req and ipsaddr_trdy;
				tpa_rxdv <= ipsaddr_ttxdv;
				tpa_rxd  <= ipsaddr_ttxd;

				(0 => arphdr_req, 1 => spa_req, 2 => tha_req, 3 => tpa_req) <= miicat_treq;
				miicat_trdy <= (0 => arphdr_rdy,  1 => spa_rdy,  2 => tha_rdy,  3 => tpa_rdy);
				miicat_rxdv <= (0 => arphdr_rxdv, 1 => spa_rxdv, 2 => tha_rxdv, 3 => tpa_rxdv);
				miicat_rxd  <=       arphdr_rxd &      spa_rxd &      tha_rxd &      tpa_rxd;

				mii_arpcat_e : entity hdl4fpga.mii_cat
				port map (
					mii_req  => rply_req,
					mii_rdy  => rply_rdy,
					mii_trdy => miicat_trdy,
					mii_rxdv => miicat_rxdv,
					mii_rxd  => miicat_rxd,
					mii_treq => miicat_treq,
					mii_txdv => txdv,
					mii_txd  => txd);

				process (mii_txc)
				begin
					if rising_edge(mii_txc) then
						-- dmacbcst_sel <= txdv;
						arp_txdv <= txdv;
						arp_txd  <= txd;
					end if;
				end process;

			end block;

		end block;

		ip_b: block
		
			constant ip_frame   : natural := ethertype.offset+ethertype.size;
			constant ip_verihl  : field   := (ip_frame+0,  1);
			constant ip_tos     : field   := (ip_frame+1,  1);
			constant ip_len     : field   := (ip_frame+2,  2);
			constant ip_ident   : field   := (ip_frame+4,  2);
			constant ip_flgsfrg : field   := (ip_frame+6,  2);
			constant ip_ttl     : field   := (ip_frame+8,  1);
			constant ip_proto   : field   := (ip_frame+9,  1);
			constant ip_chksum  : field   := (ip_frame+10, 2);
			constant ip_saddr   : field   := (ip_frame+12, 4);
			constant ip_daddr   : field   := (ip_frame+16, 4);
			constant iphdr_size : natural := 20;

			constant ip4_shdr : std_logic_vector := (
				x"4500" &    -- IP Version, TOS
				x"0000" &    -- IP Identification
				x"0000" &    -- IP Fragmentation
				x"0511");    -- IP TTL, protocol

			signal udpproto_vld : std_logic;
			signal udpproto_ena : std_logic;

			signal chksum_req    : std_logic;

			signal ip4shdr_txd   : std_logic_vector(mii_txd'range);
			signal ip4shdr_ena   : std_logic;

			constant ipptr_size  : natural := unsigned_num_bits(to_miisize(32*8));
			signal ip_ptr        : std_logic_vector(0 to ipptr_size-1);

			signal ip4len_ena    : std_logic;
			signal ip4len_txd    : std_logic_vector(mii_txd'range);

			signal ippyld_txdv   : std_logic;
			signal ippyld_txd    : std_logic_vector(mii_txd'range);
			signal ip_length     : std_logic_vector(16-1 downto 0);

			signal ip4pfx0_txdv  : std_logic;
			signal ip4pfx0_txd   : std_logic_vector(mii_txd'range);
			signal ip4pfx_txdv   : std_logic;
			signal ip4pfx_txd    : std_logic_vector(mii_txd'range);
			signal ip4hdr0_txdv  : std_logic;
			signal ip4hdr0_txd   : std_logic_vector(mii_txd'range);
			signal ip4hdr_txdv   : std_logic;
			signal ip4hdr_txd    : std_logic_vector(mii_txd'range);
			signal ip4cksm_txdv  : std_logic;
			signal ip4cksm_txd   : std_logic_vector(mii_txd'range);

			signal ip4saddr_ena  : std_logic;
            signal ip4daddr_ena  : std_logic;
			signal ip4saddr_txd  : std_logic_vector(mii_txd'range);
			signal ip4daddr_txd  : std_logic_vector(mii_txd'range);
			signal ip4addr_txdv : std_logic;
			signal ip4addr_txd  : std_logic_vector(mii_txd'range);
			signal ip4addr_rxdv : std_logic;
			signal ip4addr_rxd  : std_logic_vector(mii_txd'range);

			signal ip4dbcst_sel  : wor std_ulogic;
			signal ip4sinvd_sel  : wor std_ulogic;
		begin

			ipdata_txd <= wirebus (
				dhcp_txd,
				(0 => dhcp_txdv(0)));
			ipdata_txdv <= dhcp_txdv(0);

			process(mii_txc)
			begin
				if rising_edge(mii_txc) then
					if ipdata_txdv='0' then
						ip_ptr <= (others => '0');
					elsif ip_ptr(0)/='1' then
						ip_ptr <= std_logic_vector(unsigned(ip_ptr) + 1);
					end if;
				end if;
			end process;

			ip4shdr_ena <= lookup((ip_verihl, ip_tos, ip_ident, ip_flgsfrg, ip_ttl, ip_proto), ip_ptr, ip_frame) and ipdata_txdv;
			ip4len_ena  <= lookup((0 => ip_len), ip_ptr, ip_frame) and ipdata_txdv;

			mii_shdr_e : entity hdl4fpga.mii_rom
			generic map (
				mem_data => reverse(ip4_shdr, 8))
			port map (
				mii_txc  => mii_txc,
				mii_treq => ipdata_txdv,
				mii_tena => ip4shdr_ena,
				mii_txd  => ip4shdr_txd);

			payload_txdv_e : entity hdl4fpga.align
			generic map (
				n => 1,
				d => (0 => to_miisize(iphdr_size+ip_chksum.size+2*ip4a_size)))
			port map (
				clk   => mii_txc,
				di(0) => ipdata_txdv,
				do(0) => ippyld_txdv);

			payload_txd_e : entity hdl4fpga.align
			generic map (
				n => mii_txd'length,
				d => (0 to mii_txd'length-1 => to_miisize(iphdr_size+ip_chksum.size+2*ip4a_size)))
			port map (
				clk => mii_txc,
				di  => ipdata_txd,
				do  => ippyld_txd);

--			ip_length <= wirebus ();
			ip_length <= std_logic_vector(to_unsigned(250+28,16));
			miiipsize_e : entity hdl4fpga.mii_pll2ser
			port map (
				mii_data => ip_length,
				mii_txc  => mii_txc,
				mii_treq => ipdata_txdv,
				mii_tena => ip4len_ena,
				mii_txd  => ip4len_txd);

			ip4saddr_txd <= wirebus(
				(mii_txd'range => '0'), 
				(0 => ip4sinvd_sel));
			ip4daddr_txd <= wirebus(
				(mii_txd'range => '1'), 
				(0 => ip4dbcst_sel));

			ip4saddr_ena <= lookup((0 => ip_saddr), ip_ptr, ip_frame+ip_chksum.size) and ipdata_txdv;
			ip4daddr_ena <= lookup((0 => ip_daddr), ip_ptr, ip_frame+ip_chksum.size) and ipdata_txdv;

			ip4pfx0_txdv <= ip4shdr_ena or ip4len_ena;
			ip4pfx0_txd  <= wirebus (
				ip4shdr_txd & ip4len_txd,
				ip4shdr_ena & ip4len_ena);

			ip4addr_txdv <= ip4saddr_ena or ip4daddr_ena;
			ip4addr_txd  <= wirebus (
				  ip4saddr_txd & ip4daddr_txd,
				  ip4saddr_ena & ip4daddr_ena);

			ip4addr_ena_e : entity hdl4fpga.align
			generic map (
				n => 1,
				d => (0 => to_miisize(ip_chksum.size)))
			port map (
				clk   => mii_txc,
				di(0) => ip4addr_txdv,
				do(0) => ip4addr_rxdv);

			ip4addr_rxd_e : entity hdl4fpga.align
			generic map (
				n => mii_txd'length,
				d => (0 to mii_txd'length-1 => to_miisize(ip_chksum.size)))
			port map (
				clk => mii_txc,
				di  => ip4addr_txd,
				do  => ip4addr_rxd);

			ip4pfx_txdv <= ip4pfx0_txdv or ip4addr_rxdv;
			ip4pfx_txd  <= wirebus (
				ip4pfx0_txd  & ip4addr_rxd,
				ip4pfx0_txdv & ip4addr_rxdv);

			chksum_b : block
				signal cksm_txdv    : std_logic;
				signal cksm_txd     : std_logic_vector(mii_txd'range);

				signal ip4cksm_rxdv : std_logic;
				signal ip4cksm_rxd  : std_logic_vector(mii_txd'range);
			begin

				ip4cksm_rxdv <= (ip4addr_txdv or ip4pfx0_txdv) and ipdata_txdv;
				ip4cksm_rxd  <= wirebus(
					ip4addr_txd  & ip4pfx0_txd,
					ip4addr_txdv & ip4pfx0_txdv);

				mii_1chksum_e : entity hdl4fpga.mii_1chksum
				generic map (
					n => 16)
				port map (
					mii_txc  => mii_txc,
					mii_rxdv => ip4cksm_rxdv,
					mii_rxd  => ip4cksm_rxd,
					mii_txdv => cksm_txdv,
					mii_txd  => cksm_txd);

				fifo_b : block
				begin
					process (mii_txc)
						variable fifo : unsigned(0 to 16-mii_txd'length-1);
						variable neg  : std_logic;
					begin
						if rising_edge(mii_txc) then
							ip4cksm_txd <= std_logic_vector(fifo(mii_txd'range)) xor (mii_txd'range => not neg);
							fifo(mii_txd'range) := unsigned(cksm_txd);
							fifo := fifo ror mii_txd'length;
							if cksm_txdv='1' then
								if cksm_txd/=(cksm_txd'range => '1') then
									neg := '0';
								end if;
							elsif ip4cksm_txdv='0' then
								neg := '1';
							end if;
						end if;
					end process;

					delay_e : entity hdl4fpga.align
					generic map (
						n => 1,
						d => (0 to 1-1 => to_miisize(ip_chksum.size)))
					port map (
						clk => mii_txc,
						di(0) => cksm_txdv,
						do(0) => ip4cksm_txdv);

				end block;
			end block;

			ip4hdr_ena_e : entity hdl4fpga.align
			generic map (
				n => 1,
				d => (0 => to_miisize(2*ip4a_size+ip_chksum.size)))
			port map (
				clk   => mii_txc,
				di(0) => ip4pfx_txdv,
				do(0) => ip4hdr0_txdv);

			ip4hdr_txd_e : entity hdl4fpga.align
			generic map (
				n => mii_txd'length,
				d => (0 to mii_txd'length-1 => to_miisize(2*ip4a_size+ip_chksum.size)))
			port map (
				clk => mii_txc,
				di  => ip4pfx_txd,
				do  => ip4hdr0_txd);

			ip4hdr_txd <= wirebus (
				ip4hdr0_txd  & ip4cksm_txd,
				ip4hdr0_txdv & ip4cksm_txdv);

			ip4hdr_txdv <=
				ip4hdr0_txdv or
				ip4cksm_txdv;

			ip_txd <= wirebus(
				ip4hdr_txd  & ippyld_txd,
				ip4hdr_txdv & ippyld_txdv);

			ip_txdv <= ip4hdr_txdv or ippyld_txdv;

			rx_b : block
			begin
				udpproto_ena <= lookup((0 => ip_proto), std_logic_vector(mii_ptr)) and ipproto_vld;

				mii_udp_e : entity hdl4fpga.mii_romcmp
				generic map (
					mem_data => reverse(x"11",8))
				port map (
					mii_rxc  => mii_rxc,
					mii_rxd  => mii_rxd,
					mii_treq => ipproto_vld,
					mii_ena  => udpproto_ena,
					mii_pktv => udpproto_vld);

			end block;

			udp_b : block
				constant udp_frame  : natural :=  ip_frame+20;
				constant udp_sport  : field   := (udp_frame+0, 2);
				constant udp_dport  : field   := (udp_frame+2, 2);
				constant udp_length : field   := (udp_frame+4, 2);
				constant udp_chksum : field   := (udp_frame+6, 2);
				constant udp_data   : natural := udp_chksum.offset+udp_chksum.size;

				signal udpport_ena : std_logic;
				signal udpdata_ena : std_logic;
			begin

				udp_vld     <= lookup(udp_frame, std_logic_vector(mii_ptr)) and udpproto_vld;
				udpport_ena <= lookup((0 => udp_dport), std_logic_vector(mii_ptr)) and udpproto_vld;
				udpdata_ena <= lookup(udp_data,  std_logic_vector(mii_ptr)) and udpproto_vld;

				rx_b : block
					constant dport_size : natural := mii_rxd'length*to_miisize(udp_dport.size);
					signal dport : std_logic_vector(dport_size-1 downto 0);
				begin

					dport_b : for i in udpdports_vld'range generate
						signal vld : std_logic;
					begin

						process (udpdports_val)
							variable aux : unsigned(0 to udpdports_val'length-1);
						begin
							aux   := unsigned(udpdports_val);
							aux   := aux rol (i*dport'length);
							dport <= std_logic_vector(aux(dport'reverse_range));
						end process;

						udp_e : entity hdl4fpga.mii_pllcmp
						port map (
							mii_data => dport,
							mii_rxc  => mii_rxc,
							mii_rxd  => mii_rxd,
							mii_treq => ipproto_vld,
							mii_ena  => udpport_ena,
							mii_pktv => udpdports_vld(i));

					end generate;

					udpddata_vld <= udpdata_ena;
				end block;

				dhcpc_b : block
					constant dhcp_frame : natural :=  udp_frame+8;
					constant dhcp_yia   : field   := (dhcp_frame+16, 4);
					constant dhcp_sia   : field   := (dhcp_frame+20, 4);

					signal dhcp_ena     : std_logic;
					signal yia_ena      : std_logic;
					signal sia_ena      : std_logic;

					signal dis_txd   : std_logic_vector(mii_txd'range);
					signal dis_txdv  : std_logic;
					signal requ_txd  : std_logic_vector(mii_txd'range);
					signal requ_txdv : std_logic;

					signal offer_rcv : std_logic;
				begin
					
					dhcp_ena <= lookup((0 => udp_sport, 1 => udp_dport), std_logic_vector(mii_ptr));
					yia_ena  <= lookup((0 => dhcp_yia), std_logic_vector(mii_ptr));
					sia_ena  <= lookup((0 => dhcp_sia), std_logic_vector(mii_ptr));

					discover_b : block
						constant payload_size : natural := 244+6;

						constant vendor_data : std_logic_vector := reverse(
								x"63825363"            &    -- MAGIC COOKIE
								x"350101"              &    -- DHCPDISCOVER
								x"320400000000"        &    -- IP REQUEST
								x"FF",8);                   -- END

						constant header_data : std_logic_vector := reverse(
							udp_checksummed (
								x"00000000",
								x"ffffffff",
								x"00440043"            &    -- UDP Source port, Destination port
								std_logic_vector(to_unsigned(payload_size+8,16)) & -- UDP Length,
								oneschecksum(reverse(vendor_data, 8),16) &	-- UDP CHECKSUM
								x"01010600"            &    -- OP, HTYPE, HLEN,  HOPS
								x"3903f326"            &    -- XID
								x"00000000"            &    -- SECS, FLAGS
								x"00000000"            &    -- CIADDR
								x"00000000"            &    -- YIADDR
								x"00000000"            &    -- SIADDR
								x"00000000"            &    -- GIADDR
								mac & x"0000"          &    -- CHADDR
								x"00000000"            &    -- CHADDR
								x"00000000"),8);            -- CHADDR

						signal txdv : std_logic;
						signal txd  : std_logic_vector(mii_txd'range);

						signal header_treq : std_logic;
						signal header_trdy : std_logic;
						signal header_txdv : std_logic;
						signal header_txd  : std_logic_vector(mii_txd'range);

						signal sbname_treq : std_logic;
						signal sbname_trdy : std_logic;
						signal sbname_txdv : std_logic;
						signal sbname_txd  : std_logic_vector(mii_txd'range);

						signal vendor_treq : std_logic;
						signal vendor_trdy : std_logic;
						signal vendor_txdv : std_logic;
						signal vendor_txd  : std_logic_vector(mii_txd'range);

						signal dhcpcd_trdy : std_logic_vector(0 to 3-1);
						signal dhcpcd_treq : std_logic_vector(0 to 3-1);
						signal dhcpcd_rxdv : std_logic_vector(0 to 3-1);
						signal dhcpcd_rxd  : std_logic_vector(0 to 3*mii_txd'length-1);

					begin

						header_e  : entity hdl4fpga.mii_rom
						generic map (
							mem_data => header_data)
						port map (
							mii_txc  => mii_txc,
							mii_treq => header_treq,
							mii_trdy => header_trdy,
							mii_txdv => header_txdv,
							mii_txd  => header_txd);

						sbname_e  : entity hdl4fpga.mii_rom
						generic map (
							mem_data => (1 to 8*(64+128) => '0'))
						port map (
							mii_txc  => mii_txc,
							mii_treq => sbname_treq,
							mii_trdy => sbname_trdy,
							mii_txdv => sbname_txdv,
							mii_txd  => sbname_txd);

						vendor_e  : entity hdl4fpga.mii_rom
						generic map (
							mem_data => vendor_data)
						port map (
							mii_txc  => mii_txc,
							mii_treq => vendor_treq,
							mii_trdy => vendor_trdy,
							mii_txdv => vendor_txdv,
							mii_txd  => vendor_txd);

						(0 => header_treq, 1 => sbname_treq, 2 => vendor_treq) <= dhcpcd_treq;
						dhcpcd_trdy <= (0 => header_trdy, 1 => sbname_trdy, 2 => vendor_trdy);
						dhcpcd_rxdv <= (0 => header_txdv, 1 => sbname_txdv, 2 => vendor_txdv);
						dhcpcd_rxd  <=       header_txd & (mii_txd'range => '0') & vendor_txd;

						mii_dhcpcd_e : entity hdl4fpga.mii_cat
						port map (
							mii_req  => mii_req,
							mii_trdy => dhcpcd_trdy,
							mii_treq => dhcpcd_treq,
							mii_rxdv => dhcpcd_rxdv,
							mii_rxd  => dhcpcd_rxd,
							mii_txdv => txdv,
							mii_txd  => txd);

						process (mii_txc)
						begin
							if rising_edge(mii_txc) then
--								dmacbcst_sel <= txdv;
								ip4dbcst_sel <= txdv;
								ip4sinvd_sel <= txdv;
								dis_txdv <= txdv;
								dis_txd  <= txd;
							end if;
						end process;

					end block;

					offer_b : block
					begin
						mii_dhcp_e : entity hdl4fpga.mii_romcmp
						generic map (
							mem_data => reverse(x"00430044",8))
						port map (
							mii_rxc  => mii_rxc,
							mii_rxd  => mii_rxd,
							mii_treq => udpproto_vld,
							mii_ena  => dhcp_ena,
							mii_pktv => dhcp_vld);

						myipcfg_vld  <= dhcp_vld and yia_ena;
						ipdaddr_vld  <= dhcp_vld and sia_ena;
						offer_rcv    <= dhcp_vld;

					end block;


--					dhcp_txd  <= word2byte(dis_txd  & requ_txd,   not dis_txdv);
--					dhcp_txdv <= word2byte(dis_txdv & requ_txdv,  not dis_txdv)(0);
					dhcp_txd  <= word2byte(dis_txd  & (dhcp_txd'range => '0'), not dis_txdv);
					dhcp_txdv <= word2byte(dis_txdv & "0",                     not dis_txdv);
				end block;
			end block;

		end block;

	end block;

end;

