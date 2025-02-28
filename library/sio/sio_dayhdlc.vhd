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

entity sio_dayhdlc is
	generic (
		mem_size    : natural := 4*(2048*8));
	port (
		uart_clk    : in  std_logic;
		uartrx_irdy : in  std_logic;
		uartrx_data : in  std_logic_vector;

		uarttx_frm  : out std_logic;
		uarttx_irdy : out std_logic;
		uarttx_trdy : in  std_logic;
		uarttx_data : out std_logic_vector;

		sio_clk     : in std_logic;
		sio_addr    : in  std_logic := '0';

		si_frm      : in  std_logic := '0';
		si_irdy     : in  std_logic := '1';
		si_trdy     : out std_logic;
		si_end      : in  std_logic;
		si_data     : in  std_logic_vector;

		so_frm      : out std_logic;
		so_irdy     : out std_logic;
		so_trdy     : in  std_logic := '1';
		so_data     : out std_logic_vector;
		tp          : out std_logic_vector(1 to 32));

end;

architecture beh of sio_dayhdlc is

	signal sihdlc_frm  : std_logic;
	signal sihdlc_trdy : std_logic;
	signal sihdlc_irdy : std_logic;
	signal sihdlc_end  : std_logic;
	signal sihdlc_data : std_logic_vector(so_data'range);

	signal sohdlc_frm  : std_logic;
	signal sohdlc_trdy : std_logic;
	signal sohdlc_irdy : std_logic;
	signal sohdlc_data : std_logic_vector(so_data'range);

begin

	sihdlc_frm  <= si_frm  when sio_addr='0' else '0';
	sihdlc_irdy <= si_irdy when sio_addr='0' else '0';
	si_trdy     <= sihdlc_trdy when sio_addr='0' else so_trdy;
	sihdlc_end  <= si_end  when sio_addr='0' else '0';
	sihdlc_data <= si_data;

	siohdlc_e : entity hdl4fpga.sio_hdlc
	generic map (
		mem_size    => mem_size)
	port map (
		uart_clk  => uart_clk,

		uartrx_irdy => uartrx_irdy,
		uartrx_data => uartrx_data,

		uarttx_frm  => uarttx_frm,
		uarttx_irdy => uarttx_irdy,
		uarttx_trdy => uarttx_trdy,
		uarttx_data => uarttx_data,

		sio_clk   => sio_clk,
		si_frm    => sihdlc_frm,
		si_irdy   => sihdlc_irdy,
		si_trdy   => sihdlc_trdy,
		si_end    => sihdlc_end,
		si_data   => sihdlc_data,

		so_frm    => sohdlc_frm,
		so_irdy   => sohdlc_irdy,
		so_trdy   => sohdlc_trdy,
		so_data   => sohdlc_data,
		tp => tp);

	so_frm  <= si_frm  when sio_addr/='0' else sohdlc_frm;
	so_irdy <= si_irdy when sio_addr/='0' else sohdlc_irdy;
	sohdlc_trdy <= si_irdy when sio_addr/='0' else so_trdy;
	so_data <= si_data when sio_addr/='0' else sohdlc_data;

end;



