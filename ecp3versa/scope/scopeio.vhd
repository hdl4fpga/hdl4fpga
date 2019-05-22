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

library ecp3;
use ecp3.components.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture beh of ecp3versa is
	attribute oddrapps : string;
	attribute oddrapps of gtx_clk_i : label is "SCLK_ALIGNED";

	
	constant inputs : natural := 1;
	signal rst        : std_logic := '0';
	signal vga_clk    : std_logic;
	signal vga_hsync  : std_logic;
	signal vga_vsync  : std_logic;
	signal vga_rgb    : std_logic_vector(0 to 3-1);
	constant sample_size : natural := 9;

	function sinctab (
		constant x0 : integer;
		constant x1 : integer;
		constant n  : natural)
		return std_logic_vector is
		variable y   : real;
		variable aux : std_logic_vector(n*x0 to n*(x1+1)-1);
		constant freq : real := 4*8.0;
	begin
		for i in x0 to x1 loop
			y := real(2**(n-2)-1)*64.0*(8.0/freq);
			if i/=0 then
				y := y*sin((2.0*MATH_PI*real(i)*freq)/real(x1-x0+1))/real(i);
			else
				y := freq*y*(2.0*MATH_PI)/real(x1-x0+1);
			end if;
			y := y - (64.0+24.0);
			aux(i*n to (i+1)*n-1) := std_logic_vector(to_signed(integer(trunc(y)),n));
--			if i < (x0+x1)/2 then
--				aux(i*n to (i+1)*n-1) := ('0', others => '1');
--			else
--				aux(i*n to (i+1)*n-1) := ('1',others => '0');
--			end if;
		end loop;
		return aux;
	end;

	constant bit_rate : natural := 1;
	constant bps      : natural := 115200;

	signal uart_rxc   : std_logic;
	signal uart_sin   : std_logic;
	signal uart_ena   : std_logic;
	signal uart_rxdv  : std_logic;
	signal uart_rxd   : std_logic_vector(8-1 downto 0);

	signal si_clk  : std_logic;
	signal si_frm  : std_logic;
	signal si_data : std_logic_vector(8-1 downto 0);

	signal sample      : std_logic_vector(0 to sample_size-1);
	signal samples      : std_logic_vector(0 to inputs*sample_size-1);

	signal input_addr : std_logic_vector(11-1 downto 0);
	signal ipcfg_req  : std_logic;

	constant istream : boolean := true;

	constant baudrate : natural := 115200;
begin

--	rst <= not fpga_gsrn;
	video_b : block
		attribute FREQUENCY_PIN_CLKI  : string; 
		attribute FREQUENCY_PIN_CLKOP : string; 
		attribute FREQUENCY_PIN_CLKI  of PLL_I : label is "100.000000";
		attribute FREQUENCY_PIN_CLKOP of PLL_I : label is "150.000000";

		signal clkfb : std_logic;
		signal lock  : std_logic;
	begin
		pll_i : ehxpllf
        generic map (
			FEEDBK_PATH  => "INTERNAL", CLKOK_BYPASS=> "DISABLED", 
			CLKOS_BYPASS => "DISABLED", CLKOP_BYPASS=> "DISABLED", 
			CLKOK_INPUT  => "CLKOP", DELAY_PWD=> "DISABLED", DELAY_VAL=>  0, 
			CLKOS_TRIM_DELAY=> 0, CLKOS_TRIM_POL=> "RISING", 
			CLKOP_TRIM_DELAY=> 0, CLKOP_TRIM_POL=> "RISING", 
			PHASE_DELAY_CNTL=> "STATIC", DUTY=>  8, PHASEADJ=> "0.0", 
			CLKOK_DIV=>  2, CLKOP_DIV=>  4, CLKFB_DIV=>  3, CLKI_DIV=>  2, 
			FIN=> "100.000000")
		port map (
			rst         => rst, 
			rstk        => '0',
			clki        => clk,
			wrdel       => '0',
			drpai3      => '0', drpai2 => '0', drpai1 => '0', drpai0 => '0', 
			dfpai3      => '0', dfpai2 => '0', dfpai1 => '0', dfpai0 => '0', 
			fda3        => '0', fda2   => '0', fda1   => '0', fda0   => '0', 
			clkintfb    => clkfb,
			clkfb       => clkfb,
			clkop       => vga_clk, 
			clkos       => open,
			clkok       => open,
			clkok2      => open,
			lock        => lock);
	end block;

	samples_e : entity hdl4fpga.rom
	generic map (
		bitrom => sinctab(-1024+256, 1023+256, sample_size))
	port map (
		clk  => clk,
		addr => input_addr,
		data => sample);

	process (clk)
	begin
		if rising_edge(clk) then
			input_addr <= std_logic_vector(unsigned(input_addr) + 1);
		end if;
	end process;

	process (clk)
		constant max_count : natural := (100*10**6+16*baudrate/2)/(16*baudrate);
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

	expansionx3(5) <= 'Z';

	uart_rxc <= clk;
	uart_sin <= expansionx3(5);
	led  <= (others => not expansionx3(5));
	uartrx_e : entity hdl4fpga.uart_rx
	generic map (
		baudrate => baudrate,
		clk_rate => 16*baudrate)
	port map (
		uart_rxc  => uart_rxc,
		uart_sin  => uart_sin,
		uart_ena  => uart_ena,
		uart_rxdv => uart_rxdv,
		uart_rxd  => uart_rxd);

--	si_clk  <= phy1_rxc   when not istream else uart_rxc;
--	si_frm  <= phy1_rx_dv when not istream else uart_rxdv;
--	si_data <= phy1_rx_d  when not istream else uart_rxd;

	si_clk  <= uart_rxc;
	si_frm  <= uart_rxdv;
	si_data <= uart_rxd;

	phy1_rst <= not rst;
	ipcfg_req <= not fpga_gsrn;
	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		inputs   => inputs,
		istream  => istream,
		vlayout_id  => 0)
	port map (
		si_clk      => si_clk,
		si_frm      => si_frm,
		si_data     => si_data,
		so_clk      => phy1_125clk,
		so_dv       => phy1_tx_en,
		so_data     => phy1_tx_d,
		ipcfg_req   => ipcfg_req,
		input_clk   => clk,
		input_data  => sample,
		video_clk   => vga_clk,
		video_pixel => vga_rgb,
		video_hsync => vga_hsync,
		video_vsync => vga_vsync,
		video_blank => open);

	expansionx4io_e : entity hdl4fpga.align
	generic map (
		n => expansionx4'length,
		i => (expansionx4'range => '-'),
		d => (expansionx4'range => 1))
	port map (
		clk   => vga_clk,
		di(0) => vga_rgb(1),
		di(1) => vga_rgb(2),
		di(2) => vga_rgb(0),
		di(3) => vga_hsync,
		di(4) => vga_vsync,
		do    => expansionx4);

	gtx_clk_i : oddrxd1
	port map (
		sclk => phy1_125clk,
		da   => '0',
		db   => '1',
		q    => phy1_gtxclk);

end;
