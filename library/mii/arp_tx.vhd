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
	signal htype_frm   : std_logic;
	signal htype_irdy  : std_logic;
	signal ptype_frm   : std_logic;
	signal ptype_irdy  : std_logic;
	signal hlen_frm    : std_logic;
	signal hlen_irdy   : std_logic;
	signal plen_frm    : std_logic;
	signal plen_irdy   : std_logic;
	signal oper_frm    : std_logic;
	signal oper_irdy   : std_logic;
	signal sha_frm     : std_logic;
	signal sha_irdy    : std_logic;
	signal spa_frm     : std_logic;
	signal spa_irdy    : std_logic;
	signal tha_frm     : std_logic;
	signal tha_irdy    : std_logic;
	signal tha_trdy    : std_logic;
	signal tha_data    : std_logic_vector(arp_data'range);
	signal tpa_frm     : std_logic;
	signal tpa_irdy    : std_logic;

	signal decode_frm  : std_logic;
	signal decode_irdy : std_logic;
	signal decode_trdy : std_logic;
	signal decode_last : std_logic;
	signal decode_fin  : std_logic;
	signal decode_data : std_logic_vector(arp_data'range);

	alias  rom_frm is decode_frm;
	signal rom_irdy    : std_logic;
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

	decode_trdy <= arp_trdy or not arp_irdy;
	decode_i : entity hdl4fpga.arp_decode
	port map (
		mii_clk    => mii_clk,
		arp_frm    => decode_frm,
		arp_irdy   => decode_irdy,
		arp_data   => decode_data,
		arp_last   => decode_last,
		arp_fin    => decode_fin,
		htype_frm  => htype_frm,
		htype_irdy => htype_irdy,
		htype_trdy => decode_trdy,
		ptype_frm  => ptype_frm,
		ptype_irdy => ptype_irdy,
		ptype_trdy => decode_trdy,
		hlen_frm   => hlen_frm ,
		hlen_irdy  => hlen_irdy,
		hlen_trdy  => decode_trdy,
		plen_frm   => plen_frm,
		plen_irdy  => plen_irdy,
		plen_trdy  => decode_trdy,
		oper_frm   => oper_frm,
		oper_irdy  => oper_irdy,
		oper_trdy  => decode_trdy,
		sha_frm    => sha_frm,
		sha_irdy   => sha_irdy,
		sha_trdy   => decode_trdy,
		spa_frm    => spa_frm,
		spa_irdy   => spa_irdy,
		spa_trdy   => pa_trdy,
		tha_frm    => tha_frm,
		tha_irdy   => tha_irdy,
		tha_trdy   => decode_trdy,
		tpa_frm    => tpa_frm,
		tpa_irdy   => tpa_irdy,
		tpa_trdy   => pa_trdy);

	pa_frm  <= spa_frm or tpa_frm;
	pa_irdy <= 
		spa_irdy when spa_frm='1' else 
		tpa_irdy when tpa_frm='1' else 
		'0';

	rom_irdy <= 
		decode_trdy and htype_irdy when htype_frm='1' else 
		decode_trdy and ptype_irdy when ptype_frm='1' else 
		decode_trdy and hlen_irdy  when  hlen_frm='1' else 
		decode_trdy and plen_irdy  when  plen_frm='1' else 
		decode_trdy and oper_irdy  when  oper_frm='1' else 
		decode_trdy and sha_irdy   when   sha_frm='1' else 
		decode_trdy and tha_irdy   when   tha_frm='1' else 
		'0';

	rom_i : entity hdl4fpga.sio_rom
	generic map (
		bitdata => reverse(
			std_logic_vector'(hdo(frames)**".data.arp.htype")      &
			std_logic_vector'(hdo(frames)**".data.arp.ptype")      &
			std_logic_vector'(hdo(frames)**".data.arp.hlen")       &
			std_logic_vector'(hdo(frames)**".data.arp.plen")       &
			std_logic_vector'(hdo(frames)**".data.arp.oper.reply") &
			sha                                                    &
			x"ff_ff_ff_ff_ff_ff", 8)) -- Target Hardware Address
	port map (
        so_clk  => mii_clk,
		so_frm  => decode_frm,
		so_irdy => rom_irdy,
		so_trdy => rom_trdy,
		so_data => rom_data);

	tha_trdy <= tha_frm and tha_irdy;
	tha_data <= (arp_data'range => '1');
	decode_irdy <= 
		tha_irdy when  tha_frm='1' else
		pa_irdy  when   pa_frm='1' else
		rom_trdy when rom_irdy='1' else
		decode_frm;

	decode_data <= 
		tha_data when tha_frm='1' else
		pa_data  when  pa_frm='1' else
		rom_data;

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if (decode_irdy and arp_trdy)='1' then
				arp_data <= decode_data;
			elsif (decode_irdy and not arp_irdy)='1'then
				arp_data <= decode_data;
			end if;

			if (not arp_frm and (arp_irdy and arp_trdy))='1' then
				arp_irdy <= '0';
			elsif not decode_last='1' then
				arp_irdy <= decode_irdy;
			end if;

			if decode_frm='0' then
				arp_frm <= '0';
			else
				arp_frm <= decode_frm and not decode_last;
			end if;
		end if;
	end process;

end;
