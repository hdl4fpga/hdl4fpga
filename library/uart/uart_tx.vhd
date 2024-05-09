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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity uart_tx is
	generic (
		baudrate : natural := 115200;
		clk_rate : real);
	port (
		uart_txc  : in  std_logic;
		uart_txe  : in  std_logic := '1';
		uart_sout : out std_logic;
		uart_frm  : in  std_logic := '1';
		uart_irdy : in  std_logic;
		uart_trdy : buffer std_logic;
		uart_data : in  std_logic_vector);
end;


architecture def of uart_tx is

	type uart_states is (idle_s, start_s, data_s, stop_s);
	signal uart_state : uart_states;

	signal init_cntr  : std_logic;
	signal full_count : std_logic;

	signal debug_txen : std_logic;
	signal debug_txd  : std_logic_vector(8-1 downto 0);

begin

	debug_p : process (uart_txc)
	begin
		if rising_edge(uart_txc) then
			debug_txen <= '0';
			if uart_irdy='1' then
				if uart_trdy='1' then
					if uart_data'ascending then
						debug_txd <= reverse(uart_data);
					else
						debug_txd <= uart_data;
					end if;
					debug_txen <= '1';
				end if;
			end if;
		end if;
	end process;

	cntr_p : process (uart_txc, debug_txen)
		constant max_count  : natural := natural(floor((clk_rate+real(baudrate/2))/real(baudrate)));
		variable tcntr      : unsigned(0 to unsigned_num_bits(max_count)-1);
		constant tcntr_init : unsigned := to_unsigned(1, tcntr'length);
	begin
		if rising_edge(uart_txc) then
			if uart_txe='1' then
				if init_cntr='1' then
					tcntr := tcntr_init;
					full_count <= '0';
				else
					tcntr := tcntr + 1;
					if ispower2(max_count) then
						full_count <= tcntr(0);
					elsif tcntr >= max_count then
						full_count <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

	init_cntr <=
		'1' when uart_state=idle_s  else
		'1' when uart_state=start_s and full_count='1' else
		'1' when uart_state=data_s  and full_count='1' else
		'1' when uart_state=stop_s  and full_count='1' else
		'0';

	state_p : process (uart_txc)

		variable dcntr      : unsigned(0 to 4-1);
		constant dcntr_init : unsigned := to_unsigned(1, dcntr'length);
		variable data       : unsigned(uart_data'range);

	begin
		if rising_edge(uart_txc) then
			if uart_frm='1' then
				if uart_txe='1' then
					case uart_state is
					when idle_s =>
						uart_sout <= '1';
						if uart_irdy='1' then
							uart_trdy <= '0';
						end if;
						dcntr := (others => '-');
						data  := unsigned(uart_data);
						if uart_irdy='1' then
							uart_sout  <= '0';
							uart_state <= start_s;
						end if;
					when start_s =>
						uart_sout <= '0';
						uart_trdy <= '0';
						dcntr := dcntr_init;
						if full_count='1' then
							uart_state <= data_s;
							uart_sout  <= data(0);
							if data'ascending then
								data := data rol 1;
							else
								data := data ror 1;
							end if;
						end if;
					when data_s =>
						if full_count='1' then
							if data'ascending then
								uart_sout <= data(data'left);
								data := data rol 1;
							else
								uart_sout <= data(data'right);
								data := data ror 1;
							end if;
							if dcntr(0)='1' then
								uart_state <= stop_s;
								uart_trdy  <= uart_frm;
								dcntr := (others => '-');
							else
								uart_trdy <= '0';
								dcntr := dcntr + 1;
							end if;
						else
							uart_trdy <= '0';
						end if;
					when stop_s =>
						uart_sout <= '1';
						data  := unsigned(uart_data);
						dcntr := (others => '-');
						if full_count='1' then
							if uart_irdy='1' then
								uart_state <= start_s;
							else
								uart_state <= idle_s;
							end if;
						end if;
						if uart_irdy='1' then
							uart_trdy <= '0';
						end if;
					end case;
				elsif uart_irdy='1' then
					uart_trdy <= '0';
				end if;
			else
				uart_state <= idle_s;
				uart_sout  <= '1';
				uart_trdy  <= '0';
			end if;
		end if;
	end process;

end;
