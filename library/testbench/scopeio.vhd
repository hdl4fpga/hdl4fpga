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

architecture scopeio of testbench is

	signal sys_clk : std_logic := '0';
	signal vga_clk : std_logic := '0';

	constant inputs : natural := 1;
	constant sample_size : natural := 14;

	function sintab (
		constant x0 : integer;
		constant x1 : integer;
		constant n  : integer)
		return std_logic_vector is
		variable y   : real;
		variable aux : std_logic_vector(0 to n*(x1-x0+1)-1);
	begin
		for i in 0 to x1-x0 loop
			y := 127.0*sin(2.0*MATH_PI*real((i+x0))/64.0);
			aux(i*n to (i+1)*n-1) := std_logic_vector(to_unsigned(integer(y),n));
		end loop;
		return aux;
	end;

	signal input_addr : std_logic_vector(11-1 downto 0);
	signal sample     : std_logic_vector(sample_size-1 downto 0);
	
	constant baudrate      : natural := 115200;

	signal uart_sin   : std_logic;
	signal uart_rxc   : std_logic;
	signal uart_ena   : std_logic;
	signal uart_rxdv  : std_logic;
	signal uart_rxd   : std_logic_vector(8-1 downto 0);
	signal vga_rgb    : std_logic_vector(3-1 downto 0);

	signal istreamdaisy_frm  : std_logic;
	signal istreamdaisy_irdy : std_logic;
	signal istreamdaisy_data : std_logic_vector(8-1 downto 0);

	signal mousedaisy_frm    : std_logic;
	signal mousedaisy_irdy   : std_logic;
	signal mousedaisy_data   : std_logic_vector(8-1 downto 0);

	signal si_clk    : std_logic;
	signal si_frm    : std_logic;
	signal si_irdy   : std_logic;
	signal si_data   : std_logic_vector(8-1 downto 0);
	signal so_data   : std_logic_vector(8-1 downto 0);

	signal display    : std_logic_vector(0 to 16-1);
	signal vga_blank  : std_logic;

	type display_param is record
		layout : natural;
		mul    : natural;
		div    : natural;
	end record;

	constant mode600p    : natural := 0;
	constant mode1080p   : natural := 1;
	constant mode600px16 : natural := 2;

	type displayparam_vector is array (natural range <>) of display_param;
	constant video_params : displayparam_vector(0 to 2) := (
		mode600p    => (layout => 1, mul => 4, div => 5),
		mode1080p   => (layout => 0, mul => 3, div => 1),
		mode600px16 => (layout => 7, mul => 4, div => 5));

	constant video_mode : natural := mode600px16;

	signal rs232_rxd : std_logic;
	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;

begin

	sys_clk <= not sys_clk after 20 ns;
	vga_clk <= not vga_clk after 25 ns;

	process (sys_clk)
	begin
		if rising_edge(sys_clk) then
			input_addr <= std_logic_vector(unsigned(input_addr) + 1);
		end if;
	end process;

	samples_e : entity hdl4fpga.rom
	generic map (
		latency => 2,
		bitrom => sintab(-1024+256, 1023+256, sample_size))
	port map (
		clk  => sys_clk,
		addr => input_addr,
		data => sample);

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
		stream_dv   => uart_rxdv,
		stream_data => uart_rxd,

		chaini_data => uart_rxd,

		chaino_frm  => si_frm, 
		chaino_irdy => si_irdy,
		chaino_data => si_data);

	si_clk  <= sys_clk;
	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		inputs           => inputs,
		vlayout_id       => video_params(video_mode).layout,
		default_tracesfg => b"1_1_1",
		default_gridfg   => b"1_0_0",
		default_gridbg   => b"0_0_0",
		default_hzfg     => b"1_1_1",
		default_hzbg     => b"0_0_1",
		default_vtfg     => b"1_1_1",
		default_vtbg     => b"0_0_1",
		default_textbg   => b"0_0_0",
		default_sgmntbg  => b"1_1_1",
		default_bg       => b"0_0_0")
	port map (
		si_clk      => si_clk,
		si_frm      => si_frm,
		si_irdy     => si_irdy,
		si_data     => si_data,
		so_data     => so_data,
		input_clk   => sys_clk,
		input_data  => sample,
		video_clk   => vga_clk,
		video_pixel => vga_rgb,
		video_hsync => vga_hsync,
		video_vsync => vga_vsync,
		video_blank => vga_blank);

end;
