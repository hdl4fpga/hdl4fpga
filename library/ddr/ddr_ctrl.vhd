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

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ddr_db.all;
use hdl4fpga.ddr_param.all;

entity ddr_ctlr is
	generic (
		FPGA        : natural;
		MARK        : natural := M6T;
		TCP         : natural := 6000;

		CMMD_GEAR   : natural :=  1;
		BANK_SIZE   : natural :=  2;
		ADDR_SIZE   : natural := 13;
		SCLK_PHASES : natural :=  4;
		SCLK_EDGES  : natural :=  2;
		DATA_PHASES : natural :=  2;
		DATA_EDGES  : natural :=  2;
		DATA_GEAR   : natural :=  2;
		WORD_SIZE   : natural := 16;
		BYTE_SIZE   : natural :=  8);
	port (
		ctlr_bl      : in std_logic_vector(2 downto 0);
		ctlr_cl      : in std_logic_vector(2 downto 0);
		ctlr_cwl     : in std_logic_vector(2 downto 0);
		ctlr_wr      : in std_logic_vector(2 downto 0);
		ctlr_rtt     : in std_logic_vector;

		ctlr_rst     : in std_logic;
		ctlr_clks    : in std_logic_vector(0 to SCLK_PHASES/SCLK_EDGES-1);
		ctlr_inirdy  : out std_logic;

		ctlr_wlrdy   : in  std_logic := '-';
		ctlr_wlreq   : out std_logic;
		ctlr_rlcal   : in  std_logic := '0';
		ctlr_rlseq   : out std_logic;

		ctlr_irdy    : in  std_logic;
		ctlr_trdy    : out std_logic;
		ctlr_rw      : in  std_logic;
		ctlr_b       : in  std_logic_vector(BANK_SIZE-1 downto 0);
		ctlr_a       : in  std_logic_vector(ADDR_SIZE-1 downto 0);
		ctlr_di_irdy : in  std_logic;
		ctlr_di_trdy : out std_logic;
		ctlr_do_rdy  : out std_logic_vector(DATA_PHASES*WORD_SIZE/BYTE_SIZE-1 downto 0);
		ctlr_act     : out std_logic;
		ctlr_cas     : out std_logic;
		ctlr_dm      : in  std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0) := (others => '0');
		ctlr_di      : in  std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
		ctlr_do      : out std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
		ctlr_refreq  : out std_logic;

		phy_rst      : out std_logic;
		phy_cke      : out std_logic;
		phy_cs       : out std_logic;
		phy_ras      : out std_logic;
		phy_cas      : out std_logic;
		phy_we       : out std_logic;
		phy_b        : out std_logic_vector(BANK_SIZE-1 downto 0);
		phy_a        : out std_logic_vector(ADDR_SIZE-1 downto 0);
		phy_odt      : out std_logic;
		phy_dmi      : in  std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
		phy_dmt      : out std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
		phy_dmo      : out std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);

		phy_dqi      : in  std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
		phy_dqt      : out std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
		phy_dqo      : out std_logic_vector(DATA_GEAR*WORD_SIZE-1 downto 0);
		phy_sti      : in  std_logic_vector(DATA_PHASES*WORD_SIZE/BYTE_SIZE-1 downto 0);
		phy_sto      : out std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);

		phy_dqsi     : in  std_logic_vector(DATA_PHASES*WORD_SIZE/BYTE_SIZE-1 downto 0);
		phy_dqso     : out std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0);
		phy_dqst     : out std_logic_vector(DATA_GEAR*WORD_SIZE/BYTE_SIZE-1 downto 0));

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of ddr_ctlr is
	constant STDR         : natural := ddr_stdr(mark);

	constant STRX_LAT     : natural          := ddr_latency(FPGA, STRXL);
	constant RWNX_LAT     : natural          := ddr_latency(FPGA, RWNXL);
	constant DQSZX_LAT    : natural          := ddr_latency(FPGA, DQSZXL);
	constant DQSX_LAT     : natural          := ddr_latency(FPGA, DQSXL);
	constant DQZX_LAT     : natural          := ddr_latency(FPGA, DQZXL);
	constant RDFIFO_LAT   : natural          := ddr_latency(FPGA, hdl4fpga.ddr_db.RDFIFO_LAT);
	constant TLWR         : natural          := ddr_timing(mark, tWR)+ddr_latency(FPGA, DQSXL);
	constant LRCD         : natural          := to_xdrlatency(tCP, MARK, TRCD);
	constant LRFC         : natural          := to_xdrlatency(tCP, MARK, TRFC);
	constant LWR          : natural          := to_xdrlatency(tCP, TLWR);
	constant LRP          : natural          := to_xdrlatency(tCP, MARK, TRP);
	constant WWNX_LAT     : natural          := ddr_latency(STDR, WWNXL);
	constant WID_LAT      : natural          := ddr_latency(STDR, WIDL);
	constant BL_COD       : std_logic_vector := ddr_latcod(STDR, BL);
	constant CL_COD       : std_logic_vector := ddr_latcod(STDR, CL);
	constant CWL_COD      : std_logic_vector := ddr_latcod(STDR, ddr_selcwl(STDR));
	constant BL_TAB       : natural_vector   := ddr_lattab(STDR, BL);
	constant CL_TAB       : natural_vector   := ddr_lattab(STDR, CL);
	constant CWL_TAB      : natural_vector   := ddr_schtab(STDR, FPGA, CWL);
	constant STRL_TAB     : natural_vector   := ddr_schtab(STDR, FPGA, STRL);
	constant RWNL_TAB     : natural_vector   := ddr_schtab(STDR, FPGA, RWNL);
	constant DQSZL_TAB    : natural_vector   := ddr_schtab(STDR, FPGA, DQSZL);
	constant DQSOL_TAB    : natural_vector   := ddr_schtab(STDR, FPGA, DQSL);
	constant DQZL_TAB     : natural_vector   := ddr_schtab(STDR, FPGA, DQZL);
	constant TIMERS       : natural_vector   := ddr_timers(TCP, mark);
	constant WWNL_TAB     : natural_vector   := ddr_schtab(STDR, FPGA, WWNL);
	constant RDFIFO_DELAY : boolean          := ddr_cntlrcnfg(FPGA, hdl4fpga.ddr_db.RDFIFO_DELAY);

	subtype byte is std_logic_vector(0 to BYTE_SIZE-1);
	type byte_vector is array (natural range <>) of byte;

	signal ddr_refi_rdy   : std_logic;
	signal ddr_refi_req   : std_logic;
	signal ddr_init_rst   : std_logic;
	signal ddr_init_cke   : std_logic;
	signal ddr_init_cs    : std_logic;
	signal ddr_init_req   : std_logic;
	signal ddr_init_rdy   : std_logic;
	signal ddr_init_ras   : std_logic;
	signal ddr_init_cas   : std_logic;
	signal ddr_init_we    : std_logic;
	signal ddr_init_odt   : std_logic;
	signal ddr_init_a     : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal ddr_init_b     : std_logic_vector(BANK_SIZE-1 downto 0);

	signal ddr_pgm_cmd    : std_logic_vector(0 to 2);

	signal ddr_mpu_rst    : std_logic;
	signal ddr_mpu_trdy   : std_logic;
	signal ddr_mpu_ref    : std_logic;
	signal ddr_mpu_ras    : std_logic;
	signal ddr_mpu_cas    : std_logic;
	signal ddr_mpu_we     : std_logic;
	signal ddr_mpu_wri    : std_logic;
	signal ddr_mpu_rea    : std_logic;
	signal ddr_mpu_rwin   : std_logic;
	signal ddr_mpu_wwin   : std_logic;

	signal ddr_sch_odt    : std_logic_vector(0 to CMMD_GEAR-1);
	signal ddr_sch_dqsz   : std_logic_vector(0 to DATA_GEAR-1);
	signal ddr_sch_dqs    : std_logic_vector(ddr_sch_dqsz'range);
	signal ddr_sch_dqz    : std_logic_vector(ddr_sch_dqsz'range);
	signal ddr_sch_st     : std_logic_vector(ddr_sch_dqsz'range);
	signal ddr_sch_wwn    : std_logic_vector(0 to DATA_GEAR-1);
	signal ddr_sch_rwn    : std_logic_vector(ddr_sch_dqsz'range);
	signal ddr_wclks      : std_logic_vector(0 to DATA_PHASES*WORD_SIZE/BYTE_SIZE-1);
	signal ddr_wenas      : std_logic_vector(0 to DATA_PHASES*WORD_SIZE/BYTE_SIZE-1);

	signal ddr_win_dqs    : std_logic_vector(phy_dqsi'range);
	signal ddr_win_dq     : std_logic_vector(phy_dqsi'range);
	signal ddr_wr_dm      : std_logic_vector(ctlr_dm'range);

	signal rot_val        : std_logic_vector(unsigned_num_bits(DATA_GEAR*WORD_SIZE-1)-1 downto 0);
	signal rot_di         : std_logic_vector(ctlr_di'range);

	signal ddr_cwl        : std_logic_vector(ctlr_cwl'range);

	signal ddr_mr_addr    : std_logic_vector(3-1 downto 0);
	signal ddr_mr_data    : std_logic_vector(13-1 downto 0);
	signal ddr_mpu_sel    : std_logic;
	signal init_rdy       : std_logic;

begin

	ddr_cwl      <= ctlr_cl when stdr=2 else ctlr_cwl;
	ddr_init_req <= ctlr_rst;

	ddr_init_e : entity hdl4fpga.ddr_init
	generic map (
		DDR_STDR       => STDR,
		TIMERS         => TIMERS,
		ADDR_SIZE      => ADDR_SIZE,
		BANK_SIZE      => BANK_SIZE)
	port map (
		ddr_init_bl    => ctlr_bl,
		ddr_init_cl    => ctlr_cl,
		ddr_init_cwl   => ddr_cwl,
		ddr_init_bt    => "0",
		ddr_init_ods   => "0",
		ddr_init_wr    => ctlr_wr,
		ddr_init_rtt   => ctlr_rtt,

		ddr_init_clk   => ctlr_clks(0),
		ddr_init_req   => ddr_init_req,
		ddr_init_rdy   => ddr_init_rdy,
		ddr_init_rst   => ddr_init_rst,
		ddr_init_cke   => ddr_init_cke,
		ddr_init_cs    => ddr_init_cs,
		ddr_init_ras   => ddr_init_ras,
		ddr_init_cas   => ddr_init_cas,
		ddr_init_we    => ddr_init_we,
		ddr_init_a     => ddr_init_a,
		ddr_init_b     => ddr_init_b,
		ddr_init_odt   => ddr_init_odt,
		ddr_init_wlreq => ctlr_wlreq,
		ddr_init_wlrdy => ctlr_wlrdy,
		ddr_refi_req   => ddr_refi_req,
		ddr_refi_rdy   => ddr_refi_rdy);

	init_rdy    <= ddr_init_rdy;
	phy_rst     <= ddr_init_rst;
	phy_cke     <= ddr_init_cke;
	phy_cs      <= '0'          when ddr_mpu_sel='1' else ddr_init_cs;
	phy_ras     <= ddr_mpu_ras  when ddr_mpu_sel='1' else ddr_init_ras;
	phy_ras     <= ddr_mpu_ras  when ddr_mpu_sel='1' else ddr_init_ras;
	phy_cas     <= ddr_mpu_cas  when ddr_mpu_sel='1' else ddr_init_cas;
	phy_we      <= ddr_mpu_we   when ddr_mpu_sel='1' else ddr_init_we;
	phy_a       <= ctlr_a       when ddr_mpu_sel='1' else ddr_init_a;
	phy_b       <= ctlr_b       when ddr_mpu_sel='1' else ddr_init_b;
	phy_odt     <= ddr_init_odt when ddr_mpu_sel='0' else ddr_sch_odt(0) when stdr=3 else '1';
	ctlr_inirdy <= init_rdy;

	ddr_pgm_e : entity hdl4fpga.ddr_pgm
	generic map (
		CMMD_GEAR => CMMD_GEAR)
	port map (
		ctlr_clk      => ctlr_clks(0),
		ctlr_rst      => ddr_mpu_rst,
		ctlr_refreq   => ctlr_refreq,
		ddr_pgm_irdy  => ctlr_irdy,
		ddr_pgm_trdy  => ctlr_trdy,
		ddr_pgm_cas   => ctlr_cas,
		ddr_pgm_cmd   => ddr_pgm_cmd,
		ddr_pgm_ref   => ddr_mpu_ref,
		ddr_pgm_rrdy  => ddr_refi_rdy,
		ddr_pgm_cal   => ctlr_rlcal,
		ddr_mpu_trdy  => ddr_mpu_trdy,
		ddr_pgm_seq   => ctlr_rlseq,
		ddr_pgm_rw    => ctlr_rw);

	ddr_mpu_rst <= not init_rdy;
	ddr_mpu_sel <= init_rdy;
	ddr_mpu_ref <= ddr_refi_req;
	ddr_mpu_e : entity hdl4fpga.ddr_mpu
	generic map (
		GEAR        => DATA_GEAR,
		LRCD        => LRCD,
		LRFC        => LRFC,
		LWR         => LWR,
		LRP         => LRP,
		BL_COD      => BL_COD,
		CL_COD      => CL_COD,
		CWL_COD     => CWL_COD,
		BL_TAB      => BL_TAB,
		CL_TAB      => CL_TAB,
		CWL_TAB     => CWL_TAB)
	port map (
		ddr_mpu_bl   => ctlr_bl,
		ddr_mpu_cl   => ctlr_cl,
		ddr_mpu_cwl  => ddr_cwl,

		ddr_mpu_rst  => ddr_mpu_rst,
		ddr_mpu_clk  => ctlr_clks(0),
		ddr_mpu_cmd  => ddr_pgm_cmd,
		ddr_mpu_trdy => ddr_mpu_trdy,
		ddr_mpu_act  => ctlr_act,
		ddr_mpu_cas  => ddr_mpu_cas,
		ddr_mpu_ras  => ddr_mpu_ras,
		ddr_mpu_we   => ddr_mpu_we,
		ddr_mpu_rea  => ddr_mpu_rea,
		ddr_mpu_wri  => ddr_mpu_wri,
		ddr_mpu_rwin => ddr_mpu_rwin,
		ddr_mpu_wwin => ddr_mpu_wwin);

	ctlr_di_trdy <= ddr_mpu_wwin;

	ddr_sch_e : entity hdl4fpga.ddr_sch
	generic map (
		PROFILE     => FPGA,
		CMMD_GEAR   => CMMD_GEAR,
		DATA_PHASES => DATA_PHASES,
		CLK_PHASES  => SCLK_PHASES,
		CLK_EDGES   => SCLK_EDGES,
		DATA_GEAR   => DATA_GEAR,
		CL_COD      => CL_COD,
		CWL_COD     => CWL_COD,
                                 
		STRL_TAB    => STRL_TAB,
		RWNL_TAB    => RWNL_TAB,
		DQSZL_TAB   => DQSZL_TAB,
		DQSOL_TAB   => DQSOL_TAB,
		DQZL_TAB    => DQZL_TAB,
		WWNL_TAB    => WWNL_TAB,
                                 
		STRX_LAT    => STRX_LAT,
		RWNX_LAT    => RWNX_LAT,
		DQSZX_LAT   => DQSZX_LAT,
		DQSX_LAT    => DQSX_LAT,
		DQZX_LAT    => DQZX_LAT,
		WWNX_LAT    => WWNX_LAT,
		WID_LAT     => WID_LAT)
	port map (
		sys_cl      => ctlr_cl,
		sys_cwl     => ddr_cwl,
		sys_clks    => ctlr_clks,
		sys_rea     => ddr_mpu_rwin,
		sys_wri     => ddr_mpu_wwin,

		ddr_rwn     => ddr_sch_rwn,
		ddr_st      => ddr_sch_st,

		ddr_dqsz    => ddr_sch_dqsz,
		ddr_dqs     => ddr_sch_dqs,
		ddr_dqz     => ddr_sch_dqz,
		ddr_odt     => ddr_sch_odt,
		ddr_wwn     => ddr_sch_wwn);

	ddr_win_dqs <= phy_sti;
	ddr_win_dq  <= (others => ddr_sch_rwn(0)); 

	process (
		ddr_wr_dm,
		ddr_mpu_wri,
		ddr_sch_st,
		ddr_sch_dqz,
		ddr_sch_dqs,
		ddr_sch_dqsz,
		ddr_sch_rwn,
		ddr_sch_wwn)
	begin
		for i in 0 to WORD_SIZE/BYTE_SIZE-1 loop
			for j in 0 to DATA_GEAR-1 loop
				phy_dqt(i*DATA_GEAR+j)  <= ddr_sch_dqz(j);
				phy_dmt(i*DATA_GEAR+j)  <= reverse(ddr_sch_dqz)(j);
				phy_dqso(i*DATA_GEAR+j) <= ddr_sch_dqs(j);
				phy_dqst(i*DATA_GEAR+j) <= not ddr_sch_dqsz(j);
				phy_sto(i*DATA_GEAR+j)  <= reverse(ddr_sch_st)(j);
				phy_dmo(i*DATA_GEAR+j) <= ddr_wr_dm(i*DATA_GEAR+j);
			end loop;
			for j in 0 to DATA_PHASES-1 loop
				ddr_wenas(i*DATA_PHASES+j) <= ddr_sch_wwn(j);
			end loop;
		end loop;
	end process;

	rdfifo_i : entity hdl4fpga.ddr_rdfifo
	generic map (
		DATA_PHASES => DATA_PHASES,
		DATA_GEAR   => DATA_GEAR,
		WORD_SIZE   => WORD_SIZE,
		BYTE_SIZE   => BYTE_SIZE,
		data_delay  => RDFIFO_LAT,
		acntr_delay => RDFIFO_DELAY)
	port map (
		sys_clk     => ctlr_clks(0),
		sys_rdy     => ctlr_do_rdy,
		sys_rea     => ddr_mpu_rea,
		sys_do      => ctlr_do,
		ddr_win_dq  => ddr_win_dq,
		ddr_win_dqs => ddr_win_dqs,
		ddr_dqsi    => phy_dqsi,
		ddr_dqi     => phy_dqi);
		
	rot_val <= ddr_rotval (
		LINE_SIZE => DATA_GEAR*WORD_SIZE,
		WORD_SIZE => WORD_SIZE,
		lat_val => ctlr_cwl,
		lat_cod => CWL_COD,
		lat_tab => WWNL_TAB);

	rotate_i : entity hdl4fpga.barrel
	port map (
		disp => rot_val,
		di   => ctlr_di,
		do   => rot_di);
		
	process (ctlr_clks(ctlr_clks'high))
	begin
		for k in 0 to WORD_SIZE/BYTE_SIZE-1 loop
			for i in 0 to DATA_PHASES-1 loop
				ddr_wclks(k*DATA_PHASES+i) <= ctlr_clks(ctlr_clks'high);
				if DATA_EDGES > 1 then
					ddr_wclks(k*DATA_PHASES+1) <= not ctlr_clks(ctlr_clks'high);
				end if;
			end loop;
		end loop;
	end process;

	wrfifo_i : entity hdl4fpga.ddr_wrfifo
	generic map (
		DATA_PHASES => DATA_PHASES,
		DATA_GEAR   => DATA_GEAR,
		WORD_SIZE   => WORD_SIZE,
		BYTE_SIZE   => BYTE_SIZE)
	port map (
		ctlr_clk    => ctlr_clks(0),
		ctlr_dqi    => rot_di,
		ctlr_ena    => ctlr_di_irdy,
		ctlr_req    => ddr_mpu_wri,
		ctlr_dmi    => ctlr_dm,
		ddr_clks    => ddr_wclks,
		ddr_dmo     => ddr_wr_dm,
		ddr_enas    => ddr_wenas, 
		ddr_dqo     => phy_dqo);

end;
