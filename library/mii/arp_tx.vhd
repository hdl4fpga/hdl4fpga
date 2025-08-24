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
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;

entity arp_tx is
	generic (
		mac_sa   : std_logic_vector(0 to 48-1));
	port (
		mii_clk  : in  std_logic;
		arp_req  : in  std_logic;
		arp_rdy  : buffer std_logic;
		
		pa_frm     : out std_logic;
		pa_irdy    : out std_logic;
		pa_trdy    : in  std_logic;
		pa_data    : in  std_logic_vector;

		ethda_frm  : in  std_logic;
		ethda_irdy : in  std_logic;
		ethda_trdy : out std_logic;
		ethda_data : out std_logic_vector;

		arp_frm  : buffer std_logic;
		arp_irdy : buffer std_logic;
		arp_trdy : in  std_logic;
		arp_data : out std_logic_vector);

end;

architecture def of arp_tx is
	signal htype_frm  : std_logic;
	signal htype_irdy : std_logic;
	signal ptype_frm  : std_logic;
	signal ptype_irdy : std_logic;
	signal hlen_frm   : std_logic;
	signal hlen_irdy  : std_logic;
	signal plen_frm   : std_logic;
	signal plen_irdy  : std_logic;
	signal oper_frm   : std_logic;
	signal oper_irdy  : std_logic;
	signal sha_frm    : std_logic;
	signal sha_irdy   : std_logic;
	signal spa_frm    : std_logic;
	signal spa_irdy   : std_logic;
	signal tha_frm    : std_logic;
	signal tha_irdy   : std_logic;
	signal tpa_frm    : std_logic;
	signal tpa_irdy   : std_logic;

begin

	arp_frm <= to_stdulogic(to_bit(arp_rdy) xor to_bit(arp_req));
	decode_i : entity hdl4fpga.arp_decode
	port map (
		mii_clk    => mii_clk,
		arp_frm    => arp_frm,
		arp_irdy   => arp_irdy,
		arp_data   => arp_data,
		htype_frm  => htype_frm ,
		htype_irdy => htype_irdy,
		htype_trdy => arp_trdy,
		ptype_frm  => ptype_frm,
		ptype_irdy => ptype_irdy,
		ptype_trdy => arp_trdy,
		hlen_frm   => hlen_frm ,
		hlen_irdy  => hlen_irdy,
		hlen_trdy  => arp_trdy,
		plen_frm   => plen_frm,
		plen_irdy  => plen_irdy,
		plen_trdy  => arp_trdy,
		oper_frm   => oper_frm,
		oper_irdy  => oper_irdy,
		oper_trdy  => arp_trdy,
		sha_frm    => sha_frm,
		sha_irdy   => sha_irdy,
		sha_trdy   => arp_trdy,
		spa_frm    => spa_frm,
		spa_irdy   => spa_irdy,
		spa_trdy   => arp_trdy,
		tha_frm    => tha_frm,
		tha_irdy   => tha_irdy,
		tha_trdy   => arp_trdy,
		tpa_frm    => tpa_frm,
		tpa_irdy   => tpa_irdy,
		tpa_trdy   => arp_trdy);
	pa_frm  <= spa_frm  or tpa_frm;
	pa_irdy <= 
    	spa_irdy   when   spa_frm='1' else 
    	tpa_irdy   when   tpa_frm='1' else 

	so_irdy <= 
    	htype_trdy when htype_frm='1' else 
    	ptype_trdy when ptype_frm='1' else 
    	hlen_trdy  when  hlen_frm='1' else 
    	plen_trdy  when  plen_frm='1' else 
    	oper_trdy  when  oper_frm='1' else 
    	sha_trdy   when   sha_frm='1' else 
    	tha_trdy   when   tha_frm='1' else 
    	pyl_trdy   when   pyl_frm='1' else
		'0';

	mem_i : entity hdl4fpga.sio_rom
	generic map (
		bitdata =>
			x"0001" &                 -- htype 
			x"0800" &                 -- ptype 
			x"06"   &                 -- hlen  
			x"04"   &                 -- plen  
			x"0002" &                 -- oper  
			mac_sa  &                 -- Sender Hardware Address
			x"ff_ff_ff_ff_ff_ff", 8), -- Target Hardware Address
	port map (
        so_clk  => mii_clk,
		so_frm  => arp_frm,
		so_irdy => so_irdy,
		so_trdy => so_trdy,
		so_data => so_data);

	dlltx_irdy <= arp_frm and arp_trdy;
	dlltx_data <= (arp_data'range => '1');
	arp_irdy   <= 
		arp_frm     when dlltx_end='0' else
		arpmux_trdy when    pa_frm='0' else 
		pa_trdy;
	arp_data   <= 
		dlltx_data  when dlltx_end='0' else
		arpmux_data when    pa_frm='0' else
		pa_data;

end;
