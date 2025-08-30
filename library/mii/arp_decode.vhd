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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.ipoepkg.all;

entity arp_decode is
	port (
		mii_clk    : in  std_logic;
		arp_frm    : in  std_logic := '0';
		arp_irdy   : in  std_logic := '0';
		arp_trdy   : buffer std_logic := '0';
		arp_data   : in  std_logic_vector;
		arp_last   : out std_logic := '0';
		arp_fin    : out std_logic := '0';

		htype_frm  : buffer std_logic := '0';
		htype_irdy : out std_logic := '0';
		htype_trdy : in  std_logic := '1';
		ptype_frm  : buffer std_logic := '0';
		ptype_irdy : out std_logic := '0';
		ptype_trdy : in  std_logic := '1';
		hlen_frm   : buffer std_logic := '0';
		hlen_irdy  : out std_logic := '0';
		hlen_trdy  : in  std_logic := '1';
		plen_frm   : buffer std_logic := '0';
		plen_irdy  : out std_logic := '0';
		plen_trdy  : in  std_logic := '1';
		oper_frm   : buffer std_logic := '0';
		oper_irdy  : out std_logic := '0';
		oper_trdy  : in  std_logic := '1';
		sha_frm    : buffer std_logic := '0';
		sha_irdy   : out std_logic := '0';
		sha_trdy   : in  std_logic := '1';
		spa_frm    : buffer std_logic := '0';
		spa_irdy   : out std_logic := '0';
		spa_trdy   : in  std_logic := '1';
		tha_frm    : buffer std_logic := '0';
		tha_irdy   : out std_logic := '0';
		tha_trdy   : in  std_logic := '1';
		tpa_frm    : buffer std_logic := '0';
		tpa_irdy   : out std_logic := '0';
		tpa_trdy   : in  std_logic := '1';
		pyl_frm    : buffer std_logic := '0';
		pyl_irdy   : out std_logic := '0';
		pyl_trdy   : in  std_logic := '1');
end;

architecture def of arp_decode is
	signal irdy : std_logic;
begin

	irdy <= arp_irdy and arp_trdy;
	decode_i : entity hdl4fpga.frame_decode
	generic map (
		frame => hdo(frames)**".format.arp",
		size  => arp_data'length)
	port map (
		clk     => mii_clk,
		frm     => arp_frm,
		irdy    => irdy,
		last    => arp_last,
		fin     => arp_fin,
		act(0)  => htype_frm,
		act(1)  => ptype_frm,
		act(2)  => hlen_frm,
		act(3)  => plen_frm,
		act(4)  => oper_frm,
		act(5)  => sha_frm,
		act(6)  => spa_frm,
		act(7)  => tha_frm,
		act(8)  => tpa_frm,
		act(9)  => pyl_frm);

	htype_irdy <= htype_frm;
	ptype_irdy <= ptype_frm;
	hlen_irdy  <= hlen_frm;
	plen_irdy  <= plen_frm;
	oper_irdy  <= oper_frm;
	sha_irdy   <= sha_frm;
	spa_irdy   <= spa_frm;
	tha_irdy   <= tha_frm;
	tpa_irdy   <= tpa_frm;
	pyl_irdy   <= pyl_frm;

	arp_trdy <= 
    	htype_trdy when htype_frm='1' else 
    	ptype_trdy when ptype_frm='1' else 
    	hlen_trdy  when  hlen_frm='1' else 
    	plen_trdy  when  plen_frm='1' else 
    	oper_trdy  when  oper_frm='1' else 
    	sha_trdy   when   sha_frm='1' else 
    	spa_trdy   when   spa_frm='1' else 
    	tha_trdy   when   tha_frm='1' else 
    	tpa_trdy   when   tpa_frm='1' else 
    	pyl_trdy   when   pyl_frm='1' else
		'0';

end;
