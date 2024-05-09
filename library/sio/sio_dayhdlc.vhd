--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

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
