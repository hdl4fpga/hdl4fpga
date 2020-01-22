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

library unisim;
use unisim.vcomponents.all;

architecture beh of s3starter is

	constant inputs : natural := 1;

	signal sys_clk    : std_logic;
	signal vga_clk    : std_logic;

	constant baudrate      : natural := 115200;

	signal uart_sin   : std_logic;
	signal uart_rxc   : std_logic;
	signal uart_ena   : std_logic;
	signal uart_rxdv  : std_logic;
	signal uart_rxd   : std_logic_vector(8-1 downto 0);

	signal istreamdaisy_frm  : std_logic;
	signal istreamdaisy_irdy : std_logic;
	signal istreamdaisy_data : std_logic_vector(8-1 downto 0);

	signal display : std_logic_vector(0 to 16-1);

begin

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

	uart_sin <= rs232_rxd;
	uart_rxc <= sys_clk;
	uartrx_e : entity hdl4fpga.uart_rx
	generic map (
		baudrate => baudrate,
		clk_rate => 16*baudrate)
	port map (
		uart_sin  => uart_sin,
		uart_rxc  => uart_rxc,
		uart_ena  => uart_ena,
		uart_rxdv => uart_rxdv,
		uart_rxd  => uart_rxd);

	istreamdaisy_e : entity hdl4fpga.scopeio_istreamdaisy
	generic map (
		istream_esc => std_logic_vector(to_unsigned(character'pos('\'), 8)),
		istream_eos => std_logic_vector(to_unsigned(character'pos(NUL), 8)))
	port map (
		stream_clk  => uart_rxc,
		stream_ena  => uart_ena,
		stream_dv   => uart_rxdv,
		stream_data => uart_rxd,

		chaini_data => uart_rxd,

		chaino_frm  => istreamdaisy_frm,  
		chaino_irdy => istreamdaisy_irdy,
		chaino_data => istreamdaisy_data);

	process(uart_rxc, button(0))
		variable row : unsigned(display'length-1 downto 0);
		variable pulse : unsigned(led'range) := (others => '0');
	begin
		if rising_edge(uart_rxc) then
--			if istreamdaisy_irdy='1' then
--				row := row sll 8;
--				row(8-1 downto 0) := unsigned(istreamdaisy_data);
--				display <= std_logic_vector(row);
--			end if;
			if istreamdaisy_irdy='1' then
				pulse := pulse sll 1;
				pulse(0) := '1';
				row := row sll 8;
				row(8-1 downto 0) := unsigned(uart_rxd);
				display <= std_logic_vector(row);
			end if;
			if button(0)='1' then
				pulse := (others => '0');
			end if;
				led <= std_logic_vector(pulse);
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

	vga_red   <= 'Z';
	vga_green <= 'Z';
	vga_blue  <= 'Z';
	vga_hsync <= 'Z';
	vga_vsync <= 'Z';

	led <= (others => 'Z');
	expansion_a2 <= (others => 'Z');
	rs232_txd <= 'Z';
	ps2_clk <= 'Z';
	ps2_data <= 'Z';
end;
