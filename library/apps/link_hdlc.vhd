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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.ecp5_profiles.all;

library ecp5u;
use ecp5u.components.all;

entity link_hdlc is
	generic (
		uart_freq : real;
		baudrate : natural;
		mem_size : natural := 8*(1024*8));
	port (
    	sio_clk   : in  std_logic;
    	si_frm    : in  std_logic;
    	si_irdy   : in  std_logic;
    	si_trdy   : out std_logic;
    	si_end    : in  std_logic;
    	si_data   : in  std_logic_vector(0 to 8-1);

    	so_frm    : out std_logic;
    	so_irdy   : out std_logic;
    	so_trdy   : in  std_logic;
    	so_data   : out std_logic_vector(0 to 8-1);
		uart_frm  : in  std_logic := '1';
		uart_sin  : in  std_logic;
		uart_sout : out std_logic);
end;

architecture def of link_hdlc is

	signal uart_rxdv  : std_logic;
	signal uart_rxd   : std_logic_vector(0 to 8-1);
	signal uarttx_frm : std_logic;
	signal uart_idle  : std_logic;
	signal uart_txen  : std_logic;
	signal uart_txd   : std_logic_vector(uart_rxd'range);

	signal tp         : std_logic_vector(1 to 32);

	signal dummy_txd  : std_logic_vector(uart_rxd'range);
	alias uart_clk    : std_logic is sio_clk;

	constant uart_baudrate : natural := setif(baudrate=0,
		setif(
			uart_freq >= 32.0e6, 3000000, setif(
			uart_freq >= 25.0e6, 2000000, 115200)),
		baudrate);
begin

	assert FALSE
	report CR & 
		"BAUDRATE : " & " " & natural'image(uart_baudrate)
	severity NOTE;

	uartrx_e : entity hdl4fpga.uart_rx
	generic map (
		baudrate => uart_baudrate,
		clk_rate => uart_freq)
	port map (
		uart_rxc  => uart_clk,
		uart_sin  => uart_sin,
		uart_irdy => uart_rxdv,
		uart_data => uart_rxd);

	uarttx_e : entity hdl4fpga.uart_tx
	generic map (
		baudrate => uart_baudrate,
		clk_rate => uart_freq)
	port map (
		uart_txc  => uart_clk,
		uart_frm  => uart_frm,
		uart_irdy => uart_txen,
		uart_trdy => uart_idle,
		uart_data => uart_txd,
		uart_sout => uart_sout);

	siodaahdlc_e : entity hdl4fpga.sio_dayhdlc
	generic map (
		mem_size    => mem_size)
	port map (
		uart_clk    => uart_clk,
		uartrx_irdy => uart_rxdv,
		uartrx_data => uart_rxd,
		uarttx_frm  => uarttx_frm,
		uarttx_trdy => uart_idle,
		uarttx_data => uart_txd,
		uarttx_irdy => uart_txen,
		sio_clk     => sio_clk,
		so_frm      => so_frm,
		so_irdy     => so_irdy,
		so_trdy     => so_trdy,
		so_data     => so_data,

		si_frm      => si_frm,
		si_irdy     => si_irdy,
		si_trdy     => si_trdy,
		si_end      => si_end,
		si_data     => si_data,
		tp          => tp);

end;
