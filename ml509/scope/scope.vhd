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

library unisim;
use unisim.vcomponents.all;

architecture scope of ml509 is
	constant SCLK_PHASES  : natural := 4;
	constant SCLK_EDGES   : natural := 2;
	constant DATA_PHASES  : natural := 2;
	constant DATA_EDGES   : natural := 2;
	constant CMMD_GEAR    : natural := 1;
	constant BANK_SIZE    : natural := 2;
	constant ADDR_SIZE    : natural := 13;
	constant WORD_SIZE    : natural := ddr2_d'length;
	constant DATA_GEAR    : natural := 2;
	constant BYTE_SIZE    : natural := 8;
	constant UCLK_PERIOD  : real := 10.0;

	signal ictlr_clk_bufg : std_logic;
	signal ictlr_clk      : std_logic;
	signal ictlr_rdy      : std_logic;

	signal sys_clk        : std_logic;
	signal ddrs_rst       : std_logic;
	signal input_rst      : std_logic;

	signal input_clk      : std_logic;
	signal input_rdy      : std_logic;
	signal input_req      : std_logic;
	signal input_data     : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
	constant g : std_logic_vector(input_data'length downto 1) := (128 => '1', 127 => '1', 126 => '1', 121 => '1', others => '0');

	signal ddrs_clk0      : std_logic;
	signal ddrs_clk90     : std_logic;
	signal ddr_b          : std_logic_vector(BANK_SIZE-1 downto 0);
	signal ddr_a          : std_logic_vector(ADDR_SIZE-1 downto 0);

	signal ddr2_clk       : std_logic_vector(2-1 downto 0);
	signal ddr2_dqst      : std_logic_vector(ddr2_dqs_p'range);
	signal ddr2_dqso      : std_logic_vector(ddr2_dqs_p'range);
	signal ddr2_dqsi      : std_logic_vector(ddr2_dqs_p'range);
	signal ddr2_dqo       : std_logic_vector(WORD_SIZE-1 downto 0);
	signal ddr2_dqt       : std_logic_vector(WORD_SIZE-1 downto 0);

	signal ddrphy_cke     : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_cs      : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_ras     : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_cas     : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_we      : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_odt     : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_b       : std_logic_vector(CMMD_GEAR*2-1 downto 0);
	signal ddrphy_a       : std_logic_vector(CMMD_GEAR*ADDR_SIZE-1 downto 0);
	signal ddrphy_dqsi    : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dqst    : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dqso    : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dmi     : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dmt     : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dmo     : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dqi     : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
	signal ddrphy_dqt     : std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddrphy_dqo     : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
	signal ddrphy_sto     : std_logic_vector(0 to DATA_GEAR*WORD_SIZE/BYTE_SIZE-1);
	signal ddrphy_sti     : std_logic_vector(0 to DATA_GEAR*WORD_SIZE/BYTE_SIZE-1);
	signal ddrphy_ini     : std_logic;
	signal ddrphy_act     : std_logic;
	signal ddrphy_rlreq   : std_logic;
	signal ddrphy_rlrdy   : std_logic;
	signal ddrphy_rlcal   : std_logic;
	signal ddrphy_rlseq   : std_logic;
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

	signal sys_rst        : std_logic;
	signal sys_clks       : std_logic_vector(0 to 5-1);
	signal phy_rsts       : std_logic_vector(0 to 3-1);
	signal phy_iodrst     : std_logic;

	--------------------------------------------------
	-- Frequency   -- 333 Mhz -- 400 Mhz -- 450 Mhz --
	-- Multiply by --  10     --   8     --   9     --
	-- Divide by   --   3     --   2     --   2     --
	--------------------------------------------------

	constant DDR_MUL      : natural := 8; --3; --10;
	constant DDR_DIV      : natural := 3; --1; --3;

	signal ictlr_rst      : std_logic;

	signal tp_delay : std_logic_vector(WORD_SIZE/BYTE_SIZE*6-1 downto 0);
	signal tp_bit   : std_logic_vector(WORD_SIZE/BYTE_SIZE*5-1 downto 0);
	signal tst : std_logic;
	signal tp_sel : std_logic_vector(0 to unsigned_num_bits(WORD_SIZE/BYTE_SIZE-1)-1);

	constant ddr_bytes : std_logic_vector(ddr2_d'length/BYTE_SIZE-1 downto 0) := (0 => '1', 7 => '1', others => '0');
	signal ddr_d    : std_logic_vector(WORD_SIZE-1 downto 0);
	signal ddr_dmi  : std_logic_vector(WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddr_dmo  : std_logic_vector(WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddr_dmt  : std_logic_vector(WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddr_dqst : std_logic_vector(WORD_SIZE/BYTE_SIZE-1 downto 0);
	signal ddr_dqso : std_logic_vector(WORD_SIZE/BYTE_SIZE-1 downto 0);

	attribute keep : string;
	attribute keep of ddr2_dqsi   : signal is "TRUE";
	attribute keep of ddrphy_dqso : signal is "TRUE";
begin

	idelay_ibufg_i : IBUFGDS_LVPECL_25
	port map (
		I  => clk_fpga_p,
		IB => clk_fpga_n,
		O  => ictlr_clk_bufg );

	idelay_bufg_i : BUFG
	port map (
		i => ictlr_clk_bufg,
		o => ictlr_clk);

	clkin_ibufg : ibufg
	port map (
		I => user_clk,
		O => sys_clk);

	process (gpio_sw_c, ictlr_clk)
		variable tmr : unsigned(0 to 8-1) := (others => '0');
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
		rst    => ictlr_rst,
		refclk => ictlr_clk,
		rdy    => ictlr_rdy);

	sys_rst <= not ictlr_rdy;
	dcms_e : entity hdl4fpga.dcms
	generic map (
		ddr_mul     => ddr_mul,
		ddr_div     => ddr_div, 
		sys_per     => UCLK_PERIOD)
	port map (
		sys_rst     => sys_rst,
		sys_clk     => sys_clk,
		input_clk   => input_clk,
		ddr_clk0    => ddrs_clk0,
		ddr_clk90   => ddrs_clk90,
		gtx_clk     => gtx_clk,
		input_rst   => input_rst,
		ddr_rst     => ddrs_rst,
		gtx_rst     => gtx_rst);

	testpattern_e : entity hdl4fpga.lfsr_gen
	generic map (
		g => g)
	port map (
		clk => input_clk,
		rst => input_rst,
		req => input_req,
		so  => input_data);

	ddrphy_ini <= ddrphy_rlreq;
	input_rdy <= not input_rst;
	scope_e : entity hdl4fpga.scope
	generic map (
--		MAC_DESTADDR => x"00270e0ff595",	-- MAC Destination Address UNSAM
--		MAC_DESTADDR => x"00270e0a90e9",	-- MAC Destination Address casa
		DDR_TESTCORE   => FALSE,

		fpga           => VIRTEX5,
		DDR_MARK       => M3,
		DDR_TCP        => integer(UCLK_PERIOD*1000.0)*ddr_div/ddr_mul,
		DDR_SCLKEDGES  => SCLK_EDGES,
		DDR_STROBE     => "INTERNAL",
		DDR_CLMNSIZE   => 7,
		DDR_BANKSIZE   => BANK_SIZE,
		DDR_ADDRSIZE   => ADDR_SIZE,
		DDR_CMMDGEAR   => CMMD_GEAR,
		DDR_SCLKPHASES => SCLK_PHASES,
		DDR_DATAPHASES => DATA_PHASES,
		DDR_DATAEDGES  => DATA_EDGES,
		DDR_DATAGEAR   => DATA_GEAR,
		DDR_WORDSIZE   => WORD_SIZE,
		DDR_BYTESIZE   => BYTE_SIZE)
	port map (

		input_clk      => input_clk,
		input_req      => input_req,
		input_rdy      => input_rdy,
		input_data     => input_data,

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
		ddr_rlseq      => ddrphy_rlseq,
		ddr_phyini     => ddrphy_ini,
		ddr_phyrw      => ddrphy_rw,
		ddr_phycmd_req => ddrphy_cmd_req,
		ddrs_cmd_rdy   => ddrphy_cmd_rdy,
		ddrs_act       => ddrphy_act,
		ddr_cs         => ddrphy_cs(0),
		ddr_ras        => ddrphy_ras(0),
		ddr_cas        => ddrphy_cas(0),
		ddr_we         => ddrphy_we(0),
		ddr_b          => ddr_b,
		ddr_a          => ddr_a,
		ddr_dmi        => ddrphy_dmi,
		ddr_dmt        => ddrphy_dmt,
		ddr_dmo        => ddrphy_dmo,
		ddr_dqst       => ddrphy_dqst,
		ddr_dqsi       => ddrphy_dqso,
		ddr_dqso       => ddrphy_dqsi,
		ddr_dqi        => ddrphy_dqo,
		ddr_dqt        => ddrphy_dqt,
		ddr_dqo        => ddrphy_dqi,
		ddr_odt        => ddrphy_odt(0),
		ddr_sto        => ddrphy_sto,
		ddr_sti        => ddrphy_sti,

--		mii_rst        => mii_rst,
		mii_rxc        => mii_rxc,
		mii_rxdv       => mii_rxdv,
		mii_rxd        => mii_rxd,
		mii_txc        => gtx_clk,
		mii_txen       => mii_txen,
		mii_txd        => mii_txd);
	
	gear_g : for i in 1 to CMMD_GEAR-1 generate
		ddrphy_cke(i) <= ddrphy_cke(0);
		ddrphy_cs(i)  <= ddrphy_cs(0);
		ddrphy_ras(i) <= '1';
		ddrphy_cas(i) <= '1';
		ddrphy_we(i)  <= '1';
		ddrphy_odt(i) <= ddrphy_odt(0);
	end generate;

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

	sys_clks <= (0 => ddrs_clk0, 1 => ddrs_clk90, 2 => sys_clk, 3 => ddrs_clk0, 4 => ddrs_clk90);
	phy_rsts <= (0 => ddrs_rst, 2 => phy_iodrst, others => '0');
	process (sys_rst, sys_clk)
		variable sync : std_logic;
	begin
		if sys_rst='1' then
			phy_iodrst <= '1';
			sync := '1';
		elsif rising_edge(sys_clk) then
			phy_iodrst <= sync;
			sync := '0';
		end if;
	end process;

	ddrphy_e : entity hdl4fpga.ddrphy
	generic map (
		LOOPBACK    => FALSE,
		BANK_SIZE   => BANK_SIZE,
		ADDR_SIZE   => ADDR_SIZE,
		DATA_GEAR   => DATA_GEAR,
		WORD_SIZE   => WORD_SIZE,
		BYTE_SIZE   => BYTE_SIZE)
	port map (
		phy_rst     => phy_rsts(0),
		sys_clks    => sys_clks(0 to 1),
		sys_rst     => (others => '-'),
		sys_cke     => ddrphy_cke,
		sys_cs      => ddrphy_cs,
		sys_ras     => ddrphy_ras,
		sys_cas     => ddrphy_cas,
		sys_we      => ddrphy_we,
		sys_b       => ddrphy_b,
		sys_a       => ddrphy_a,

		sys_dqst    => ddrphy_dqst,
		sys_dqso    => ddrphy_dqso,
		sys_dqsi    => ddrphy_dqsi,
		sys_dmi     => ddrphy_dmo,
		sys_dmt     => ddrphy_dmt,
		sys_dmo     => ddrphy_dmi,
		sys_dqi     => ddrphy_dqi,
		sys_dqt     => ddrphy_dqt,
		sys_dqo     => ddrphy_dqo,
		sys_odt     => ddrphy_odt,
		sys_sti     => ddrphy_sto,
		sys_sto     => ddrphy_sti,
		ddr_clk     => ddr2_clk,
		ddr_cke     => ddr2_cke(0),
		ddr_cs      => ddr2_cs(0),
		ddr_ras     => ddr2_ras,
		ddr_cas     => ddr2_cas,
		ddr_we      => ddr2_we,
		ddr_b       => ddr2_ba(BANK_SIZE-1 downto 0),
		ddr_a       => ddr2_a(ADDR_SIZE-1 downto 0),
		ddr_odt     => ddr2_odt(0),

		ddr_dmt     => ddr_dmt(WORD_SIZE/BYTE_SIZE-1 downto 0),
		ddr_dmi     => ddr_dmi(WORD_SIZE/BYTE_SIZE-1 downto 0),
		ddr_dmo     => ddr_dmo(WORD_SIZE/BYTE_SIZE-1 downto 0),
		ddr_dqo     => ddr2_dqo,
		ddr_dqi     => ddr_d(WORD_SIZE-1 downto 0),
		ddr_dqt     => ddr2_dqt,
		ddr_dqst    => ddr2_dqst(WORD_SIZE/BYTE_SIZE-1 downto 0),
		ddr_dqsi    => ddr2_dqsi(WORD_SIZE/BYTE_SIZE-1 downto 0),
		ddr_dqso    => ddr2_dqso(WORD_SIZE/BYTE_SIZE-1 downto 0));

	ddr2_a(14-1 downto ADDR_SIZE) <= (others => '0');
	ddr2_ba(3-1 downto 2)  <= (others => '0');
	ddr2_cs(1 downto 1)    <= "1";
  	ddr2_cke(1 downto 1)   <= "0";
	ddr2_odt(1 downto 1)   <= (others => 'Z');
	ddr2_d(ddr2_d'left downto WORD_SIZE) <= (others => 'Z');

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

		ddr_dq_g : for i  in WORD_SIZE-1 downto 0 generate
			idelay_i : idelay
			port map (
				rst => '0',
				i   => ddr2_d(i),
				c   => '0',
				ce  => '0',
				inc => '0',
				o   => ddr_d(i));
--			ddr_d(i) <= ddr2_d(i);
		end generate;

		ddr_dqs_g : for i in ddr2_dqs_p'range generate
			signal dqsi : std_logic;
			attribute keep of dqsi        : signal is "TRUE";
		begin
			dmidelay_i : idelay
			port map (
				rst => '0',
				i   => ddr2_dm(i),
				c   => '0',
				ce  => '0',
				inc => '0',
				o   => ddr_dmi(i));
--			ddr_dmi(i) <= ddr2_dm(i);

			ddr2_dm(i) <= ddr_dmo(i) when ddr_dmt(i)='0' else 'Z';

			dqsiobuf_i : iobufds
			generic map (
				iostandard => "DIFF_SSTL18_II_DCI")
			port map (
				t   => ddr2_dqst(i),
				i   => ddr2_dqso(i),
				o   => dqsi,
				io  => ddr2_dqs_p(i),
				iob => ddr2_dqs_n(i));
			
			dqsidelay_i : idelay
			port map (
				rst => '0',
				i   => dqsi,
				c   => '0',
				ce  => '0',
				inc => '0',
				o   => ddr2_dqsi(i));
--			ddr2_dqsi(i) <= dqsi;
		end generate;

		ddr_d_g : for i in 0 to WORD_SIZE-1 generate
			ddr2_d(i) <= ddr2_dqo(i) when ddr2_dqt(i)='0' else 'Z';
		end generate;

	end block;
	
	phy_reset  <= not gtx_rst;
	phy_txer   <= '0';
	phy_mdc    <= '0';
	phy_mdio   <= '0';

	dvi_gpio1  <= '1';
	dvi_reset  <= '0';
	dvi_xclk_p <= 'Z';
	dvi_xclk_n <= 'Z';
	dvi_v      <= 'Z';
	dvi_h      <= 'Z';
	dvi_de     <= 'Z';
	dvi_d      <= (others => 'Z');

	sel_b : block
		signal clk : std_logic;
	begin
		process (gpio_sw_w, gpio_sw_e)
		begin
			if gpio_sw_w='1' then
				clk <= '1';
			elsif gpio_sw_e='1' then
				clk <= '0';
			end if;
		end process;

		process (gpio_sw_c, clk)
			variable sel : unsigned(tp_sel'range);
		begin
			if gpio_sw_c='1' then
				sel := (others => '0');
			elsif rising_edge(clk) then
				sel := sel + 1;
			end if;
			tp_sel <= std_logic_vector(sel);
		end process;
	end block;

	gpio_led <= 
		reverse("00" & word2byte (word => tp_delay, addr => tp_sel)) when gpio_sw_n='0' else
		reverse(std_logic_vector(resize(unsigned(tp_sel),gpio_led'length)));

	bus_error <= (others => 'Z');
	(0 => gpio_led_n, 1 => gpio_led_s, 2 => gpio_led_w, 3 => gpio_led_e, 4 => gpio_led_c) <= 
		word2byte(word => tp_bit, addr => tp_sel);
	fpga_diff_clk_out_p <= 'Z';
	fpga_diff_clk_out_n <= 'Z';

end;
