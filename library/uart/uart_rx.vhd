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
		tcntr_size : natural := 4);
	port (
		uart_rxc  : in  std_logic;
		uart_sin  : in  std_logic;
		uart_rxdv : out std_logic;
		uart_rxd  : out std_logic_vector);
end;

architecture def of uart_rx is
	signal din : std_logic;
begin

	process (uart_rxc)
		variable sin : std_logic;
	begin
		if rising_edge(uart_rxc) then
			din <= sin;
			sin := uart_sin;
		end if;
	end process;

	process (uart_rxc)
		type uart_states is (idle_s, start_s, data_s, stop_s);
		variable uart_state : uart_states;

		variable tcntr      : unsigned(0 to tcntr_size);
		constant tcntr_init : unsigned := to_unsigned(1, tcntr'length);
		variable dcntr      : unsigned(0 to 4-1);
		constant dcntr_init : unsigned := to_unsigned(1, dcntr'length);
		variable data       : unsigned(8-1 downto 0);
	begin
		if rising_edge(uart_rxc) then
			case uart_state is
			when idle_s  =>
				if din='0' then
					uart_state := start_s;
				end if;
				tcntr := tcntr_init;
				dcntr := (others => '-');
				uart_rxdv <= '0';
			when start_s =>
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
				dcntr := (others => '0');
				uart_rxdv <= '0';
			when data_s  =>
				if tcntr(0)='1' then
					dcntr := dcntr + 1;
					tcntr := tcntr_init;
				else
					data := data sll 1;
					data(0) := din;

					tcntr := tcntr + 1;
					if dcntr(0)='1' then
						uart_state := stop_s;
						dcntr := (others => '-');
					else
						dcntr := dcntr + 1;
					end if;
				end if;
				uart_rxdv <= '0';
			when stop_s  =>
				dcntr := (others => '-');
				if tcntr(0)='1' then
					uart_rxdv <= '1';
					uart_state := idle_s;
				else
					tcntr := tcntr + 1;
					uart_rxdv <= '0';
				end if;
			end case;

			uart_rxd <= std_logic_vector(data);
		end if;
	end process;
end;
