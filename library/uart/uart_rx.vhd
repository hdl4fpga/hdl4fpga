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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity uart_rx is
	generic (
		bit_rate  : natural := 4);
	port (
		uart_rxc  : in  std_logic;
		uart_sin  : in  std_logic;
		uart_rxdv : out std_logic;
		uart_rxd  : out std_logic_vector(8-1 downto 0));
end;

architecture def of uart_rx is
	signal din : std_logic;
begin

	process (uart_rxc)
	begin
		if rising_edge(uart_rxc) then
		end if;
	end process;

	process (uart_rxc)
		type uart_states is (idle_s, start_s, data_s, stop_s);
		variable uart_state : uart_states;

		variable tcntr      : unsigned(0 to bit_rate);
		constant tcntr_init : unsigned := to_unsigned(1, tcntr'length);
		variable dcntr      : unsigned(0 to 4-1);
		constant dcntr_init : unsigned := to_unsigned(1, dcntr'length);
		variable data       : unsigned(8-1 downto 0);

		variable sin        : unsigned(0 to 2-1);
	begin
		if rising_edge(uart_rxc) then

			din    <= sin(0);
			sin(0) := uart_sin;
			sin    := sin rol 1;

			case uart_state is
			when idle_s =>
				uart_rxdv <= '0';
				dcntr := (others => '-');
				if sin(0)='0' then
					uart_state := start_s;
				end if;
				tcntr := tcntr_init;
			when start_s =>
				uart_rxdv <= '0';
				dcntr := dcntr_init;
				if tcntr(1)='1' then
					if din='0' then
						uart_state := data_s;
						tcntr := tcntr_init;
					else
						uart_state := idle_s;
					end if;
				else
					tcntr := tcntr + 1;
				end if;
			when data_s =>
				uart_rxdv <= '0';
				if tcntr(0)='1' then

					data(0) := din;
					data    := data ror 1;
					if dcntr(0)='1' then
						uart_rxdv <= '1';
						uart_state := stop_s;
						dcntr := (others => '-');
					else
						uart_rxdv <= '0';
						dcntr := dcntr + 1;
					end if;

					tcntr := tcntr_init;
				else
					uart_rxdv <= '0';
					tcntr := tcntr + 1;
				end if;
			when stop_s =>
				uart_rxdv <= '0';
				dcntr     := (others => '-');
				if tcntr(0)='1' then
					uart_state := idle_s;
				else
					tcntr := tcntr + 1;
				end if;
			end case;

			uart_rxd <= std_logic_vector(data);
		end if;
	end process;
end;
