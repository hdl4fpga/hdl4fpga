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

entity hdlcdll_tx is
	port (
		fcs_g       : in  std_logic_vector := x"1021";
		fcs_rem     : in  std_logic_vector := x"1d0f";

		uart_clk    : in  std_logic;
		uart_idle   : in  std_logic;
		uart_txen   : out std_logic;
		uart_txd    : out std_logic_vector;

		hdlctx_frm  : in  std_logic;
		hdlctx_irdy : in  std_logic;
		hdlctx_trdy : buffer std_logic;
		hdlctx_data : in  std_logic_vector);

end;

architecture def of hdlcdll_tx is

	signal fcs_frm  : std_logic;
	signal fcs_data : std_logic_vector(hdlctx_data'range);
	signal fcs_irdy : std_logic;
	signal fcs_trdy : std_logic;

	signal crc_init : std_logic;
	signal crc_sero : std_logic;
	signal crc_ena  : std_logic;
	signal crc      : std_logic_vector(0 to 16-1);
	signal cy       : std_logic;

begin

	cntr_p : process (uart_clk)
		variable cntr : unsigned(0 to unsigned_num_bits(crc'length/fcs_data'length-1));
	begin
		if rising_edge(uart_clk) then
			if fcs_trdy='1' then
				if crc_sero='0' then
					if hdlctx_frm='1' then
						cntr := to_unsigned(crc'length/hdlctx_data'length-1, cntr'length);
					end if;
				elsif cy='0' then
					cntr := cntr - 1;
				end if;
			end if;
			cy <= setif(cntr(0)/='0');
		end if;
	end process;

	fcs_p : process (hdlctx_frm, cy, uart_clk)
		variable q : std_logic;
	begin
		if rising_edge(uart_clk) then
			if uart_idle='1' then
				if hdlctx_frm='1' then
					if cy='1' then
						q := '0';
					end if;
				else
					q := '1';
				end if;
			end if;
		end if;
		crc_init <= cy and q;
		crc_sero <= setif(hdlctx_frm='1', q and not cy, not cy);
	end process;

	crc_ena <= (hdlctx_frm and hdlctx_irdy and hdlctx_trdy) or (fcs_trdy and crc_sero);
	crc_e : entity hdl4fpga.crc
	port map (
		g    => x"1021",
		clk  => uart_clk,
		init => crc_init,
		ena  => crc_ena,
		sero => crc_sero,
		data => hdlctx_data,
		crc  => crc);

	fcs_frm  <= (hdlctx_frm or crc_sero) and not crc_init;
	fcs_data <= wirebus(hdlctx_data & crc(0 to fcs_data'length-1), not crc_sero & crc_sero);
	fcs_irdy <= setif(crc_sero='0', hdlctx_irdy, '1');

	hdlctx_e : entity hdl4fpga.hdlcsync_tx
	port map (
		uart_clk    => uart_clk,
		uart_irdy   => uart_txen,
		uart_idle   => uart_idle,
		uart_txd    => uart_txd,

		hdlctx_frm  => fcs_frm,
		hdlctx_irdy => fcs_irdy, 
		hdlctx_trdy => fcs_trdy,
		hdlctx_data => fcs_data);

	hdlctx_trdy <= hdlctx_frm and fcs_trdy and not crc_init and not crc_sero;

end;
