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

begin

	eth_b : block
		constant etherdmac : field := (0, 6);
		constant ethersmac : field := (etherdmac.offset+etherdmac.size, 6);
		constant ethertype : field := (ethersmac.offset+ethersmac.size, 2);

		signal mii_ptr      : unsigned(0 to to_miisize(8));

		signal pre_vld      : std_logic;
		signal ethdmac_vld  : std_logic;
		signal ethsmac_vld  : std_logic;
		signal ethdbcst_vld : std_logic;
		signal bucst_vld    : std_logic;
		signal arp_vld      : std_logic;

		signal dhcp_vld     : std_logic;
		signal myipcfg_vld  : std_logic;
		signal myipcfg_txd  : std_logic_vector(mii_txd'range);

		signal ipsaddr_rdy  : std_logic;
		signal ipsaddr_ena  : std_logic;

		signal ethsmac_ena  : std_logic;
		signal ethty_ena    : std_logic;
		signal sha_ena : std_logic;

		signal arppa_req    : std_logic;

		signal ipsaddr_txdv : std_logic;
		signal miidhcp_txd  : std_logic_vector(mii_txd'range);
		signal miidhcp_txdv : std_logic;
		signal miiarp_txd   : std_logic_vector(mii_txd'range);
		signal miiarp_txdv  : std_logic;
		signal ethdmac_txd  : std_logic_vector(mii_txd'range);
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
				mii_rdy  => pre_vld);

			process (mii_rxc)
			begin
				if rising_edge(mii_rxc) then
					if pre_vld='0' then
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

			bucst_vld   <= ethdmac_vld or ethdbcst_vld;
			ethsmac_ena <= lookup(to_miisize((0 => ethersmac), mii_txd'length), std_logic_vector(mii_ptr));
			ethsmac_vld <= (ethdmac_vld and ethsmac_ena) or (arp_vld and sha_ena);
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
			signal arp_req  : std_logic;
			signal arp_rply : std_logic;

			signal spa_rdy  : std_logic;
			signal spa_req  : std_logic;
			signal spa_rxdv : std_logic;
			signal spa_rxd  : std_logic_vector(mii_txd'range);

		begin

			request_b : block
				constant arp_sha   : field := (ethertype.offset+ethertype.size+ 8, 6);
				constant arp_tpa   : field := (ethertype.offset+ethertype.size+24, 4);

				signal tpa_ena   : std_logic;
				signal mytpa_txd : std_logic_vector(mii_txd'range);
				signal mytpa_rdy : std_logic;

			begin
				sha_ena <= lookup(to_miisize((0 => arp_sha), mii_txd'length), std_logic_vector(mii_ptr));
				tpa_ena <= lookup(to_miisize((0 => arp_tpa), mii_txd'length), std_logic_vector(mii_ptr)) or spa_req;

				mii_arp_e : entity hdl4fpga.mii_romcmp
				generic map (
					mem_data => reverse(arpproto,8))
				port map (
					mii_rxc  => mii_rxc,
					mii_rxd  => mii_rxd,
					mii_treq => bucst_vld,
					mii_ena  => ethty_ena,
					mii_pktv => arp_vld);

				miirx_tpa_e : entity hdl4fpga.mii_ram
				generic map (
					size => to_miisize(4))
				port map(
					mii_rxc  => mii_rxc,
					mii_rxd  => mii_rxd,
					mii_rxdv => myipcfg_vld,
					mii_treq => arp_vld,
					mii_trdy => mytpa_rdy,
					mii_txc  => mii_rxc,
					mii_tena => tpa_ena,
					mii_txd  => mytpa_txd);

				mii_tpacmp : entity hdl4fpga.mii_cmp
				port map (
					mii_req  => arp_vld,
					mii_rxc  => mii_rxc,
					mii_ena  => tpa_ena,
					mii_rdy  => mytpa_rdy,
					mii_rxd1 => mii_rxd,
					mii_rxd2 => mytpa_txd,
					mii_equ  => arp_req);

				ipsaddr_ena <= tpa_ena;
			end block;

			reply_b : block
				signal arp_rdy       : std_logic;

				signal etherhdr_rdy  : std_logic;
				signal etherhdr_req  : std_logic;
				signal etherhdr_rxdv : std_logic;
				signal etherhdr_rxd  : std_logic_vector(mii_txd'range);

				signal tha_rdy       : std_logic;
				signal tha_req       : std_logic;
				signal tha_rxdv      : std_logic;
				signal tha_rxd       : std_logic_vector(mii_txd'range);

				signal tpa_rdy       : std_logic;
				signal tpa_req       : std_logic;
				signal tpa_rxdv      : std_logic;
				signal tpa_rxd       : std_logic_vector(mii_txd'range);

				signal trailer_rdy   : std_logic;
				signal trailer_req   : std_logic;
				signal trailer_rxdv  : std_logic;
				signal trailer_rxd   : std_logic_vector(mii_txd'range);

				signal miicat_trdy   : std_logic_vector(0 to 5-1);
				signal miicat_treq   : std_logic_vector(0 to 5-1);
				signal miicat_rxdv   : std_logic_vector(0 to 5-1);
				signal miicat_rxd    : std_logic_vector(0 to 5*mii_txd'length-1);

				signal spacpy_rdy    : std_logic;
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

				(0 => etherhdr_req, 1 => spa_req, 2 => tha_req, 3 => tpa_req, 4 => trailer_req) <= miicat_treq;
				miicat_trdy <= (0 => etherhdr_rdy,  1 => spa_rdy,  2 => tha_rdy,  3 => tpa_rdy,  4 => trailer_rdy);
				miicat_rxdv <= (0 => etherhdr_rxdv, 1 => spa_rxdv, 2 => tha_rxdv, 3 => tpa_rxdv, 4 => trailer_rxdv);
				miicat_rxd  <=       etherhdr_rxd &      spa_rxd &      tha_rxd &      tpa_rxd   &     trailer_rxd;

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
				   		x"ff_ff_ff_ff_ff_ff" & mac &
						arpproto & x"0001_0800_0604_0002"  &
						mac, 8))
				port map (
					mii_txc  => mii_txc,
					mii_treq => etherhdr_req,
					mii_trdy => etherhdr_rdy,
					mii_txdv => etherhdr_rxdv,
					mii_txd  => etherhdr_rxd);

				mii_tha_e : entity hdl4fpga.mii_rom
				generic map (
					mem_data => reverse( x"ff_ff_ff_ff_ff_ff", 8))
				port map (
					mii_txc  => mii_txc,
					mii_treq => tha_req,
					mii_trdy => tha_rdy,
					mii_txdv => tha_rxdv,
					mii_txd  => tha_rxd);

				spa_rxdv <= ipsaddr_txdv;
				spa_rxd  <= myipcfg_txd;
				process (mii_txc)
				begin
					if rising_edge(mii_txc) then
						if arp_rply='0' then
							spacpy_rdy <= '0';
						elsif ipsaddr_rdy='1' then
							spacpy_rdy <= '1';
						end if;
					end if;
				end process;
				spa_rdy   <= arp_rply and (ipsaddr_rdy or spacpy_rdy);
				arppa_req <= spa_req  when spacpy_rdy='0' else tpa_req;

				tpa_rdy  <= tpa_req and ipsaddr_rdy;
				tpa_rxdv <= ipsaddr_txdv;
				tpa_rxd  <= myipcfg_txd;

				mii_trailer_e : entity hdl4fpga.mii_rom
				generic map (
					mem_data => reverse(
						x"00_00_00_00_00_00_00_00_00" &
						x"00_00_00_00_00_00_00_00_00", 8))
				port map (
					mii_txc  => mii_txc,
					mii_treq => trailer_req,
					mii_trdy => trailer_rdy,
					mii_txdv => trailer_rxdv,
					mii_txd  => trailer_rxd);
			end block;

		end block;

		ip_b: block

			constant ip_proto  : field := (ethertype.offset+ethertype.size+9,  1);
			constant ip_saddr  : field := (ethertype.offset+ethertype.size+12, 4);
			constant ip_daddr  : field := (ethertype.offset+ethertype.size+16, 4);
			constant udp_sport : field := (ethertype.offset+ethertype.size+20, 2);
			constant udp_dport : field := (ethertype.offset+ethertype.size+22, 2);
			constant dhcp_cia  : field := (ethertype.offset+ethertype.size+44, 4);


			signal ipproto_vld : std_logic;
			signal ipsaddr_req : std_logic;
			signal dhcp_ena    : std_logic;
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

			ipsaddr_req <= arppa_req;
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
				mii_tena => ipsaddr_ena,
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
