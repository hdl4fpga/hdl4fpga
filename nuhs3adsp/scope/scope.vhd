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

architecture scope of nuhs3adsp is

	constant sclk_phases : natural := 4;
	constant sclk_edges  : natural := 2;
	constant data_phases : natural := 2;
	constant data_edges  : natural := 2;
	constant cmmd_gear   : natural := 1;
	constant bank_size   : natural := 2;
	constant addr_size   : natural := 13;
	constant DATA_GEAR   : natural := 2;
	constant word_size   : natural := 16;
	constant byte_size   : natural := 8;

	constant sys_per : real    := 50.0;
	signal sys_rst   : std_logic;
	signal sys_clk : std_logic;

	signal video_clk : std_logic;

	signal ddrs_rst  : std_logic;
	signal vga_rst   : std_logic;

	signal input_rst : std_logic;
	signal input_clk : std_logic;
	signal input_rdy  : std_logic;
	signal input_req  : std_logic;
	signal input_data : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
	constant g  : std_logic_vector(input_data'length downto 1) := (32 => '1', 30 => '1', 26 => '1', 25 => '1', others => '0');

	--------------------------------------------------
	-- Frequency   -- 133 Mhz -- 166 Mhz -- 200 Mhz --
	-- Multiply by --  20     --  25     --  10     --
	-- Divide by   --   3     --   3     --   1     --
	--------------------------------------------------

	constant ddr_mul   : natural := 25;
	constant ddr_div   : natural :=  3;
	constant clk0      : natural :=  0;
	constant clk90     : natural :=  1;
	signal ddrs_clks   : std_logic_vector(0 to 2-1);

	signal ddr_dqst    : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr_dqso    : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr_dqt     : std_logic_vector(ddr_dq'range);
	signal ddr_dqo     : std_logic_vector(ddr_dq'range);
	signal ddr_clk     : std_logic_vector(0 downto 0);
	signal ddr_lp_clk  : std_logic;
	signal ddr_sto1_open : std_logic;

	signal ddrphy_cke  : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_cs   : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_ras  : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_cas  : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_we   : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_odt  : std_logic_vector(CMMD_GEAR-1 downto 0);
	signal ddrphy_b    : std_logic_vector(CMMD_GEAR*ddr_ba'length-1 downto 0);
	signal ddrphy_a    : std_logic_vector(CMMD_GEAR*ddr_a'length-1 downto 0);
	signal ddrphy_dqsi : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal ddrphy_dqst : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal ddrphy_dqso : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal ddrphy_dmi  : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal ddrphy_dmt  : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal ddrphy_dmo  : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal ddrphy_dqi  : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);

	signal ddrphy_dqt  : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal ddrphy_dqo  : std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
	signal ddrphy_sto  : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);
	signal ddrphy_sti  : std_logic_vector(DATA_GEAR*WORD_SIZE/byte_size-1 downto 0);

	signal rxdv : std_logic;
	signal rxd  : std_logic_vector(mii_rxd'range);
	signal txen : std_logic;
	signal txd  : std_logic_vector(mii_txd'range);

	signal vga_clk   : std_logic;
	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;
	signal vga_blank : std_logic;
	signal vga_frm   : std_logic;
	signal vga_red   : std_logic_vector(8-1 downto 0);
	signal vga_green : std_logic_vector(8-1 downto 0);
	signal vga_blue  : std_logic_vector(8-1 downto 0);

begin

	clkin_ibufg : ibufg
	port map (
		I => xtal,
		O => sys_clk);

	sys_rst <= not sw1;

	dcms_e : entity hdl4fpga.dcms
	generic map (
		ddr_mul   => ddr_mul,
		ddr_div   => ddr_div,
		sys_per   => sys_per)
	port map (
		sys_rst   => sys_rst,
		sys_clk   => sys_clk,
		input_clk => input_clk,
		ddr_clk0  => ddrs_clks(clk0),
		ddr_clk90 => ddrs_clks(clk90),
		video_clk => video_clk,
		mii_clk   => mii_refclk,
		input_rst => input_rst,
		ddr_rst   => ddrs_rst, 
    	mii_rst   => mii_rst,  
		video_rst => vga_rst);

	testpattern_e : entity hdl4fpga.lfsr_gen
	generic map (
		g => g)
	port map (
		clk => input_clk,
		rst => input_rst,
		req => input_req,
		so  => input_data);

	input_rdy <= not input_rst;
	scope_e : entity hdl4fpga.scope
	generic map (
--		MAC_DESTADDR => x"00270e0ff595",	-- MAC Destination Address UNSAM
--		MAC_DESTADDR => x"00270e0a90e9",	-- MAC Destination Address casa
		DDR_TESTCORE   => "FALSE",
		FPGA            => SPARTAN3,
		DDR_MARK        => M6T,
		DDR_TCP         => integer(sys_per*1000.0)*ddr_div/ddr_mul,
		DDR_SCLKEDGES   => SCLK_EDGES,
		DDR_STROBE      => "INTERNAL",
		DDR_CLMNSIZE    => 6,
		DDR_BANKSIZE    => ddr_ba'length,
		DDR_ADDRSIZE    => ddr_a'length,
		DDR_SCLKPHASES  => sclk_phases,
		DDR_DATAPHASES  => data_phases,
		DDR_DATAEDGES   => data_edges,
		DDR_DATAGEAR    => DATA_GEAR,
		ddr_cmmdgear    => CMMD_GEAR,
		DDR_WORDSIZE    => word_size,
		DDR_BYTESIZE    => byte_size)
	port map (
		input_clk      => input_clk,
		input_req      => input_req,
		input_rdy      => input_rdy,
		input_data     => input_data,

		ddrs_rst       => ddrs_rst,
		ddrs_clks(0)   => ddrs_clks(clk0),
		ddrs_clks(1)   => ddrs_clks(clk90),
		ddrs_bl        => "011",
		ddrs_cl        => "110",
		ddrs_rtt       => "--",
		ddr_cke        => ddrphy_cke(0),
		ddr_cs         => ddrphy_cs(0),
		ddr_ras        => ddrphy_ras(0),
		ddr_cas        => ddrphy_cas(0),
		ddr_we         => ddrphy_we(0),
		ddr_b          => ddrphy_b(ddr_ba'length-1 downto 0),
		ddr_a          => ddrphy_a(ddr_a'length-1 downto 0),
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
		ddr_sto        => ddrphy_sti,
		ddr_sti        => ddrphy_sto,

--		mii_rst        => mii_rst,
		mii_rxc        => mii_rxc,
		mii_rxdv       => rxdv,
		mii_rxd        => rxd,
		mii_txc        => mii_txc,
		mii_txen       => txen,
		mii_txd        => txd);

	ddrphy_e : entity hdl4fpga.ddrphy
	generic map (
		loopback => TRUE,
		registered_dout => false,
		BANK_SIZE => ddr_ba'length,
		ADDR_SIZE => ddr_a'length,
		cmmd_gear => CMMD_GEAR,
		data_gear => DATA_GEAR,
		WORD_SIZE => word_size,
		BYTE_SIZE => byte_size)
	port map (
		sys_clks(clk0)  => ddrs_clks(clk0),
		sys_clks(clk90) => ddrs_clks(clk90), 
		phy_rst => ddrs_rst,

		sys_cke => ddrphy_cke,
		sys_cs  => ddrphy_cs,
		sys_ras => ddrphy_ras,
		sys_cas => ddrphy_cas,
		sys_we  => ddrphy_we,
		sys_b   => ddrphy_b,
		sys_a   => ddrphy_a,
		sys_dqsi => ddrphy_dqsi,
		sys_dqst => ddrphy_dqst,
		sys_dqso => ddrphy_dqso,
		sys_dmi => ddrphy_dmo,
		sys_dmt => ddrphy_dmt,
		sys_dmo => ddrphy_dmi,
		sys_dqi => ddrphy_dqi,
		sys_dqt => ddrphy_dqt,
		sys_dqo => ddrphy_dqo,
		sys_odt => ddrphy_odt,
		sys_sti => ddrphy_sti,
		sys_sto => ddrphy_sto,

		ddr_clk => ddr_clk,
		ddr_cke => ddr_cke,
		ddr_cs  => ddr_cs,
		ddr_ras => ddr_ras,
		ddr_cas => ddr_cas,
		ddr_we  => ddr_we,
		ddr_b   => ddr_ba,
		ddr_a   => ddr_a,

		ddr_sto(0) => ddr_st_dqs,
		ddr_sto(1) => ddr_sto1_open,
		ddr_sti(0) => ddr_st_lp_dqs,
		ddr_sti(1) => ddr_st_lp_dqs,
		ddr_dm  => ddr_dm,
		ddr_dqt  => ddr_dqt,
		ddr_dqi  => ddr_dq,
		ddr_dqo  => ddr_dqo,
		ddr_dqst => ddr_dqst,
		ddr_dqsi => ddr_dqs,
		ddr_dqso => ddr_dqso);

	ddr_dqs_g : for i in ddr_dqs'range generate
		ddr_dqs(i) <= ddr_dqso(i) when ddr_dqst(i)='0' else 'Z';
	end generate;

	process (ddr_dqt, ddr_dqo)
	begin
		for i in ddr_dq'range loop
			ddr_dq(i) <= 'Z';
			if ddr_dqt(i)='0' then
				ddr_dq(i) <= ddr_dqo(i);
			end if;
		end loop;
	end process;

	ddr_clk_i : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => ddr_clk(0),
		o  => ddr_ckp,
		ob => ddr_ckn);

	adcclkab_iob_b : block
		signal clk_n : std_logic;
	begin
		clk_n <= input_clk;
		oddr_i : oddr2
		port map (
			r => '0',
			s => '0',
			c0 => input_clk,
			c1 => clk_n,
			ce => '1',
			d0 => '0',
			d1 => '1',
			q => adc_clkab);
	end block;

	vga_iob_e : entity hdl4fpga.adv7125_iob
	port map (
		sys_clk   => video_clk,
		sys_hsync => vga_hsync,
		sys_vsync => vga_vsync,
		sys_blank => vga_blank,
		sys_red   => vga_red,
		sys_green => vga_green,
		sys_blue  => vga_blue,

		vga_clk => clk_videodac,
		vga_hsync => hsync,
		vga_vsync => vsync,
		dac_blank => blank,
		dac_sync  => sync,
		dac_psave => psave,

		dac_red   => red,
		dac_green => green,
		dac_blue  => blue);

	mii_mdc  <= '0';
	mii_mdio <= '0';

	mii_iob_e : entity hdl4fpga.mii_iob
	generic map (
		xd_len => mii_txd'length)
	port map (
		mii_rxc  => mii_rxc,
		iob_rxdv => mii_rxdv,
		iob_rxd  => mii_rxd,
		mii_rxdv => rxdv,
		mii_rxd  => rxd,

		mii_txc  => mii_txc,
		mii_txen => txen,
		mii_txd  => txd,
		iob_txen => mii_txen,
		iob_txd  => mii_txd);

	hd_t_data <= 'Z';

	-- LEDs DAC --
	--------------
		
	led18 <= '0';
	led16 <= '0';
	led15 <= '0';
	led13 <= '0';
	led11 <= '0';
	led9  <= '0';
	led8  <= '0';
	led7  <= not sys_rst;

	-- RS232 Transceiver --
	-----------------------

	rs232_rts <= '0';
	rs232_td  <= '0';
	rs232_dtr <= '0';

	-- Ethernet Transceiver --
	--------------------------

	mii_mdc  <= '0';
	mii_mdio <= 'Z';

	-- LCD --
	---------

	lcd_e <= 'Z';
	lcd_rs <= 'Z';
	lcd_rw <= 'Z';
	lcd_data <= (others => 'Z');
	lcd_backlight <= 'Z';

end;
