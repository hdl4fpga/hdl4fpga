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
		baudrate : natural := 115200;
		clk_rate : natural := 4);
	port (
		uart_rxc  : in  std_logic;
		uart_ena  : in  std_logic := '1';
		uart_sin  : in  std_logic;
		uart_rxdv : out std_logic;
		uart_rxd  : out std_logic_vector(8-1 downto 0));
end;

architecture def of uart_rx is
	type uart_states is (idle_s, start_s, data_s, stop_s);
	signal uart_state : uart_states;

	signal sample_rxd : std_logic;
	signal init_cntr  : std_logic;
	signal half_count : std_logic;
	signal full_count : std_logic;
begin

	sample_p : process (uart_rxc)
		variable sin  : unsigned(0 to 1-1);
	begin
		if rising_edge(uart_rxc) then
			sample_rxd  <= sin(0);
			sin(0)      := uart_sin;
			sin         := sin rol 1;
		end if;
	end process;

	cntr_p : process (uart_rxc)
		constant max_count  : natural := (clk_rate+baudrate/2)/baudrate;
		variable tcntr      : unsigned(0 to unsigned_num_bits(max_count)/baudrate-1);
		constant tcntr_init : unsigned := to_unsigned(1, tcntr'length);
	begin
		if rising_edge(uart_rxc) then
			if uart_ena='1' then
				if init_cntr='1' then
					tcntr := tcntr_init;
				else
					tcntr := tcntr + 1;
				end if;
				if ispower2(max_count) then
					half_count <= tcntr(1);
					full_count <= tcntr(0);
				else
					if tcntr >= max_count/2 then
						half_count <= '1';
					end if;
					if tcntr >= max_count then
						full_count <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

	init_cntr <= 
		'1' when uart_state=idle_s  else
		'1' when uart_state=start_s and half_count='1' and sample_rxd='0' else
		'1' when uart_state=data_s  and full_count='1' else
		'1' when uart_state=stop_s  and full_count='1' else
		'0';

	state_p : process (uart_rxc)

		variable dcntr      : unsigned(0 to 4-1);
		constant dcntr_init : unsigned := to_unsigned(1, dcntr'length);
		variable data       : unsigned(8-1 downto 0);

	begin
		if rising_edge(uart_rxc) then
			if uart_ena='1' then
				case uart_state is
				when idle_s =>
					uart_rxdv <= '0';
					dcntr := (others => '-');
					if sample_rxd='0' then
						uart_state <= start_s;
					end if;
				when start_s =>
					uart_rxdv <= '0';
					dcntr := dcntr_init;
					if half_count='1' then
						if sample_rxd='0' then
							uart_state <= data_s;
						else
							uart_state <= idle_s;
						end if;
					end if;
				when data_s =>
					uart_rxdv <= '0';
					if full_count='1' then
						data(0) := sample_rxd;
						data    := data ror 1;
						if dcntr(0)='1' then
							uart_rxdv <= '1';
							uart_state <= stop_s;
							dcntr := (others => '-');
						else
							dcntr := dcntr + 1;
						end if;
					end if;
				when stop_s =>
					uart_rxdv <= '0';
					dcntr     := (others => '-');
					if full_count='1' then
						uart_state <= idle_s;
					end if;
				end case;
			end if;

			uart_rxd <= std_logic_vector(data);
		end if;
	end process;
end;
