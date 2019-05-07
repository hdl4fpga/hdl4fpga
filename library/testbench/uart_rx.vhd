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

architecture uart_rx of testbench is
	signal rst   : std_logic := '1';
	signal clk   : std_logic := '1';
	signal xclk  : std_logic := '1';

	signal uart_rxc   : std_logic;
	signal uart_sin   : std_logic;
	signal uart_rxdv  : std_logic;
	signal uart_rxd   : std_logic_vector(8-1 downto 0);
begin

	xclk <= not xclk after 1000000000 ns/(2*115200);
	clk <= not clk after 10 ns;
	rst <= '1', '0' after 100 ns;

	process (rst, xclk)
		variable data : unsigned(10-1 downto 0);
	begin
		if rst='1' then
			data := b"0100_0011_01";
		elsif rising_edge(xclk) then
			data := data ror 1;
		end if;
		uart_sin <= data(0);
	end process;

	process (clk)
		constant period : natural := 50000000/(16*115200);
		variable cntr   : unsigned(0 to unsigned_num_bits(period-1)-1) := (others => '0');
	begin
		if rising_edge(clk) then
			if cntr < (period/2) then
				uart_rxc <= '0';
			else
				uart_rxc <= '1';
			end if;

			if cntr < period-1 then
				cntr := cntr + 1;
			else
				cntr := (others => '0');
			end if;
		end if;
	end process;

	uartrx_e : entity hdl4fpga.uart_rx
	port map (
		uart_rxc  => uart_rxc,
		uart_sin  => uart_sin,
		uart_rxdv => uart_rxdv,
		uart_rxd  => uart_rxd);

end;
