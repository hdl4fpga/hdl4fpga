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

entity arp_rx is
	port (
		mii_clk   : in  std_logic;
		arp_frm   : in  std_logic;
		arp_irdy  : in  std_logic;
		arp_data  : in  std_logic_vector;

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
		per_frm    : buffer std_logic := '0';
		per_irdy   : out std_logic := '0';
		per_trdy   : in  std_logic := '1';
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

architecture def of arp_rx is
begin

	decode_i : entity hdl4fpga.frame_decode
	generic map (
		frame => hdo(frames)**".format.arp",
		size  => arp_data'length)
	port map (
		clk     => mii_clk,
		frm     => arp_frm,
		irdy    => arp_irdy,
		act(0)  => htype_frm,
		act(1)  => ptype_frm,
		act(2)  => hlen_frm,
		act(3)  => plen_frm,
		act(4)  => per_frm,
		act(5)  => sha_frm,
		act(6)  => spa_frm,
		act(7)  => tha_frm,
		act(8)  => tpa_frm,
		act(9)  => pyl_frm);

end;
