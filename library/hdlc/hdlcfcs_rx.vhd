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

entity hdlcfcs_rx is
	port (
		fcs_g       : in  std_logic_vector := std_logic_vector'(x"1021");
		fcs_rem     : in  std_logic_vector := std_logic_vector'(x"1d0f");

		uart_clk    : in  std_logic;

		hdlcrx_frm  : in  std_logic;
		hdlcrx_irdy : in  std_logic;
		hdlcrx_trdy : out std_logic := '1';
		hdlcrx_end  : in  std_logic;
		hdlcrx_data : in  std_logic_vector;

		fcs_sb      : out std_logic;
		fcs_vld     : out std_logic);
end;

architecture def of hdlcfcs_rx is

	signal crc_frm : std_logic;
	signal crc      : std_logic_vector(fcs_rem'range);

begin

	crc_frm <= to_stdulogic(to_bit(hdlcrx_frm));
	crc_e : entity hdl4fpga.crc
	port map (
		g    => fcs_g,
		clk  => uart_clk,
		frm  => crc_frm,
		irdy => hdlcrx_irdy,
		data => hdlcrx_data,
		crc  => crc);

	fcs_sb  <= hdlcrx_frm and hdlcrx_end and hdlcrx_irdy;
	fcs_vld <= setif(crc=not fcs_rem);

end;



