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

library unisim;
use unisim.vcomponents.all;

architecture uart_tx of s3starter is

	signal sys_clk    : std_logic;

	constant baudrate : natural := 115200;

	signal uart_rxdv  : std_logic;
	signal uart_rxd   : std_logic_vector(8-1 downto 0);
	signal uart_ena   : std_logic;

	signal uart_txdv  : std_logic;
	signal uart_txd   : std_logic_vector(8-1 downto 0);

	signal display    : std_logic_vector(0 to 16-1);begin

	clkin_ibufg : ibufg
	port map (
		I => xtal,
		O => sys_clk);

	process (sys_clk)
		constant max_count : natural := (50*10**6+16*baudrate/2)/(16*baudrate);
		variable cntr      : unsigned(0 to unsigned_num_bits(max_count-1)-1) := (others => '0');
	begin
		if rising_edge(sys_clk) then
			if cntr >= max_count-1 then
				uart_ena <= '1';
				cntr := (others => '0');
			else
				uart_ena <= '0';
				cntr := cntr + 1;
			end if;
		end if;
	end process;

	uartrx_e : entity hdl4fpga.uart_rx
	generic map (
		baudrate => baudrate,
		clk_rate => 16*baudrate)
	port map (
		uart_sin  => rs232_rxd,
		uart_rxc  => sys_clk,
		uart_ena  => uart_ena,
		uart_rxdv => uart_rxdv,
		uart_rxd  => uart_rxd);

	uart_txdv <= uart_rxdv;
	uart_txd  <= uart_rxd;

	uarttx_e : entity hdl4fpga.uart_tx
	generic map (
		baudrate => baudrate,
		clk_rate => 16*baudrate)
	port map (
		uart_sout => rs232_txd,
		uart_ena  => uart_ena,
		uart_txc  => sys_clk,
		uart_txdv => uart_txdv,
		uart_txd  => uart_txd);

	process(sys_clk)
	begin
		if rising_edge(sys_clk) then
			if uart_rxdv='1' then
				display <= std_logic_vector(resize(unsigned(uart_rxd), display'length));
			end if;
		end if;
	end process;

	seg7_e : entity hdl4fpga.seg7
	generic map (
		refresh => 2*8)
	port map (
		clk  => uart_ena,
		data => display,
		segment_a  => s3s_segment_a,
		segment_b  => s3s_segment_b,
		segment_c  => s3s_segment_c,
		segment_d  => s3s_segment_d,
		segment_e  => s3s_segment_e,
		segment_f  => s3s_segment_f,
		segment_g  => s3s_segment_g,
		segment_dp => s3s_segment_dp,
		display_turnon => s3s_anodes);

	expansion_a2 <= (others => 'Z');
	ps2_clk      <= 'Z';
	ps2_data     <= 'Z';
	led          <= (others => 'Z');
	vga_red      <= 'Z';
	vga_green    <= 'Z';
	vga_blue     <= 'Z';
	vga_hsync    <= 'Z';
	vga_vsync    <= 'Z';

end;
