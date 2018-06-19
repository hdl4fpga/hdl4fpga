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
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

entity mii_ipcfg is
	generic (
		mac       : in std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		mii_rxc    : in  std_logic;
		mii_rxd    : in  std_logic_vector;
		mii_rxdv   : in  std_logic;

		mii_req    : in  std_logic;
		mii_txc    : in  std_logic;
		mii_txd    : out std_logic_vector;
		mii_txdv   : out std_logic;

		udp_length : in std_logic_vector(16-1 downto 0) := x"6789";
		udp_txdv   : in std_logic;
		udp_txd    : in std_logic_vector;

		mii_prev   : out std_logic;
		mii_bcstv  : out std_logic;
		mii_macv   : out std_logic;
		mii_ipv    : out std_logic;
		mii_udpv   : out std_logic;
		mii_myipv  : out std_logic
);
end;

architecture struct of mii_ipcfg is

	type field is record
		offset : natural;
		size   : natural;
	end record;

	type field_vector is array (natural range <>) of field;

	function to_miisize (
		constant arg  : natural;
		constant size : natural := mii_txd'length)
		return natural is
	begin
		return arg*8/size;
	end;

	function to_miisize (
		constant table : field_vector;
		constant size  : natural := mii_txd'length)
		return   field_vector is
		variable retval : field_vector(table'range);
	begin
		for i in table'range loop
			retval(i).offset := table(i).offset*8/size;
			retval(i).size   := table(i).size*8/size;
		end loop;
		return retval;
	end;

	function lookup (
		constant table : field_vector;
		constant data  : std_logic_vector;
		constant base  : natural := 0) 
		return std_logic is
		variable aux    : field_vector(table'range);
		variable offset : natural;
	begin
		aux := to_miisize(table);
		for i in aux'range loop
			offset := aux(i).offset-base;
			if offset <= to_integer(unsigned(data)) then
				if to_integer(unsigned(data)) < offset+aux(i).size then
					return '1';
				end if;
			end if;
		end loop;
		return '0';
	end;

	function lookup (
		constant offset : natural;
		constant data  : std_logic_vector;
		constant base  : natural := 0) 
		return std_logic is
	begin
		if to_miisize(offset-base) <= to_integer(unsigned(data)) then
			return '1';
		end if;
		return '0';
	end;

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

begin

	eth_b : block
		constant ip4a_size : natural := 4;
		constant mac_size  : natural := 6;

		constant etherdmac : field := (0, mac_size);
		constant ethersmac : field := (etherdmac.offset+etherdmac.size, mac_size);
		constant ethertype : field := (ethersmac.offset+ethersmac.size, 2);
		constant ipproto   : std_logic_vector := x"0800";
		constant arpproto  : std_logic_vector := x"0806";


		signal mii_ptr       : unsigned(0 to to_miisize(8));

		signal pre_vld       : std_logic;
		signal ethdmac_vld   : std_logic;
		signal ethsmac_vld   : wor std_ulogic;
		signal ethdbcst_vld  : std_logic;
		signal ipproto_vld   : std_logic;
		signal ethdbucst_vld : std_logic;
		signal arpproto_vld  : std_logic;
		signal udp_vld       : std_logic;
		signal dhcp_vld      : std_logic;
		signal myipcfg_vld   : std_logic;
		signal ipdaddr_vld   : std_logic;

		signal ethsmac_ena   : std_logic;
		signal ethty_ena     : std_logic;

		signal ipsaddr_treq  : std_logic;
		signal ipsaddr_trdy  : std_logic;
		signal ipsaddr_teoc  : std_logic;
		signal ipsaddr_tena  : std_logic;
		signal ipsaddr_ttxd  : std_logic_vector(mii_txd'range);
		signal ipsaddr_ttxdv : std_logic;

		signal ipdaddr_treq  : std_logic;
		signal ipdaddr_trdy  : std_logic;
		signal ipdaddr_teoc  : std_logic;
		signal ipdaddr_ttxd  : std_logic_vector(mii_txd'range);
		signal ipdaddr_ttxdv : std_logic;

		signal ipsaddr_rreq  : std_logic;
		signal ipsaddr_rrdy  : std_logic;
		signal ipsaddr_rena  : std_logic;
		signal ipsaddr_rtxd  : std_logic_vector(mii_rxd'range);
		signal ipsaddr_rtxdv : std_logic;

		signal ipdaddr_rreq  : std_logic;
		signal ipdaddr_rrdy  : std_logic;
		signal ipdaddr_reoc  : std_logic;
		signal ipdaddr_rena  : std_logic;
		signal ipdaddr_rtxd  : std_logic_vector(mii_rxd'range);
		signal ipdaddr_rtxdv : std_logic;

		signal miidhcp_txd   : std_logic_vector(mii_txd'range);
		signal miidhcp_txdv  : std_logic;
		signal arp_txd       : std_logic_vector(mii_txd'range);
		signal arp_txdv      : std_logic;
		signal ip_txd        : std_logic_vector(mii_txd'range);
		signal ip_txdv       : std_logic;
		signal ipdata_txd    : std_logic_vector(mii_txd'range);
		signal ipdata_txdv   : std_logic;
		signal ethdmac_txd   : std_logic_vector(mii_txd'range);
	begin

		register_file_b : block
		begin
			tx_b : block
			begin
				miitx_ipsaddr_e : entity hdl4fpga.mii_ram
				generic map (
					size => to_miisize(ip4a_size))
				port map(
					mii_rxc  => mii_rxc,
					mii_rxd  => mii_rxd,
					mii_rxdv => myipcfg_vld,
					mii_txc  => mii_txc,
					mii_txdv => ipsaddr_ttxdv,
					mii_txd  => ipsaddr_ttxd,
					mii_tena => ipsaddr_tena,
					mii_treq => ipsaddr_treq,
					mii_teoc => ipsaddr_teoc,
					mii_trdy => ipsaddr_trdy);

				miitx_ipdaddr_e : entity hdl4fpga.mii_ram
				generic map (
					size => to_miisize(ip4a_size))
				port map(
					mii_rxc  => mii_rxc,
					mii_rxd  => mii_rxd,
					mii_rxdv => ipdaddr_vld,
					mii_txc  => mii_txc,
					mii_txdv => ipdaddr_ttxdv,
					mii_txd  => ipdaddr_ttxd,
					mii_treq => ipdaddr_treq,
					mii_teoc => ipdaddr_teoc,
					mii_trdy => ipdaddr_trdy);
			end block;

			rx_b : block
			begin

				miitx_ethsmac_e : entity hdl4fpga.mii_ram
				generic map (
					size => to_miisize(mac_size))
				port map(
					mii_rxc  => mii_rxc,
					mii_rxd  => mii_rxd,
					mii_rxdv => ethsmac_vld,
					mii_txc  => mii_txc,
					mii_txd  => ethdmac_txd,
					mii_treq => std_logic'('0'));

				miirx_ipsaddr_e : entity hdl4fpga.mii_ram
				generic map (
					size => to_miisize(ip4a_size))
				port map(
					mii_rxc  => mii_rxc,
					mii_rxd  => mii_rxd,
					mii_rxdv => myipcfg_vld,
					mii_txc  => mii_rxc,
					mii_txd  => ipsaddr_rtxd,
					mii_txdv => ipsaddr_rtxdv,
					mii_tena => ipsaddr_rena,
					mii_treq => ipsaddr_rreq,
					mii_trdy => ipsaddr_rrdy);

				miirx_ipdaddr_e : entity hdl4fpga.mii_ram
				generic map (
					size => to_miisize(ip4a_size))
				port map(
					mii_rxc  => mii_rxc,
					mii_rxd  => mii_rxd,
					mii_rxdv => ipdaddr_vld,
					mii_txc  => mii_txc,
					mii_txdv => ipdaddr_rtxdv,
					mii_txd  => ipdaddr_rtxd,
					mii_tena => ipdaddr_rena,
					mii_treq => ipdaddr_rreq,
					mii_teoc => ipdaddr_reoc,
					mii_trdy => ipdaddr_rrdy);
			end block;

		end block;

		tx_b : block
			signal dmac_ena     : std_logic;
			signal smac_ena     : std_logic;
			signal type_ena     : std_logic;

			signal dmac_txd   : std_logic_vector(mii_txd'range);
			signal smac_txd   : std_logic_vector(mii_txd'range);

			signal txdv         : std_logic;
			signal txd          : std_logic_vector(0 to mii_txd'length-1);
			signal rxdv         : std_logic;
			signal rxd          : std_logic_vector(0 to mii_txd'length-1);

			signal dll_txdv     : std_logic;
			signal dll_txd      : std_logic_vector(0 to mii_txd'length-1);

			signal type_txdv     : std_logic;
			signal type_txd      : std_logic_vector(0 to mii_txd'length-1);

			signal arptype_rdy  : std_logic;
			signal arptype_req  : std_logic;
			signal arptype_rxdv : std_logic;
			signal arptype_rxd  : std_logic_vector(mii_txd'range);

			signal iptype_rdy   : std_logic;
			signal iptype_req   : std_logic;
			signal iptype_rxdv  : std_logic;
			signal iptype_rxd   : std_logic_vector(mii_txd'range);

			signal miitx_ptr    : unsigned(0 to to_miisize(4));
		begin
			rxd <= wirebus(
				arp_txd  & ip_txd,
				arp_txdv & ip_txdv);
			rxdv <= arp_txdv or ip_txdv;

			process (mii_txc)
			begin
				if rising_edge(mii_txc) then
					if rxdv='1' then
						miitx_ptr <= (others => '0');
					elsif miitx_ptr(0)='1' then
						mii_ptr <= mii_ptr + 1;
					end if;
				end if;
			end process;

			dmac_ena <= lookup((0 => etherdmac), std_logic_vector(miitx_ptr));
			smac_ena <= lookup((0 => ethersmac), std_logic_vector(miitx_ptr));
			type_ena <= lookup((0 => ethertype), std_logic_vector(miitx_ptr));

			mii_mac_e : entity hdl4fpga.miitx_dll
			port map (
				mii_txc  => mii_txc,
				mii_rxdv => dll_txdv,
				mii_rxd  => dll_txd,
				mii_txdv => mii_txdv,
				mii_txd  => mii_txd);

			dll_rxd_e : entity hdl4fpga.align
			generic map (
				n => mii_txd'length,
				d => (0 to mii_txd'length-1 => to_miisize(etherdmac.size+ethersmac.size+ethertype.size)))
			port map (
				clk => mii_txc,
				di => rxd,
				do => txd);

			dll_rxdv_e : entity hdl4fpga.align
			generic map (
				n => 1,
				d => (0 to mii_txd'length-1 => to_miisize(etherdmac.size+ethersmac.size+ethertype.size)))
			port map (
				clk   => mii_txc,
				di(0) => rxdv,
				do(0) => txdv);

			arpproto_e : entity hdl4fpga.mii_rom
			generic map (
				mem_data => reverse(arpproto, 8))
			port map (
				mii_txc  => mii_txc,
				mii_treq => arptype_req,
				mii_trdy => arptype_rdy,
				mii_txdv => arptype_rxdv,
				mii_txd  => arptype_rxd);

			ipproto_e : entity hdl4fpga.mii_rom
			generic map (
				mem_data => reverse(ipproto, 8))
			port map (
				mii_txc  => mii_txc,
				mii_treq => iptype_req,
				mii_trdy => iptype_rdy,
				mii_txdv => iptype_rxdv,
				mii_txd  => iptype_rxd);

			type_txd <= wirebus(
				iptype_rxd  & arptype_rxd,
				iptype_rxdv & arptype_rxdv);
			type_txdv <=
				iptype_rxdv or arptype_rxdv;

			dll_txd <= wirebus (
				dmac_txd & smac_txd & type_txd,
				dmac_ena & smac_ena & type_ena);
			dll_txdv <=
				dmac_ena or smac_ena or type_ena;

		end block;

		rx_b : block
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

			ethsmac_ena <= lookup((0 => ethersmac), std_logic_vector(mii_ptr));
			ethty_ena   <= lookup((0 => ethertype), std_logic_vector(mii_ptr));

			mii_mac_e : entity hdl4fpga.mii_romcmp
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

			mii_arp_e : entity hdl4fpga.mii_romcmp
			generic map (
				mem_data => reverse(arpproto,8))
			port map (
				mii_rxc  => mii_rxc,
				mii_rxd  => mii_rxd,
				mii_treq => ethdbucst_vld,
				mii_ena  => ethty_ena,
				mii_pktv => arpproto_vld);

			mii_ip_e : entity hdl4fpga.mii_romcmp
			generic map (
				mem_data => reverse(ipproto,8))
			port map (
				mii_rxc  => mii_rxc,
				mii_rxd  => mii_rxd,
				mii_treq => ethdmac_vld,
				mii_ena  => ethty_ena,
				mii_pktv => ipproto_vld);

		end block;

		arp_b : block
			signal requ_rcv : std_logic;
			signal rply_req : std_logic;

			signal spa_rdy  : std_logic;
			signal spa_req  : std_logic;
			signal spa_rxdv : std_logic;
			signal spa_rxd  : std_logic_vector(mii_txd'range);

		begin

			request_b : block
				constant arp_sha : field := (ethertype.offset+ethertype.size+ 8, 6);
				constant arp_tpa : field := (ethertype.offset+ethertype.size+24, 4);
				signal   sha_ena : std_logic;
				signal   tpa_ena : std_logic;

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
					mii_equ  => requ_rcv);

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
			begin
				
				process (mii_txc)
					variable rply : std_logic;
				begin
					if rising_edge(mii_txc) then
						if rply_rdy='1' then
							rply_req <= '0';
							rply     := '0';
						elsif mii_rxdv='1' then
							rply_req <= '0';
							rply     := requ_rcv;
						elsif rply='1' then
							rply_req <= '1';
							rply     := '0';
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

			signal chksum_req    : std_logic;

			signal ip4shdr_txd   : std_logic_vector(mii_txd'range);
			signal ip4shdr_ena   : std_logic;

			signal ip_ptr        : std_logic_vector(0 to to_miisize(5));

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

			ip4shdr_ena <= lookup((ip_verihl, ip_tos, ip_ident, ip_flgsfrg, ip_ttl, ip_proto), ip_ptr, ip_frame);
			ip4len_ena  <= lookup((0 => ip_len   ), ip_ptr, ip_frame);

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
				di(0) => udp_txdv,
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

			ip4saddr_ena <= lookup((0 => ip_saddr), ip_ptr, ip_frame+ip_chksum.size);
			ip4daddr_ena <= lookup((0 => ip_daddr), ip_ptr, ip_frame+ip_chksum.size);

			ip4pfx0_txdv <= (ip4shdr_ena or ip4len_ena) and ipdata_txdv;
			ip4pfx0_txd  <= 
				(ip4shdr_txd and ip4shdr_ena) or
				(ip4len_txd  and ip4len_ena);

			ip4addr_txdv <= (ip4saddr_ena or ip4daddr_ena) and ipdata_txdv;
			ip4addr_txd  <= 
				  (ip4saddr_txd and ip4saddr_ena) or 
				  (ip4daddr_txd and ip4daddr_ena);

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
			ip4pfx_txd  <= 
				(ip4pfx0_txd and ip4pfx0_txdv)  or
				(ip4addr_rxd and ip4addr_rxdv);

			chksum_b : block
				signal cksm_txdv    : std_logic;
				signal cksm_txd     : std_logic_vector(mii_txd'range);

				signal ip4cksm_rxdv : std_logic;
				signal ip4cksm_rxd  : std_logic_vector(mii_txd'range);
			begin

				ip4cksm_rxdv <= (ip4addr_txdv or ip4pfx0_txdv) and ipdata_txdv;
				ip4cksm_rxd  <= 
					(ip4addr_txd and ip4addr_txdv) or
					(ip4pfx0_txd and ip4pfx0_txdv);

				mii_1chksum_e : entity hdl4fpga.mii_1chksum
				generic map (
					n => 16)
				port map (
					mii_txc  => mii_txc,
					mii_rxdv => ip4cksm_rxdv,
					mii_rxd  => ip4cksm_rxd,
					mii_txdv => cksm_txdv,
					mii_txd  => cksm_txd);

				lifo_b : block
					signal lifo : std_logic_vector(0 to 16-1);
				begin
					process (mii_txc)
						variable aux : unsigned(lifo'range);
					begin
						if rising_edge(mii_txc) then
							aux := unsigned(lifo);
							if cksm_txdv='1' then
								aux := aux ror mii_txd'length;
								aux(mii_txd'range) := unsigned(not cksm_txd);
							else
								aux := aux rol mii_txd'length;
							end if;
							lifo <= std_logic_vector(aux);
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

					ip4cksm_txd <= lifo(mii_txd'range);
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

			ip4hdr_txd <= 
				(ip4hdr0_txd and ip4hdr0_txdv) or
				(ip4cksm_txd and ip4cksm_txdv);

			ip4hdr_txdv <=
				ip4hdr0_txdv or
				ip4cksm_txdv;

			udp_b : block
				constant udp_frame  : natural :=  ip_frame+20;
				constant udp_sport  : field   := (udp_frame+0, 2);
				constant udp_dport  : field   := (udp_frame+2, 2);

				signal udpproto_vld : std_logic;
				signal udpproto_ena : std_logic;
			begin

				udpproto_ena <= lookup((0 => ip_proto), std_logic_vector(mii_ptr));
				udp_vld      <= lookup(udp_frame, std_logic_vector(mii_ptr)) and udpproto_vld;

				dhcpc_b : block
					constant dhcp_frame : natural :=  udp_frame+8;
					constant dhcp_yia   : field   := (dhcp_frame+16, 4);
					constant dhcp_sia   : field   := (dhcp_frame+20, 4);

					signal dhcp_ena     : std_logic;
					signal yia_ena      : std_logic;
					signal sia_ena      : std_logic;

					signal miidis_txd   : std_logic_vector(mii_txd'range);
					signal miidis_txdv  : std_logic;
					signal miirequ_txd  : std_logic_vector(mii_txd'range);
					signal miirequ_txdv : std_logic;

					signal offer_rcv : std_logic;
				begin
					
					dhcp_ena <= lookup((0 => udp_sport, 1 => udp_dport), std_logic_vector(mii_ptr));
					yia_ena  <= lookup((0 => dhcp_yia), std_logic_vector(mii_ptr));
					sia_ena  <= lookup((0 => dhcp_sia), std_logic_vector(mii_ptr));

					discover_b : block

					signal txdv : std_logic;
						signal txd  : std_logic_vector(mii_txd'range);

						constant payload_size : natural := 244+6;

						constant mii_data : std_logic_vector := reverse(
							udp_checksumed (
								x"00000000",
								x"ffffffff",
								x"00440043"            &    -- UDP Source port, Destination port
								std_logic_vector(to_unsigned(payload_size+8,16)) & -- UDP Length,
								x"0000"                &	-- UDP CHECKSUM
								x"01010600"            &    -- OP, HTYPE, HLEN,  HOPS
								x"3903f326"            &    -- XID
								x"00000000"            &    -- SECS, FLAGS
								x"00000000"            &    -- CIADDR
								x"00000000"            &    -- YIADDR
								x"00000000"            &    -- SIADDR
								x"00000000"            &    -- GIADDR
								mac & x"0000"          &    -- CHADDR
								x"00000000"            &    -- CHADDR
								x"00000000"            &    -- CHADDR
								(1 to 8* 64 => '0')    &    -- SNAME
								(1 to 8*128 => '0')    &    -- SNAME
								x"63825363"            &    -- MAGIC COOKIE
								x"350101"              &    -- DHCPDISCOVER
								x"320400000000"        &    -- IP REQUEST
								x"FF"),8);                  -- END

					begin

						miitx_mem_e  : entity hdl4fpga.mii_rom
						generic map (
							mem_data => mii_data)
						port map (
							mii_txc  => mii_txc,
							mii_treq => mii_req,
							mii_txdv => txdv,
							mii_txd  => txd);

						process (mii_txc)
						begin
							if rising_edge(mii_txc) then
								miidis_txdv <= txdv;
								miidis_txd  <= txd;
							end if;
						end process;

					end block;

					offer_b : block
					begin
				mii_udp_e : entity hdl4fpga.mii_romcmp
				generic map (
					mem_data => reverse(x"11",8))
				port map (
					mii_rxc  => mii_rxc,
					mii_rxd  => mii_rxd,
					mii_treq => ipproto_vld,
					mii_ena  => udpproto_ena,
					mii_pktv => udpproto_vld);

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


					miidhcp_txd  <= word2byte(miidis_txd  & miirequ_txd,   not miidis_txdv);
					miidhcp_txdv <= word2byte(miidis_txdv & miirequ_txdv,  not miidis_txdv)(0);
				end block;
			end block;

			mii_prev  <= pre_vld;
			mii_bcstv <= ethdbcst_vld;
			mii_macv  <= ethdmac_vld;
			mii_ipv   <= ipproto_vld;
			mii_udpv  <= udp_vld;
			mii_myipv <= myipcfg_vld;

		end block;

	end block;

end;
