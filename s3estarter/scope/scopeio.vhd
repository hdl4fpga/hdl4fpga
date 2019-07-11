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

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture beh of s3estarter is

	signal sys_clk    : std_logic;
	signal vga_clk    : std_logic;

	constant sample_size : natural := 14;

	constant inputs  : natural := 2;
	constant baudrate : natural := 115200;

	signal sample    : std_logic_vector(inputs*sample_size-1 downto 0);
	signal spi_clk   : std_logic;
	signal spiclk_rd : std_logic;
	signal spiclk_fd : std_logic;
	signal sckamp_rd : std_logic;
	signal sckamp_fd : std_logic;
	signal amp_spi   : std_logic;
	signal amp_sdi   : std_logic;
	signal amp_rdy   : std_logic;
	signal adc_spi   : std_logic;
	signal ampcs     : std_logic;
	signal spi_rst   : std_logic;
	signal dac_sdi   : std_logic;
	signal input_ena : std_logic;
	signal tdiv      : std_logic_vector(4-1 downto 0) := b"1111";
	signal vga_rgb   : std_logic_vector(3-1 downto 0);
	signal ipcfg_req : std_logic;

	signal uart_rxc  : std_logic;
	signal uart_sin  : std_logic;
	signal uart_ena  : std_logic;
	signal uart_rxdv : std_logic;
	signal uart_rxd  : std_logic_vector(8-1 downto 0);

	signal toudpdaisy_clk  : std_logic;
	signal toudpdaisy_frm  : std_logic;
	signal toudpdaisy_irdy : std_logic;
	signal toudpdaisy_data : std_logic_vector(e_rxd'range);

	signal si_clk    : std_logic;
	signal si_frm    : std_logic;
	signal si_irdy   : std_logic;
	signal si_data   : std_logic_vector(8-1 downto 0);

	signal so_clk    : std_logic;
	signal so_frm    : std_logic;
	signal so_trdy   : std_logic;
	signal so_irdy   : std_logic;
	signal so_data   : std_logic_vector(8-1 downto 0);

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

	constant video_mode : natural := mode1080p;

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
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => vga_clk);

	spi_b: block
	begin

		spidcm_e : entity hdl4fpga.dfs2dfs
		generic map (
			dcm_per  => 20.0,
			dfs1_mul => 32,
			dfs1_div => 25,
			dfs2_mul => 17,
			dfs2_div => 25)
		port map(
			dcm_rst  => '0',
			dcm_clk  => sys_clk,
			dfs_clk  => spi_clk,
			dcm_lck  => spi_rst);
--		spi_clk <= sys_clk;
--		spi_rst <= not dfs_rst;


		spiclk_rd <= '0' when spi_rst='0' else sckamp_rd when amp_spi='1' else '0' ;
		spiclk_fd <= '0' when spi_rst='0' else sckamp_fd when amp_spi='1' else '1' ;
		spi_mosi  <= amp_sdi   when amp_spi='1' else dac_sdi;

		spi_sck_e : entity hdl4fpga.ddro
		port map (
			clk => spi_clk,
			dr  => spiclk_rd,
			df  => spiclk_fd,
			q   => spi_sck);

		ampclkr_p : process (spi_rst, spi_clk)
			variable cntr : unsigned(0 to 4-1);
		begin
			if spi_rst='0' then
				cntr := (others => '0');
				sckamp_rd <= cntr(0);
				adc_spi <= '1';
			elsif rising_edge(spi_clk) then
				cntr := cntr + 1;
				sckamp_rd <= cntr(0);
				amp_cs <= ampcs;
			end if;
		end process;

		ampclkf_p : process (spi_rst, spi_clk)
		begin
			if spi_rst='0' then
				sckamp_fd <= '0';
			elsif falling_edge(spi_clk) then
				sckamp_fd <= sckamp_rd;
			end if;
		end process;

		ampp2sr_p : process (spi_rst, sckamp_fd)
		begin
			if spi_rst='0' then
				ampcs <= '1';
			elsif falling_edge(sckamp_fd) then
				ampcs <= not amp_rdy or not amp_spi;
			end if;
		end process;

		amp_p : process (spi_rst, sckamp_fd)
			variable cntr : unsigned(0 to 4);
			variable val  : unsigned(0 to 8-1);
		begin
			if spi_rst='0' then
				amp_spi <= '1';
				amp_rdy <= '0';
				amp_sdi <= '0';
				cntr    := to_unsigned(val'length-2,cntr'length);
				val     := B"0001_0001";
			elsif falling_edge(sckamp_fd) then
				if ampcs='0' then
					if cntr(0)='0' then
						cntr := cntr - 1;
						val  := val rol 1;
					end if;
				end if;
				amp_sdi <= val(0);
				amp_rdy <= not cntr(0);
				amp_spi <= not cntr(0) or not ampcs;
			end if;
		end process;

		adcdac_p : process (amp_spi, spi_clk)
			constant p2p        : natural := 2*1550;
			constant cycle      : natural := 34;
			variable cntr       : unsigned(0 to 6) := (others => '0');
			variable adin       : unsigned(32-1 downto 0);
			variable aux        : unsigned(sample'range);
			variable dac_shr    : unsigned(0 to 30-1);
			variable adcdac_sel : std_logic;
			variable dac_data   : unsigned(0 to 12-1);
			variable dac_chan   : unsigned(0 to 2-1);
		begin
			if amp_spi='1' then
				cntr       := to_unsigned(cycle-2, cntr'length);
				adcdac_sel := '0';
				dac_sdi    <= '0';
				dac_cs     <= '1';
			elsif rising_edge(spi_clk) then
				if cntr(0)='1' then
					if adcdac_sel ='0' then
						sample <= std_logic_vector(
							adin(1*16+sample_size-1 downto 1*16) &
							adin(0*16+sample_size-1 downto 0*16));
						input_ena <= not amp_spi;
						ad_conv   <= '0';
					else
						if to_integer(dac_data)=(2048+p2p/2) then
							dac_data := to_unsigned(2048-p2p/2, dac_data'length);
						else
							dac_data := dac_data + 1;
						end if;
						ad_conv <= not amp_spi;
					end if;

					if tdiv=(1 to 4 => '0') then
						adcdac_sel := '0';
						ad_conv    <= '1';
					else 
						adcdac_sel := not adcdac_sel;
					end if;

					dac_shr := (1 to 10 => '-') & "001100" & dac_chan & dac_data;
					cntr    := to_unsigned(cycle-2, cntr'length);
				else
					input_ena <= '0';
					ad_conv   <= '0';
					dac_shr   := dac_shr sll 1;
					cntr      := cntr - 1;
				end if;
				adin    := adin sll 1;
				adin(0) := spi_miso;

				dac_cs  <= not adcdac_sel or amp_spi;
				dac_sdi <= dac_shr(0);
			end if;
		end process;
	end block;

	dhcpreq_p : process (sw0, e_tx_clk)
	begin
		if sw0='1' then
			ipcfg_req <= '0';
			led0      <= '1';
		elsif rising_edge(e_tx_clk) then
			led0      <= '0';
			ipcfg_req <= '1';
		end if;
	end process;

	process (e_rx_clk)
		constant max_count : natural := (25*10**6+16*baudrate/2)/(16*baudrate);
		variable cntr      : unsigned(0 to unsigned_num_bits(max_count-1)-1) := (others => '0');
	begin
		if rising_edge(e_rx_clk) then
			if cntr >= max_count-1 then
				uart_ena <= '1';
				cntr := (others => '0');
			else
				uart_ena <= '0';
				cntr := cntr + 1;
			end if;
		end if;
	end process;

	uart_sin <= rs232_dce_rxd;
	uart_rxc <= e_rx_clk;
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

--	istreamdaisy_e : entity hdl4fpga.scopeio_istreamdaisy
--	generic map (
--		istream_esc => std_logic_vector(to_unsigned(character'pos('\'), 8)),
--		istream_eos => std_logic_vector(to_unsigned(character'pos(NUL), 8)))
--	port map (
--		stream_clk  => uart_rxc,
--		stream_dv   => uart_rxdv,
--		stream_data => uart_rxd,
--
--		chaini_data => uart_rxd,
--
--		chaino_frm  => toudpdaisy_frm, 
--		chaino_irdy => toudpdaisy_irdy,
--		chaino_data => toudpdaisy_data);

	udpipdaisy_e : entity hdl4fpga.scopeio_udpipdaisy
	port map (
		ipcfg_req   => ipcfg_req,

		phy_rxc     => e_rx_clk,
		phy_rx_dv   => e_rx_dv,
		phy_rx_d    => e_rxd,

		phy_txc     => e_tx_clk,
		phy_tx_en   => e_txen,
		phy_tx_d    => e_txd,
	
		chaini_sel  => '0',

		chaini_frm  => toudpdaisy_frm,
		chaini_irdy => toudpdaisy_irdy,
		chaini_data => toudpdaisy_data,

		chaino_frm  => si_frm,
		chaino_irdy => si_irdy,
		chaino_data => si_data);
	
	si_clk <= e_rx_clk;
	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		test => true,
		axis_unit   => std_logic_vector(to_unsigned(25,5)),
		vlayout_id       => video_params(video_mode).layout,
		inputs           => inputs,
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
		si_clk      => si_clk,
		si_frm      => si_frm,
		si_irdy     => si_irdy,
		si_data     => si_data,
		so_irdy     => so_irdy,
		so_data     => so_data,
		input_clk   => spi_clk,
		input_ena   => input_ena,
		input_data  => sample,
		video_clk   => vga_clk,
		video_pixel => vga_rgb,
		video_hsync => vga_hsync,
		video_vsync => vga_vsync,
		video_blank => open);

	vga_red   <= vga_rgb(2);
	vga_green <= vga_rgb(1);
	vga_blue  <= vga_rgb(0);

	-- Ethernet Transceiver --
	--------------------------

	e_txen <= 'Z';
	e_mdc  <= '0';
	e_mdio <= 'Z';
	e_txd_4 <= '0';

	-- DDR --
	---------

	ddr_clk_i : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => 'Z',
		o  => sd_ck_p,
		ob => sd_ck_n);

	sd_cke    <= 'Z';
	sd_cs     <= 'Z';
	sd_ras    <= 'Z';
	sd_cas    <= 'Z';
	sd_we     <= 'Z';
	sd_ba     <= (others => 'Z');
	sd_a      <= (others => 'Z');
	sd_dm     <= (others => 'Z');
	sd_dqs    <= (others => 'Z');
	sd_dq     <= (others => 'Z');

	amp_shdn <= '0';
	dac_clr <= '1';
	sf_ce0 <= '1';
	fpga_init_b <= '0';
	spi_ss_b <= '0';

	led1 <= '1';
	led2 <= '1';
	led3 <= '1';
	led4 <= '1';
	led5 <= '1';
	led6 <= '1';
	led7 <= '1';

	rs232_dte_txd <= 'Z';
	rs232_dce_txd <= 'Z';
end;
