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
use hdl4fpga.std.all;

library unisim;
use unisim.vcomponents.all;

architecture beh of s3starter is

	signal sys_clk    : std_logic;
	signal vga_clk    : std_logic;

	constant sample_size : natural := 14;

	function sinctab (
		constant x0 : integer;
		constant x1 : integer;
		constant n  : integer)
		return std_logic_vector is
		variable y   : real;
		variable aux : std_logic_vector(0 to n*(x1-x0+1)-1);
	begin
		for i in 0 to x1-x0 loop
			y := sin(2.0*MATH_PI*real((i+x0))/64.0);
			aux(i*n to (i+1)*n-1) := std_logic_vector(to_unsigned(integer(real(2**(n-2))*y),n));
		end loop;
		return aux;
	end;

	signal input_addr : std_logic_vector(11-1 downto 0);
	signal sample     : std_logic_vector(sample_size-1 downto 0);
	
	constant bit_rate : natural := 4;
	constant bps      : natural := 115200;

	signal uart_rxc   : std_logic;
	signal uart_sin   : std_logic;
	signal uart_rxdv  : std_logic;
	signal uart_rxd   : std_logic_vector(8-1 downto 0);
	signal vga_rgb    : std_logic_vector(3-1 downto 0);

	signal so_null    : std_logic_vector(8-1 downto 0);
	signal display    : std_logic_vector(0 to 16-1);
	signal vga_blank  : std_logic;
	signal si_data    : std_logic_vector(0 to 8-1);
begin

	clkin_ibufg : ibufg
	port map (
		I => xtal,
		O => sys_clk);

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dfs_frequency_mode => "low",
		dcm_per => 20.0,
		dfs_mul => 4,
		dfs_div => 5)
	port map(
		dcm_rst => button(0),
		dcm_clk => sys_clk,
		dfs_clk => vga_clk);

	process (sys_clk)
	begin
		if rising_edge(sys_clk) then
			input_addr <= std_logic_vector(unsigned(input_addr) + 1);
		end if;
	end process;

	samples_e : entity hdl4fpga.rom
	generic map (
		bitrom => sinctab(-1024+256, 1023+256, sample_size))
	port map (
		clk  => sys_clk,
		addr => input_addr,
		data => sample);

	process (sys_clk)
		constant bpsX   : natural := 2**bit_rate*bps;
		constant period : natural := (50*1000*1000+((bpsX+1)/2-1))/bpsX;
		variable cntr   : unsigned(0 to unsigned_num_bits(period-1)-1) := (others => '0');
	begin
		if rising_edge(sys_clk) then
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

	uart_sin <= rs232_rxd;
	uartrx_e : entity hdl4fpga.uart_rx
	generic map (
		bit_rate => bit_rate)
	port map (
		uart_rxc  => uart_rxc,
		uart_sin  => uart_sin,
		uart_rxdv => uart_rxdv,
		uart_rxd  => uart_rxd);

	si_data <= uart_rxd;
	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		vlayout_id  => 1,
		tcpip            => false,
		istream => true,
		istream_esc      => std_logic_vector(to_unsigned(character'pos('\'), 8)),
		istream_eos      => std_logic_vector(to_unsigned(character'pos(NUL), 8)),
		default_tracesfg => b"1_1_1",
		default_gridfg   => b"1_0_0",
		default_gridbg   => b"0_0_0",
		default_hzfg     => b"1_1_1",
		default_hzbg     => b"0_0_1",
		default_vtfg     => b"1_1_1",
		default_vtbg     => b"0_0_1",
		default_textbg   => b"0_0_0",
		default_sgmntbg  => b"0_1_1",
		default_bg       => b"1_1_1")
	port map (
		si_clk      => uart_rxc,
		si_frm      => uart_rxdv,
		si_data     => si_data,
		so_data     => so_null,
		input_clk   => sys_clk,
		input_data  => sample,
		video_clk   => vga_clk,
		video_pixel => vga_rgb,
		video_hsync => vga_hsync,
		video_vsync => vga_vsync,
		video_blank => vga_blank);

	led(7 downto 2) <= (others => 'Z');

	led(1) <= uart_rxdv;
	process(uart_rxc, button(0))
	begin
		if button(0)='1' then
			led(0) <= '0';
		elsif rising_edge(uart_rxc) then
			if uart_rxdv='1' then
				led(0) <= '1';
				display <= std_logic_vector(resize(unsigned(uart_rxd), display'length));
			end if;
		end if;
	end process;

	seg7_e : entity hdl4fpga.seg7
	generic map (
		refresh => 2*8)
	port map (
		clk  => uart_rxc,
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

	vga_red   <= vga_rgb(2);
	vga_green <= vga_rgb(1);
	vga_blue  <= vga_rgb(0);

	rs232_txd <= 'Z';
end;
