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
use hdl4fpga.base.all;
use hdl4fpga.scopeiopkg.all;

architecture beh of ecp3versa is
	attribute oddrapps : string;
	attribute oddrapps of gtx_clk_i : label is "SCLK_ALIGNED";
	
	signal expansionx4_d : std_logic_vector(expansionx4'range);
	signal expansionx3_d : std_logic_vector(expansionx3'range);

	constant inputs : natural := 1;
	signal rst        : std_logic := '0';
	signal vga_clk    : std_logic;
	signal vga_hsync  : std_logic;
	signal vga_vsync  : std_logic;
	signal vga_rgb    : std_logic_vector(0 to 3-1);

	constant sample_size : natural := 9;

	function sintab (
		constant base : integer;
		constant size : natural)
		return integer_vector is
		variable offset : natural;
		variable retval : integer_vector(0 to size-1);
	begin
		for i in 0 to size-1 loop
			offset := base + i;
			retval(i) := integer(floor(127.0*sin(2.0*MATH_PI*real((offset))/64.0)));
--			retval(i) := 0;
--			if i=0 then
--				retval(i) := 127;
--			end if;
--			if i=735 then
--				retval(i) := -63;
--			end if;
		end loop;
		return retval;
	end;

	signal uart_rxc  : std_logic;
	signal uart_sin  : std_logic;
	signal uart_ena  : std_logic;
	signal uart_rxdv : std_logic;
	signal uart_rxd  : std_logic_vector(8-1 downto 0);

	signal toudpdaisy_clk  : std_logic;
	signal toudpdaisy_frm  : std_logic;
	signal toudpdaisy_irdy : std_logic;
	signal toudpdaisy_data : std_logic_vector(8-1 downto 0);

	signal si_clk    : std_logic;
	signal si_frm    : std_logic;
	signal si_irdy   : std_logic;
	signal si_data   : std_logic_vector(8-1 downto 0);

	signal so_clk    : std_logic;
	signal so_frm    : std_logic;
	signal so_trdy   : std_logic;
	signal so_irdy   : std_logic;
	signal so_data   : std_logic_vector(8-1 downto 0);

	signal sample     : std_logic_vector(0 to sample_size-1);

	signal ipcfg_req  : std_logic;
	signal input_addr : unsigned(11-1 downto 0);
	signal input_ena  : std_logic := '1';
	signal input_dv   : std_logic;

	constant baudrate : natural := 115200;

	type display_param is record
		layout    : natural;
		clkok_div : natural;
		clkop_div : natural;
		clkfb_div : natural;
		clki_div  : natural; 
	end record;

	type layout_mode is (
		mode600p, 
		mode1080p,
		mode600px16);

	type displayparam_vector is array (layout_mode) of display_param;
	constant video_params : displayparam_vector := (
		mode600p    => (layout => 1, clkok_div => 2, clkop_div => 16, clkfb_div => 2, clki_div => 5),
		mode1080p   => (layout => 0, clkok_div => 2, clkop_div =>  4, clkfb_div => 3, clki_div => 2),
		mode600px16 => (layout => 6, clkok_div => 2, clkop_div => 32, clkfb_div => 1, clki_div => 4));

	constant video_mode : layout_mode := mode1080p;
--	constant layout     : natural := video_params(1).layout;
	constant layout     : natural := video_params(video_mode).layout;

		signal lock  : std_logic;
begin

	rst <= not fpga_gsrn;
	video_b : block
		attribute FREQUENCY_PIN_CLKI  : string; 
		attribute FREQUENCY_PIN_CLKOP : string; 
		attribute FREQUENCY_PIN_CLKI  of PLL_I : label is "100.000000";
		attribute FREQUENCY_PIN_CLKOP of PLL_I : label is "150.000000";

		signal clkfb : std_logic;
	begin
		pll_i : ehxpllf
        generic map (
			FEEDBK_PATH  => "CLKOP",
			CLKOK_BYPASS=> "DISABLED", CLKOS_BYPASS => "DISABLED", CLKOP_BYPASS=> "DISABLED", 
			CLKOK_INPUT  => "CLKOP", DELAY_PWD=> "DISABLED", DELAY_VAL=>  0, 
			CLKOS_TRIM_DELAY=> 0, CLKOS_TRIM_POL=> "RISING", 
			CLKOP_TRIM_DELAY=> 0, CLKOP_TRIM_POL=> "RISING", 
			PHASE_DELAY_CNTL=> "STATIC", DUTY=>  8, PHASEADJ=> "0.0", 
-- 			CLKOK_DIV=>  2, CLKOP_DIV=>  4, CLKFB_DIV=>  3, CLKI_DIV=>  2, 
 			CLKOK_DIV => video_params(video_mode).clkok_div,
			CLKOP_DIV => video_params(video_mode).clkop_div,
			CLKFB_DIV => video_params(video_mode).clkfb_div,
			CLKI_DIV  => video_params(video_mode).clki_div,
			FIN=> "100.000000")
		port map (
			rst         => '0', 
			rstk        => '0',
			clki        => clk,
			wrdel       => '0',
			drpai3      => '0', drpai2 => '0', drpai1 => '0', drpai0 => '0', 
			dfpai3      => '0', dfpai2 => '0', dfpai1 => '0', dfpai0 => '0', 
			fda3        => '0', fda2   => '0', fda1   => '0', fda0   => '0', 
			clkintfb    => open,
			clkfb       => vga_clk,
			clkop       => vga_clk, 
			clkos       => open,
			clkok       => open,
			clkok2      => open,
			lock        => lock);
	end block;

--	process (clk)
--		variable cntr : unsigned(0 to 2-1);
--	begin 
--		if rising_edge(clk) then
--			cntr := cntr + 1;
--			vga_clk <= cntr(0);
--		end if;
--	end process;

	input_ena <= '1'; --uart_ena;
	process (clk)
	begin
		if rising_edge(clk) then
			if input_ena='1' then
				input_addr <= input_addr + 1;
			end if;
		end if;
	end process;

	samples_e : entity hdl4fpga.rom
	generic map (
		latency => 2,
		bitrom => to_bitrom(sintab(base => 0, size => 2**input_addr'length), sample_size))
	port map (
		clk  => clk,
		addr => std_logic_vector(input_addr),
		data => sample);

	ena_e : entity hdl4fpga.latency
	generic map (
		n => 1,
		d => (0 to 0 => 2))
	port map (
		clk => clk,
		di(0) => input_ena,
		do(0) => input_dv);

	uart_rxc <= phy1_rxc;
	process (uart_rxc)
		constant max_count : natural := (125*10**6+16*baudrate/2)/(16*baudrate);
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

	uart_sin <= expansionx3(5);
--	led  <= (others => not lock);
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

	istreamdaisy_e : entity hdl4fpga.scopeio_istreamdaisy
	port map (
		stream_clk  => uart_rxc,
		stream_dv   => uart_rxdv,
		stream_data => uart_rxd,

		chaini_data => (uart_rxd'range => '-'),

		chaino_frm  => toudpdaisy_frm, 
		chaino_irdy => toudpdaisy_irdy,
		chaino_data => toudpdaisy_data);

	ipcfg_req <= not fpga_gsrn;
	udpipdaisy_e : entity hdl4fpga.scopeio_udpipdaisy
	port map (
		ipcfg_req   => ipcfg_req,

		phy_rxc     => phy1_rxc,
		phy_rx_dv   => phy1_rx_dv,
		phy_rx_d    => phy1_rx_d,

		phy_txc     => phy1_125clk,
		phy_tx_en   => phy1_tx_en,
		phy_tx_d    => phy1_tx_d,
	
		chaini_sel  => '0',

		chaini_frm  => toudpdaisy_frm,
		chaini_irdy => toudpdaisy_irdy,
		chaini_data => toudpdaisy_data,

		chaino_frm  => si_frm,
		chaino_irdy => si_irdy,
		chaino_data => si_data);
	
	si_clk   <= phy1_rxc;
	led  <= not si_data;
	phy1_rst <= not '0'; --rst;
	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		hz_unit     => 25.0*micro,
		vt_unit     => 500.0*micro,
		vt_step     => 1000.0*milli/(2.0**16),
		inputs      => inputs,
		vlayout_id  => layout)
	port map (
		si_clk      => si_clk,
		si_frm      => si_frm,
		si_irdy     => si_irdy,
		si_data     => si_data,
		so_clk      => so_clk,
		so_frm      => so_frm,
		so_irdy     => so_irdy,
		so_trdy     => so_trdy,
		so_data     => so_data,
		input_clk   => clk,
		input_data  => sample,
		input_ena   => input_dv,
		video_clk   => vga_clk,
		video_pixel => vga_rgb,
		video_hsync => vga_hsync,
		video_vsync => vga_vsync,
		video_blank => open);

--	expansionx4_d(3) <= vga_rgb(1);
	expansionx3_d(4) <= vga_rgb(2);
	expansionx3_d(5) <= vga_rgb(0);
	expansionx3_d(6) <= vga_hsync;
	expansionx3_d(7) <= vga_vsync;

	expansion_g : for i in expansionx3'range generate
	begin
		oreg : OFD1S3AX
		port map (
			sclk => vga_clk,
			d    => expansionx3_d(i),
			q    => expansionx3(i));
	end generate;

	gtx_clk_i : oddrxd1
	port map (
		sclk => phy1_125clk,
		da   => '0',
		db   => '1',
		q    => phy1_gtxclk);

end;
