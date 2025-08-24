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

entity udp_rx is
	port (
		mii_clk     : in  std_logic;
		udp_frm     : in  std_logic;
		udp_irdy    : in  std_logic;
		udp_data    : in  std_logic_vector;

		sp_frm      : buffer std_logic := '0';
		sp_irdy     : out std_logic := '0';
		sp_trdy     : in  std_logic := '1';
		dp_frm      : buffer std_logic := '0';
		dp_irdy     : out std_logic := '0';
		dp_trdy     : in  std_logic := '1';
		length_frm  : buffer std_logic := '0';
		length_irdy : out std_logic := '0';
		length_trdy : in  std_logic := '1';
		chksum_frm  : buffer std_logic := '0';
		chksum_irdy : out std_logic := '0';
		chksum_trdy : in  std_logic := '1';
		pyl_frm     : buffer std_logic := '0';
		pyl_irdy    : out std_logic := '0';
		pyl_trdy    : in  std_logic := '1');
end;

architecture def of udp_rx is
begin
					
	decode_i : entity hdl4fpga.frame_decode
	generic map (
		frame => hdo(frames)**".format.udp",
		size  => udp_data'length)
	port map (
		clk     => mii_clk,
		frm     => udp_frm,
		irdy    => udp_irdy,
		act(0)  => sp_frm,
		act(1)  => dp_frm,
		act(2)  => length_frm,
		act(3)  => chksum_frm,
		act(4)  => pyl_frm);

	sp_irdy     <= sp_frm;
	dp_irdy     <= dp_frm;
	length_irdy <= length_frm;
	chksum_irdy <= chksum_frm;
	pyl_irdy    <= pyl_frm;

end;
