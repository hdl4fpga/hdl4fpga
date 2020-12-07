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
use hdl4fpga.std.all;

entity sio_ahdlc is
	port (
		uart_clk  : in  std_logic;
		uart_rxdv : in  std_logic;
		uart_rxd  : in  std_logic_vector;

		sio_clk   : in  std_logic;
		so_frm    : out std_logic;
		so_irdy   : out std_logic;
		so_trdy   : in  std_logic;
		so_data   : out std_logic_vector);

end;

architecture def of sio_ahdlc is

	constant ccitt_residue : std_logic_vector := not x"1d0f";

	signal ahdlc_frm  : std_logic;
	signal ahdlc_irdy : std_logic;
	signal ahdlc_data : std_logic_vector(so_data'range);
	signal ahdlc_crc  : std_logic_vector(ccitt_residue'range);

	signal buffer_cmmt : std_logic;
	signal buffer_rlk  : std_logic;
	signal buffer_ovfl : std_logic;

begin

	ahdlc_e : entity hdl4fpga.ahdlc_rx
	port map (
		clk        => uart_clk,

		uart_rxdv  => uart_rxdv,
		uart_rxd   => uart_rxd,

		ahdlc_frm  => ahdlc_frm,
		ahdlc_irdy => ahdlc_irdy,
		ahdlc_data => ahdlc_data);

	llc_b : block
		signal crc_init : std_logic;
		signal crc_sero : std_logic;
		signal crc_ena  : std_logic;
		signal crc      : std_logic_vector(16-1 downto 0);
	begin
		crc_init <= not ahdlc_frm;
		crc_ena  <= (ahdlc_frm and ahdlc_irdy) or not ahdlc_frm;
		crc_ccitt_e : entity hdl4fpga.crc
		generic map (
			g => x"1021")
		port map (
			clk  => uart_clk,
			init => crc_init,
			ena  => crc_ena,
			data => ahdlc_data,
			crc  => crc);

--		buffer_cmmt <= '1' when ahdlc_frm='0' and ahdlc_crc =ccitt_residue else '0';
--		buffer_rlk  <= '1' when ahdlc_frm='0' and ahdlc_crc/=ccitt_residue else '0';
--
	end block;

	buffer_e : entity hdl4fpga.sio_buffer
	port map (
		si_clk    => uart_clk,
		si_frm    => ahdlc_frm,
		si_irdy   => ahdlc_irdy,
		si_data   => ahdlc_data,

		rollback  => buffer_rlk,
		commit    => buffer_cmmt,
		overflow  => buffer_ovfl,

		so_clk    => sio_clk,
		so_frm    => so_frm,
		so_irdy   => so_irdy,
		so_trdy   => so_trdy,
		so_data   => so_data);

end;
