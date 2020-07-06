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
use hdl4fpga.ipoe.all;

entity ip_tx is
	port (
		mii_txc   : in  std_logic;

		pl_txdv   : in  std_logic;
		pl_txd    : in  std_logic_vector;

		ipsa_treq : out std_logic;
		ipsa_trdy : in  std_logic := '-';
		ipsa_txen : in  std_logic;
		ipsa_txd  : in  std_logic_vector;

		ipda_treq : out std_logic;
		ipda_trdy : in  std_logic := '-';
		ipda_txen : in  std_logic;
		ipda_txd  : in  std_logic_vector;

		ip_txdv : out std_logic;
		ip_txd  : out std_logic_vector);
end;

architecture def of ip_tx is
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

