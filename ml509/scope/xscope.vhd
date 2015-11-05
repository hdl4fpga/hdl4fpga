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
	constant sclk_phases : natural := 2;
	constant data_phases : natural := 2;
	constant cmd_phases : natural := 1;
	constant bank_size : natural := 2;
	constant addr_size : natural := 13;
	constant line_size : natural := 2*16;
	constant word_size : natural := 16;
	constant byte_size : natural := 8;

	constant uclk_period : real := 10.0;

	signal ictlr_clk : std_logic;
	signal ictlr_rdy : std_logic;
	signal ictlr_rst : std_logic;
	signal grst : std_logic;

	signal sys_clk : std_logic;
	signal dcm_rst  : std_logic;
	signal dcm_lckd : std_logic;
	signal ddrs_lckd  : std_logic;
	signal input_lckd : std_logic;

	signal input_clk : std_logic;

	signal ddrs_clk0  : std_logic;
	signal ddrs_clk90 : std_logic;
	signal ddrs_wclks : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
	signal ddrs_wenas : std_logic_vector(data_phases*word_size/byte_size-1 downto 0);

	signal ddr2_dqst : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr2_dqso : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr2_dqsi : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddr2_clk : std_logic;

	signal ddr_lp_clk : std_logic;
	signal tpo : std_logic_vector(0 to 4-1) := (others  => 'Z');

	signal sto : std_logic;
	signal ddrphy_cke : std_logic_vector(cmd_phases-1 downto 0);
	signal ddrphy_cs : std_logic_vector(cmd_phases-1 downto 0);
	signal ddrphy_ras : std_logic_vector(cmd_phases-1 downto 0);
	signal ddrphy_cas : std_logic_vector(cmd_phases-1 downto 0);
	signal ddrphy_we : std_logic_vector(cmd_phases-1 downto 0);
	signal ddrphy_odt : std_logic_vector(cmd_phases-1 downto 0);
	signal ddrphy_b : std_logic_vector(cmd_phases*ddr2_ba'length-1 downto 0);
	signal ddrphy_a : std_logic_vector(cmd_phases*ddr2_a'length-1 downto 0);
	signal ddrphy_dqsi : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dqst : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dqso : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dmi : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dmt : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dmo : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dqi : std_logic_vector(line_size-1 downto 0) := x"f4_f3_f2_f1";
	signal ddrphy_dqi2 : std_logic_vector(line_size-1 downto 0) := x"f4_f3_f2_f1";
	signal ddrphy_dqt : std_logic_vector(line_size/byte_size-1 downto 0);
	signal ddrphy_dqo : std_logic_vector(line_size-1 downto 0);
	signal ddrphy_sto : std_logic_vector(data_phases*line_size/word_size-1 downto 0);
	signal ddrphy_sti : std_logic_vector(data_phases*line_size/word_size-1 downto 0);
	signal ddr_eclkph : std_logic_vector(4-1 downto 0);
	signal ddrphy_wlreq : std_logic;
	signal ddrphy_wlrdy : std_logic;


	signal gtx_clk  : std_logic;
	signal mii_rxdv : std_logic;
	signal mii_rxd  : std_logic_vector(phy_rxd'range);
	signal mii_txen : std_logic;
	signal mii_txd  : std_logic_vector(phy_txd'range);

	signal vga_clk : std_logic;
	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;
	signal vga_blank : std_logic;
	signal vga_frm : std_logic;
	signal vga_red : std_logic_vector(8-1 downto 0);
	signal vga_green : std_logic_vector(8-1 downto 0);
	signal vga_blue  : std_logic_vector(8-1 downto 0);
	signal dvdelay : std_logic_vector(0 to 2);

	signal sys_rst   : std_logic;
	signal valid : std_logic;

	signal wlpha : std_logic_vector(8-1 downto 0);
	--------------------------------------------------
	-- Frequency   -- 333 Mhz -- 400 Mhz -- 450 Mhz --
	-- Multiply by --  10     --   8     --   9     --
	-- Divide by   --   3     --   2     --   2     --
	--------------------------------------------------

	constant ddr_mul   : natural := 10;
	constant ddr_div   : natural := 3;
	constant ddr_fbdiv : natural := 1;
	constant r : natural := 0;
	constant f : natural := 1;
	signal ddr_eclk  : std_logic;

	signal input_rst : std_logic;
	signal ddrs_rst : std_logic;
	signal mii_rst : std_logic;
	signal vga_rst : std_logic;

	signal debug_clk : std_logic;
	signal yyyy : std_logic_vector(ddrphy_a'range);

	function shuffle (
		constant arg : byte_vector)
		return byte_vector is
		variable dat : byte_vector(arg'length-1 downto 0);
		variable val : byte_vector(dat'range);
	begin
		dat := arg;
		for i in 2-1 downto 0 loop
			for j in dat'length/2-1 downto 0 loop
				val(dat'length/2*i+j) := dat(2*j+i);
			end loop;
		end loop;
		return val;
	end;
begin

	clkin_ibufg : ibufg
	port map (
		I => user_clk,
		O => sys_clk);

	process (gpio_sw_c, sys_clk)
		variable aux : std_logic_vector(0 to 3);
	begin
		if gpio_sw_c='1' then
			sys_rst <= '1';
			aux := (others => '0');
		elsif rising_edge(sys_clk) then
			sys_rst <= not aux(0);
			if aux(0)='0' then
				aux := inc(gray(aux));
			end if;
		end if;
	end process;

	dcms_e : entity hdl4fpga.dcms
	generic map (
		ddr_mul => ddr_mul,
		ddr_div => ddr_div, 
		sys_per => uclk_period)
	port map (
		sys_rst => sys_rst,
		sys_clk => sys_clk,
		ictlr_clk => ictlr_clk,
		input_clk => input_clk,
		ddr_clk0 => ddrs_clk0,
		ddr_clk90 => ddrs_clk90,
		video_clk => open,
		video_clk90 => open,
		gtx_clk => gtx_clk,
		dcm_lckd => dcm_lckd);

	grst <= dcm_lckd and ictlr_rdy;
	ictlr_rst <= not dcm_lckd;
	idelayctrl_i : idelayctrl
	port map (
		rst => ictlr_rst,
		refclk => ictlr_clk,
		rdy => ictlr_rdy);

	rsts_b : block
		signal clks : std_logic_vector(0 to 3);
		signal rsts : std_logic_vector(0 to 3);
		signal grst : std_logic;
	begin
		grst    <= grst;
		clks(0) <= input_clk;
		clks(1) <= ddrs_clk0;
		clks(2) <= gtx_clk;
		clks(3) <= vga_clk;

		input_rst <= rsts(0);
		ddrs_rst  <= rsts(1);
		mii_rst   <= rsts(2);
		vga_rst   <= rsts(3);

		rsts_g: for i in clks'range generate
			signal q : std_logic;
		begin
			process (clks(i), dcm_lckd)
			begin
				if dcm_lckd='0' then
					q <= '1';
				elsif rising_edge(clks(i)) then
					q <= not dcm_lckd;
				end if;
			end process;
			rsts(i) <= q;
		end generate;
	end block;

--	ddrphy_sti <= (others => ddrphy_cfgo(0));
	scope_e : entity hdl4fpga.scope
	generic map (
		DDR_MARK => M3,
		DDR_TCP => integer(uclk_period*1000.0)*ddr_div*ddr_fbdiv/ddr_mul,
		DDR_STROBE => "INTERNAL",
		DDR_CLMNSIZE => 7,
		DDR_BANKSIZE => ddr2_ba'length,
		DDR_ADDRSIZE => ddr2_a'length,
		DDR_SCLKPHASES => sclk_phases,
		DDR_DATAPHASES => data_phases,
		DDR_LINESIZE => line_size,
		DDR_WORDSIZE => word_size,
		DDR_BYTESIZE => byte_size,
		xd_len  => 8)
	port map (

--		input_rst => input_rst,
		input_clk => ddrs_clk0, --input_clk,

		ddrs_rst => ddrs_rst,
		ddrs_clks(0) => ddrs_clk0,
		ddrs_clks(1) => ddrs_clk90,
		ddrs_bl  => "011",
		ddrs_cl  => "101",
		ddrs_wclks => ddrs_wclks,
		ddrs_wenas => ddrs_wenas,
		ddr_cke  => ddrphy_cke(0),
		ddr_wlreq => ddrphy_wlreq,
		ddr_wlrdy => ddrphy_wlrdy,
		ddr_cs   => ddrphy_cs(0),
		ddr_ras  => ddrphy_ras(0),
		ddr_cas  => ddrphy_cas(0),
		ddr_we   => ddrphy_we(0),
		ddr_b    => ddrphy_b(ddr2_ba'length-1 downto 0),
		ddr_a    => ddrphy_a(ddr2_a'length-1 downto 0),
		ddr_dmi  => ddrphy_dmi,
		ddr_dmt  => ddrphy_dmt,
		ddr_dmo  => ddrphy_dmo,
		ddr_dqst => ddrphy_dqst,
		ddr_dqsi => ddrphy_dqsi,
		ddr_dqso => ddrphy_dqso,
		ddr_dqi  => ddrphy_dqi2,
		ddr_dqt  => ddrphy_dqt,
		ddr_dqo  => ddrphy_dqo,
		ddr_odt  => ddrphy_odt(0),
		ddr_sto  => ddrphy_sto,
		ddr_sti  => ddrphy_sti,

--		mii_rst  => mii_rst,
		mii_rxc  => phy_rxclk,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,
		mii_txc  => gtx_clk,
		mii_txen => mii_txen,
		mii_txd  => mii_txd,

--		vga_rst   => vga_rst,
		vga_clk   => vga_clk,
		vga_hsync => vga_hsync,
		vga_vsync => vga_vsync,
		vga_frm   => vga_frm,
		vga_blank => vga_blank,
		vga_red   => vga_red,
		vga_green => vga_green,
		vga_blue  => vga_blue,
		tpo => tpo);

	sto <= ddrphy_sto(0);

	process (ddrs_clk0)
		variable q : std_logic_vector(0 to 2);
	begin
		if rising_edge(ddrs_clk0) then
			q := q(1 to q'right) & ddrphy_sto(0);
			ddrphy_sti <= (others => q(0));
		end if;
	end process;

	ddrphy_dqi2 <= ddrphy_dqi;

	ddrphy_e : entity hdl4fpga.ddrphy
	generic map (
		BANK_SIZE => ddr2_ba'length,
		ADDR_SIZE => ddr2_a'length,
		LINE_SIZE => line_size,
		WORD_SIZE => word_size,
		BYTE_SIZE => byte_size)
	port map (
		sys_clk0 => ddrs_clk0,
		sys_clk90 => ddrs_clk90, 
		phy_rst => ddrs_rst,
		sys_wclks => ddrs_wclks,
		sys_wenas => ddrs_wenas,

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

		ddr_clk => ddr2_clk,
		ddr_cke => ddr2_cke(0),
		ddr_cs  => ddr2_cs(0),
		ddr_ras => ddr2_ras,
		ddr_cas => ddr2_cas,
		ddr_we  => ddr2_we,
		ddr_b   => ddr2_ba,
		ddr_a   => ddr2_a,

--		ddr_dm  => ddr2_dm,
		ddr_dq  => ddr2_d(word_size-1 downto 0),
		ddr_dqst => ddr2_dqst,
		ddr_dqsi => ddr2_dqsi,
		ddr_dqso => ddr2_dqso);
	ddr2_dm <= (others => '0');

	phy_reset  <= dcm_lckd;
	phy_mdc  <= '0';
	phy_mdio <= '0';

	mii_iob_e : entity hdl4fpga.mii_iob
	generic map (
		xd_len => 8)
	port map (
		mii_rxc  => phy_rxclk,
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

	ddr2_dqs_g : for i in ddr2_dqsi'range generate
		signal dqsi : std_logic;
		signal st   : std_logic;
	begin

--		dqsidelay_i : idelay 
--		port map (
--			rst => ictlr_rst,
--			c   => '0',
--			ce  => '0',
--			inc => '0',
--			i   => dqsi,
--			o   => ddr_dqsi(i));

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

	ddr_ck_obufds : obufds
	generic map (
		iostandard => "DIFF_SSTL18_II")
	port map (
		i  => ddr2_clk,
		o  => ddr2_clk_p(0),
		ob => ddr2_clk_n(0));
end;
