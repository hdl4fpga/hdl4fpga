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

use std.textio.all;

entity scope is
	generic (
		constant FPGA           : natural;
		constant DDR_TCP        : natural;
		constant DDR_SCLKPHASES : natural;
		constant DDR_SCLKEDGE   : boolean;
		constant DDR_MARK       : natural;
		constant DDR_CMMDGEAR   : natural;
		constant DDR_BANKSIZE   : natural :=  3;
		constant DDR_ADDRSIZE   : natural := 13;
		constant DDR_CLMNSIZE   : natural :=  6;
		constant DDR_DATAGEAR   : natural :=  2;
		constant DDR_DATAPHASES : natural :=  2;
		constant DDR_DATAEDGE   : boolean := TRUE;
		constant DDR_WORDSIZE   : natural := 16;
		constant DDR_BYTESIZE   : natural :=  8;

		constant PAGE_SIZE      : natural :=  9;
		constant NIBBLE_SIZE    : natural :=  4);

	port (
		ddrs_rst     : in std_logic;
		sys_ini      : out std_logic;

		input_rst    : in std_logic := '0';
		input_clk    : in std_logic;

		ddrs_clks    : in std_logic_vector(0 to ddr_sclkphases/ddr_sclkedges-1);
		ddrs_rtt     : in std_logic_vector;
		ddrs_bl      : in std_logic_vector(3-1 downto 0) := "000";
		ddrs_cl      : in std_logic_vector(3-1 downto 0) := "010";
		ddrs_cwl     : in std_logic_vector(3-1 downto 0) := "000";
		ddrs_wr      : in std_logic_vector(3-1 downto 0) := "101";
		ddrs_ini     : out std_logic;
		ddrs_act     : out std_logic;
		ddrs_cmd_rdy : out std_logic;

		ddr_wlreq    : out std_logic;
		ddr_wlrdy    : in  std_logic := '-';
		ddr_rlreq    : out std_logic;
		ddr_rlrdy    : in  std_logic := '-';
		ddr_rlcal    : in  std_logic := '0';
		ddr_rlseq    : out std_logic := '0';
		ddr_phyini   : in std_logic := '1';
		ddr_phyrw    : in std_logic := '-';
		ddr_phycmd_req : in std_logic := '0';

		ddr_rst      : out std_logic;
		ddr_cke      : out std_logic;
		ddr_cs       : out std_logic;
		ddr_ras      : out std_logic;
		ddr_cas      : out std_logic;
		ddr_we       : out std_logic;
		ddr_b        : out std_logic_vector(DDR_BANKSIZE-1 downto 0);
		ddr_a        : out std_logic_vector(DDR_ADDRSIZE-1 downto 0);
		ddr_dmi      : in  std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dmo      : out std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dmt      : out std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dqsi     : in  std_logic_vector(DDR_DATAPHASES*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dqst     : out std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dqso     : out std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dqt      : out std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
		ddr_dqi      : in  std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE-1 downto 0);
		ddr_dqo      : out std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE-1 downto 0);
		ddr_odt      : out std_logic;
		ddr_sto      : out std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
		ddr_sti      : in  std_logic_vector(DDR_DATAPHASES*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);

		mii_rst      : in std_logic := '0';
		mii_rxc      : in std_logic;
		mii_rxdv     : in std_logic;
		mii_rxd      : in std_logic_vector;
		mii_txc      : in std_logic;
		mii_txen     : out std_logic;
		mii_txd      : out std_logic_vector;

		vga_rst      : in  std_logic := '0';
		vga_clk      : in  std_logic;
		vga_hsync    : out std_logic;
		vga_vsync    : out std_logic;
		vga_blank    : out std_logic;
		vga_frm      : out std_logic;
		vga_red      : out std_logic_vector(8-1 downto 0);
		vga_green    : out std_logic_vector(8-1 downto 0);
		vga_blue     : out std_logic_vector(8-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.xdr_db.all;

architecture def of scope is
	signal video_don : std_logic;
	signal video_frm : std_logic;
	signal video_ena : std_logic;
	signal video_hsync : std_logic;
	signal video_vsync : std_logic;
	signal video_blank : std_logic;

	signal cga_clk : std_logic;
	signal vga_row : std_logic_vector(9-1 downto 0);
	signal cga_row : std_logic_vector(9-1 downto 4);
	signal cga_col : std_logic_vector(4-1 downto 0);
	signal cga_ptr : std_logic_vector(9-1 downto 0);
	signal cga_we  : std_logic;
	signal cga_dot : std_logic;
	signal cga_don : std_logic;
	signal cga_code : byte;

	signal ddrs_clk180  : std_logic;

	signal ddr_lp_clk   : std_logic;

	signal ddr_ini      : std_logic;
	signal ini          : std_logic;
	signal ddr_cmd_req  : std_logic;
	signal ddr_rw       : std_logic;

	signal cmd_rdy      : std_logic;
	signal ddrs_ref_req : std_logic;
	signal ddrs_cmd_req : std_logic;
	signal ddrs_ba      : std_logic_vector(0 to DDR_BANKSIZE-1);
	signal ddrs_a       : std_logic_vector(0 to DDR_ADDRSIZE-1);
	signal ddrs_rowa    : std_logic_vector(0 to DDR_ADDRSIZE-1);
	signal ddrs_cola    : std_logic_vector(0 to DDR_ADDRSIZE-1);
	signal ddr_act      : std_logic;
	signal ddrs_cas     : std_logic;
	signal ddrs_pre     : std_logic;
	signal ddrs_rw      : std_logic;

	signal ddrs_di_rdy  : std_logic;
	signal ddrs_di_req  : std_logic;
	signal ddrs_di      : std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE-1 downto 0);
	signal ddrs_do_rdy  : std_logic_vector(DDR_DATAPHASES*DDR_WORDSIZE/DDR_BYTESIZE-1 downto 0);
	signal ddrs_do      : std_logic_vector(DDR_DATAGEAR*DDR_WORDSIZE-1 downto 0);

	signal dataio_rst   : std_logic;
	signal input_rdy    : std_logic := '0';
	signal input_req    : std_logic := '0';
	signal input_dat    : std_logic_vector(0 to 15);
	
	signal win_rowid    : std_logic_vector(2-1 downto 0);
	signal win_rowpag   : std_logic_vector(5-1 downto 0);
    signal win_rowoff   : std_logic_vector(7-1 downto 0);
    signal win_colid    : std_logic_vector(2-1 downto 0);
    signal win_colpag   : std_logic_vector(2-1 downto 0);
    signal win_coloff   : std_logic_vector(13-1 downto 0);

    signal chann_dat    : std_logic_vector(32-1 downto 0);

	signal grid_dot     : std_logic;
	signal plot_dot     : std_logic_vector(0 to 2-1);

	signal miirx_req    : std_logic;
	signal miirx_rdy    : std_logic;
	signal ddr2mii_req  : std_logic;
	signal ddr2mii_rdy  : std_logic;
	signal miitx_req    : std_logic;
	signal miitx_rdy    : std_logic;
	signal miidma_req   : std_logic;
	signal miidma_rdy   : std_logic;
	signal miidma_txen  : std_logic;
	signal miidma_txd   : std_logic_vector(mii_txd'length-1 downto 0);

	signal rlreq : std_logic;

begin


--	process (input_clk)
--		variable sample : unsigned(0 to 15) := (others => '0');
--	begin
--		if falling_edge(input_clk) then
--			input_dat <= std_logic_vector(resize(sample, input_dat'length));
--			if ddrs_ini='0' then
--				input_req <= '0';
--			elsif input_rdy='0' then
--				input_req <= '1';
--			end if;
--			sample := sample + 1;
--		end if;
--	end process;

	input_req <= ini and not input_rdy;
	process (input_rst, input_clk)
		constant n : natural := 15;
		variable r : unsigned(0 to n);
	begin
		if input_rst='0' then
			r := to_unsigned(61, r'length);
		elsif rising_edge(input_clk) then
			input_dat <= std_logic_vector(resize(signed(r(0 to n)), input_dat'length));
--			input_dat <= (others => r(n-2));
			r := r + 1;
		end if;
	end process;

--	video_vga_e : entity hdl4fpga.video_vga
--	generic map (
--		n => 12)
--	port map (
--		clk   => vga_clk,
--		hsync => video_hsync,
--		vsync => video_vsync,
--		frm   => video_frm,
--		don   => video_don);
--	vga_frm <= video_frm;
--	video_blank <= video_don and video_frm;
--		
--	win_stym_e : entity hdl4fpga.win_sytm
--	port map (
--		win_clk => vga_clk,
--		win_frm => video_frm,
--		win_don => video_don,
--		win_rowid  => win_rowid ,
--		win_rowpag => win_rowpag,
--		win_rowoff => win_rowoff,
--		win_colid  => win_colid,
--		win_colpag => win_colpag,
--		win_coloff => win_coloff);
--
--	win_ena_b : block
--		signal scope_win : std_logic;
--		signal cga_win : std_logic;
--		signal grid_don : std_logic;
--		signal plot_dot1 : std_logic_vector(plot_dot'range);
--		signal grid_dot1 : std_logic;
--		signal plot_start  : std_logic;
--		signal plot_end  : std_logic;
--	begin
--		scope_win <= setif(win_rowid&win_colid = "1111");
--		cga_win   <= cga_dot and setif(win_rowid&win_colid="1101");
--
--		align_e : entity hdl4fpga.align
--		generic map (
--			n => 10,
--			d => (
--				0 to 2 => 4+10,		-- hsync, vsync, blank
--				3 to 3 => 2+10,		-- scope_win -> plot_end
--				4 to 5 => 1,		-- plot
--				6 to 6 => 1+10,		-- grid
--			    7 to 7 => 1,		-- plot_end -> grid_don
--			    8 to 8 => 3,		-- grid_don -> plot_start
--			    9 to 9 => 3))		-- cga_dot -> cga_dot
--		port map (
--			clk   => vga_clk,
--
--			di(0) => video_hsync,
--			di(1) => video_vsync,
--			di(2) => video_blank,
--
--			di(3) => scope_win,
--
--			di(4) => plot_dot(0),
--			di(5) => plot_dot(1),
--			di(6) => grid_dot,
--			di(7) => plot_end,
--			di(8) => grid_don,
--			di(9) => cga_win,
--
--			do(0) => vga_hsync,
--			do(1) => vga_vsync,
--			do(2) => vga_blank,
--
--			do(3) => plot_end,
--
--			do(4) => plot_dot1(0),
--			do(5) => plot_dot1(1),
--			do(6) => grid_dot1,
--			do(7) => grid_don,
--			do(8) => plot_start,
--			do(9) => cga_don);
--
--		vga_red   <= (others => (plot_start and plot_end and plot_dot1(1)) or cga_don);
--		vga_green <= (others => (plot_start and plot_end and plot_dot1(0)) or cga_don);
--		vga_blue  <= (others => (grid_don and grid_dot1) or cga_don);
--		
--	end block;
--
--	video_ena <= setif(win_rowid="11");

	miirx_b : block
		signal pktrx_rdy : std_logic;
		signal pkttx_req : std_logic;
		signal cntr : unsigned(0 to 3);
	begin

		miirx_udp_e : entity hdl4fpga.miirx_mac
		port map (
			mii_rxc  => mii_rxc,
			mii_rxdv => mii_rxdv,
			mii_rxd  => mii_rxd,
			mii_txc  => open,
			mii_txen => pktrx_rdy);

		process (mii_rxc)
			variable rdy_edge : std_logic;
			variable req_edge : std_logic;
			variable aux : unsigned(cntr'range);
		begin
			if dataio_rst='1' then
				pkttx_req <= '0';
				cntr <= (others => '1');
			elsif rising_edge(mii_rxc) then
				aux := cntr;
				if miirx_req='1' then
					pkttx_req <= '0';
					if req_edge='0' then
						aux := aux -1;
					end if;
				elsif cntr(0)='0' then
					pkttx_req <= '1';
				end if;
				if pktrx_rdy='1' then
					if rdy_edge='0' then
						aux := aux + 1;
					end if;
				end if;
				cntr <= aux;
				rdy_edge := pktrx_rdy;
				req_edge := miirx_req;
			end if;
		end process;

		miirx2ddr_e : entity hdl4fpga.align
		generic map (
			d => (0 to 0 => 1))
		port map (
			clk   => ddrs_clks(0),
			di(0) => pkttx_req,
			do(0) => ddr2mii_req);

	end block;

	ddrs_a   <= ddrs_rowa when ddr_act='1' else ddrs_cola;
	ddrs_act <= ddr_act;

	dataio_rst <= not ini;
	dataio_e : entity hdl4fpga.dataio 
	generic map (
		PAGE_SIZE    => PAGE_SIZE,
		DDR_BANKSIZE => DDR_BANKSIZE,
		DDR_ADDRSIZE => DDR_ADDRSIZE,
		DDR_CLNMSIZE => DDR_CLMNSIZE,
		DDR_LINESIZE => DDR_DATAGEAR*DDR_WORDSIZE)
	port map (
		sys_rst      => dataio_rst,

		input_req    => input_req,
		input_rdy    => input_rdy,
		input_clk    => input_clk,
		input_dat    => input_dat,

		video_clk    => vga_clk,
		video_ena    => video_ena,
		video_row    => win_rowpag(3 downto 0),
		video_col    => win_coloff,
		video_do     => chann_dat,

		ddrs_clk     => ddrs_clks(0),
		ddrs_rreq    => ddrs_ref_req,
		ddrs_creq    => ddrs_cmd_req,
		ddrs_crdy    => cmd_rdy,
		ddrs_bnka    => ddrs_ba,
		ddrs_rowa    => ddrs_rowa,
		ddrs_cola    => ddrs_cola,
		ddrs_rw      => ddrs_rw,
		ddrs_act     => ddr_act,
		ddrs_cas     => ddrs_cas,

		ddrs_di_rdy  => ddrs_di_rdy,
		ddrs_di_req  => ddrs_di_req,
		ddrs_di      => ddrs_di,
		ddrs_do_rdy  => ddrs_do_rdy(0),
		ddrs_do      => ddrs_do,

		mii_rst      => mii_rst,
		mii_txc      => mii_txc,
		ddr2mii_req  => ddr2mii_req,
		ddr2mii_rdy  => ddr2mii_rdy,
		miitx_req    => miidma_req,
		miitx_rdy    => miidma_rdy,
		miitx_ena    => miidma_txen,
		miitx_dat    => miidma_txd);
	
	miitx_b : block
	begin

		ddr2miitx_e : entity hdl4fpga.align
		generic map (
			D     => (0 to 0 => 1))
		port map (
			clk   => mii_txc,
			di(0) => ddr2mii_rdy,
			do(0) => miitx_req);

		miitx_udp_e : entity hdl4fpga.miitx_udp
		generic map (
			payload_size => 2**(PAGE_SIZE+1))
		port map (
			mii_txc      => mii_txc,
			mii_treq     => miitx_req,
			mii_trdy     => miitx_rdy,
			mii_txen     => mii_txen,
			mii_txd      => mii_txd,
			miidma_req   => miidma_req,
			miidma_rxen  => miidma_txen,
			miidma_rxd   => miidma_txd);

		miitx2rx_e : entity hdl4fpga.align
		generic map (
			d => (0 to 0 => 1))
		port map (
			clk   => mii_rxc,
			di(0) => miitx_rdy,
			do(0) => miirx_req);

	end block;
	
	ini          <= ddr_phyini   when FPGA=VIRTEX5   else ddr_ini;
	ddr_rlreq    <= ddr_ini      when FPGA=VIRTEX5   else rlreq;
	ddr_cmd_req  <= ddrs_cmd_req when ddr_phyini='1' else ddr_phycmd_req;
	ddr_rw       <= ddrs_rw      when ddr_phyini='1' else ddr_phyrw;
	ddrs_ini     <= ini;
	ddrs_cmd_rdy <= cmd_rdy;

	ddr_e : entity hdl4fpga.xdr
	generic map (
		FPGA        => FPGA,
		TCP         => DDR_TCP,
		MARK        => DDR_MARK,
		SCLK_PHASES => DDR_SCLKPHASES,
		SCLK_EDGE   => DDR_SCLKEDGE,
		BANK_SIZE   => DDR_BANKSIZE,
		ADDR_SIZE   => DDR_ADDRSIZE,
		WORD_SIZE   => DDR_WORDSIZE,
		BYTE_SIZE   => DDR_BYTESIZE,
		CMMD_GEAR   => DDR_CMMDGEAR,
		DATA_GEAR   => DDR_DATAGEAR,
		DATA_EDGE   => DDR_DATAEDGE,
		DATA_PHASES => DDR_DATAPHASES)
	port map (
		sys_rst     => ddrs_rst,
		sys_rtt     => ddrs_rtt,
		sys_bl      => ddrs_bl,
		sys_cl      => ddrs_cl,
		sys_cwl     => ddrs_cwl,
		sys_wr      => ddrs_wr,
		sys_clks    => ddrs_clks,
		sys_ini     => ddr_ini,

		sys_cmd_req => ddr_cmd_req,
		sys_cmd_rdy => cmd_rdy,
		sys_wlreq   => ddr_wlreq,
		sys_wlrdy   => ddr_wlrdy,
		sys_rlreq   => rlreq,
		sys_rlrdy   => ddr_rlrdy,
		sys_rlcal   => ddr_rlcal,
		sys_rlseq   => ddr_rlseq,
		sys_b       => ddrs_ba,
		sys_a       => ddrs_a,
		sys_rw      => ddr_rw,
		sys_act     => ddr_act,
		sys_cas     => ddrs_cas,
		sys_di_rdy  => ddrs_di_rdy,
		sys_di_req  => ddrs_di_req,
		sys_di      => ddrs_di,
		sys_do_rdy  => ddrs_do_rdy,
		sys_do      => ddrs_do,

		sys_ref     => ddrs_ref_req,

		xdr_rst     => ddr_rst,
		xdr_cke     => ddr_cke,
		xdr_cs      => ddr_cs,
		xdr_ras     => ddr_ras,
		xdr_cas     => ddr_cas,
		xdr_we      => ddr_we,
		xdr_b       => ddr_b,
		xdr_a       => ddr_a,
		xdr_dmi     => ddr_dmi,
		xdr_dmt     => ddr_dmt,
		xdr_dmo     => ddr_dmo,
		xdr_dqst    => ddr_dqst,
		xdr_dqsi    => ddr_dqsi,
		xdr_dqso    => ddr_dqso,
		xdr_dqt     => ddr_dqt,
		xdr_dqi     => ddr_dqi,
		xdr_dqo     => ddr_dqo,
		xdr_odt     => ddr_odt,

		xdr_sti     => ddr_sti,
		xdr_sto     => ddr_sto);
end;
