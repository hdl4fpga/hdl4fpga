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
use hdl4fpga.xdr_db.all;
--use hdl4fpga.cgafont.all;

library unisim;
use unisim.vcomponents.all;

architecture scope of ml509 is
	constant UCLK_PERIOD  : real    := 10.0;
	constant BANK_SIZE    : natural := 2;
	constant ADDR_SIZE    : natural := 13;
	constant WORD_SIZE    : natural := ddr2_d'length;
	constant BYTE_SIZE    : natural := 8;
	constant SCLK_PHASES  : natural := 4;
	constant SCLK_EDGES   : natural := 2;
	constant CMMD_GEAR    : natural := 1;
	constant DATA_GEAR    : natural := 2;
	constant DATA_PHASES  : natural := 2;

	signal ictlr_clk      : std_logic;
	signal ictlr_rdy      : std_logic;

	signal sys_clk        : std_logic;
	signal ddrs_rst       : std_logic;
	signal input_rst      : std_logic;

	signal input_clk      : std_logic;

	signal ddrs_clk0      : std_logic;
	signal ddrs_clk90     : std_logic;

	signal ddr2_dqst      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr2_dqso      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr2_dqsi      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr2_dqo       : std_logic_vector(word_size-1 downto 0);
	signal ddr2_dqt       : std_logic_vector(word_size-1 downto 0);
	signal ddr2_clk       : std_logic_vector(2-1 downto 0);

	signal tp1 : std_logic_vector(ddr2_d'range) := (others  => 'Z');

	signal ddr_b          : std_logic_vector(CMMD_GEAR*2-1 downto 0);
	signal ddr_a          : std_logic_vector(CMMD_GEAR*13-1 downto 0);
	signal ddrphy_cke     : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_cs      : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_ras     : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_cas     : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_we      : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_odt     : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_b       : std_logic_vector(CMMD_GEAR*2-1 downto 0);
	signal ddrphy_a       : std_logic_vector(CMMD_GEAR*13-1 downto 0);
	signal ddrphy_dqsi    : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal ddrphy_dqst    : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal ddrphy_dqso    : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal ddrphy_dmi     : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal ddrphy_dmt     : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal ddrphy_dmo     : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal ddrphy_dqi     : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
	signal ddrphy_dqt     : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal ddrphy_dqo     : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
	signal ddrphy_sto     : std_logic_vector(0 to DATA_GEAR*WORD_SIZE/byte_size-1);
	signal ddrphy_sti     : std_logic_vector(0 to DATA_GEAR*WORD_SIZE/byte_size-1);
	signal ddrphy_ini     : std_logic;
	signal ddrphy_rlreq   : std_logic;
	signal ddrphy_rlrdy   : std_logic;
	signal ddrphy_rlcal   : std_logic;
	signal ddrphy_rw      : std_logic;
	signal ddrphy_cmd_req : std_logic;
	signal ddrphy_cmd_rdy : std_logic;

	signal gtx_clk        : std_logic;
	signal gtx_rst        : std_logic;
	signal mii_rxdv       : std_logic;
	signal mii_rxc        : std_logic;
	signal mii_rxd        : std_logic_vector(phy_rxd'range);
	signal mii_txen       : std_logic;
	signal mii_txd        : std_logic_vector(phy_txd'range);

	signal vga_clk        : std_logic;
	signal vga_hsync      : std_logic;
	signal vga_vsync      : std_logic;
	signal vga_blank      : std_logic;
	signal vga_frm        : std_logic;
	signal vga_red        : std_logic_vector(8-1 downto 0);
	signal vga_green      : std_logic_vector(8-1 downto 0);
	signal vga_blue       : std_logic_vector(8-1 downto 0);
	signal dvdelay        : std_logic_vector(0 to 2);

	signal sys_rst        : std_logic;

	--------------------------------------------------
	-- Frequency   -- 333 Mhz -- 400 Mhz -- 450 Mhz --
	-- Multiply by --  10     --   8     --   9     --
	-- Divide by   --   3     --   2     --   2     --
	--------------------------------------------------

	constant ddr_mul   : natural := 3; --10;
	constant ddr_div   : natural := 1; --3;

	signal ictlr_clk_ibufg : std_logic;
	signal ictlr_rst : std_logic;
begin

	idelay_ibufg_i : IBUFGDS_LVPECL_25
	port map (
		I  => clk_fpga_p,
		IB => clk_fpga_n,
		O  => ictlr_clk_ibufg );

	idelay_bufg_i : BUFG
	port map (
		i => ictlr_clk_ibufg,
		o => ictlr_clk);

	clkin_ibufg : ibufg
	port map (
		I => user_clk,
		O => sys_clk);

	process (gpio_sw_c, ictlr_clk)
		variable tmr : unsigned(0 to 8-1);
	begin
		if gpio_sw_c='1' then
			tmr := (others => '0');
		elsif rising_edge(ictlr_clk) then
			if tmr(0)='0' then
				tmr := tmr + 1;
			end if;
		end if;
		ictlr_rst <= not tmr(0);
	end process;

	idelayctrl_i : idelayctrl
	port map (
		rst => ictlr_rst,
		refclk => ictlr_clk,
		rdy => ictlr_rdy);
	sys_rst <= not ictlr_rdy;

	dcms_e : entity hdl4fpga.dcms
	generic map (
		ddr_mul     => ddr_mul,
		ddr_div     => ddr_div, 
		sys_per     => uclk_period)
	port map (
		sys_rst     => sys_rst,
		sys_clk     => sys_clk,
		input_clk   => input_clk,
		ddr_clk0    => ddrs_clk0,
		ddr_clk90   => ddrs_clk90,
		gtx_clk     => gtx_clk,
		video_clk   => open,
		video_clk90 => open,
		ddr_rst     => ddrs_rst,
		gtx_rst     => gtx_rst);

	ddrphy_dqsi <= (others => ddrs_clk0);
	scope_e : entity hdl4fpga.scope
	generic map (
		FPGA           => virtex5,
		DDR_TCP        => integer(uclk_period*1000.0)*ddr_div/ddr_mul,
		DDR_MARK       => M3,
		CMMD_GEAR      => CMMD_GEAR,
		DDR_SCLKPHASES => sclk_phases,
		DDR_SCLKEDGE   => TRUE,
		DDR_CLMNSIZE   => 7,
		DDR_BANKSIZE   => 2, --ddr2_ba'length,
		DDR_ADDRSIZE   => 13,
		DDR_DATAGEAR   => data_gear,
		DDR_DATAEDGE   => TRUE,
		DDR_DATAPHASES => TRUE,
		DDR_WORDSIZE   => word_size,
		DDR_BYTESIZE   => byte_size)
	port map (
		input_clk      => input_clk,

		ddrs_rst       => ddrs_rst,
		ddrs_clks(0)   => ddrs_clk0,
		ddrs_clks(1)   => ddrs_clk90,
		ddrs_bl        => "011",
		ddrs_cl        => "101",
		ddrs_rtt       => "11",
		ddr_cke        => ddrphy_cke(0),
		ddr_rlreq      => ddrphy_rlreq,
		ddr_rlrdy      => ddrphy_rlrdy,
		ddr_rlcal      => ddrphy_rlcal,
		ddr_phyini     => ddrphy_ini,
		ddr_phyrw      => ddrphy_rw,
		ddr_phycmd_req => ddrphy_cmd_req,
		ddrs_cmd_rdy   => ddrphy_cmd_rdy,
		ddr_cs         => ddrphy_cs(0),
		ddr_ras        => ddrphy_ras(0),
		ddr_cas        => ddrphy_cas(0),
		ddr_we         => ddrphy_we(0),
		ddr_b          => ddr_b(2-1 downto 0),
		ddr_a          => ddr_a(13-1 downto 0),
		ddr_dmi        => ddrphy_dmi,
		ddr_dmt        => ddrphy_dmt,
		ddr_dmo        => ddrphy_dmo,
		ddr_dqst       => ddrphy_dqst,
		ddr_dqsi       => ddrphy_dqsi,
		ddr_dqso       => ddrphy_dqso,
		ddr_dqi        => ddrphy_dqi,
		ddr_dqt        => ddrphy_dqt,
		ddr_dqo        => ddrphy_dqo,
		ddr_odt        => ddrphy_odt(0),
		ddr_sto        => ddrphy_sto,
		ddr_sti        => ddrphy_sti,

		mii_rxc        => mii_rxc,
		mii_rxdv       => mii_rxdv,
		mii_rxd        => mii_rxd,
		mii_txc        => gtx_clk,
		mii_txen       => mii_txen,
		mii_txd        => mii_txd,

		vga_clk        => vga_clk,
		vga_hsync      => vga_hsync,
		vga_vsync      => vga_vsync,
		vga_frm        => vga_frm,
		vga_blank      => vga_blank,
		vga_red        => vga_red,
		vga_green      => vga_green,
		vga_blue       => vga_blue);

	ddrphy_rst(1) <= ddrphy_rst(0);
	ddrphy_cke(1) <= ddrphy_cke(0);
	ddrphy_cs(1)  <= ddrphy_cs(0);
	ddrphy_ras(1) <= '1';
	ddrphy_cas(1) <= '1';
	ddrphy_we(1)  <= '1';
	ddrphy_odt(1) <= ddrphy_odt(0);

	process (ddr_b)
	begin
		for i in ddr_b'range loop
			for j in 0 to CMMD_GEAR-1 loop
				ddrphy_b(i*CMMD_GEAR+j) <= ddr_b(i);
			end loop;
		end loop;
	end process;

	process (ddr_a)
	begin
		for i in ddr_a'range loop
			for j in 0 to CMMD_GEAR-1 loop
				ddrphy_a(i*CMMD_GEAR+j) <= ddr_a(i);
			end loop;
		end loop;
	end process;

	ddrphy_e : entity hdl4fpga.ddrphy
	generic map (
		BANK_SIZE   => 2,
		ADDR_SIZE   => 13,
		data_gear   => data_gear,
		WORD_SIZE   => word_size,
		BYTE_SIZE   => byte_size)
	port map (
		sys_rst     => sys_rst,
		sys_clk0    => ddrs_clk0,
		sys_clk90   => ddrs_clk90, 
		phy_rst     => ddrs_rst,

		sys_cke     => ddrphy_cke,
		sys_cs      => ddrphy_cs,
		sys_ras     => ddrphy_ras,
		sys_cas     => ddrphy_cas,
		sys_we      => ddrphy_we,
		sys_b       => ddrphy_b,
		sys_a       => ddrphy_a,

		sys_rlreq   => ddrphy_rlreq,
		sys_rlrdy   => ddrphy_rlrdy,
		sys_rlcal   => ddrphy_rlcal,
		phy_ini     => ddrphy_ini,
		phy_rw      => ddrphy_rw,
		phy_cmd_rdy => ddrphy_cmd_rdy,
		phy_cmd_req => ddrphy_cmd_req,
		sys_dqst    => ddrphy_dqst,
		sys_dqso    => ddrphy_dqso,
		sys_dmi     => ddrphy_dmo,
		sys_dmt     => ddrphy_dmt,
		sys_dmo     => ddrphy_dmi,
		sys_dqi     => ddrphy_dqi,
		sys_dqt     => ddrphy_dqt,
		sys_dqo     => ddrphy_dqo,
		sys_odt     => ddrphy_odt,
		sys_sti     => ddrphy_sto,
		sys_sto     => ddrphy_sti,
		sysiod_clk  => ictlr_clk,
		sys_tp      => tp1,
		ddr_clk     => ddr2_clk,
		ddr_cke     => ddr2_cke(0),
		ddr_cs      => ddr2_cs(0),
		ddr_ras     => ddr2_ras,
		ddr_cas     => ddr2_cas,
		ddr_we      => ddr2_we,
		ddr_b       => ddr2_ba(2-1 downto 0),
		ddr_a       => ddr2_a(13-1 downto 0),
		ddr_odt     => ddr2_odt(0),

		ddr_dm      => ddr2_dm,
		ddr_dqo     => ddr2_dqo,
		ddr_dqi     => ddr2_d,
		ddr_dqt     => ddr2_dqt,
		ddr_dqst    => ddr2_dqst,
		ddr_dqsi    => ddr2_dqsi,
		ddr_dqso    => ddr2_dqso);

	ddr2_cs (1 downto 1)   <= "1";
  	ddr2_cke(1 downto 1)   <= "0";
	ddr2_odt(1 downto 1)   <= (others => 'Z');
	ddr2_a(14-1 downto 13) <= (others => '0');
	ddr2_ba(3-1 downto  2) <= (others => '0');

	phy_mdc  <= '0';
	phy_mdio <= '0';

	mii_rxc <= not phy_rxclk;

	mii_iob_e : entity hdl4fpga.mii_iob
	generic map (
		xd_len => 8)
	port map (
		mii_rxc  => mii_rxc,
		iob_rxdv => phy_rxctl_rxdv,
		iob_rxd  => phy_rxd,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,

		mii_txc  => gtx_clk,
		mii_txen => mii_txen,
		mii_txd  => mii_txd,
		iob_txen => phy_txctl_txen,
		iob_txd  => phy_txd,
		iob_gtxclk => phy_txc_gtxclk);

	iob_b : block
	begin

		ddr_clks_g : for i in ddr2_clk'range generate
			ddr_ck_obufds : obufds
			generic map (
				iostandard => "DIFF_SSTL18_II")
			port map (
				i  => ddr2_clk(i),
				o  => ddr2_clk_p(i),
				ob => ddr2_clk_n(i));
		end generate;

		ddr_dqs_g : for i in ddr2_dqs_p'range generate
			dqsiobuf_i : iobufds
			generic map (
				iostandard => "DIFF_SSTL18_II_DCI")
			port map (
				t   => ddr2_dqst(i),
				i   => ddr2_dqso(i),
				o   => ddr2_dqsi(i),
				io  => ddr2_dqs_p(i),
				iob => ddr2_dqs_n(i));

		end generate;

		ddr_d_g : for i in ddr2_d'range generate
			ddr2_d(i) <= ddr2_dqo(i) when ddr2_dqt(i)='0' else 'Z';
		end generate;

	end block;
	
	phy_reset  <= not gtx_rst;
	phy_txer   <= '0';
	phy_mdc    <= '0';
	phy_mdio   <= '0';

	dvi_reset  <= '0';
	dvi_xclk_p <= 'Z';
	dvi_xclk_n <= 'Z';
	dvi_v      <= 'Z';
	dvi_h      <= 'Z';
	dvi_de     <= 'Z';
	dvi_d      <= (others => 'Z');
	dvi_gpio1  <= '1';

	tp_g : for i in 0 to 8-1 generate
		gpio_led(i) <= tp1(i*8+1) when gpio_sw_n='1' else tp1(i*8+2) when gpio_sw_e='1' else tp1(i*8+0) when gpio_sw_w='1' else tp1(i*8+5) ;
	end generate;

	gpio_led_n <= '0';
	gpio_led_s <= '0';
	gpio_led_w <= '0';
	gpio_led_e <= '0';
	gpio_led_c <= ddrphy_ini;

	bus_error  <= (others => 'Z');

	fpga_diff_clk_out_p <= 'Z';
	fpga_diff_clk_out_n <= 'Z';


end;
