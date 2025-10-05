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
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;

entity dhcpcd is
	generic (
		hwaddr        : std_logic_vector(0 to 48-1));
	port (
		dhcpcd_req    : in  std_logic := '0';
		dhcpcd_rdy    : buffer std_logic := '0';

		arp_req       : buffer std_logic := '0';
		arp_rdy       : in  std_logic := '0';

		upspa_frm     : out std_logic;
		upspa_irdy    : out std_logic;
		upspa_trdy    : in  std_logic := '1';
		upspa_data    : out std_logic_vector;

		miirx_clk     : in  std_logic;
		dhcpcdrx_frm  : in  std_logic;
		dhcpcdrx_irdy : in  std_logic;
		dhcpcdrx_trdy : out std_logic := '1';
		dhcpcdrx_data : in  std_logic_vector;

		miitx_clk     : in  std_logic;
		thatx_frm     : in  std_logic;
		thatx_irdy    : in  std_logic;
		thatx_trdy    : buffer std_logic := '1';

		lentx_frm     : in  std_logic;
		lentx_irdy    : in  std_logic;
		lentx_trdy    : buffer std_logic := '1';

		tpatx_frm     : in  std_logic;
		tpatx_irdy    : in  std_logic;
		tpatx_trdy    : buffer std_logic := '1';

		dhcpcdtx_frm  : buffer std_logic;
		dhcpcdtx_irdy : buffer std_logic;
		dhcpcdtx_trdy : in  std_logic;
		dhcpcdtx_data : out std_logic_vector;
		tp            : out std_logic_vector(1 to 32));
end;

architecture def of dhcpcd is
	signal yiaddr_act : std_logic;
begin

	offer_b : block
		signal discard0 : std_logic;
		signal discard2 : std_logic;
	begin
		decode_i : entity hdl4fpga.frame_decode
		generic map (
			frame => compact('{'                        &
				"discard0:" & natural'image(
					hdo(frames)**".format.dhcp.op"      +
					hdo(frames)**".format.dhcp.htype"   +
					hdo(frames)**".format.dhcp.hlen "   +
					hdo(frames)**".format.dhcp.hops "   +
					hdo(frames)**".format.dhcp.xid"     +
					hdo(frames)**".format.dhcp.secs"    +
					hdo(frames)**".format.dhcp.flags"   +
					hdo(frames)**".format.dhcp.ciaddr")  & ',' &
				" yiaddr:" & string'(hdo(frames)**".format.dhcp.yiaddr") & '}'),
			size  => dhcpcdtx_data'length)
		port map (
			clk    => miirx_clk,
			frm    => dhcpcdrx_frm,
			irdy   => dhcpcdrx_irdy,
			act(0) => discard0,
			act(1) => yiaddr_act,
			act(2) => discard2);
		
		process (miirx_clk)
			variable refresh_req : std_logic := '0';
			variable refresh_rdy : std_logic := '0';
		begin
			if rising_edge(miirx_clk) then
				if dhcpcdrx_frm='1' then
					refresh_req := not refresh_rdy;
				elsif (refresh_rdy xor refresh_req)='1' then
					refresh_rdy := refresh_req;
					arp_req <= not arp_rdy;
				end if;
			end if;
		end process;

	end block;

	tp(1) <= dhcpcdrx_frm;
	tp(2 to 2+dhcpcdrx_data'length-1) <= dhcpcdrx_data;
	discover_b : block
		constant thaddress : std_logic_vector  := x"ff_ff_ff_ff_ff_ff";
		constant tpaddress : std_logic_vector  := x"ff_ff_ff_ff";
		constant discover_length : natural := 250;
		constant udp_length  : std_logic_vector := std_logic_vector(to_unsigned(discover_length+8,16));
		constant ipv4_length : std_logic_vector := std_logic_vector(to_unsigned(discover_length+8+20,16));
		constant udp_chksum  : std_logic_vector := not chksum1 (
				x"00" & std_logic_vector'(hdo(frames)**".data.ipv4.proto.udp")   &
				udp_length                                                       &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.sp")         &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.dp")         &
				udp_length                                                       &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.op")         &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.htype")      &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.hlen")       &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.hops")       &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.xid")        &
				hwaddr                                                           &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.cookie")     &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.vendordata") &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.iprequest")  &
				std_logic_vector'(hdo(frames)**".data.dhcp.endmark"), 16);
		signal decode_frm  : std_logic := '0';
		signal decode_irdy : std_logic;
		signal decode_last : std_logic;
		signal rom0_act    : std_logic;
		signal rom2_act    : std_logic;
		signal rom4_act    : std_logic;
		signal rom_irdy    : std_logic;
		signal rom_data    : std_logic_vector(dhcpcdtx_data'range);
		signal discard1    : std_logic;
		signal discard3    : std_logic;
		signal discard5    : std_logic;
	begin

		process (miitx_clk)
		begin
			if rising_edge(miitx_clk) then
				if (dhcpcd_req xor dhcpcd_rdy)='1' then
					if decode_last='0' then
						decode_frm <= '1';
					elsif dhcpcdtx_frm='1' then
						decode_frm <= '1';
					elsif (dhcpcdtx_irdy and not dhcpcdtx_trdy)='1' then
						decode_frm <= '1';
					else
						decode_frm <= '0';
						dhcpcd_rdy <= dhcpcd_req;
					end if;
				else
					decode_frm <= '0';
				end if;
			end if;
		end process;

		dhcpcdtx_frm  <= decode_frm and not decode_last;
		dhcpcdtx_irdy <= decode_frm;
		decode_irdy <=
			   '0'        when decode_frm='0' else
			   thatx_irdy when  thatx_frm='1' else
			   lentx_irdy when  lentx_frm='1' else
			   tpatx_irdy when  tpatx_frm='1' else
			   dhcpcdtx_trdy;

		decode_i : entity hdl4fpga.frame_decode
		generic map (
			frame => compact('{'                      &
				"    rom0:" & natural'image(
					hdo(frames)**".format.mac.hwda"   +
					hdo(frames)**".format.udp.length" +
					hdo(frames)**".format.ipv4.da"    +
					hdo(frames)**".format.udp.sp"     +
					hdo(frames)**".format.udp.dp"     +
					hdo(frames)**".format.udp.length" +
					hdo(frames)**".format.udp.chksum" +
					hdo(frames)**".format.dhcp.op"    +
					hdo(frames)**".format.dhcp.htype" +
					hdo(frames)**".format.dhcp.hlen " +
					hdo(frames)**".format.dhcp.hops " +
					hdo(frames)**".format.dhcp.xid")  & ',' &
				"discard0:" & natural'image(
					hdo(frames)**".format.dhcp.secs"    +
					hdo(frames)**".format.dhcp.flags"   +
					hdo(frames)**".format.dhcp.ciaddr"  +
					hdo(frames)**".format.dhcp.yiaddr"  +
					hdo(frames)**".format.dhcp.siaddr"  +
					hdo(frames)**".format.dhcp.giaddr") & ',' &
					"    rom1:" & string'(hdo(frames)**".format.dhcp.chaddr6") & ',' & 
				"discard1:" & natural'image(
					hdo(frames)**".format.dhcp.chaddr10" +
					hdo(frames)**".format.dhcp.shname"   +
					hdo(frames)**".format.dhcp.fbname")  & ',' & 
				"    rom2:" & natural'image(
					hdo(frames)**".format.dhcp.cookie"     +
					hdo(frames)**".format.dhcp.vendordata" +
					hdo(frames)**".format.dhcp.iprequest"  +
					hdo(frames)**".format.dhcp.endmark") & '}'),
			size  => dhcpcdtx_data'length)
		port map (
			clk    => miitx_clk,
			frm    => decode_frm,
			irdy   => decode_irdy,
			last   => decode_last,
			act(0) => rom0_act,
			act(1) => discard1,
			act(2) => rom2_act,
			act(3) => discard3,
			act(4) => rom4_act,
			act(5) => discard5);
		
		rom_irdy <= 
			'0'        when decode_frm='0' else
			thatx_irdy and thatx_trdy when thatx_frm='1' else
			lentx_irdy and lentx_trdy when lentx_frm='1' else
			tpatx_irdy and tpatx_trdy when tpatx_frm='1' else
			(rom0_act or rom2_act or rom4_act) and dhcpcdtx_trdy;

		rom_i : entity hdl4fpga.sio_rom
		generic map (
			bitdata => reverse(
				thaddress                                                        &
				ipv4_length                                                      &
				tpaddress                                                        &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.sp")         &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.dp")         &
				udp_length                                                       &
				udp_chksum                                                       &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.op")         &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.htype")      &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.hlen")       &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.hops")       &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.xid")        &
				hwaddr &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.cookie")     &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.vendordata") &
				std_logic_vector'(hdo(frames)**".data.dhcp.discover.iprequest")  &
				std_logic_vector'(hdo(frames)**".data.dhcp.endmark") ,8))
		port map (
			so_clk  => miitx_clk,
			so_frm  => decode_frm,
			so_irdy => rom_irdy,
			so_trdy => open,
			so_data => rom_data);

		dhcpcdtx_data <=
			rom_data when rom0_act='1' else
			rom_data when rom2_act='1' else
			rom_data when rom4_act='1' else
			(rom_data'range => '0');
		
		thatx_trdy <= thatx_irdy;

		lentx_trdy <= lentx_irdy;
		tpatx_trdy <= tpatx_irdy;

	end block;

	upspa_frm  <= dhcpcdtx_irdy or yiaddr_act;
	upspa_irdy <= dhcpcdtx_irdy or yiaddr_act;
	upspa_data <= 
		dhcpcdrx_data             when    yiaddr_act='1' else
		(upspa_data'range => '0') when dhcpcdtx_irdy='1' else
		(upspa_data'range => '-');

end;
