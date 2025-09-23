-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity dhcpcd is
	port (
		mii_clk       : in  std_logic;
		dhcpcdrx_frm  : in  std_logic;
		dhcpcdrx_irdy : in  std_logic;
		dhcpcdrx_data : in  std_logic_vector;

		arp_req       : buffer std_logic := '0';
		arp_rdy       : in  std_logic := '0';

		dhcpcd_req    : in  std_logic := '0';
		dhcpcd_rdy    : buffer std_logic := '0';

		ipv4sawr_frm  : out std_logic := '0';
		ipv4sawr_irdy : out std_logic := '0';
		ipv4sawr_end  : in  std_logic := '1';
		ipv4sawr_data : out std_logic_vector;

		hwda_frm      : out std_logic;
		hwda_irdy     : out std_logic;
		hwda_trdy     : in  std_logic;
		hwda_last     : in  std_logic;
		hwda_equ      : in  std_logic;
		hwdarx_vld    : in  std_logic;

		dhcpcdtx_frm  : buffer std_logic;
		dhcpcdtx_irdy : buffer std_logic;
		dhcpcdtx_trdy : in  std_logic;
		dhcpcdtx_data : out std_logic_vector;
		tp            : out std_logic_vector(1 to 32));
end;

architecture def of dhcpcd is

begin

	discover_b : block
		signal decode_frm  : std_logic;
		signal decode_irdy : std_logic;
		signal rom0_frm    : std_logic;
		signal rom2_frm    : std_logic;
		signal rom3_frm    : std_logic;
		signal rom_irdy    : std_logic;
		signal rom_data    : std_logic_vector(dhcpcdtx_data'range);
		signal discard1    : std_logic;
		signal discard3    : std_logic;
		signal discard5    : std_logic;
	begin
		decode_i : entity hdl4fpga.frame_decode
		generic map (
			frame => '{'                                                       &
				"    rom:" & natural'image(
					hdo(frames)**".format.dhcp.op   " +
					hdo(frames)**".format.dhcp.htype" +
					hdo(frames)**".format.dhcp.hlen " +
					hdo(frames)**".format.dhcp.hops " +
					hdo(frames)**".format.dhcp.xid") & ',' &
				"discard:" & natural'image(
					hdo(frames)**".data.dhcp.secs"    +
					hdo(frames)**".data.dhcp.flags"   +
					hdo(frames)**".data.dhcp.ciaddr"  +
					hdo(frames)**".data.dhcp.yiaddr"  +
					hdo(frames)**".data.dhcp.siaddr"  +
					hdo(frames)**".data.dhcp.giaddr") & ',' &
				"    rom:" & string'(hdo(frames)**".data.dhcp.chaddr6") & ',' & 
				"discard:" & natural'image(
					hdo(frames)**".format.dhcp.chaddr10" +
					hdo(frames)**".format.dhcp.shname"   +
					hdo(frames)**".format.dhcp.fbname")  & ',' & 
				"    rom:" & natural'image(
					hdo(frames)**".format.dhcp.cookie"     +
					hdo(frames)**".format.dhcp.vendordata" +
					hdo(frames)**".format.dhcp.iprequest"  +
					hdo(frames)**".format.dhcp.endmark") & '}',
			size  => ipv4tx_data'length)
		port map (
			clk    => miitx_clk,
			frm    => decode_frm,
			irdy   => decode_irdy,
			act(0) => rom0_frm,
			act(1) => discard1,
			act(2) => rom2_frm,
			act(3) => discard3,
			act(4) => rom4_frm,
			act(5) => discard5;
		
		rom_irdy <= (rom0_frm or rom2_frm or rom4_frm) and dhcpcdtx_trdy);
		rom_i : entity hdl4fpga.rom
		generic map (
			bitdata => reverse(
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.op   ")       &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.htype")       &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.hlen ")       &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.hops ")       &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.xid")         &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.cookie") &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.vendordata")  &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.iprequest")   &
				std_logic_vector'(hdo(frames)**".data.dhcp.endmark") ,8))
		port map
			clk  => miitx_clk,
			frm  => decode_frm,
			irdy => rom_irdy,
			trdy => open,
			data => rom_data);

	end block;

	dhcpoffer_e : entity hdl4fpga.dhcpc_offer
	port map (
		mii_clk          => mii_clk,
		dhcp_frm         => dhcpcdrx_frm,
		dhcp_irdy        => dhcpcdrx_irdy,
		dhcp_data        => dhcpcdrx_data,

		dhcpop_irdy      => dhcpop_irdy,
		dhcpchaddr6_frm  => dhcpchaddr6_frm,
		dhcpchaddr6_irdy => dhcpchaddr6_irdy,
		dhcpyia_frm      => dhcpyia_frm,
		dhcpyia_irdy     => dhcpyia_irdy);

	process (mii_clk)
		type states is (s_idle, s_offer, s_arp);
		variable state : states;
	begin
		if rising_edge(mii_clk) then
			case state is
			when s_idle =>
				if (dhcpyia_frm and hwdarx_vld)='1' then
					state := s_offer;
				else
				end if;
			when s_offer =>
				if (dhcpyia_frm and hwdarx_vld)='0' then
					if (to_bit(arp_req) xor to_bit(arp_rdy))='0' then
						arp_req <= not to_stdulogic(to_bit(arp_rdy));
						state := s_arp;
					end if;
				end if;
			when s_arp =>
				if (to_bit(arp_req) xor to_bit(arp_rdy))='0' then
					state := s_idle;
				end if;
			end case;
		end if;
	end process;

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if (dhcpcd_req xor dhcpcd_rdy)='1' then
				if dhcpcdtx_trdy='1' then
					dhcpcd_rdy <= dhcpcdtx_end xnor dhcpcd_req;
				end if;
			end if;
		end if;
	end process;

	dhcpcdtx_frm <= to_stdulogic(to_bit(dhcpcd_req)) xor dhcpcd_rdy;
	dhcpdscb_e : entity hdl4fpga.dhcpc_dscb
	port map (
		mii_clk       => mii_clk,
		dhcpdscb_frm  => dhcpcdtx_frm,
		dlltx_irdy    => dlltx_irdy,
		dlltx_end     => dlltx_end,
		dlltx_data    => dlltx_data,
		netdatx_irdy  => netdatx_irdy,
		netdatx_end   => netdatx_end,
		netlentx_irdy => netlentx_irdy,
		netlentx_data => netlentx_data,
		netlentx_end  => netlentx_end,
		nettx_end     => nettx_end,
		dhcpdscb_irdy => dhcpcdtx_irdy,
		dhcpdscb_trdy => dhcpcdtx_trdy,
		dhcpdscb_end  => dhcpcdtx_end,
		dhcpdscb_data => dhcpcdtx_data);

	ipv4sawr_frm  <= dhcpcdtx_frm or (dhcpyia_frm and hwdarx_vld);
	ipv4sawr_irdy <=
		'1'          when dhcpcdtx_frm='1' else
		dhcpyia_irdy when (dhcpyia_frm and hwdarx_vld)='1'  else
		'0';
	ipv4sawr_data <=
		(ipv4sawr_data'range => '0') when dhcpcdtx_frm='1' else
		dhcpcdrx_data                when  dhcpyia_frm='1' else
		(ipv4sawr_data'range => '-');

end;
