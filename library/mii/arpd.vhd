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

		upspa_frm     : in std_logic;
		upspa_irdy    : in std_logic;
		upspa_trdy    : in std_logic := '1';
		upspa_data    : in std_logic_vector;

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
		arptx_irdy    : buffer std_logic := '0';
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
		signal pyl_frm  : std_logic;
		signal discard  : std_logic;
	begin

		decode_i : entity hdl4fpga.frame_decode
		generic map (
			frame => compact('{' &
				"discard:" & natural'image(
					hdo(frames)**".format.arp.htype" +
					hdo(frames)**".format.arp.ptype" +
					hdo(frames)**".format.arp.hlen"  +
					hdo(frames)**".format.arp.plen"  +
					hdo(frames)**".format.arp.oper"  +
					hdo(frames)**".format.arp.sha"   +
					hdo(frames)**".format.arp.spa"   +
					hdo(frames)**".format.arp.tha")  & ',' &
				"    tpa:" & string'(hdo(frames)**".format.arp.tpa") & '}'),
			size  => arprx_data'length)
		port map (
			clk    => miirx_clk,
			frm    => arprx_frm,
			irdy   => arprx_irdy,
			act(0) => discard,
			act(1) => tpa_frm,
			act(2) => pyl_frm);

		tpacmp_b : block
			signal tpa_equ : std_logic;
		begin
			ipsa_i : entity hdl4fpga.sio_ram
			generic map (
				bitdata => reverse(ipv4addr,8))
			port map (
				si_clk  => miirx_clk,
				si_frm  => upspa_frm,
				si_irdy => upspa_irdy,
				si_trdy => open,
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
		signal rom_frm : std_logic;
		signal rom_irdy : std_logic;
		signal rom_trdy    : std_logic;
		signal rom_data    : std_logic_vector(arptx_data'range);

		signal spa_frm : std_logic;
		signal tpa_frm : std_logic;
		signal tha_frm : std_logic;
		alias tha_irdy is tha_frm;
		constant tha_data : std_logic_vector := (arptx_data'range => '1');

		signal pyl_frm : std_logic;

		signal decode_frm  : std_logic;
		signal decode_irdy : std_logic;
		signal decode_trdy : std_logic;
		signal decode_last : std_logic;
		signal decode_data : std_logic_vector(arptx_data'range);

		signal pa_frm   : std_logic;
		signal pa_irdy  : std_logic;
		signal pa_trdy  : std_logic;
		signal pa_data  : std_logic_vector(arptx_data'range);

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

		spa_e : entity hdl4fpga.sio_ram
		generic map (
			bitdata => reverse(ipv4addr,8))
		port map (
			si_clk  => miirx_clk,
			si_data => arprx_data,
		
			so_clk  => miitx_clk,
			so_frm  => pa_frm,
			so_irdy => pa_irdy,
			so_trdy => pa_trdy,
			so_data => pa_data);

		process (miitx_clk)
		begin
			if rising_edge(miitx_clk) then
				if (tx_rdy xor tx_req)='1' then
					if (decode_last and not arptx_frm and arptx_irdy and arptx_trdy)='1' then
						tx_rdy <= tx_req;
						decode_frm <= '0';
					else
						decode_frm <= '1';
					end if;
				else
					decode_frm <= '0';
				end if;
			end if;
		end process;

		decode_i : entity hdl4fpga.frame_decode
		generic map (
			frame => '{'                                             &
				"    rom:" & natural'image(
					hdo(frames)**".format.arp.htype" +
					hdo(frames)**".format.arp.ptype" +
					hdo(frames)**".format.arp.hlen"  +
					hdo(frames)**".format.arp.plen"  +
					hdo(frames)**".format.arp.oper"  +
					hdo(frames)**".format.arp.sha")                  & ',' &
				"    spa:" & string'(hdo(frames)**".format.arp.spa") & ',' &
				"    tha:" & string'(hdo(frames)**".format.arp.tha") & ',' &
				"    tpa:" & string'(hdo(frames)**".format.arp.tpa") & '}',
			size  => arptx_data'length)
		port map (
			clk    => miitx_clk,
			frm    => decode_frm,
			irdy   => decode_irdy,
			last   => decode_last,
			act(0) => rom_frm,
			act(1) => spa_frm,
			act(2) => tha_frm,
			act(3) => tpa_frm,
			act(4) => pyl_frm);
		pa_frm  <= spa_frm or tpa_frm;
		pa_irdy <= spa_frm or tpa_frm;

		decode_irdy <= 
			tha_irdy and decode_trdy when tha_frm='1' else
			pa_irdy  and decode_trdy when  pa_frm='1' else
			rom_irdy and decode_trdy when rom_frm='1' else
			tha_irdy and decode_trdy when tha_frm='1' else
			'0';

		rom_irdy <= 
			decode_trdy when rom_frm='1' else
			'0';

		rom_i : entity hdl4fpga.sio_rom
		generic map (
			bitdata => reverse(
				std_logic_vector'(hdo(frames)**".data.arp.htype")      &
				std_logic_vector'(hdo(frames)**".data.arp.ptype")      &
				std_logic_vector'(hdo(frames)**".data.arp.hlen")       &
				std_logic_vector'(hdo(frames)**".data.arp.plen")       &
				std_logic_vector'(hdo(frames)**".data.arp.oper.reply") &
				hwaddr,8))
		port map (
			so_clk  => miitx_clk,
			so_frm  => rom_frm,
			so_irdy => rom_irdy,
			so_trdy => rom_trdy,
			so_data => rom_data);

		decode_data <= 
			rom_data when rom_frm='1' else
			pa_data  when  pa_frm='1' else
			tha_data when tha_frm='1' else
			(decode_data'range => '-');

		buffer_b : block
			signal buffer_frm : std_logic;
		begin
			buffer_frm  <= decode_frm and not decode_last;
			buffer_i : entity hdl4fpga.mii_buffer
			port map (
				clk => miitx_clk,
				src_frm  => buffer_frm,
				src_irdy => decode_irdy,
				src_trdy => decode_trdy,
				src_data => decode_data,
				dst_frm  => arptx_frm,
				dst_irdy => arptx_irdy,
				dst_trdy => arptx_trdy,
				dst_data => arptx_data);
		end block;

	end block;

end;
