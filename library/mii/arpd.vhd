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
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;

entity arpd is
	generic (
		ipv4addr : std_logic_vector(0 to 32-1) := aton("192.168.0.14");
		hwaddr   : std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03");
	port (
		miirx_clk     : in  std_logic;

		arprx_frm     : in  std_logic;
		arprx_irdy    : in  std_logic;
		arprx_data    : in  std_logic_vector;

		thatx_frm     : in  std_logic := '0';
		thatx_irdy    : in  std_logic := '0';
		thatx_trdy    : out std_logic := '0';
		thatx_data    : out std_logic_vector;

		ethtyptx_frm  : in  std_logic := '0';
		ethtyptx_irdy : in  std_logic := '0';
		ethtyptx_trdy : out std_logic := '0';
		ethtyptx_data : out std_logic_vector;

		miitx_clk     : in  std_logic;
		arptx_frm     : buffer std_logic := '0';
		arptx_irdy    : out std_logic := '0';
		arptx_trdy    : in  std_logic := '1';
		arptx_data    : out std_logic_vector;

		tp            : out std_logic_vector(1 to 32));
end;

architecture def of arpd is
	signal tx_req      : std_logic := '0';
	signal tx_rdy      : std_logic := '0';
begin

	rx_b : block
		signal tpa_frm  : std_logic;
		alias  tpa_irdy is tpa_frm;
		signal tpa_trdy : std_logic := '1';
		signal tpa_data : std_logic_vector(arprx_data'range);

		signal act0    : std_logic;
		signal pyl_frm : std_logic;
	begin

		decode_i : entity hdl4fpga.frame_decode
		generic map (
			frame => '{' &
				"discard:" & natural'image(
					hdo(frames)**".format.arp.htype" +
					hdo(frames)**".format.arp.ptype" +
					hdo(frames)**".format.arp.hlen"  +
					hdo(frames)**".format.arp.plen"  +
					hdo(frames)**".format.arp.oper"  +
					hdo(frames)**".format.arp.sha"   +
					hdo(frames)**".format.arp.spa"   +
					hdo(frames)**".format.arp.tha")  & ',' &
				"    tpa:" & string'(hdo(frames)**".format.arp.tpa") & '}',
			size  => arprx_data'length)
		port map (
			clk    => miirx_clk,
			frm    => arprx_frm,
			irdy   => arprx_irdy,
			act(0) => act0,
			act(1) => tpa_frm,
			act(2) => pyl_frm);

		tpacmp_b : block
			signal tpa_equ : std_logic;
		begin
			ipsa_i : entity hdl4fpga.sio_ram
			generic map (
				bitdata => reverse(ipv4addr,8))
			port map (
				si_data => arprx_data,
				so_clk  => miirx_clk,
				so_frm  => tpa_frm,
				so_irdy => tpa_irdy,
				so_trdy => tpa_trdy,
				so_data => tpa_data);

			cmp_i : entity hdl4fpga.sio_cmp
			port map (
				clk     => miirx_clk,
				mr_frm  => tpa_frm,
				mr_irdy => tpa_irdy,
				-- mr_trdy => tpa_trdy,
				mr_data => tpa_data,
				sl_data => arprx_data,
				equ     => tpa_equ);

			process (miirx_clk)
				variable lat1 : std_logic;
			begin
				if rising_edge(miirx_clk) then
					if (tpa_frm or tpa_irdy)='0' then
						if (lat1 and tpa_equ)='1' then
							tx_req <= not tx_rdy;
						end if;
					end if;
					lat1 := (tpa_frm or tpa_irdy);
				end if;
			end process;
		end block;
	end block;

	tx_b : block
		signal spatx_frm   : std_logic;
		signal spatx_irdy  : std_logic;
		signal spatx_trdy  : std_logic;
		signal spatx_data  : std_logic_vector(arptx_data'range);
	begin
		ethtyptx_i : entity hdl4fpga.sio_rom
		generic map (
			bitdata => reverse(hdo(frames)**".data.mac.type.arp",8))
		port map (
			so_clk  => miitx_clk,
			so_frm  => ethtyptx_frm,
			so_irdy => ethtyptx_irdy,
			so_trdy => ethtyptx_trdy,
			so_data => ethtyptx_data);

		thatx_i : entity hdl4fpga.sio_rom
		generic map (
			bitdata => reverse(x"ff_ff_ff_ff_ff_ff", 8))
		port map (
			so_clk  => miitx_clk,
			so_frm  => thatx_frm,
			so_irdy => thatx_irdy,
			so_trdy => thatx_trdy,
			so_data => thatx_data);

		spatx_e : entity hdl4fpga.sio_ram
		generic map (
			bitdata => reverse(ipv4addr,8))
		port map (
			si_clk  => miirx_clk,
			si_data => arprx_data,
		
			so_clk  => miitx_clk,
			so_frm  => spatx_frm,
			so_irdy => spatx_irdy,
			so_trdy => spatx_trdy,
			so_data => spatx_data);

		arptx_e : entity hdl4fpga.arp_tx
		generic map (
			sha      => hwaddr)
		port map (
			mii_clk  => miitx_clk,
			tx_req   => tx_req,
			tx_rdy   => tx_rdy,

			pa_frm   => spatx_frm,
			pa_irdy  => spatx_irdy,
			pa_trdy  => spatx_trdy,
			pa_data  => spatx_data,

			arp_frm  => arptx_frm,
			arp_irdy => arptx_irdy,
			arp_trdy => arptx_trdy,
			arp_data => arptx_data);
	end block;

end;
