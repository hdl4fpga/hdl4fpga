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

architecture beh of nexys2 is

	signal sys_clk    : std_logic;
	signal vga_clk    : std_logic;

	constant sample_size : natural := 14;

	function squaretab (
		constant period      : natural;
		constant duty        : natural;
		constant table_size  : integer;
		constant sample_size : natural)
		return std_logic_vector is
		variable y   : real;
		variable aux : std_logic_vector(0 to sample_size*table_size-1);
	begin
		for i in 0 to table_size-1 loop
			if (i mod period) < (period*duty)/100 then
				aux(i*sample_size to (i+1)*sample_size-1) := std_logic_vector(to_signed(2**11-1, sample_size));
			else
				aux(i*sample_size to (i+1)*sample_size-1) := std_logic_vector(to_signed(-2**11-1, sample_size));
			end if;
		end loop;
		return aux;
	end;

	function sintab (
		constant x0 : integer;
		constant x1 : integer;
		constant n  : integer)
		return std_logic_vector is
		variable y   : real;
		variable aux : std_logic_vector(0 to n*(x1-x0+1)-1);
	begin
		for i in 0 to x1-x0 loop
			y := sin(2.0*MATH_PI*real((i+x0))/64.0)/2.0;
			aux(i*n to (i+1)*n-1) := std_logic_vector(to_unsigned(integer(real(2**(n-2))*y),n));
		end loop;
		return aux;
	end;

	constant baudrate : natural := 115200;

	signal input_addr : std_logic_vector(11-1 downto 0);
	signal sample     : std_logic_vector(sample_size-1 downto 0);
	
	signal uart_rxc   : std_logic;
	signal uart_sin   : std_logic;
	signal uart_ena   : std_logic;
	signal uart_rxdv  : std_logic;
	signal uart_rxd   : std_logic_vector(8-1 downto 0);
	signal vga_rgb    : std_logic_vector(vga_red'length+vga_green'length+vga_blue'length-1 downto 0);

	signal si_clk    : std_logic;
	signal si_frm    : std_logic;
	signal si_irdy   : std_logic;
	signal si_data   : std_logic_vector(8-1 downto 0);
	signal so_data   : std_logic_vector(8-1 downto 0);

	signal display   : std_logic_vector(0 to 16-1);

	type display_param is record
		layout : natural;
		mul    : natural;
		div    : natural;
	end record;

	constant mode600p  : natural := 0;
	constant mode1080p : natural := 1;

	type displayparam_vector is array (natural range <>) of display_param;
	constant video_params : displayparam_vector(0 to 1) := (
		mode600p  => (layout => 1, mul => 4, div => 5),
		mode1080p => (layout => 0, mul => 3, div => 1));

	constant video_mode : natural := mode600p;

begin

	clkin_ibufg : ibufg
	port map (
		I => xtal,
		O => sys_clk);

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dfs_frequency_mode => "low",
		dcm_per => 20.0,
		dfs_mul => video_params(video_mode).mul,
		dfs_div => video_params(video_mode).div)
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
		latency => 2,
		bitrom => sintab(-1024+256, 1023+256, sample_size))
--		bitrom => squaretab(period => 32, duty => 25, table_size => 2048, sample_size => sample_size))
	port map (
		clk  => sys_clk,
		addr => input_addr,
		data => sample);

	uart_rxc <= sys_clk;
	process (uart_rxc)
		constant max_count : natural := (50*10**6+16*baudrate/2)/(16*baudrate);
		variable cntr      : unsigned(0 to unsigned_num_bits(max_count-1)-1) := (others => '0');
	begin
		if rising_edge(uart_rxc) then
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

	si_clk <= uart_rxc;
	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		vlayout_id       => video_params(video_mode).layout,
		default_tracesfg => b"111_111_11",
		default_gridfg   => b"111_000_00",
		default_gridbg   => b"000_000_00",
		default_hzfg     => b"111_111_11",
		default_hzbg     => b"000_000_11",
		default_vtfg     => b"111_111_11",
		default_vtbg     => b"000_000_11",
		default_textbg   => b"000_000_00",
		default_sgmntbg  => b"000_111_11",
		default_bg       => b"000_000_00")
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
		video_vsync => vga_vsync);

	process (vga_rgb)
		variable aux : unsigned(vga_rgb'range);
	begin
		aux := unsigned(vga_rgb);
		vga_blue  <= std_logic_vector(aux(vga_blue'range));
		aux := aux srl vga_blue'length;
		vga_green <= std_logic_vector(aux(vga_green'range));
		aux := aux srl vga_green'length;
		vga_red   <= std_logic_vector(aux(vga_red'range));
	end process;

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

	rs232_txd <= 'Z';
end;
