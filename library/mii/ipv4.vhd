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
		ipv4tx_data   : out std_logic_vector;
		tp            : out std_logic_vector(1 to 32));
end;

architecture def of ipv4 is

	signal tha1rx_frm  : std_logic;
	signal tha1rx_irdy : std_logic;
	signal tha1rx_trdy : std_logic := '1';
	signal tparx_frm   : std_logic;
	alias  tparx_irdy  is tparx_frm;
	signal tparx_trdy  : std_logic := '1';

	signal icmprx_frm  : std_logic;
	signal icmprx_irdy : std_logic;
	signal icmprx_trdy : std_logic;
	signal icmprx_data : std_logic_vector(ipv4rx_data'range);

	signal tpatx_frm   : std_logic;
	signal tpatx_irdy  : std_logic;
	signal tpatx_trdy  : std_logic := '1';
	signal icmptx_trdy : std_logic;
	signal icmptx_data : std_logic_vector(ipv4tx_data'range);

begin

	rx_b : block
		signal proto_frm  : std_logic;
		alias  proto_irdy is proto_frm;
		signal spa_frm    : std_logic;
		signal ipv4da_frm : std_logic;
		alias  ipv4da_irdy is ipv4da_frm;
		signal pyl_frm    : std_logic;
		signal act0       : std_logic;
		signal act1       : std_logic;
	begin
		ipv4_i : entity hdl4fpga.frame_decode
		generic map (
			frame => compact('{'                                                         &
				"           lead:" & natural'image(
					hdo(frames)**".format.ipv4.verihl"  +
					hdo(frames)**".format.ipv4.tos"     +  
					hdo(frames)**".format.ipv4.length"  +
					hdo(frames)**".format.ipv4.ident"   +
					hdo(frames)**".format.ipv4.flgsfrg" +
					hdo(frames)**".format.ipv4.ttl")                             & ',' &
				"          proto:" & string'(hdo(frames)**".format.ipv4.proto")  & ',' &
				"         chksum:" & string'(hdo(frames)**".format.ipv4.chksum") & ',' &
				"             sa:" & string'(hdo(frames)**".format.ipv4.sa")     & ',' &
				"             da:" & string'(hdo(frames)**".format.ipv4.da")     & '}'),
			size  => ipv4tx_data'length)
		port map (
			clk    => miirx_clk,
			frm    => ipv4rx_frm,
			irdy   => ipv4rx_irdy,
			act(0) => act0,
			act(1) => proto_frm,
			act(2) => act1,
			act(3) => spa_frm,
			act(4) => ipv4da_frm,
			act(5) => pyl_frm);

		process (miirx_clk)
			variable icmp_vld : std_logic := '0';
			variable pa_vld   : std_logic := '0';
		begin
			if rising_edge(miirx_clk) then
				tha1rx_frm  <= tharx_frm;
				tha1rx_irdy <= tharx_irdy;
				tparx_frm   <= spa_frm;
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
		signal verihltos_frm : std_logic;
		signal identflgsfrgttl_frm : std_logic;
		signal length_frm  : std_logic;
		signal proto_frm   : std_logic;
		signal chksum_frm  : std_logic;
		signal sa_frm      : std_logic;
		alias  sa_irdy is sa_frm; 
		signal sa_data     : std_logic_vector(ipv4rx_data'range);
		signal da_frm      : std_logic;
		signal pyl_frm     : std_logic;
		signal decode_irdy : std_logic;
		alias  rom_frm is ipv4tx_frm;
		signal rom_irdy    : std_logic;
		signal rom_data    : std_logic_vector(ipv4rx_data'range);
		signal length_data : std_logic_vector(ipv4rx_data'range);
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

		decode_irdy <= ipv4tx_irdy and ipv4tx_trdy;
		ipv4_i : entity hdl4fpga.frame_decode
		generic map (
			frame => compact('{'                                                         &
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
			frm    => ipv4tx_frm,
			irdy   => decode_irdy,
			act(0) => verihltos_frm,
			act(1) => length_frm,
			act(2) => identflgsfrgttl_frm,
			act(3) => proto_frm,
			act(4) => chksum_frm,
			act(5) => sa_frm,
			act(6) => da_frm,
			act(7) => pyl_frm);
		icmptx_trdy <= pyl_frm;

		length_p : process (miitx_clk)
			variable shr : unsigned(0 to hdo(frames)**".format.ipv4.length"-1);
		begin
			if rising_edge(miitx_clk) then
				length_data <= std_logic_vector(shr(0 to length_data'length-1));
				if length_frm='1' then
					if decode_irdy='1' then
						shr := rotate_left(shr, length_data'length);
					end if;
				else
					shr := (others => '1');
				end if;
			end if;
		end process;

		rom_irdy <=
		   '1' and decode_irdy when       verihltos_frm='1' else
		   '1' and decode_irdy when identflgsfrgttl_frm='1' else
		   '0';

		rom_i : entity hdl4fpga.sio_rom
		generic map (
			bitdata => reverse (
				std_logic_vector'(hdo(frames)**".data.ipv4.verihl")  &
				std_logic_vector'(hdo(frames)**".data.ipv4.tos")     &
				std_logic_vector'(hdo(frames)**".data.ipv4.ident")   &
				std_logic_vector'(hdo(frames)**".data.ipv4.flgsfrg") &
				std_logic_vector'(hdo(frames)**".data.ipv4.ttl"), 8))
		port map (
			so_clk  => miitx_clk,
			so_frm  => rom_frm,
			so_irdy => rom_irdy,
			so_trdy => open,
			so_data => rom_data);

		spa_i : entity hdl4fpga.sio_ram
		generic map (
			bitdata => reverse(ipv4addr,8))
		port map (
			si_data => ipv4rx_data,
			so_clk  => miitx_clk,
			so_frm  => sa_frm,
			so_irdy => sa_irdy,
			so_trdy => open,
			so_data => sa_data);

		tpatx_frm  <= sa_frm;
		tpatx_irdy <= sa_irdy;
		ipv4tx_data <= 
			rom_data    when       verihltos_frm='1' else
			rom_data    when identflgsfrgttl_frm='1' else
			length_data when          length_frm='1' else
			(ipv4tx_data'range => '-');
	end block;

	icmpd_i : entity hdl4fpga.icmpd
	port map (
		miirx_clk   => miirx_clk,
		tharx_frm   => tha1rx_frm,
		tharx_irdy  => tha1rx_irdy,
		tharx_trdy  => tha1rx_trdy,
		tparx_frm   => tparx_frm,
		tparx_irdy  => tparx_irdy,
		tparx_trdy  => tparx_trdy,
		icmprx_frm  => icmprx_frm,
		icmprx_irdy => icmprx_frm,
		icmprx_trdy => open,
		icmprx_data => icmprx_data,

		miitx_clk   => miitx_clk,

		thatx_frm   => thatx_frm,
		thatx_irdy  => thatx_irdy,
		thatx_trdy  => thatx_trdy,
		thatx_data  => thatx_data,

		tpatx_frm   => tpatx_frm,
		tpatx_irdy  => tpatx_irdy,
		tpatx_trdy  => tpatx_trdy,

		icmptx_frm  => ipv4tx_frm,
		icmptx_irdy => ipv4tx_irdy,
		icmptx_trdy => icmptx_trdy,
		icmptx_data => icmptx_data);

	tp(1) <= icmprx_frm;
	tp(2 to 2+ipv4rx_data'length-1) <= icmprx_data;
end;
