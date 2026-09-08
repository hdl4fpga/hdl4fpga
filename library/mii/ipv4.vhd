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

		upspa_frm     : buffer std_logic := '0';
		upspa_irdy    : buffer std_logic := '0';
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
	signal sparx_irdy     : std_Logic;
	signal sparx_trdy     : std_logic := '1';

	signal icmprx_frm     : std_logic;
	alias  icmprx_irdy    is icmprx_frm;
	signal icmprx_trdy    : std_logic;
	signal icmprx_data    : std_logic_vector(ipv4rx_data'range);

	signal udprx_frm      : std_logic;
	signal udprx_irdy     : std_logic;
	signal udprx_trdy     : std_logic;
	signal udprx_data     : std_logic_vector(ipv4rx_data'range);
	signal udptharx_trdy  : std_logic := '1';
	signal udpsparx_trdy  : std_logic := '1';

	signal ipv4pyltx_frms  : std_logic_vector(0 to 2-1) := (others => '0');
	signal ipv4pyltx_irdys : std_logic_vector(0 to 2-1) := (others => '0');
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
		constant discard0_length : natural := -- latticesemi : Expecting constant string
			hdo(frames)**".format.ipv4.verihl" +
			hdo(frames)**".format.ipv4.tos";
		constant discard0_value  : string := natural'image(discard0_length); -- latticesemi : Expecting constant string
		constant discard1_length : natural := -- latticesemi : Expecting constant string
			hdo(frames)**".format.ipv4.ident"   +
			hdo(frames)**".format.ipv4.flgsfrg" +
			hdo(frames)**".format.ipv4.ttl";
		constant discard1_value  : string := natural'image(discard1_length); -- latticesemi : Expecting constant string
		constant ipv4rx_frame : string := compact('{'                           &
			"discard0:" & discard0_value                              & ',' &
			"  length:" & string'(hdo(frames)**".format.ipv4.length") & ',' &
			"discard1:" & discard1_value                              & ',' &
			"   proto:" & string'(hdo(frames)**".format.ipv4.proto")  & ',' &
			"  chksum:" & string'(hdo(frames)**".format.ipv4.chksum") & ',' &
			"      sa:" & string'(hdo(frames)**".format.ipv4.sa")     & ',' &
			"      da:" & string'(hdo(frames)**".format.ipv4.da")     & '}');
		signal ipv4rx_acts  : std_logic_vector(0 to length(ipv4rx_frame));
		signal ipv4rx_frms  : std_logic_vector(ipv4rx_acts'range);
		signal ipv4rx_irdys : std_logic_vector(ipv4rx_acts'range);
		signal ipv4rx_trdys : std_logic_vector(ipv4rx_acts'range) := (others => '1');

		alias length_frm  is ipv4rx_frms(1);
		alias proto_frm   is ipv4rx_frms(3);
		alias chksum_frm  is ipv4rx_frms(4);
		alias spa_frm     is ipv4rx_frms(5);
		alias ipv4da_frm  is ipv4rx_frms(6);
		alias length_irdy is ipv4rx_irdys(1);
		alias proto_irdy  is ipv4rx_irdys(3);
		alias chksum_irdy is ipv4rx_irdys(4);
		alias spa_irdy    is ipv4rx_irdys(5);
		alias ipv4da_irdy is ipv4rx_irdys(6);

	begin
		ipv4_i : entity hdl4fpga.frame_decode
		generic map (
			frame => ipv4rx_frame,
			size  => ipv4rx_data'length)
		port map (
			clk    => miirx_clk,
			frm    => ipv4rx_frm,
			irdy   => ipv4rx_irdy,
			acts   => ipv4rx_acts,
			frms   => ipv4rx_frms,
			irdys  => ipv4rx_irdys,
			trdys  => ipv4rx_trdys);

		process (miirx_clk)
		begin
			if rising_edge(miirx_clk) then
				tha1rx_frm    <= sharx_frm;
				tha1rx_irdy   <= sharx_irdy;
				ipv4lenrx_frm <= length_frm;
				sparx_frm     <= spa_frm;
				sparx_irdy    <= spa_irdy;
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
					udprx_irdy <= ipv4rx_irdy;
					udprx_data <= ipv4rx_data;
				end if;
			end process;

		end block;
	end block;

	tx_b : block
		signal ipv4pyltx_frm  : std_logic;
		signal ipv4pyltx_irdy : std_logic;
		signal ipv4pyltx_trdy : std_logic;

		signal gntd : std_logic_vector(0 to 2-1) := (others => '0');
		alias  icmp_gntd   is gntd(0);
		alias  udp_gntd    is gntd(1);
		constant header_frame : string := compact('{'                     &
			"   tha:" & string'(hdo(frames)**".format.mac.hwda")    & ',' &
			"length:" & string'(hdo(frames)**".format.ipv4.length") & ',' &
			"    da:" & string'(hdo(frames)**".format.ipv4.da")     & ',' &
			"adjlen:" & string'(hdo(frames)**".format.ipv4.length") & ',' &
			"    sa:" & string'(hdo(frames)**".format.ipv4.sa")     & '}');

		signal header_frms  : std_logic_vector(0 to length(header_frame));
		signal header_acts  : std_logic_vector(header_frms'range);
		signal header_irdys : std_logic_vector(header_frms'range);
		signal header_trdys : std_logic_vector(header_frms'range);
		signal header_fins  : std_logic_vector(header_frms'range);

		alias tha_act     is header_acts(0);
		alias length_act  is header_acts(1);
		alias length_frm  is header_frms(1);
		alias length_irdy is header_irdys(1);
		alias da_frm      is header_frms(2);
		alias da_irdy     is header_irdys(2);
		alias da_act      is header_acts(2);
		alias al_act      is header_acts(3);
		alias al_frm      is header_frms(3);
		alias al_irdy     is header_irdys(3);
		alias sa_act      is header_acts(4);
		alias sa_frm      is header_frms(4);
		alias sa_irdy     is header_irdys(4);

		constant ipv4hdr_size   : natural := hdo(frames)**".format.ipv4.length";
		constant ipv4hdr_length : natural := summation(hdo(frames)**".format.ipv4")/8;
		constant ipv4hdr_value  : std_logic_vector := std_logic_vector(to_unsigned(ipv4hdr_length, ipv4hdr_size));
		constant vertos_length : natural :=  -- latticesemi Expecting constant string
			hdo(frames)**".format.mac.type"     +
			hdo(frames)**".format.ipv4.verihl"  +
			hdo(frames)**".format.ipv4.tos";
		constant vertos_value : string := natural'image(vertos_length); -- latticesemi Expecting constant string
		constant frags_length : natural := -- latticesemi Expecting constant string
			hdo(frames)**".format.ipv4.ident"   +
			hdo(frames)**".format.ipv4.flgsfrg" +
			hdo(frames)**".format.ipv4.ttl";
		constant frags_value : string := natural'image(frags_length); -- latticesemi Expecting constant string
		constant ipv4_frame : string := compact('{'                              &
				"vertos:" & vertos_value                                & ',' & 
				"length:" & string'(hdo(frames)**".format.ipv4.length") & ',' &
				" frags:" & frags_value                                 & ',' & 
				" proto:" & string'(hdo(frames)**".format.ipv4.proto")  & ',' &
				"chksum:" & string'(hdo(frames)**".format.ipv4.chksum") & ',' &
				"    sa:" & string'(hdo(frames)**".format.ipv4.sa")     & ',' &
				"    da:" & string'(hdo(frames)**".format.ipv4.da")     & '}');
		constant ipv4hdr_bitdata : std_logic_vector := 
			std_logic_vector'(hdo(frames)**".data.ipv4.verihl")  &
			std_logic_vector'(hdo(frames)**".data.ipv4.tos")     &
			std_logic_vector'(hdo(frames)**".data.ipv4.ident")   &
			std_logic_vector'(hdo(frames)**".data.ipv4.flgsfrg") &
			std_logic_vector'(hdo(frames)**".data.ipv4.ttl");

		signal ipv4_frms  : std_logic_vector(0 to length(ipv4_frame));
		signal ipv4_acts  : std_logic_vector(ipv4_frms'range);
		signal ipv4_irdys : std_logic_vector(ipv4_frms'range);
		signal ipv4_trdys : std_logic_vector(ipv4_frms'range);

		signal adjlen_irdy    : std_logic;
		signal adjlen_init    : std_logic_vector(0 to ipv4hdr_size-1);

		alias ipv4_act        is header_fins(0);
		alias ipv4_frm        is header_fins(0);
		signal ipv4_irdy       : std_logic;
		signal ipv4_fin        : std_logic;
		alias vertos_act      is ipv4_acts(0);
		alias vertos_irdy     is ipv4_irdys(0);
		alias ipv4length_act  is ipv4_acts(1);
		alias ipv4length_frm  is ipv4_frms(1);
		alias ipv4length_irdy is ipv4_irdys(1);
		signal ipv4length_data : std_logic_vector(ipv4tx_data'range);
		alias frags_act       is ipv4_acts(2);
		alias frags_irdy      is ipv4_irdys(2);
		alias ipv4proto_act   is ipv4_acts(3);
		alias ipv4proto_frm   is ipv4_frms(3);
		alias ipv4proto_irdy  is ipv4_irdys(3);
		signal ipv4proto_init  : std_logic_vector(0 to hdo(frames)**".format.ipv4.proto"-1);
		signal ipv4proto_data  : std_logic_vector(ipv4tx_data'range);
		alias ipv4chksum_act  is ipv4_acts(4);
		alias ipv4chksum_frm  is ipv4_frms(4);
		alias ipv4chksum_irdy is ipv4_irdys(4);
		signal ipv4chksum_data : std_logic_vector(ipv4tx_data'range);
		alias ipv4sa_act      is ipv4_acts(5);
		alias ipv4sa_frm      is ipv4_frms(5);
		alias ipv4sa_irdy     is ipv4_irdys(5);
		signal ipv4sa_data     : std_logic_vector(ipv4tx_data'range);
		alias ipv4da_act      is ipv4_acts(6);
		alias ipv4da_frm      is ipv4_frms(6);
		alias ipv4da_irdy     is ipv4_irdys(6);
		signal ipv4da_data     : std_logic_vector(ipv4tx_data'range);

		alias  rom_frm        is ipv4_frm;
		signal rom_irdy        : std_logic;
		signal rom_data        : std_logic_vector(ipv4tx_data'range);

		alias  buffer_frm     is ipv4pyltx_frm;
		signal buffer_irdy     : std_logic;
		signal buffer_trdy     : std_logic;
		signal buffer_data     : std_logic_vector(ipv4tx_data'range);

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

		ipv4pyltx_trdy <= 
			buffer_trdy when    tha_act='1' else
			'1'         when length_act='1' else 
			'1'         when     da_act='1' else 
			'0'         when   ipv4_fin='0' else
			buffer_trdy;
		ipv4pyltx_data <= 
			icmptx_data when gntd(0)='1' else
			 udptx_data when gntd(1)='1' else
			(ipv4pyltx_data'range => '-');

-- disable UDP
--		gntd <= "10";
--		ipv4pyltx_frm  <= icmptx_frm;
--		ipv4pyltx_irdy <= icmptx_irdy;
--		icmptx_trdy <= 
--			buffer_trdy when    tha_act='1' else
--			'1'         when length_act='1' else 
--			'1'         when     da_act='1' else 
--			'0'         when   ipv4_fin='0' else
--			buffer_trdy;
--		ipv4pyltx_data <= icmptx_data;

		header_i : entity hdl4fpga.frame_decode
		generic map (
			frame => header_frame,
			size  => ipv4tx_data'length)
		port map (
			clk   => miitx_clk,
			frm   => ipv4pyltx_frm,
			irdy  => ipv4pyltx_irdy,
			acts  => header_acts,
			frms  => header_frms,
			irdys => header_irdys,
			fins  => header_fins);

		adjlen_init <= ipv4hdr_value when icmp_gntd='0' else (others => '0');
		adjlen_irdy <= ipv4length_irdy or al_irdy;
		miiadjlen_i : entity hdl4fpga.mii_adjlen
		port map (
			clk     => miitx_clk,
			init    => adjlen_init,
			frm     => ipv4_frm,
			irdy    => length_irdy,
			si_data => ipv4pyltx_data,
			so_irdy => adjlen_irdy,
			so_data => ipv4length_data);

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
			so_frm  => ipv4sa_frm,
			so_irdy => ipv4sa_irdy,
			so_trdy => open,
			so_data => ipv4sa_data);

		da_i : entity hdl4fpga.sio_ram
		generic map (
			bitdata => (0 to hdo(frames)**".format.ipv4.da"-1 => '-'))
		port map (
			si_clk  => miitx_clk,
			si_frm  => da_frm,
			si_irdy => da_irdy,
			si_trdy => open,
			si_data => ipv4pyltx_data,
			so_clk  => miitx_clk,
			so_frm  => ipv4da_frm,
			so_irdy => ipv4da_irdy,
			so_trdy => open,
			so_data => ipv4da_data);

		ipv4_irdy <= ipv4_act and ipv4pyltx_irdy;
		ipv4_i : entity hdl4fpga.frame_decode
		generic map (
			frame => ipv4_frame,
			size  => ipv4tx_data'length)
		port map (
			clk   => miitx_clk,
			frm   => ipv4_frm,
			irdy  => ipv4_irdy,
			fin   => ipv4_fin,
			acts  => ipv4_acts,
			frms  => ipv4_frms,
			irdys => ipv4_irdys,
			trdys => ipv4_trdys);

		ipv4_trdys <= (others => buffer_trdy);

		rom_irdy <= vertos_irdy or frags_irdy;
		rom_i : entity hdl4fpga.sio_rom
		generic map (
			bitdata => reverse (std_logic_vector'(hdo(frames)**".data.mac.type.ipv4") & ipv4hdr_bitdata,8))
		port map (
			so_clk  => miitx_clk,
			so_frm  => rom_frm,
			so_irdy => rom_irdy,
			so_trdy => open,
			so_data => rom_data);

		ipv4proto_init <=
			reverse(hdo(frames)**".data.ipv4.proto.icmp",8) when icmp_gntd='1' else
			reverse(hdo(frames)**".data.ipv4.proto.udp", 8);

		proto_e : entity hdl4fpga.sio_mux
		port map (
			mux_data => ipv4proto_init,
			sio_clk  => miitx_clk,
			sio_frm  => ipv4proto_frm,
			sio_irdy => ipv4proto_irdy,
			so_data  => ipv4proto_data);

		chksum_b : block

			signal chksum_init : std_logic_vector(0 to hdo(frames)**".format.ipv4.chksum"-1);
			signal chksum_irdy : std_logic;
			signal chksum_data : std_logic_vector(ipv4rx_data'range);
			signal sa_data     : std_logic_vector(ipv4rx_data'range);

		begin

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
 
			chksum_init <= 
				chksum1(
					ipv4hdr_bitdata & 
					std_logic_vector'(hdo(frames)**".data.ipv4.proto.icmp"), 
					natural'(hdo(frames)**".format.ipv4.chksum")) when icmp_gntd='1' else
				chksum1(
					ipv4hdr_bitdata & 
					std_logic_vector'(hdo(frames)**".data.ipv4.proto.udp") & 
					ipv4hdr_value,  
					natural'(hdo(frames)**".format.ipv4.chksum"));

			chksum_irdy <= da_irdy or al_irdy or sa_irdy;
			chksum_data <=
				ipv4length_data when al_act='1' else
				sa_data         when sa_act='1' else
				ipv4pyltx_data;

			miiadjlen_i : entity hdl4fpga.mii_adjlen
			port map (
				clk     => miitx_clk,
				init    => chksum_init,
				frm     => ipv4_frm,
				irdy    => chksum_irdy,
				si_data => chksum_data,
				so_irdy => ipv4chksum_irdy,
				so_data => ipv4chksum_data);

		end block;

		buffer_data <= 
			ipv4pyltx_data      when        tha_act='1' else
			rom_data            when     vertos_act='1' else
			ipv4length_data     when ipv4length_act='1' else
			rom_data            when      frags_act='1' else
			ipv4proto_data      when  ipv4proto_act='1' else
			not ipv4chksum_data when ipv4chksum_act='1' else
			ipv4sa_data         when     ipv4sa_act='1' else
			ipv4da_data         when     ipv4da_act='1' else
			ipv4pyltx_data;

		buffer_irdy <= 
			ipv4pyltx_irdy when icmp_gntd='1' else
			ipv4pyltx_irdy or rom_irdy;

		buffer_i : entity hdl4fpga.mii_buffer
		generic map (
			latency => 12)
		port map (
			src_clk  => miitx_clk,
			src_frm  => buffer_frm,
			src_irdy => buffer_irdy,
			src_trdy => buffer_trdy,
			src_data => buffer_data,
			dst_clk  => miitx_clk,
			dst_frm  => ipv4tx_frm,
			dst_irdy => ipv4tx_irdy,
			dst_trdy => ipv4tx_trdy,
			dst_data => ipv4tx_data);

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
		icmprx_trdy    => icmprx_trdy,
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
		sharx_trdy => udptharx_trdy,
                                 
		sparx_frm  => sparx_frm ,
		sparx_irdy => sparx_irdy,
		sparx_trdy => udpsparx_trdy,

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
