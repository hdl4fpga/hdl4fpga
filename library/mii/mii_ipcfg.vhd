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
		btn       : in  std_logic:= '0';
		mii_rxc   : in  std_logic;
		mii_rxd   : in  std_logic_vector;
		mii_rxdv  : in  std_logic;

		mii_req   : in  std_logic;
		mii_txc   : in  std_logic;
		mii_txd   : out std_logic_vector;
		mii_txdv  : out std_logic);
	end;

architecture struct of mii_ipcfg is

	constant ipproto  : std_logic_vector := x"0800";
	constant arpproto : std_logic_vector := x"0806";

	type field is record
		offset : natural;
		size   : natural;
	end record;

	type field_vector is array (natural range <>) of field;

	impure function to_miisize (
		constant arg : natural)
		return natural is
	begin
		return arg*8/mii_txd'length;
	end;

	function to_miisize (
		constant table    : field_vector;
		constant mii_size : natural)
		return   field_vector is
		variable retval : field_vector(table'range);
	begin
		for i in table'range loop
			retval(i).offset := table(i).offset*8/mii_size;
			retval(i).size   := table(i).size*8/mii_size;
		end loop;
		return retval;
	end;

	function lookup (
		constant table : field_vector;
		constant data  : std_logic_vector) 
		return std_logic is
	begin
		for i in table'range loop
			if table(i).offset <= to_integer(unsigned(data)) then
				if to_integer(unsigned(data)) < table(i).offset+table(i).size then
					return '1';
				end if;
			end if;
		end loop;
		return '0';
	end;

	signal ethdmac_vld  : std_logic;
	signal ethdbcst_vld : std_logic;
	signal ethsmac_vld  : std_logic;
	signal ipproto_vld  : std_logic;
	signal arp_vld      : std_logic;
	signal dhcp_vld     : std_logic;
	signal myipcfg_vld  : std_logic;

	signal myipcfg_txd  : std_logic_vector(mii_txd'range);

	signal arp_req      : std_logic;

	signal arppaddr_ena : std_logic;
begin

	eth_b : block
		constant etherdmac : field := (0, 6);
		constant ethersmac : field := (etherdmac.offset+etherdmac.size, 6);
		constant ethertype : field := (ethersmac.offset+ethersmac.size, 2);

		signal pre_rdy         : std_logic;
		signal mac_rdy         : std_logic;
		signal ipsaddr_rdy     : std_logic;
		signal mii_ptr         : unsigned(0 to to_miisize(8));
		signal bucst_vld       : std_logic;

		signal ethsmac_ena     : std_logic;
		signal ethty_ena       : std_logic;
		signal arphaddr_ena    : std_logic;

		signal arpipsaddr_rply : std_logic;

		signal ipsaddr_txdv    : std_logic;
		signal miidhcp_txd     : std_logic_vector(mii_txd'range);
		signal miidhcp_txdv    : std_logic;
		signal miiarp_txd      : std_logic_vector(mii_txd'range);
		signal miiarp_txdv     : std_logic;
		signal ethdmac_txd     : std_logic_vector(mii_txd'range);
	begin

		tx_b : block
			signal txdv : std_logic_vector(0 to 2-1);
			signal txd  : std_logic_vector(0 to txdv'length*mii_txd'length-1);
		begin
			txdv <= miiarp_txdv & miidhcp_txdv;
			txd  <= miiarp_txd  & miidhcp_txd;

			mii_dll_e : entity hdl4fpga.miitx_dll
			port map (
				mii_txc  => mii_txc,
				mii_rxdv => txdv,
				mii_rxd  => txd,
				mii_txdv => mii_txdv,
				mii_txd  => mii_txd);

		end block;

		rx_b : block
		begin
			mii_pre_e : entity hdl4fpga.miirx_pre 
			port map (
				mii_rxc  => mii_rxc,
				mii_rxd  => mii_rxd,
				mii_rxdv => mii_rxdv,
				mii_rdy  => pre_rdy);

			process (mii_rxc)
			begin
				if rising_edge(mii_rxc) then
					if pre_rdy='0' then
						mii_ptr <= (others => '0');
					else
						mii_ptr <= mii_ptr + 1;
					end if;
				end if;
			end process;

			mii_mac_e : entity hdl4fpga.mii_romcmp
			generic map (
				mem_data => reverse(mac,8))
			port map (
				mii_rxc  => mii_rxc,
				mii_rxd  => mii_rxd,
				mii_treq => pre_rdy,
				mii_pktv => ethdmac_vld);

			mii_bcst_e : entity hdl4fpga.mii_romcmp
			generic map (
				mem_data => reverse(x"ff_ff_ff_ff_ff_ff", 8))
			port map (
				mii_rxc  => mii_rxc,
				mii_rxd  => mii_rxd,
				mii_treq => pre_rdy,
				mii_pktv => ethdbcst_vld);

			bucst_vld   <= ethdmac_vld or ethdbcst_vld;
			ethsmac_ena <= lookup(to_miisize((0 => ethersmac), mii_txd'length), std_logic_vector(mii_ptr));
			ethsmac_vld    <= (ethdmac_vld and ethsmac_ena) or (arp_vld and arphaddr_ena);
			miitx_ethsmac_e : entity hdl4fpga.mii_ram
			generic map (
				size => to_miisize(6))
			port map(
				mii_rxc  => mii_rxc,
				mii_rxd  => mii_rxd,
				mii_rxdv => ethsmac_vld,
				mii_txc  => mii_txc,
				mii_txd  => ethdmac_txd,
				mii_treq => std_logic'('0'));

			ethty_ena <= lookup(to_miisize((0 => ethertype), mii_txd'length), std_logic_vector(mii_ptr));
		end block;

		arp_b : block
			signal arp_rply : std_logic;
				signal arpsaddr_rdy  : std_logic;
				signal arpsaddr_req  : std_logic;
				signal arpsaddr_rxdv : std_logic;
				signal arpsaddr_rxd  : std_logic_vector(mii_txd'range);

		begin

			rx_b : block
				constant arp_haddr   : field := (ethertype.offset+ethertype.size+ 8, 6);
				constant arp_paddr   : field := (ethertype.offset+ethertype.size+24, 4);
				signal   myipcmp_txd : std_logic_vector(mii_txd'range);
				signal   ipsaddr_rdy : std_logic;

				signal   arpproto_req : std_logic;
			begin
				arphaddr_ena <= lookup(to_miisize((0 => arp_haddr), mii_txd'length), std_logic_vector(mii_ptr));
				arppaddr_ena <= lookup(to_miisize((0 => arp_paddr), mii_txd'length), std_logic_vector(mii_ptr)) or arpsaddr_req;

				arpproto_req <= bucst_vld;
				mii_arp_e : entity hdl4fpga.mii_romcmp
				generic map (
					mem_data => reverse(arpproto,8))
				port map (
					mii_rxc  => mii_rxc,
					mii_rxd  => mii_rxd,
					mii_treq => arpproto_req,
					mii_ena  => ethty_ena,
					mii_pktv => arp_vld);

				miirx_ipsaddr_e : entity hdl4fpga.mii_ram
				generic map (
					size => to_miisize(4))
				port map(
					mii_rxc  => mii_rxc,
					mii_rxd  => mii_rxd,
					mii_rxdv => myipcfg_vld,
					mii_treq => arp_vld,
					mii_trdy => ipsaddr_rdy,
					mii_txc  => mii_rxc,
					mii_tena => arppaddr_ena,
					mii_txd  => myipcmp_txd);

				mii_saddrcmp : entity hdl4fpga.mii_cmp
				port map (
					mii_req  => arp_vld,
					mii_rxc  => mii_rxc,
					mii_ena  => arppaddr_ena,
					mii_rdy  => ipsaddr_rdy,
					mii_rxd1 => mii_rxd,
					mii_rxd2 => myipcmp_txd,
					mii_equ  => arp_req);

			end block;

			tx_b : block
				signal arp_rdy       : std_logic;

				signal etherhdr_rdy  : std_logic;
				signal etherhdr_req  : std_logic;
				signal etherhdr_rxdv : std_logic;
				signal etherhdr_rxd  : std_logic_vector(mii_txd'range);

				signal tmac_rdy      : std_logic;
				signal tmac_req      : std_logic;
				signal tmac_rxdv     : std_logic;
				signal tmac_rxd      : std_logic_vector(mii_txd'range);

				signal arptaddr_rdy  : std_logic;
				signal arptaddr_req  : std_logic;
				signal arptaddr_rxdv : std_logic;
				signal arptaddr_rxd  : std_logic_vector(mii_txd'range);

				signal arptrailer_rdy  : std_logic;
				signal arptrailer_req  : std_logic;
				signal arptrailer_rxdv : std_logic;
				signal arptrailer_rxd  : std_logic_vector(mii_txd'range);

				signal miicat_trdy   : std_logic_vector(0 to 5-1);
				signal miicat_treq   : std_logic_vector(0 to 5-1);
				signal miicat_rxdv   : std_logic_vector(0 to 5-1);
				signal miicat_rxd    : std_logic_vector(0 to 5*mii_txd'length-1);
			begin
				
				process (mii_txc)
					variable rply : std_logic;
				begin
					if rising_edge(mii_txc) then
						if arp_rdy='1' then
							arp_rply <= '0';
							rply     := '0';
						elsif mii_rxdv='1' then
							arp_rply <= '0';
							rply     := arp_req;
						elsif rply='1' then
							arp_rply <= '1';
							rply     := '0';
						end if;
--						arp_rply <= btn;
					end if;
				end process;

				miicat_trdy <= (0 => etherhdr_rdy,  1 => arpsaddr_rdy,  2 => tmac_rdy,  3 => arptaddr_rdy,  4 => arptrailer_rdy);
				(0 => etherhdr_req, 1 => arpsaddr_req, 2 => tmac_req, 3 => arptaddr_req, 4 => arptrailer_req) <= miicat_treq;
				miicat_rxdv <= (0 => etherhdr_rxdv, 1 => arpsaddr_rxdv, 2 => tmac_rxdv, 3 => arptaddr_rxdv, 4 => arptrailer_rxdv);
				miicat_rxd  <=       etherhdr_rxd &      arpsaddr_rxd &      tmac_rxd &      arptaddr_rxd   &     arptrailer_rxd;

				mii_arpcat_e : entity hdl4fpga.mii_cat
				port map (
					mii_req  => arp_rply,
					mii_rdy  => arp_rdy,
					mii_trdy => miicat_trdy,
					mii_rxdv => miicat_rxdv,
					mii_rxd  => miicat_rxd,
					mii_treq => miicat_treq,
					mii_txdv => miiarp_txdv,
					mii_txd  => miiarp_txd);

				mii_ethhdr_e : entity hdl4fpga.mii_rom
				generic map (
					mem_data => reverse(
				   		x"ff_ff_ff_ff_ff_ff" & mac & arpproto &
						x"00010800"          &
						x"06040002"          & mac , 8))
				port map (
					mii_txc  => mii_txc,
					mii_treq => etherhdr_req,
					mii_trdy => etherhdr_rdy,
					mii_txdv => etherhdr_rxdv,
					mii_txd  => etherhdr_rxd);

				mii_tmac_e : entity hdl4fpga.mii_rom
				generic map (
					mem_data => reverse( x"ff_ff_ff_ff_ff_ff", 8))
				port map (
					mii_txc  => mii_txc,
					mii_treq => tmac_req,
					mii_trdy => tmac_rdy,
					mii_txdv => tmac_rxdv,
					mii_txd  => tmac_rxd);

				arpsaddr_rxdv <= ipsaddr_txdv;
				arpsaddr_rxd  <= myipcfg_txd;
				process (
					mii_txc, 
					arp_rply, 
					ipsaddr_rdy,
					arpsaddr_req,
					arptaddr_req)
					variable sdr_rdy : std_logic;
				begin
					if rising_edge(mii_txc) then
						if arp_rply='0' then
							sdr_rdy := '0';
						elsif ipsaddr_rdy='1' then
							sdr_rdy := '1';
						end if;
					end if;
					arpipsaddr_rply <= (arpsaddr_req and not sdr_rdy) or (arptaddr_req and sdr_rdy);
					arpsaddr_rdy   <= arp_rply and (ipsaddr_rdy or sdr_rdy);
				end process;

				arptaddr_rdy  <= ipsaddr_rdy and arptaddr_req;
				arptaddr_rxdv <= ipsaddr_txdv;
				arptaddr_rxd  <= myipcfg_txd;

				mii_trailer_e : entity hdl4fpga.mii_rom
				generic map (
					mem_data => reverse(
						x"00_00_00_00_00_00_00_00_00" &
						x"00_00_00_00_00_00_00_00_00", 8))
				port map (
					mii_txc  => mii_txc,
					mii_treq => arptrailer_req,
					mii_trdy => arptrailer_rdy,
					mii_txdv => arptrailer_rxdv,
					mii_txd  => arptrailer_rxd);

			end block;

		end block;

		ip_b: block

			constant ip_proto  : field := (ethertype.offset+ethertype.size+9,  1);
			constant ip_saddr  : field := (ethertype.offset+ethertype.size+12, 4);
			constant ip_daddr  : field := (ethertype.offset+ethertype.size+16, 4);
			constant udp_sport : field := (ethertype.offset+ethertype.size+20, 2);
			constant udp_dport : field := (ethertype.offset+ethertype.size+22, 2);
			constant dhcp_cia  : field := (ethertype.offset+ethertype.size+44, 4);


			signal ipsaddr_req    : std_logic;
			signal dhcp_ena     : std_logic;
			signal cia_ena     : std_logic;
		begin

			dhcp_ena  <= lookup(to_miisize((0 => ip_proto, 1 => udp_sport, 2 => udp_dport), mii_txd'length), std_logic_vector(mii_ptr));
			cia_ena   <= lookup(to_miisize((0 => dhcp_cia), mii_txd'length), std_logic_vector(mii_ptr));

			mii_ip_e : entity hdl4fpga.mii_romcmp
			generic map (
				mem_data => reverse(ipproto,8))
			port map (
				mii_rxc  => mii_rxc,
				mii_rxd  => mii_rxd,
				mii_treq => ethdmac_vld,
				mii_ena  => ethty_ena,
				mii_pktv => ipproto_vld);

			mii_dhcp_e : entity hdl4fpga.mii_romcmp
			generic map (
				mem_data => reverse(x"1100430044",8))
			port map (
				mii_rxc  => mii_rxc,
				mii_rxd  => mii_rxd,
				mii_treq => ipproto_vld,
				mii_ena  => dhcp_ena,
				mii_pktv => dhcp_vld);

			ipsaddr_req <= arpipsaddr_rply;
			myipcfg_vld <= dhcp_vld and cia_ena;
			miitx_ipsaddr_e : entity hdl4fpga.mii_ram
			generic map (
				size => to_miisize(4))
			port map(
				mii_rxc  => mii_rxc,
				mii_rxd  => mii_rxd,
				mii_rxdv => myipcfg_vld,
				mii_txc  => mii_txc,
				mii_txd  => myipcfg_txd,
				mii_txdv => ipsaddr_txdv,
				mii_tena => arppaddr_ena,
				mii_treq => ipsaddr_req,
				mii_trdy => ipsaddr_rdy);

		end block;

		du : entity hdl4fpga.miitx_dhcp
		port map (
			mii_txc  => mii_txc,
			mii_treq => mii_req,
			mii_txdv => miidhcp_txdv,
			mii_txd  => miidhcp_txd);

	end block;
		

end;
