-- Copyright (c) <2015> <Miguel Angel Sagreras>                                    --
--                                                                                 --
-- Permission is hereby granted, free of charge, to any person obtaining a copy of --
-- this software and associated documentation files (the "Software"), to deal in   --
-- the Software without restriction, including without limitation the rights to    --
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   --
-- of the Software, and to permit persons to whom the Software is furnished to do  --
-- so, subject to the following conditions:                                        --
--                                                                                 --
-- The above copyright notice and this permission notice shall be included in all  --
-- copies or substantial portions of the Software.                                 --
--                                                                                 --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   --
-- SOFTWARE.                                                                       --
--                                                                                 --

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture uart_rx of testbench is
	constant n : natural := 2;

	signal rst       : std_logic := '1';
	signal clk       : std_logic := '1';
	signal xclk      : std_logic := '1';

	signal uart_rxc  : std_logic;
	signal uart_sin  : std_logic;
	signal uart_ena  : std_logic := '1' ;
	signal uart_rxdv : std_logic;
	signal uart_rxd  : std_logic_vector(8-1 downto 0);

	constant mesg : string := "hello world hola mundo";

	constant baudrate   : natural := 115200;
	constant clk_period : time := 1 sec / (50*10**6);
begin

	rst  <= '1', '0' after 100 ns;
	clk  <= not clk after clk_period/2;
	xclk <= not xclk after (1 sec / baudrate / 2);

	process (rst, xclk)
		variable data : unsigned(mesg'length*10-1 downto 0);
	begin
		if rst='1' then
			for i in mesg'range loop
				data(10-1 downto 0) := to_unsigned(character'pos(mesg(i)),8) & b"01";
				data := data ror 10;
			end loop;
		elsif rising_edge(xclk) then
			data := data ror 1;
		end if;
		uart_sin <= data(0);
	end process;

	process(clk)
		constant max_count : natural := (1 sec / clk_period+16*baudrate/2)/(16*baudrate);
		variable cntr      : unsigned(0 to unsigned_num_bits(max_count-1)-1) := (others => '0');
	begin
		if rising_edge(clk) then
			if cntr >= max_count-1 then
				uart_ena <= '1';
				cntr := (others => '0');
			else
				uart_ena <= '0';
				cntr := cntr + 1;
			end if;
		end if;
	end process;

	uart_rxc <= clk;
	uartrx_e : entity hdl4fpga.uart_rx
	generic map (
		baudrate => baudrate,
		clk_rate => 16*baudrate)
	port map (
		uart_rxc  => uart_rxc,
		uart_ena  => uart_ena,
		uart_sin  => uart_sin,
		uart_rxdv => uart_rxdv,
		uart_rxd  => uart_rxd);

	process (rst, uart_rxc)
		variable data : unsigned(mesg'length*8-1 downto 0);
	begin
		if rst='1' then
			for i in mesg'range loop
				data(8-1 downto 0) := to_unsigned(character'pos(mesg(i)),8);
				data := data ror 8;
			end loop;
		elsif rising_edge(uart_rxc) then
			if uart_rxdv='1' then
				assert uart_rxd=std_logic_vector(data(8-1 downto 0))
					report "DATA ERROR"
					severity FAILURE;
				data := data ror 8;
			end if;
		end if;
	end process;

end;
