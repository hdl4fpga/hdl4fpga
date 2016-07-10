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
use hdl4fpga.xdr_db.all;
use hdl4fpga.xdr_param.all;

entity xdr is
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
		LINE_SIZE   : natural := 32;
		WORD_SIZE   : natural := 16;
		BYTE_SIZE   : natural :=  8);
	port (
		sys_bl      : in std_logic_vector(2 downto 0);
		sys_cl      : in std_logic_vector(2 downto 0);
		sys_cwl     : in std_logic_vector(2 downto 0);
		sys_wr      : in std_logic_vector(2 downto 0);
		sys_rtt     : in std_logic_vector;

		sys_rst     : in std_logic;
		sys_clks    : in std_logic_vector(0 to sclk_phases/sclk_edges-1);
		sys_ini     : out std_logic;

		sys_wlrdy   : in  std_logic := '-';
		sys_wlreq   : out std_logic;
		sys_rlrdy   : in  std_logic := '-';
		sys_rlreq   : out std_logic;
		sys_rlcal   : in  std_logic := '0';
		sys_rlseq   : out std_logic;

		sys_cmd_req : in  std_logic;
		sys_cmd_rdy : out std_logic;
		sys_rw      : in  std_logic;
		sys_b       : in  std_logic_vector(bank_size-1 downto 0);
		sys_a       : in  std_logic_vector(addr_size-1 downto 0);
		sys_di_rdy  : in  std_logic;
		sys_di_req  : out std_logic;
		sys_do_rdy  : out std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
		sys_act     : out std_logic;
		sys_cas     : out std_logic;
		sys_dm      : in  std_logic_vector(line_size/byte_size-1 downto 0) := (others => '0');
		sys_di      : in  std_logic_vector(line_size-1 downto 0);
		sys_do      : out std_logic_vector(line_size-1 downto 0);
		sys_ref     : out std_logic;

		xdr_rst     : out std_logic;
		xdr_cke     : out std_logic;
		xdr_cs      : out std_logic;
		xdr_ras     : out std_logic;
		xdr_cas     : out std_logic;
		xdr_we      : out std_logic;
		xdr_b       : out std_logic_vector(bank_size-1 downto 0);
		xdr_a       : out std_logic_vector(addr_size-1 downto 0);
		xdr_odt     : out std_logic;
		xdr_dmi     : in  std_logic_vector(line_size/byte_size-1 downto 0);
		xdr_dmt     : out std_logic_vector(line_size/byte_size-1 downto 0);
		xdr_dmo     : out std_logic_vector(line_size/byte_size-1 downto 0);

		xdr_dqi     : in  std_logic_vector(line_size-1 downto 0);
		xdr_dqt     : out std_logic_vector(line_size/byte_size-1 downto 0);
		xdr_dqo     : out std_logic_vector(line_size-1 downto 0);
		xdr_sti     : in  std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
		xdr_sto     : out std_logic_vector(line_size/byte_size-1 downto 0);

		xdr_dqsi    : in  std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
		xdr_dqso    : out std_logic_vector(line_size/byte_size-1 downto 0);
		xdr_dqst    : out std_logic_vector(line_size/byte_size-1 downto 0));

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of xdr is
	constant DATA_GEAR    : natural := line_size/word_size;
	constant STDR         : natural := xdr_stdr(mark);

	constant STRX_LAT     : natural          := xdr_latency(STDR, STRXL);
	constant RWNX_LAT     : natural          := xdr_latency(STDR, RWNXL);
	constant DQSZX_LAT    : natural          := xdr_latency(STDR, DQSZXL);
	constant DQSX_LAT     : natural          := xdr_latency(STDR, DQSXL);
	constant DQZX_LAT     : natural          := xdr_latency(STDR, DQZXL);
	constant RDFIFO_LAT   : natural          := xdr_latency(STDR, hdl4fpga.xdr_db.RDFIFO_LAT);
	constant TLWR         : natural          := xdr_timing(mark, tWR)+xdr_latency(stdr, DQSXL);
	constant LRCD         : natural          := to_xdrlatency(tCP, MARK, TRCD);
	constant LRFC         : natural          := to_xdrlatency(tCP, MARK, TRFC);
	constant LWR          : natural          := to_xdrlatency(tCP, TLWR);
	constant LRP          : natural          := to_xdrlatency(tCP, MARK, TRP);
	constant WWNX_LAT     : natural          := xdr_latency(STDR, WWNXL);
	constant WID_LAT      : natural          := xdr_latency(STDR, WIDL);
	constant BL_COD       : std_logic_vector := xdr_latcod(STDR, BL);
	constant CL_COD       : std_logic_vector := xdr_latcod(STDR, CL);
	constant CWL_COD      : std_logic_vector := xdr_latcod(STDR, xdr_selcwl(STDR));
	constant BL_TAB       : natural_vector   := xdr_lattab(STDR, BL);
	constant CL_TAB       : natural_vector   := xdr_lattab(STDR, CL);
	constant CWL_TAB      : natural_vector   := xdr_schtab(STDR, CWL);
	constant STRL_TAB     : natural_vector   := xdr_schtab(STDR, STRL);
	constant RWNL_TAB     : natural_vector   := xdr_schtab(STDR, RWNL);
	constant DQSZL_TAB    : natural_vector   := xdr_schtab(STDR, DQSZL);
	constant DQSOL_TAB    : natural_vector   := xdr_schtab(STDR, DQSL);
	constant DQZL_TAB     : natural_vector   := xdr_schtab(STDR, DQZL);
	constant TIMERS       : natural_vector   := ddr_timers(TCP, mark);
	constant WWNL_TAB     : natural_vector   := xdr_schtab(STDR, WWNL);
	constant RDFIFO_DELAY : boolean          := xdr_cntlrcnfg(FPGA, hdl4fpga.xdr_db.RDFIFO_DELAY);

	subtype byte is std_logic_vector(0 to byte_size-1);
	type byte_vector is array (natural range <>) of byte;

	signal xdr_refi_rdy   : std_logic;
	signal xdr_refi_req   : std_logic;
	signal xdr_init_rst   : std_logic;
	signal xdr_init_cke   : std_logic;
	signal xdr_init_cs    : std_logic;
	signal xdr_init_req   : std_logic;
	signal xdr_init_rdy   : std_logic;
	signal xdr_init_ras   : std_logic;
	signal xdr_init_cas   : std_logic;
	signal xdr_init_we    : std_logic;
	signal xdr_init_odt   : std_logic;
	signal xdr_init_a     : std_logic_vector(addr_size-1 downto 0);
	signal xdr_init_b     : std_logic_vector(bank_size-1 downto 0);

	signal xdr_pgm_cmd    : std_logic_vector(0 to 2);

	signal xdr_mpu_rst    : std_logic;
	signal xdr_mpu_rdy    : std_logic;
	signal xdr_mpu_req    : std_logic;
	signal xdr_mpu_ref    : std_logic;
	signal xdr_mpu_ras    : std_logic;
	signal xdr_mpu_cas    : std_logic;
	signal xdr_mpu_we     : std_logic;
	signal xdr_mpu_wri    : std_logic;
	signal xdr_mpu_rea    : std_logic;
	signal xdr_mpu_rwin   : std_logic;
	signal xdr_mpu_wwin   : std_logic;

	signal xdr_sch_odt    : std_logic_vector(0 to CMMD_GEAR-1);
	signal xdr_sch_dqsz   : std_logic_vector(0 to DATA_GEAR-1);
	signal xdr_sch_dqs    : std_logic_vector(xdr_sch_dqsz'range);
	signal xdr_sch_dqz    : std_logic_vector(xdr_sch_dqsz'range);
	signal xdr_sch_st     : std_logic_vector(xdr_sch_dqsz'range);
	signal xdr_sch_wwn    : std_logic_vector(0 to DATA_GEAR-1);
	signal xdr_sch_rwn    : std_logic_vector(xdr_sch_dqsz'range);
	signal xdr_wclks      : std_logic_vector(0 to data_phases*word_size/byte_size-1);
	signal xdr_wenas      : std_logic_vector(0 to data_phases*word_size/byte_size-1);

	signal xdr_win_dqs    : std_logic_vector(xdr_dqsi'range);
	signal xdr_win_dq     : std_logic_vector(xdr_dqsi'range);
	signal xdr_wr_dm      : std_logic_vector(sys_dm'range);

	signal rot_val        : std_logic_vector(unsigned_num_bits(line_size-1)-1 downto 0);
	signal rot_di         : std_logic_vector(sys_di'range);

	signal xdr_cwl        : std_logic_vector(sys_cwl'range);

	signal xdr_mr_addr    : std_logic_vector(3-1 downto 0);
	signal xdr_mr_data    : std_logic_vector(13-1 downto 0);
	signal xdr_mpu_sel    : std_logic;
	signal init_rdy       : std_logic;

begin

	xdr_cwl      <= sys_cl when stdr=2 else sys_cwl;
	xdr_init_req <= sys_rst;

	xdr_init_e : entity hdl4fpga.xdr_init
	generic map (
		DDR_STDR       => STDR,
		TIMERS         => TIMERS,
		ADDR_SIZE      => ADDR_SIZE,
		BANK_SIZE      => BANK_SIZE)
	port map (
		xdr_init_bl    => sys_bl,
		xdr_init_cl    => sys_cl,
		xdr_init_cwl   => xdr_cwl,
		xdr_init_bt    => "0",
		xdr_init_ods   => "0",
		xdr_init_wr    => sys_wr,
		xdr_init_rtt   => sys_rtt,

		xdr_init_clk   => sys_clks(0),
		xdr_init_req   => xdr_init_req,
		xdr_init_rdy   => xdr_init_rdy,
		xdr_init_rst   => xdr_init_rst,
		xdr_init_cke   => xdr_init_cke,
		xdr_init_cs    => xdr_init_cs,
		xdr_init_ras   => xdr_init_ras,
		xdr_init_cas   => xdr_init_cas,
		xdr_init_we    => xdr_init_we,
		xdr_init_a     => xdr_init_a,
		xdr_init_b     => xdr_init_b,
		xdr_init_odt   => xdr_init_odt,
		xdr_init_wlreq => sys_wlreq,
		xdr_init_wlrdy => sys_wlrdy,
		xdr_refi_req   => xdr_refi_req,
		xdr_refi_rdy   => xdr_refi_rdy);

	init_rdy    <= xdr_init_rdy;
	xdr_rst     <= xdr_init_rst;
	xdr_cke     <= xdr_init_cke;
	xdr_cs      <= '0'          when xdr_mpu_sel='1' else xdr_init_cs;
	xdr_ras     <= xdr_mpu_ras  when xdr_mpu_sel='1' else xdr_init_ras;
	xdr_ras     <= xdr_mpu_ras  when xdr_mpu_sel='1' else xdr_init_ras;
	xdr_cas     <= xdr_mpu_cas  when xdr_mpu_sel='1' else xdr_init_cas;
	xdr_we      <= xdr_mpu_we   when xdr_mpu_sel='1' else xdr_init_we;
	xdr_a       <= sys_a        when xdr_mpu_sel='1' else xdr_init_a;
	xdr_b       <= sys_b        when xdr_mpu_sel='1' else xdr_init_b;
	xdr_odt     <= xdr_init_odt when xdr_mpu_sel='0' else xdr_sch_odt(0) when stdr=3 else '1';
	sys_ini     <= init_rdy;

	xdr_pgm_e : entity hdl4fpga.xdr_pgm
	generic map (
		CMMD_GEAR => CMMD_GEAR)
	port map (
		xdr_pgm_rst   => xdr_mpu_rst,
		xdr_pgm_clk   => sys_clks(0),
		sys_pgm_ref   => sys_ref,
		xdr_pgm_cas   => sys_cas,
		xdr_pgm_cmd   => xdr_pgm_cmd,
		xdr_pgm_ref   => xdr_mpu_ref,
		xdr_pgm_rrdy  => xdr_refi_rdy,
		xdr_pgm_start => xdr_mpu_req,
		xdr_pgm_cal   => sys_rlcal,
		xdr_pgm_rdy   => sys_cmd_rdy,
		xdr_pgm_req   => xdr_mpu_rdy,
		xdr_pgm_seq   => sys_rlseq,
		xdr_pgm_rw    => sys_rw);

	xdr_mpu_rst <= not init_rdy;
	xdr_mpu_sel <= init_rdy;
	xdr_mpu_ref <= xdr_refi_req;
	xdr_mpu_req <= sys_cmd_req;
	xdr_mpu_e : entity hdl4fpga.xdr_mpu
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
		xdr_mpu_bl   => sys_bl,
		xdr_mpu_cl   => sys_cl,
		xdr_mpu_cwl  => xdr_cwl,

		xdr_mpu_rst  => xdr_mpu_rst,
		xdr_mpu_clk  => sys_clks(0),
		xdr_mpu_cmd  => xdr_pgm_cmd,
		xdr_mpu_rdy  => xdr_mpu_rdy,
		xdr_mpu_act  => sys_act,
		xdr_mpu_cas  => xdr_mpu_cas,
		xdr_mpu_ras  => xdr_mpu_ras,
		xdr_mpu_we   => xdr_mpu_we,
		xdr_mpu_rea  => xdr_mpu_rea,
		xdr_mpu_wri  => xdr_mpu_wri,
		xdr_mpu_rwin => xdr_mpu_rwin,
		xdr_mpu_wwin => xdr_mpu_wwin);

	sys_di_req  <= xdr_mpu_wwin;

	xdr_sch_e : entity hdl4fpga.xdr_sch
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
		sys_cl      => sys_cl,
		sys_cwl     => xdr_cwl,
		sys_clks    => sys_clks,
		sys_rea     => xdr_mpu_rwin,
		sys_wri     => xdr_mpu_wwin,

		xdr_rwn     => xdr_sch_rwn,
		xdr_st      => xdr_sch_st,

		xdr_dqsz    => xdr_sch_dqsz,
		xdr_dqs     => xdr_sch_dqs,
		xdr_dqz     => xdr_sch_dqz,
		xdr_odt     => xdr_sch_odt,
		xdr_wwn     => xdr_sch_wwn);

	xdr_win_dqs <= xdr_sti;
	xdr_win_dq  <= (others => xdr_sch_rwn(0)); 

	process (
		xdr_wr_dm,
		xdr_mpu_wri,
		xdr_sch_st,
		xdr_sch_dqz,
		xdr_sch_dqs,
		xdr_sch_dqsz,
		xdr_sch_rwn,
		xdr_sch_wwn)
	begin
		for i in 0 to word_size/byte_size-1 loop
			for j in 0 to DATA_GEAR-1 loop
				xdr_dqt(i*DATA_GEAR+j)  <= xdr_sch_dqz(j);
				xdr_dmt(i*DATA_GEAR+j)  <= reverse(xdr_sch_dqz)(j);
				xdr_dqso(i*DATA_GEAR+j) <= xdr_sch_dqs(j);
				xdr_dqst(i*DATA_GEAR+j) <= not xdr_sch_dqsz(j);
				xdr_sto(i*DATA_GEAR+j)  <= reverse(xdr_sch_st)(j);
				xdr_dmo(i*DATA_GEAR+j) <= xdr_wr_dm(i*DATA_GEAR+j);
			end loop;
			for j in 0 to data_phases-1 loop
				xdr_wenas(i*data_phases+j) <= xdr_sch_wwn(j);
			end loop;
		end loop;
	end process;

	rdfifo_i : entity hdl4fpga.xdr_rdfifo
	generic map (
		data_phases => data_phases,
		line_size => line_size,
		word_size => word_size,
		byte_size => byte_size,
		data_delay => RDFIFO_LAT,
		acntr_delay => RDFIFO_DELAY)
	port map (
		sys_clk => sys_clks(0),
		sys_rdy => sys_do_rdy,
		sys_rea => xdr_mpu_rea,
		sys_do  => sys_do,
		xdr_win_dq  => xdr_win_dq,
		xdr_win_dqs => xdr_win_dqs,
		xdr_dqsi => xdr_dqsi,
		xdr_dqi  => xdr_dqi);
		
	rot_val <= xdr_rotval (
		line_size => line_size,
		word_size => word_size,
		lat_val => sys_cwl,
		lat_cod => CWL_COD,
		lat_tab => WWNL_TAB);

	rotate_i : entity hdl4fpga.barrel
	generic map (
		n => sys_di'length,
		m => unsigned_num_bits(line_size-1))
	port map (
		rot  => rot_val,
		din  => sys_di,
		dout => rot_di);
		
	process (sys_clks(sys_clks'high))
	begin
		for k in 0 to word_size/byte_size-1 loop
			for i in 0 to data_phases-1 loop
				xdr_wclks(k*data_phases+i) <= sys_clks(sys_clks'high);
				if data_edges > 1 then
					xdr_wclks(k*data_phases+1) <= not sys_clks(sys_clks'high);
				end if;
			end loop;
		end loop;
	end process;

	wrfifo_i : entity hdl4fpga.xdr_wrfifo
	generic map (
		data_phases  => data_phases,
		line_size => line_size,
		word_size => word_size,
		byte_size => byte_size)
	port map (
		sys_clk => sys_clks(0),
		sys_dqi => rot_di,
		sys_ena => sys_di_rdy,
		sys_req => xdr_mpu_wri,
		sys_dmi => sys_dm,
		xdr_clks => xdr_wclks,
		xdr_dmo => xdr_wr_dm,
		xdr_enas => xdr_wenas, 
		xdr_dqo => xdr_dqo);

end;
