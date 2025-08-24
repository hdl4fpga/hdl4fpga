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

entity icmp_rx is
	port (
		mii_clk      : in  std_logic;
		icmp_frm     : in  std_logic := '0';
		icmp_irdy    : in  std_logic := '0';
		icmp_data    : in  std_logic_vector;

		type_frm    : buffer std_logic := '0';
		type_irdy   : out std_logic := '0';
		type_trdy   : in  std_logic := '1';
		code_frm    : buffer std_logic := '0';
		code_irdy   : out std_logic := '0';
		code_trdy   : in  std_logic := '1';
		chksum_frm  : buffer std_logic := '0';
		chksum_irdy : out std_logic := '0';
		chksum_trdy : in  std_logic := '1';
		id_frm      : buffer std_logic := '0';
		id_irdy     : out std_logic := '0';
		id_trdy     : in  std_logic := '1';
		seq_frm     : buffer std_logic := '0';
		seq_irdy    : out std_logic := '0';
		seq_trdy    : in  std_logic := '1';
		pyl_frm     : buffer std_logic := '0';
		pyl_irdy    : out std_logic := '0';
		pyl_trdy    : in  std_logic := '1');
end;

architecture def of icmp_rx is
begin

	decode_i : entity hdl4fpga.frame_decode
	generic map (
		frame => hdo(frames)**".format.icmp",
		size  => icmp_data'length)
	port map (
		clk     => mii_clk,
		frm     => icmp_frm,
		irdy    => icmp_irdy,
		act(0)  => type_frm,
		act(1)  => code_frm,
		act(2)  => chksum_frm,
		act(3)  => id_frm,
		act(4)  => seq_frm,
		act(5)  => pyl_frm);

		type_irdy   <= type_frm;
		code_irdy   <= code_frm;
		chksum_irdy <= chksum_frm;
		id_irdy     <= id_frm;
		seq_irdy    <= seq_frm;
		pyl_irdy    <= pyl_frm;
end;
