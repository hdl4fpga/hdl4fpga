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

entity ipv4 is
	generic (
		hwaddr        : std_logic_vector;
		ipv4addr      : std_logic_vector);
	port (
		dhcpcd_req    : in  std_logic := '0';
		dhcpcd_rdy    : buffer std_logic := '0';

		arp_req       : buffer std_logic := '0';
		arp_rdy       : in  std_logic := '0';

		upspa_frm     : buffer std_logic;
		upspa_irdy    : buffer std_logic;
		upspa_trdy    : in std_logic := '1';
		upspa_data    : buffer std_logic_vector;

		miirx_clk     : in  std_logic;

		sharx_frm     : in  std_logic;
		sharx_irdy    : in  std_logic;
		sharx_trdy    : out std_logic := '1';

		ipv4rx_frm    : in  std_logic;
		ipv4rx_irdy   : in  std_logic;
		ipv4rx_trdy   : out std_logic := '1';
		ipv4rx_data   : in  std_logic_vector;

		udppylrx_frm  : out std_logic;
		udppylrx_irdy : out std_logic;
		udppylrx_trdy : in  std_logic := '1';
		udppylrx_data : out std_logic_vector;

		miitx_clk     : in  std_logic;

		udppyltx_frm  : in  std_logic := '0';
		udppyltx_irdy : in  std_logic := '0';
		udppyltx_trdy : out std_logic := '1';
		udppyltx_data : in  std_logic_vector;

		ipv4tx_frm    : buffer std_logic;
		ipv4tx_irdy   : buffer std_logic;
		ipv4tx_trdy   : in  std_logic;
		ipv4tx_data   : buffer std_logic_vector;
		tp            : out std_logic_vector(1 to 32));
end;

architecture def of ipv4 is

	signal tha1rx_frm     : std_logic;
	signal tha1rx_irdy    : std_logic;
	signal tha1rx_trdy    : std_logic := '1';

	signal ipv4lenrx_frm  : std_logic;
	alias  ipv4lenrx_irdy is ipv4lenrx_frm;
	signal ipv4lenrx_trdy : std_logic := '1';

	signal sparx_frm      : std_logic;
	alias  sparx_irdy  is sparx_frm;
	signal sparx_trdy     : std_logic := '1';

	signal icmprx_frm     : std_logic;
	alias  icmprx_irdy    is icmprx_frm;
	signal icmprx_trdy    : std_logic;
	signal icmprx_data    : std_logic_vector(ipv4rx_data'range);

	signal udprx_frm      : std_logic;
	alias  udprx_irdy     is udprx_frm;
	signal udprx_trdy     : std_logic;
	signal udprx_data     : std_logic_vector(ipv4rx_data'range);

	signal ipv4pyltx_frms  : std_logic_vector(0 to 2-1);
	signal ipv4pyltx_irdys : std_logic_vector(0 to 2-1);
	signal ipv4pyltx_trdys : std_logic_vector(0 to 2-1) := (others => '1');
	signal ipv4pyltx_data  : std_logic_vector(ipv4tx_data'range);

	alias  icmptx_frm    is ipv4pyltx_frms(0);
	alias  icmptx_irdy   is ipv4pyltx_irdys(0);
	alias  icmptx_trdy   is ipv4pyltx_trdys(0);
	signal icmptx_data   : std_logic_vector(ipv4tx_data'range);

	alias  udptx_frm    is ipv4pyltx_frms(1);
	alias  udptx_irdy   is ipv4pyltx_irdys(1);
	alias  udptx_trdy   is ipv4pyltx_trdys(1);
	signal udptx_data   : std_logic_vector(ipv4tx_data'range);

begin
	rx_b : block
		signal length_frm : std_logic;
		signal proto_frm  : std_logic;
		alias  proto_irdy is proto_frm;
		signal spa_frm    : std_logic;
		signal ipv4da_frm : std_logic;
		alias  ipv4da_irdy is ipv4da_frm;
		signal pyl_frm    : std_logic;
		signal discard0   : std_logic;
		signal discard2   : std_logic;
		signal chksum     : std_logic;
	begin
		ipv4_i : entity hdl4fpga.frame_decode
		generic map (
			frame => compact('{'                                                        &
				"         discard:" & natural'image(
					hdo(frames)**".format.ipv4.verihl"  +
					hdo(frames)**".format.ipv4.tos")                              & ',' &
				"          length:" & string'(hdo(frames)**".format.ipv4.length") & ',' &
				"         discard:" & natural'image(
					hdo(frames)**".format.ipv4.ident"   +
					hdo(frames)**".format.ipv4.flgsfrg" +
					hdo(frames)**".format.ipv4.ttl")                              & ',' &
				"          proto:" & string'(hdo(frames)**".format.ipv4.proto")   & ',' &
				"         chksum:" & string'(hdo(frames)**".format.ipv4.chksum")  & ',' &
				"             sa:" & string'(hdo(frames)**".format.ipv4.sa")      & ',' &
				"             da:" & string'(hdo(frames)**".format.ipv4.da")      & '}'),
			size  => ipv4tx_data'length)
		port map (
			clk    => miirx_clk,
			frm    => ipv4rx_frm,
			irdy   => ipv4rx_irdy,
			act(0) => discard0,
			act(1) => length_frm,
			act(2) => discard2,
			act(3) => proto_frm,
			act(4) => chksum,
			act(5) => spa_frm,
			act(6) => ipv4da_frm,
			act(7) => pyl_frm);

		process (miirx_clk)
		begin
			if rising_edge(miirx_clk) then
				tha1rx_frm    <= sharx_frm;
				tha1rx_irdy   <= sharx_irdy;
				ipv4lenrx_frm <= length_frm;
				sparx_frm     <= spa_frm;
			end if;
		end process;

		pa_b : block
			constant dflt_data : std_logic_vector := (ipv4rx_data'range => '0');
			constant bcst_data : std_logic_vector := (ipv4rx_data'range => '1');
			signal bcst_equ  : std_logic;
			signal pa_data   : std_logic_vector(ipv4rx_data'range);
			signal pa_equ    : std_logic;
			signal dflt_equ  : std_logic;
			signal icmp_equ  : std_logic;
			signal udp_equ   : std_logic;
		begin

			bcstcmp_i : entity hdl4fpga.sio_cmp
			port map (
				clk     => miirx_clk,
				mr_frm  => ipv4da_frm,
				mr_irdy => ipv4da_irdy,
				mr_trdy => open,
				mr_data => bcst_data,
				sl_data => ipv4rx_data,
				equ     => bcst_equ);

			ipaddr_i : entity hdl4fpga.sio_ram
			generic map (
				bitdata => reverse(ipv4addr,8))
			port map (
				si_clk  => miirx_clk,
				si_frm  => upspa_frm,
				si_irdy => upspa_irdy,
				si_trdy => open,
				si_data => upspa_data,
				so_clk  => miirx_clk,
				so_frm  => ipv4da_frm,
				so_irdy => ipv4da_irdy,
				so_trdy => open,
				so_data => pa_data);

			dfltcmp_i : entity hdl4fpga.sio_cmp
			port map (
				clk     => miirx_clk,
				mr_frm  => ipv4da_frm,
				mr_irdy => ipv4da_irdy,
				mr_trdy => open,
				mr_data => pa_data,
				sl_data => dflt_data,
				equ     => dflt_equ);

			pacmp_i : entity hdl4fpga.sio_cmp
			port map (
				clk     => miirx_clk,
				mr_frm  => ipv4da_frm,
				mr_irdy => ipv4da_irdy,
				mr_trdy => open,
				mr_data => pa_data,
				sl_data => ipv4rx_data,
				equ     => pa_equ);

			icmpproto_i : entity hdl4fpga.mii_cmp
			generic map (
				bitdata => reverse(hdo(frames)**".data.ipv4.proto.icmp",8))
			port map (
				mii_clk => miirx_clk,
				frm     => proto_frm,
				irdy    => proto_irdy,
				trdy    => open,
				data    => ipv4rx_data,
				equ     => icmp_equ);

			udproto_i : entity hdl4fpga.mii_cmp
			generic map (
				bitdata => reverse(hdo(frames)**".data.ipv4.proto.udp",8))
			port map (
				mii_clk => miirx_clk,
				frm     => proto_frm,
				irdy    => proto_irdy,
				trdy    => open,
				data    => ipv4rx_data,
				equ     => udp_equ);

			icmp_p : process (miirx_clk)
				variable icmp_vld : std_logic := '0';
				variable pa_vld   : std_logic := '0';
			begin
				if rising_edge(miirx_clk) then
					if (ipv4rx_frm or ipv4rx_irdy)='0' then
						 icmp_vld := '0';
						 pa_vld   := '0';
					else
						if (not icmp_vld and icmp_equ)='1' then
							icmp_vld := '1';
						end if;
						if (not pa_vld and (pa_equ or dflt_equ))='1' then
							pa_vld := '1';
						end if;
					end if;
					icmprx_frm  <= ipv4rx_frm and pa_vld and icmp_vld;
					icmprx_data <= ipv4rx_data;
				end if;
			end process;

			udp_p : process (icmprx_frm, miirx_clk)
				variable udp_vld  : std_logic := '0';
				variable pa_vld   : std_logic := '0';
			begin
				if rising_edge(miirx_clk) then
					if (ipv4rx_frm or ipv4rx_irdy)='0' then
						 udp_vld := '0';
						 pa_vld  := '0';
					else
						if (not udp_vld and udp_equ)='1' then
							udp_vld := '1';
						end if;
						if (not pa_vld and (pa_equ or dflt_equ or bcst_equ))='1' then
							pa_vld  := '1';
						end if;
					end if;
					udprx_frm  <= ipv4rx_frm and pa_vld and udp_vld;
					udprx_data <= ipv4rx_data;
				end if;
			end process;

		end block;
	end block;

	tx_b : block
		signal ipv4pyltx_frm  : std_logic;
		signal ipv4pyltx_irdy : std_logic;
		signal ipv4pyltx_trdy : std_logic;

		signal ipv4lentx_act  : std_logic;
		signal ipv4tpatx_act  : std_logic;

		signal buffer_trdy    : std_logic;
		signal gntd           : std_logic_vector(0 to 2-1);

		alias icmp_gntd is gntd(0);
		alias udp_gntd  is gntd(1);


		signal decode_frm  : std_logic;
		signal decode_irdy : std_logic;
		signal decode_fin  : std_logic;
		signal decode_data : std_logic_vector(ipv4rx_data'range);

		signal tha_act       : std_logic;
		signal verihltos_frm : std_logic;
		signal identflgsfrgttl_frm : std_logic;

		signal length_act  : std_logic;
		signal length_data : std_logic_vector(ipv4rx_data'range);

		signal protoid_act  : std_logic;
		signal protoid_data : std_logic_vector(ipv4rx_data'range);

		signal chksum_frm   : std_logic;
		signal chksum_data  : std_logic_vector(ipv4rx_data'range);

		signal sa_frm       : std_logic;
		alias  sa_irdy is sa_frm; 
		signal sa_data      : std_logic_vector(ipv4rx_data'range);
		signal da_frm       : std_logic;
		alias  da_irdy is da_frm;
		signal da_data      : std_logic_vector(ipv4rx_data'range);
		signal pyl_act      : std_logic;

		constant rom_bitdata : std_logic_vector := 
				std_logic_vector'(hdo(frames)**".data.mac.type.ipv4") &
				std_logic_vector'(hdo(frames)**".data.ipv4.verihl")  &
				std_logic_vector'(hdo(frames)**".data.ipv4.tos")     &
				std_logic_vector'(hdo(frames)**".data.ipv4.ident")   &
				std_logic_vector'(hdo(frames)**".data.ipv4.flgsfrg") &
				std_logic_vector'(hdo(frames)**".data.ipv4.ttl");

		signal rom_frm     : std_logic;
		signal rom_irdy    : std_logic;
		signal rom_data    : std_logic_vector(ipv4rx_data'range);

	begin

		arbiter_i : entity hdl4fpga.mii_arbiter
		port map (
			clk   => miitx_clk,
			gntd  => gntd,
			frms  => ipv4pyltx_frms,
			irdys => ipv4pyltx_irdys,
			trdys => ipv4pyltx_trdys,
			frm   => ipv4pyltx_frm,
			irdy  => ipv4pyltx_irdy,
			trdy  => ipv4pyltx_trdy);

		ipv4pyltx_data <= 
			icmptx_data when gntd(0)='1' else
			 udptx_data when gntd(1)='1' else
			(ipv4pyltx_data'range => '-');

		decode_frm  <= ipv4pyltx_frm or ipv4pyltx_irdy;
		decode_irdy <= buffer_trdy;

		ipv4_i : entity hdl4fpga.frame_decode
		generic map (
			frame => compact('{'                                                 &
				"            tha:" & string'(hdo(frames)**".format.mac.hwda")    & ',' &
				"      verihltos:" & natural'image(
					hdo(frames)**".format.mac.type"     +
					hdo(frames)**".format.ipv4.verihl"  +
					hdo(frames)**".format.ipv4.tos")                             & ',' & 
				"         length:" & string'(hdo(frames)**".format.ipv4.length") & ',' &
				"identflgsfrgttl:" & natural'image(
					hdo(frames)**".format.ipv4.ident"   +
					hdo(frames)**".format.ipv4.flgsfrg" +
					hdo(frames)**".format.ipv4.ttl")                             & ',' &
				"          proto:" & string'(hdo(frames)**".format.ipv4.proto")  & ',' &
				"         chksum:" & string'(hdo(frames)**".format.ipv4.chksum") & ',' &
				"             sa:" & string'(hdo(frames)**".format.ipv4.sa")     & ',' &
				"             da:" & string'(hdo(frames)**".format.ipv4.da")     & '}'),
			size  => ipv4tx_data'length)
		port map (
			clk    => miitx_clk,
			frm    => decode_frm,
			irdy   => decode_irdy,
			fin    => decode_fin,
			act(0) => tha_act,
			act(1) => verihltos_frm,
			act(2) => length_act,
			act(3) => identflgsfrgttl_frm,
			act(4) => protoid_act,
			act(5) => chksum_frm,
			act(6) => sa_frm,
			act(7) => da_frm,
			act(8) => pyl_act);

		ipv4pyltx_trdy <= (tha_act or ipv4lentx_act or ipv4tpatx_act or pyl_act) and buffer_trdy;

		rom_irdy <=
		   '1' and buffer_trdy when       verihltos_frm='1' else
		   '1' and buffer_trdy when identflgsfrgttl_frm='1' else
		   '0';

		rom_frm  <= decode_frm;
		rom_i : entity hdl4fpga.sio_rom
		generic map (
			bitdata => reverse (rom_bitdata,8))
		port map (
			so_clk  => miitx_clk,
			so_frm  => rom_frm,
			so_irdy => rom_irdy,
			so_trdy => open,
			so_data => rom_data);

		chksum_b : block
			signal decode_irdy : std_logic;
			signal sa_frm      : std_logic;
			alias  sa_irdy     is sa_frm;
			signal sa_data     : std_logic_vector(ipv4rx_data'range);
			constant miichksum_icmp : std_logic_vector := chksum1(reverse(reverse(rom_bitdata & std_logic_vector'(hdo(frames)**".data.ipv4.proto.icmp"),16),8), 16);
			constant miichksum_udp  : std_logic_vector := chksum1(reverse(reverse(rom_bitdata & std_logic_vector'(hdo(frames)**".data.ipv4.proto.udp"), 16),8), 16);
			signal miichksum_init   : std_logic_vector(0 to 16-1);
			signal miichksum_frm    : std_logic;
			signal miichksum_irdy   : std_logic;
			signal miichksum_data   : std_logic_vector(ipv4rx_data'range);
			signal act3 : std_logic;

		begin
			decode_irdy <= ipv4pyltx_irdy when tha_act='0' else '0';
			chksum_i : entity hdl4fpga.frame_decode
			generic map (
				frame => compact('{'                                                       &
					"length:" & string'(hdo(frames)**".format.ipv4.length") & ',' &
					"    da:" & string'(hdo(frames)**".format.ipv4.da")     & ',' &
					"    sa:" & string'(hdo(frames)**".format.ipv4.sa")     & '}'), -- &
				size  => ipv4tx_data'length)
			port map (
				clk    => miitx_clk,
				frm    => ipv4pyltx_frm,
				irdy   => decode_irdy,
				act(0) => ipv4lentx_act,
				act(1) => ipv4tpatx_act,
				act(2) => sa_frm,
				act(3) => act3);

			length_i : entity hdl4fpga.sio_ram
			generic map (
				bitdata => (0 to hdo(frames)**".format.ipv4.length"-1 => '-'))
			port map (
				si_clk  => miitx_clk,
				si_frm  => ipv4lentx_act,
				si_irdy => ipv4lentx_act,
				si_trdy => open,
				si_data => ipv4pyltx_data,
				so_clk  => miitx_clk,
				so_frm  => length_act,
				so_irdy => length_act,
				so_trdy => open,
				so_data => length_data);

			sa_i : entity hdl4fpga.sio_ram
			generic map (
				bitdata => reverse(ipv4addr,8))
			port map (
				si_clk  => miirx_clk,
				si_frm  => upspa_frm,
				si_irdy => upspa_irdy,
				si_trdy => open,
				si_data => upspa_data,
				so_clk  => miitx_clk,
				so_frm  => sa_frm,
				so_irdy => sa_irdy,
				so_trdy => open,
				so_data => sa_data);

			da_i : entity hdl4fpga.sio_ram
			generic map (
				bitdata => (0 to hdo(frames)**".format.ipv4.da"-1 => '-'))
			port map (
				si_clk  => miitx_clk,
				si_frm  => ipv4tpatx_act,
				si_irdy => ipv4tpatx_act,
				si_trdy => open,
				si_data => ipv4pyltx_data,
				so_clk  => miitx_clk,
				so_frm  => da_frm,
				so_irdy => da_irdy,
				so_trdy => open,
				so_data => da_data);

			miichksum_frm  <= (ipv4pyltx_frm or ipv4pyltx_irdy);
			miichksum_irdy <= ipv4lentx_act or ipv4tpatx_act or sa_frm or chksum_frm;
			miichksum_data <=
				ipv4pyltx_data when ipv4lentx_act='1' else
				ipv4pyltx_data when ipv4tpatx_act='1' else
				       sa_data when        sa_frm='1' else
				(miichksum_data'range => '0');

			miichksum_init <= (miichksum_udp and udp_gntd) or (miichksum_icmp and icmp_gntd);
			mii_chksum1_i : entity hdl4fpga.mii_chksum1
			port map (
				init   => miichksum_init,
				clk    => miitx_clk,
				frm    => miichksum_frm,
				irdy   => miichksum_irdy,
				trdy   => open,
				data   => miichksum_data,
				chksum => chksum_data);

		end block;

		process (miitx_clk)
			variable shr : unsigned(0 to hdo(frames)**".format.ipv4.proto"-1);
		begin
			if rising_edge(miitx_clk) then
				if protoid_act='0' then
					shr := unsigned(
						(std_logic_vector'(hdo(frames)**".data.ipv4.proto.icmp") and icmp_gntd) or
						(std_logic_vector'(hdo(frames)**".data.ipv4.proto.udp")  and udp_gntd));
					shr := reverse(shr,8);
				elsif decode_irdy='1' then
					shr := rotate_left(shr, ipv4tx_data'length);
				end if;
				protoid_data <= std_logic_vector(shr(0 to ipv4tx_data'length-1));
			end if;
		end process;

		spa_i : entity hdl4fpga.sio_ram
		generic map (
			bitdata => reverse(ipv4addr,8))
		port map (
			si_clk  => miirx_clk,
			si_frm  => upspa_frm,
			si_irdy => upspa_irdy,
			si_trdy => open,
			si_data => upspa_data,
			so_clk  => miitx_clk,
			so_frm  => sa_frm,
			so_irdy => sa_irdy,
			so_trdy => open,
			so_data => sa_data);

		decode_data <= 
			ipv4pyltx_data when             tha_act='1' else
			rom_data       when       verihltos_frm='1' else
			rom_data       when identflgsfrgttl_frm='1' else
			protoid_data   when         protoid_act='1' else
			chksum_data    when          chksum_frm='1' else
			length_data    when          length_act='1' else
			sa_data        when              sa_frm='1' else
			da_data        when              da_frm='1' else
			ipv4pyltx_data when             pyl_act='1' else
			ipv4pyltx_data;

		buffer_b : block
			signal buffer_frm  : std_logic;
			signal buffer_irdy : std_logic;
		begin
			buffer_frm  <= ipv4pyltx_frm;
			buffer_irdy <= ipv4pyltx_irdy;

			buffer_i : entity hdl4fpga.mii_buffer
			generic map (
				latency => 12)
			port map (
				clk => miitx_clk,
				src_frm  => buffer_frm,
				src_irdy => buffer_irdy,
				src_trdy => buffer_trdy,
				src_data => decode_data,
				dst_frm  => ipv4tx_frm,
				dst_irdy => ipv4tx_irdy,
				dst_trdy => ipv4tx_trdy,
				dst_data => ipv4tx_data);

		end block;


	end block;

	icmpd_i : entity hdl4fpga.icmpd
	port map (
		miirx_clk      => miirx_clk,
		sharx_frm      => tha1rx_frm,
		sharx_irdy     => tha1rx_irdy,
		sharx_trdy     => tha1rx_trdy,
		sparx_frm      => sparx_frm,
		sparx_irdy     => sparx_irdy,
		sparx_trdy     => sparx_trdy,
		ipv4lenrx_frm  => ipv4lenrx_frm,
		ipv4lenrx_irdy => ipv4lenrx_irdy,
		ipv4lenrx_trdy => ipv4lenrx_trdy,

		icmprx_frm     => icmprx_frm,
		icmprx_irdy    => icmprx_irdy,
		icmprx_trdy    => open,
		icmprx_data    => icmprx_data,

		miitx_clk      => miitx_clk,

		icmptx_frm     => icmptx_frm,
		icmptx_irdy    => icmptx_irdy,
		icmptx_trdy    => icmptx_trdy,
		icmptx_data    => icmptx_data);

	udp_i: entity hdl4fpga.udp
	generic map (
		hwaddr => hwaddr)
	port map (
		tp => tp,

		dhcpcd_req => dhcpcd_req,
		dhcpcd_rdy => dhcpcd_rdy,

		arp_req    => arp_req,
		arp_rdy    => arp_rdy,

		upspa_frm  => upspa_frm,
		upspa_irdy => upspa_irdy,
		upspa_trdy => upspa_trdy,
		upspa_data => upspa_data,

		miirx_clk  => miirx_clk,

		sharx_frm  => tha1rx_frm,
		sharx_irdy => tha1rx_irdy,
		-- sharx_trdy => tha1rx_trdy,
                                 
		sparx_frm  => sparx_frm ,
		sparx_irdy => sparx_irdy,
		-- sparx_trdy => sparx_trdy,

		udprx_frm  => udprx_frm,
		udprx_irdy => udprx_irdy,
		udprx_trdy => udprx_trdy,
		udprx_data => udprx_data,

		pylrx_frm  => udppylrx_frm,
		pylrx_irdy => udppylrx_irdy,
		pylrx_trdy => udppylrx_trdy,
		pylrx_data => udppylrx_data,

		miitx_clk  => miitx_clk,

		pyltx_frm  => udppyltx_frm,
		pyltx_irdy => udppyltx_irdy,
		pyltx_trdy => udppyltx_trdy,
		pyltx_data => udppyltx_data,

		udptx_frm  => udptx_frm,
		udptx_irdy => udptx_irdy,
		udptx_trdy => udptx_trdy,
		udptx_data => udptx_data);

	-- tp(1) <= ipv4tx_frm;
	-- tp(2 to 2+ipv4rx_data'length-1) <= ipv4tx_data;
end;
