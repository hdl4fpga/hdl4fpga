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

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.xdr_param.all;

entity xdr is
	generic (
		strobe : string := "NONE_LOOPBACK";
		registered_output : boolean := true;
		mark : tmrk_ids := M15E;
		tCP  : natural := 6000;
		tDDR : natural := 6000;

		bank_size : natural :=  2;
		addr_size : natural := 13;

		data_phases : natural;
		line_size : natural := 16;
		word_size : natural := 16;
		byte_size : natural :=  8);

	port (
		sys_bl  : in std_logic_vector(2 downto 0);
		sys_cl  : in std_logic_vector(2 downto 0);
		sys_cwl : in std_logic_vector(2 downto 0);
		sys_wr  : in std_logic_vector(2 downto 0);

		sys_rst  : in std_logic := '-';
		sys_clks : in std_logic_vector;
		sys_ini  : out std_logic;
		sys_wlrdy : in  std_logic;
		sys_wlreq : out std_logic;

		sys_cmd_req : in  std_logic := '-';
		sys_cmd_rdy : out std_logic;
		sys_rw : in  std_logic := '0';
		sys_b  : in  std_logic_vector(bank_size-1 downto 0) := (others => '-');
		sys_a  : in  std_logic_vector(addr_size-1 downto 0) := (others => '-');
		sys_di_rdy : out std_logic;
--		sys_do_rdy : out std_logic_vector(word_size/byte_size-1 downto 0);
		sys_do_rdy : out std_logic_vector(2-1 downto 0);
		sys_act : out std_logic;
		sys_cas : out std_logic;
		sys_pre : out std_logic := '0';
		sys_dm  : in  std_logic_vector(line_size/byte_size-1 downto 0) := (others => '0');
		sys_di  : in  std_logic_vector(line_size-1 downto 0) := (others => '-');
		sys_do  : out std_logic_vector(line_size-1 downto 0);
		sys_ref : out std_logic;

		xdr_wclks : in std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
		xdr_rst : out std_logic;
		xdr_cke : out std_logic;
		xdr_cs  : out std_logic;
		xdr_ras : out std_logic;
		xdr_cas : out std_logic;
		xdr_we  : out std_logic;
		xdr_b   : out std_logic_vector(bank_size-1 downto 0);
		xdr_a   : out std_logic_vector(addr_size-1 downto 0);
		xdr_odt : out std_logic;
		xdr_dmi : in  std_logic_vector(line_size/byte_size-1 downto 0) := (others => '-');
		xdr_dmt : out std_logic_vector(line_size/byte_size-1 downto 0) := (others => '0');
		xdr_dmo : out std_logic_vector(line_size/byte_size-1 downto 0) := (others => '-');

		xdr_dqi : in  std_logic_vector(line_size-1 downto 0) := (others => '-');
		xdr_dqt : out std_logic_vector(line_size/byte_size-1 downto 0);
		xdr_dqo : out std_logic_vector(line_size-1 downto 0) := (others => '-');
		xdr_sti  : in  std_logic_vector(line_size/byte_size-1 downto 0) := (others => '-');
		xdr_sto  : out std_logic_vector(line_size/byte_size-1 downto 0) := (others => '-');

		xdr_dqsi : in  std_logic_vector(data_phases*word_size/byte_size-1 downto 0) := (others => '-');
		xdr_dqso : out std_logic_vector(data_phases*word_size/byte_size-1 downto 0) := (others => '-');
		xdr_dqst : out std_logic_vector(data_phases*word_size/byte_size-1 downto 0));

	constant stdr : natural := xdr_stdr(mark);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of xdr is
	subtype byte is std_logic_vector(0 to byte_size-1);
	type byte_vector is array (natural range <>) of byte;

	signal xdr_refi_rdy : std_logic;
	signal xdr_refi_req : std_logic;
	signal xdr_init_rst : std_logic;
	signal xdr_init_cke : std_logic;
	signal xdr_init_cs  : std_logic;
	signal xdr_init_req : std_logic;
	signal xdr_init_rdy : std_logic;
	signal xdr_init_ras : std_logic;
	signal xdr_init_cas : std_logic;
	signal xdr_init_we  : std_logic;
	signal xdr_init_wlr : std_logic;
	signal xdr_init_zqc : std_logic := '1';
	signal xdr_init_odt : std_logic;
	signal xdr_init_a   : std_logic_vector(addr_size-1 downto 0);
	signal xdr_init_b   : std_logic_vector(bank_size-1 downto 0);

	signal dll_timer_rdy : std_logic;

	signal xdr_pgm_cmd : std_logic_vector(0 to 2);

	signal xdr_mpu_rst : std_logic;
	signal xdr_mpu_rdy : std_logic;
	signal xdr_mpu_req : std_logic;
	signal xdr_mpu_ref : std_logic;
	signal xdr_mpu_ras : std_logic;
	signal xdr_mpu_cas : std_logic;
	signal xdr_mpu_we  : std_logic;
	signal xdr_mpu_wri : std_logic;
	signal xdr_mpu_rea : std_logic;
	signal xdr_mpu_rwin : std_logic;
	signal xdr_mpu_wwin : std_logic;

	signal xdr_sch_dqsz : std_logic_vector(0 to line_size/word_size-1);
	signal xdr_sch_dqs : std_logic_vector(xdr_sch_dqsz'range);
	signal xdr_sch_dqz : std_logic_vector(xdr_sch_dqsz'range);
	signal xdr_sch_st : std_logic_vector(xdr_sch_dqsz'range);
	signal xdr_sch_wwn : std_logic_vector(xdr_sch_dqsz'range);
	signal xdr_sch_rwn : std_logic_vector(xdr_sch_dqsz'range);

	signal xdr_win_dqs : std_logic_vector(xdr_dmi'range);
	signal xdr_win_dq  : std_logic_vector(xdr_dqsi'range);
	signal xdr_wr_fifo_rst : std_logic;
	signal xdr_wr_fifo_req : std_logic;
	signal xdr_wr_fifo_ena : std_logic_vector(line_size/word_size-1 downto 0);
	signal xdr_wr_dm : std_logic_vector(sys_dm'range);
	signal xdr_wr_dq : std_logic_vector(sys_di'range);

	signal rot_val : std_logic_vector(unsigned_num_bits(line_size-1)-1 downto 0);
	signal rot_di : std_logic_vector(sys_di'range);

	signal xdr_cwl : std_logic_vector(sys_cwl'range);

	signal rst : std_logic;

	constant tlWR : natural := xdr_timing(mark, tWR)+tCP/2*xdr_latency(stdr, DQSXL,  tDDR => tDDR, tCP => tDDR/2);
	constant timers : ddrtid_vector := (
			TMR_RST  => to_xdrlatency(tCP, mark, tPreRST),
			TMR_RRDY => to_xdrlatency(tCP, mark, tPstRST),
			TMR_WLC  => xdr_latency(stdr, MODu),
			TMR_WLDQSEN => 25,
			TMR_CKE  => to_xdrlatency(tCP, mark, tXPR),
			TMR_MRD  => to_xdrlatency(tCP, mark, tMRD),
			TMR_MOD  => xdr_latency(stdr, MODu),
			TMR_DLL  => xdr_latency(stdr, cDLL),
			TMR_ZQINIT => xdr_latency(stdr, ZQINIT),
			TMR_REF  => to_xdrlatency(tCP, mark, tREFI));

	signal xdr_mr_addr : std_logic_vector(3-1 downto 0);
	signal xdr_mr_data : std_logic_vector(13-1 downto 0);
	signal wl_req : std_logic;

	constant lRCD : natural := to_xdrlatency(tCP, mark, tRCD);
	constant lRFC : natural := to_xdrlatency(tCP, mark, tRFC);
	constant lWR  : natural := to_xdrlatency(tCP, tlWR);
	constant lRP  : natural := to_xdrlatency(tCP, mark, tRP);
	constant bl_cod : std_logic_vector := xdr_latcod(stdr, BL);
	constant bl_tab : natural_vector := xdr_lattab(stdr, BL, tCP,tDDR);
	constant cl_tab : natural_vector := xdr_lattab(stdr, CL, tCP,tDDR);
	constant cwl_tab : natural_vector := xdr_lattab(stdr, xdr_selcwl(stdr), tCP, tDDR);

	constant CL_COD    : std_logic_vector := xdr_latcod(stdr, CL);
	constant CWL_COD   : std_logic_vector := xdr_latcod(stdr, CWL);
	constant STRL_TAB  : natural_vector := xdr_lattab(stdr, STRT,  tDDR => tDDR, tCP => tDDR/2);
	constant RWNL_tab  : natural_vector := xdr_lattab(stdr, RWNT,  tDDR => tDDR, tCP => tDDR/2);
	constant DQSZL_TAB : natural_vector := xdr_lattab(stdr, DQSZT, tDDR => tDDR, tCP => tDDR/2);
	constant DQSOL_TAB : natural_vector := xdr_lattab(stdr, DQST,  tDDR => tDDR, tCP => tDDR/2);
	constant DQZL_TAB  : natural_vector := xdr_lattab(stdr, DQZT,  tDDR => tDDR, tCP => tDDR/2);
	constant WWNL_TAB  : natural_vector := xdr_lattab(stdr, WWNT,  tDDR => tDDR, tCP => tDDR/2);
	constant STRX_LAT  : natural := xdr_latency(stdr, STRXL,  tDDR => tDDR, tCP => tDDR/2);
	constant RWNX_LAT  : natural := xdr_latency(stdr, RWNXL,  tDDR => tDDR, tCP => tDDR/2);
	constant DQSZX_LAT : natural := xdr_latency(stdr, DQSZXL, tDDR => tDDR, tCP => tDDR/2);
	constant DQSZX_TAB : natural_vector := xdr_lattab(stdr, DQSZXT, tDDR => tDDR, tCP => tDDR/4);
	constant DQSX_LAT  : natural := xdr_latency(stdr, DQSXL,  tDDR => tDDR, tCP => tDDR/2);
	constant DQZX_TAB  : natural_vector := xdr_lattab(stdr, DQZXT,  tDDR => tDDR, tCP => tDDR/4);
	constant WWNX_LAT  : natural := xdr_latency(stdr, WWNXL,  tDDR => tDDR, tCP => tDDR/2);
	constant WID_LAT   : natural := xdr_latency(stdr, WIDL,   tDDR => tDDR, tCP => tDDR);

begin

	process (sys_clks(0), sys_rst)
	begin
		if sys_rst='1' then
			rst <= '1';
		elsif rising_edge(sys_clks(0)) then
			rst <= sys_rst;
		end if;
	end process;

	xdr_cwl <= sys_cl when stdr=2 else sys_cwl;

	xdr_init_req <= rst;
	xdr_mr_e : entity hdl4fpga.xdr_mr
	port map (
		xdr_mr_bl  => sys_bl,
		xdr_mr_cl  => sys_cl,
		xdr_mr_cwl => sys_cwl,
		xdr_mr_wl(0) => xdr_init_wlr,
		xdr_mr_zqc(0) => xdr_init_zqc,
		xdr_mr_wr  => sys_wr,

		xdr_mr_addr => xdr_mr_addr,
		xdr_mr_data => xdr_mr_data);

	xdr_init_e : entity hdl4fpga.xdr_init
	generic map (
		timers => timers,
		addr_size => addr_size,
		bank_size => bank_size)
	port map (
		xdr_mr_addr  => xdr_mr_addr,
		xdr_mr_data  => xdr_mr_data,

		xdr_init_clk => sys_clks(0),
		xdr_init_req => xdr_init_req,
		xdr_init_rdy => xdr_init_rdy,
		xdr_init_rst => xdr_init_rst,
		xdr_init_cke => xdr_init_cke,
		xdr_init_cs  => xdr_init_cs,
		xdr_init_ras => xdr_init_ras,
		xdr_init_cas => xdr_init_cas,
		xdr_init_we  => xdr_init_we,
		xdr_init_a   => xdr_init_a,
		xdr_init_b   => xdr_init_b,
		xdr_init_odt => xdr_init_odt,
		xdr_init_wlreq => wl_req,
		xdr_init_wlrdy => sys_wlrdy,
		xdr_init_wlr => xdr_init_wlr,
		xdr_refi_req => xdr_refi_req,
		xdr_refi_rdy => xdr_refi_rdy);
	sys_wlreq <= wl_req;

	xdr_rst <= xdr_init_rst;
	xdr_cs  <= '0'         when xdr_init_rdy='1' else xdr_init_cs;
	xdr_cke <= xdr_init_cke;
	xdr_odt <= '1'         when xdr_init_rdy='1' else xdr_init_odt;
	xdr_ras <= xdr_mpu_ras when xdr_init_rdy='1' else xdr_init_ras;
	xdr_ras <= xdr_mpu_ras when xdr_init_rdy='1' else xdr_init_ras;
	xdr_cas <= xdr_mpu_cas when xdr_init_rdy='1' else xdr_init_cas;
	xdr_we  <= xdr_mpu_we  when xdr_init_rdy='1' else xdr_init_we;
	xdr_a   <= sys_a       when xdr_init_rdy='1' else xdr_init_a;
	xdr_b   <= sys_b       when xdr_init_rdy='1' else xdr_init_b;

	sys_ini <= xdr_init_rdy;
	xdr_mpu_rst <= not xdr_init_rdy;
	xdr_mpu_ref <= xdr_refi_req;

	xdr_pgm_e : entity hdl4fpga.xdr_pgm(registered)
--	xdr_pgm_e : entity hdl4fpga.xdr_pgm(non_registered)
	port map (
		xdr_pgm_rst => xdr_mpu_rst,
		xdr_pgm_clk => sys_clks(0),
		sys_pgm_ref => sys_ref,
		xdr_pgm_cas => sys_cas,
		xdr_pgm_cmd => xdr_pgm_cmd,
		xdr_pgm_ref => xdr_mpu_ref,
		xdr_pgm_rrdy => xdr_refi_rdy,
		xdr_pgm_start => xdr_mpu_req,
		xdr_pgm_rdy => sys_cmd_rdy,
		xdr_pgm_req => xdr_mpu_rdy,
		xdr_pgm_rw  => sys_rw);

	xdr_mpu_req <= sys_cmd_req;
	sys_di_rdy  <= xdr_mpu_wwin;
				   
	xdr_mpu_e : entity hdl4fpga.xdr_mpu
	generic map (
		lRCD    => lRCD,
		lRFC    => lRFC,
		lWR     => lWR,
		lRP     => lRP,
		bl_cod  => bl_cod,
		cl_cod  => cl_cod,
		cwl_cod => cwl_cod,
		bl_tab  => bl_tab,
		cl_tab  => cl_tab,
		cwl_tab => cwl_tab)
	port map (
		xdr_mpu_bl  => sys_bl,
		xdr_mpu_cl  => sys_cl,
		xdr_mpu_cwl => xdr_cwl,

		xdr_mpu_rst => xdr_mpu_rst,
		xdr_mpu_clk => sys_clks(0),
		xdr_mpu_cmd => xdr_pgm_cmd,
		xdr_mpu_rdy => xdr_mpu_rdy,
		xdr_mpu_act => sys_act,
		xdr_mpu_cas => xdr_mpu_cas,
		xdr_mpu_ras => xdr_mpu_ras,
		xdr_mpu_we  => xdr_mpu_we,
		xdr_mpu_rea => xdr_mpu_rea,
		xdr_mpu_wri => xdr_mpu_wri,
		xdr_mpu_rwin => xdr_mpu_rwin,
		xdr_mpu_wwin => xdr_mpu_wwin);

	xdr_sch_e : entity hdl4fpga.xdr_sch
	generic map (
		line_size   => line_size/word_size,
		word_size   => 1,
		CL_COD    => CL_COD,
		CWL_COD   => CWL_COD,
                               
		STRL_TAB  => STRL_TAB,
		RWNL_tab  => RWNL_tab,
		DQSZL_TAB => DQSZL_TAB,
		DQSOL_TAB => DQSOL_TAB,
		DQZL_TAB  => DQZL_TAB,
		WWNL_TAB  => WWNL_TAB,
                               
		STRX_LAT  => STRX_LAT,
		RWNX_LAT  => RWNX_LAT,
		DQSZX_TAB => DQSZX_TAB ,
		DQSX_LAT  => DQSX_LAT,
		DQZX_TAB  => DQZX_TAB,
		WWNX_LAT  => WWNX_LAT,
		WID_LAT   => WID_LAT)
	port map (
		sys_cl   => sys_cl,
		sys_cwl  => xdr_cwl,
		sys_clks => sys_clks(0 to 0),
		sys_rea  => xdr_mpu_rwin,
		sys_wri  => xdr_mpu_wwin,

		xdr_rwn => xdr_sch_rwn,
		xdr_st  => xdr_sch_st,

		xdr_dqsz => xdr_sch_dqsz,
		xdr_dqs  => xdr_sch_dqs,
		xdr_dqz  => xdr_sch_dqz,
		xdr_wwn  => xdr_sch_wwn);

	xdr_win_dqs <= (others => xdr_sti(0));
	xdr_win_dq  <= (others => xdr_sti(0));
	xdr_sto <= xdr_sch_rwn;

	xdr_dqso <= xdr_sch_dqs & xdr_sch_dqs;
	xdr_dqt <= xdr_sch_dqz & xdr_sch_dqz;
	xdr_dmt <= xdr_sch_dqz & xdr_sch_dqz;
	xdr_dqst <= not xdr_sch_dqsz & not xdr_sch_dqsz;

	rdfifo_i : entity hdl4fpga.xdr_rdfifo
	generic map (
		data_phases => data_phases,
		line_size => line_size,
		word_size => word_size,
		byte_size => byte_size,
		data_delay => 0)
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
		lat_cod => xdr_latcod(stdr, CWL),
		lat_tab => xdr_lattab(stdr, WWNT,  tDDR => tDDR, tCP => tDDR/2));

	rotate_i : entity hdl4fpga.barrel
	generic map (
		n => sys_di'length,
		m => unsigned_num_bits(line_size-1))
	port map (
		rot  => rot_val,
		din  => sys_di,
		dout => rot_di);
		
	wrfifo_i : entity hdl4fpga.xdr_wrfifo
	generic map (
		registered_output => registered_output,
		data_phases  => data_phases,

		line_size => line_size,
		word_size => word_size,
		byte_size => byte_size)
	port map (
		sys_clk => sys_clks(0),
		sys_dqi => rot_di,
		sys_req => xdr_mpu_wwin,
		sys_dmi => sys_dm,
		xdr_clks => xdr_wclks,
		xdr_dmo  => xdr_wr_dm,
		xdr_enas => xdr_sch_wwn, 
		xdr_dqo  => xdr_dqo);
	xdr_dmo <= 
	xdr_wr_dm when xdr_mpu_wri='1' else
	xdr_sch_st & xdr_sch_st;


end;
