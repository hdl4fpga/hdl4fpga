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
		ipv4addr    : std_logic_vector);
	port (
		miirx_clk     : in  std_logic;

		tharx_frm     : in  std_logic;
		tharx_irdy    : in  std_logic;
		tharx_trdy    : out std_logic := '1';

		ipv4rx_frm    : in  std_logic;
		ipv4rx_irdy   : in  std_logic;
		ipv4rx_trdy   : out std_logic := '1';
		ipv4rx_data   : in  std_logic_vector;

		miitx_clk     : in  std_logic;

		ethtyptx_frm  : in  std_logic;
		ethtyptx_irdy : in  std_logic;
		ethtyptx_trdy : out std_logic := '1';
		ethtyptx_data : out std_logic_vector;

		thatx_frm     : in  std_logic;
		thatx_irdy    : in  std_logic;
		thatx_trdy    : out std_logic := '1';
		thatx_data    : out std_logic_vector;

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
	signal tparx_frm      : std_logic;
	alias  tparx_irdy  is tparx_frm;
	signal tparx_trdy     : std_logic := '1';

	signal icmprx_frm     : std_logic;
	signal icmprx_irdy    : std_logic;
	signal icmprx_trdy    : std_logic;
	signal icmprx_data    : std_logic_vector(ipv4rx_data'range);

	signal icmplentx_frm  : std_logic;
	alias  icmplentx_irdy is icmplentx_frm;
	signal icmplentx_trdy : std_logic;

	signal tpatx_frm      : std_logic;
	signal tpatx_irdy     : std_logic;
	signal tpatx_trdy     : std_logic := '1';

	signal icmptx_frm     : std_logic;
	signal icmptx_irdy    : std_logic;
	signal icmptx_trdy    : std_logic;
	signal icmptx_data    : std_logic_vector(ipv4tx_data'range);

	signal icmpthatx_frm  : std_logic;
	signal icmpthatx_irdy : std_logic;
	signal icmpthatx_trdy : std_logic := '1';
	signal icmpthatx_data : std_logic_vector(thatx_data'range);
	signal icmpdatx_frm   : std_logic;
	alias  icmpdatx_irdy  is icmpdatx_frm;

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
			variable icmp_vld : std_logic := '0';
			variable pa_vld   : std_logic := '0';
		begin
			if rising_edge(miirx_clk) then
				tha1rx_frm    <= tharx_frm;
				tha1rx_irdy   <= tharx_irdy;
				ipv4lenrx_frm <= length_frm;
				tparx_frm     <= spa_frm;
			end if;
		end process;

		pa_b : block
			signal so_data  : std_logic_vector(ipv4rx_data'range);
			signal icmp_equ : std_logic;
			signal udp_equ  : std_logic;
			signal pa_equ   : std_logic;
		begin
			mem_i : entity hdl4fpga.sio_ram
			generic map (
				bitdata => reverse(ipv4addr,8))
			port map (
				si_data => ipv4rx_data,
				so_clk  => miirx_clk,
				so_frm  => ipv4da_frm,
				so_irdy => ipv4da_irdy,
				so_trdy => open,
				so_data => so_data);

			cmp_i : entity hdl4fpga.sio_cmp
			port map (
				clk     => miirx_clk,
				mr_frm  => ipv4da_frm,
				mr_irdy => ipv4da_irdy,
				mr_trdy => open,
				mr_data => so_data,
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

			process (miirx_clk)
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
						if (not pa_vld and pa_equ)='1' then
							pa_vld := '1';
						end if;
					end if;
					icmprx_frm  <= ipv4rx_frm and pa_vld and icmp_vld;
					icmprx_data <= ipv4rx_data;
				end if;
			end process;
		end block;
	end block;

	tx_b : block
		signal decode_trdy : std_logic;
		signal proto_frm : std_logic;
	begin
		ethtyptx_i : entity hdl4fpga.sio_rom
		generic map (
			bitdata => reverse(hdo(frames)**".data.mac.type.ipv4",8))
		port map (
			so_clk  => miitx_clk,
			so_frm  => ethtyptx_frm,
			so_irdy => ethtyptx_irdy,
			so_trdy => ethtyptx_trdy,
			so_data => ethtyptx_data);

		hwaddr_b : block
			signal hwaddr_frm  : std_logic;
			signal hwaddr_irdy : std_logic;
			signal hwaddr_fin  : std_logic;
			signal pyl_frm     : std_logic;
		begin
			hwaddr_frm     <= (icmptx_frm or icmptx_irdy);
			hwaddr_irdy    <= icmptx_irdy and decode_trdy;
			icmpthatx_irdy <= decode_trdy when icmpthatx_frm='1' else '0';
			tha_i : entity hdl4fpga.frame_decode
			generic map (
				frame => compact('{' &
					"tha:" & string'(hdo(frames)**".format.mac.hwda") & '}'),
				size  => ipv4tx_data'length)
			port map (
				clk    => miitx_clk,
				frm    => hwaddr_frm,
				irdy   => hwaddr_irdy,
				fin    => hwaddr_fin,
				act(0) => icmpthatx_frm,
				act(1) => proto_frm);
		end block;

		proto_b : block
			signal decode_frm  : std_logic;
			signal decode_irdy : std_logic;
			signal decode_fin  : std_logic;
			signal decode_data : std_logic_vector(ipv4rx_data'range);

			signal verihltos_frm : std_logic;
			signal identflgsfrgttl_frm : std_logic;
			signal ipv4length_frm  : std_logic;
			alias  ipv4length_irdy is ipv4length_frm;
			signal ivp4proto_frm   : std_logic;
			signal chksum_frm  : std_logic;
			signal ipv4sa_frm      : std_logic;
			alias  ipv4sa_irdy is ipv4sa_frm; 
			signal ipv4sa_data     : std_logic_vector(ipv4rx_data'range);
			signal ipv4da_frm      : std_logic;
			alias  ipv4da_irdy is ipv4da_frm;
			signal pyl_frm     : std_logic;

			constant rom_bitdata : std_logic_vector := 
					std_logic_vector'(hdo(frames)**".data.ipv4.verihl")  &
					std_logic_vector'(hdo(frames)**".data.ipv4.tos")     &
					std_logic_vector'(hdo(frames)**".data.ipv4.ident")   &
					std_logic_vector'(hdo(frames)**".data.ipv4.flgsfrg") &
					std_logic_vector'(hdo(frames)**".data.ipv4.ttl");

			signal rom_frm     : std_logic;
			signal rom_irdy    : std_logic;
			signal rom_data    : std_logic_vector(ipv4rx_data'range);
			signal ipv4length_data : std_logic_vector(ipv4rx_data'range);
			signal ipv4chksum_data : std_logic_vector(ipv4rx_data'range);
			signal ipv4da_data     : std_logic_vector(ipv4rx_data'range);

		begin
			decode_frm  <= proto_frm; -- or icmptx_irdy;
			decode_irdy <= decode_trdy;
				-- decode_trdy when chksum_frm='1' else
				-- decode_trdy when    pyl_frm='1' else
				-- '0';

			ipv4_i : entity hdl4fpga.frame_decode
			generic map (
				frame => compact('{'                                                       &
					"      verihltos:" & natural'image(
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
				act(0) => verihltos_frm,
				act(1) => ipv4length_frm,
				act(2) => identflgsfrgttl_frm,
				act(3) => ivp4proto_frm,
				act(4) => chksum_frm,
				act(5) => ipv4sa_frm,
				act(6) => ipv4da_frm,
				act(7) => pyl_frm);

			icmptx_trdy <= (pyl_frm or decode_fin) and ipv4tx_irdy and ipv4tx_trdy;

			rom_irdy <=
			   '1' and decode_trdy when       verihltos_frm='1' else
			   '1' and decode_trdy when identflgsfrgttl_frm='1' else
			   '0';

			rom_frm  <= proto_frm; -- or icmptx_irdy;
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
				signal sa_frm      : std_logic;
				signal length_data : std_logic_vector(ipv4rx_data'range);
				signal chksum_frm  : std_logic;
				signal chksum_irdy : std_logic;
				signal chksum_data : std_logic_vector(ipv4rx_data'range);
			begin
				chksum_frm <= proto_frm;
				chksum_i : entity hdl4fpga.frame_decode
				generic map (
					frame => compact('{'                                                       &
						"length:" & string'(hdo(frames)**".format.ipv4.length") & ',' &
						"    sa:" & string'(hdo(frames)**".format.ipv4.sa")     & ',' &
						"    da:" & string'(hdo(frames)**".format.ipv4.da")     & '}'),
					size  => ipv4tx_data'length)
				port map (
					clk    => miitx_clk,
					frm    => chksum_frm,
					irdy   => chksum_irdy,
					act(0) => icmplentx_frm,
					act(1) => icmpdatx_frm,
					act(2) => sa_frm,
					act(3) => pyl_frm);

				length_i : entity hdl4fpga.sio_ram
				generic map (
					bitdata => (0 to hdo(frames)**".format.ipv4.length"-1 => '-'))
				port map (
					si_clk  => miitx_clk,
					si_frm  => icmplentx_frm,
					si_irdy => icmplentx_irdy,
					si_trdy => open,
					si_data => icmptx_data,
					so_clk  => miitx_clk,
					so_frm  => ipv4length_frm,
					so_irdy => ipv4length_irdy,
					so_trdy => open,
					so_data => ipv4length_data);

				da_i : entity hdl4fpga.sio_ram
				generic map (
					bitdata => (0 to hdo(frames)**".format.ipv4.da"-1 => '-'))
				port map (
					si_clk  => miitx_clk,
					si_frm  => icmpdatx_frm,
					si_irdy => icmpdatx_irdy,
					si_trdy => open,
					si_data => icmptx_data,
					so_clk  => miitx_clk,
					so_frm  => ipv4da_frm,
					so_irdy => ipv4da_irdy,
					so_trdy => open,
					so_data => ipv4da_data);

				chksum_irdy <= icmplentx_frm or icmpdatx_frm or sa_frm;
				chksum_data <=
					icmptx_data when   icmplentx_frm='1' else
					icmptx_data when icmpdatx_frm='1' else
					ipv4sa_data when       sa_frm='1' else
					(chksum_data'range => '0');

				mii_chksum1_i : entity hdl4fpga.mii_chksum1
				port map (
					clk    => miitx_clk,
					frm    => chksum_frm,
					irdy   => chksum_irdy,
					trdy   => open,
					data   => chksum_data,
					chksum => ipv4chksum_data);
			end block;

			spa_i : entity hdl4fpga.sio_ram
			generic map (
				bitdata => reverse(ipv4addr,8))
			port map (
				si_data => ipv4rx_data,
				so_clk  => miitx_clk,
				so_frm  => ipv4sa_frm,
				so_irdy => ipv4sa_irdy,
				so_trdy => open,
				so_data => ipv4sa_data);

			tpatx_frm  <= icmpdatx_frm;
			tpatx_irdy <= icmpdatx_irdy;

			decode_data <= 
				icmptx_data     when       icmpthatx_frm='1' else
				rom_data        when       verihltos_frm='1' else
				rom_data        when identflgsfrgttl_frm='1' else
				x"6" when ivp4proto_frm='1' else
				x"9" when    chksum_frm='1' else
				ipv4length_data when      ipv4length_frm='1' else
				ipv4sa_data     when          ipv4sa_frm='1' else
				icmptx_data     when          ipv4da_frm='1' else
				icmptx_data     when             pyl_frm='1' else
				icmptx_data;

			buffer_b : block
				signal buffer_frm  : std_logic;
				signal buffer_irdy : std_logic;
				signal buffer_trdy : std_logic;
				signal dst_trdy    : std_logic;
			begin
				buffer_frm  <= icmptx_frm;
				buffer_irdy <= 
					icmpthatx_trdy when icmpthatx_frm='1' else 
					decode_frm;

				buffer_i : entity hdl4fpga.mii_buffer
				generic map (
					latency => 12)
				port map (
					clk => miitx_clk,
					src_frm  => buffer_frm,
					src_irdy => buffer_irdy,
					src_trdy => decode_trdy,
					src_data => decode_data,
					dst_frm  => ipv4tx_frm,
					dst_irdy => ipv4tx_irdy,
					dst_trdy => buffer_trdy,
					dst_data => ipv4tx_data);

				buffer_trdy <= 
					thatx_irdy when thatx_frm='1' else
					ipv4tx_trdy;
		
				thatx_trdy <= thatx_irdy;

			end block;

			thatx_data <= ipv4tx_data;

		end block;

	end block;

	icmpd_i : entity hdl4fpga.icmpd
	port map (
		miirx_clk      => miirx_clk,
		tharx_frm      => tha1rx_frm,
		tharx_irdy     => tha1rx_irdy,
		tharx_trdy     => tha1rx_trdy,
		tparx_frm      => tparx_frm,
		tparx_irdy     => tparx_irdy,
		tparx_trdy     => tparx_trdy,
		ipv4lenrx_frm  => ipv4lenrx_frm,
		ipv4lenrx_irdy => ipv4lenrx_irdy,
		ipv4lenrx_trdy => ipv4lenrx_trdy,

		icmprx_frm     => icmprx_frm,
		icmprx_irdy    => icmprx_frm,
		icmprx_trdy    => open,
		icmprx_data    => icmprx_data,

		miitx_clk      => miitx_clk,

		thatx_frm      => icmpthatx_frm,
		thatx_irdy     => icmpthatx_irdy,
		thatx_trdy     => icmpthatx_trdy,
		thatx_data     => icmpthatx_data,

		tpatx_frm      => tpatx_frm,
		tpatx_irdy     => tpatx_irdy,
		tpatx_trdy     => tpatx_trdy,

		ipv4lentx_frm  => icmplentx_frm,
		ipv4lentx_irdy => icmplentx_irdy,
		ipv4lentx_trdy => icmplentx_trdy,

		icmptx_frm     => icmptx_frm,
		icmptx_irdy    => icmptx_irdy,
		icmptx_trdy    => icmptx_trdy,
		icmptx_data    => icmptx_data);

	tp(1) <= ipv4tx_frm;
	tp(2 to 2+ipv4rx_data'length-1) <= icmprx_data;
end;
