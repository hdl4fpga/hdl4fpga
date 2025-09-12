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

entity arp_tx is
	generic (
		sha      : std_logic_vector(0 to 48-1));
	port (
		mii_clk  : in  std_logic;
		
		tx_req   : in  std_logic := '0';
		tx_rdy   : buffer std_logic := '0';

		pa_frm   : buffer std_logic := '0';
		pa_irdy  : buffer std_logic := '0';
		pa_trdy  : in  std_logic := '0';
		pa_data  : in  std_logic_vector;

		arp_frm  : buffer std_logic := '0';
		arp_irdy : buffer std_logic := '0';
		arp_trdy : in  std_logic := '1';
		arp_data : buffer std_logic_vector);
end;

architecture def of arp_tx is
	signal rom_frm : std_logic;
	alias rom_irdy is rom_frm;
	signal spa_frm : std_logic;
	signal tpa_frm : std_logic;
	signal tha_frm : std_logic;
	alias tha_irdy is tha_frm;
	constant tha_data : std_logic_vector := (arp_data'range => '1');
	signal pyl_frm : std_logic;

	signal decode_frm  : std_logic;
	signal decode_irdy : std_logic;
	signal decode_trdy : std_logic;
	signal decode_last : std_logic;
	signal decode_data : std_logic_vector(arp_data'range);

	signal rom_trdy    : std_logic;
	signal rom_data    : std_logic_vector(arp_data'range);

begin

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if (tx_rdy xor tx_req)='1' then
				if (decode_last and not arp_frm and arp_irdy and arp_trdy)='1' then
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
		size  => arp_data'length)
	port map (
		clk    => mii_clk,
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
			sha,8))
	port map (
        so_clk  => mii_clk,
		so_frm  => rom_frm,
		so_irdy => rom_irdy,
		so_trdy => rom_trdy,
		so_data => rom_data);

	decode_data <= 
		rom_data when rom_frm='1' else
		pa_data  when  pa_frm='1' else
		tha_data when tha_frm='1' else
		(others => '-');

	buffer_b : block
		signal buffer_frm : std_logic;
	begin
		buffer_frm  <= decode_frm and not decode_last;
		buffer_i : entity hdl4fpga.mii_buffer
		port map (
			clk => mii_clk,
			src_frm  => buffer_frm,
			src_irdy => decode_irdy,
			src_trdy => decode_trdy,
			src_data => decode_data,
			dst_frm  => arp_frm,
			dst_irdy => arp_irdy,
			dst_trdy => arp_trdy,
			dst_data => arp_data);
	end block;

end;
