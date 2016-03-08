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
		strobe : string := "NONE_LOOPBACK";
		mark : natural := M6T;
		tcp : natural := 6000;

		bank_size : natural :=  2;
		addr_size : natural := 13;

		sclk_phases : natural := 4;
		sclk_edges : natural := 2;
		data_phases : natural := 2;
		data_edges : natural := 2;
		line_size : natural := 32;
		word_size : natural := 16;
		byte_size : natural :=  8);

	port (
		sys_bl  : in std_logic_vector(2 downto 0);
		sys_cl  : in std_logic_vector(2 downto 0);
		sys_cwl : in std_logic_vector(2 downto 0);
		sys_wr  : in std_logic_vector(2 downto 0);
		sys_rtt : in std_logic_vector;

		sys_rst  : in std_logic;
		sys_clks : in std_logic_vector(0 to sclk_phases/sclk_edges-1);
		sys_ini  : out std_logic;
		sys_wlrdy : in  std_logic := '-';
		sys_wlreq : out std_logic;

		sys_cmd_req : in  std_logic;
		sys_cmd_rdy : out std_logic;
		sys_rw : in  std_logic;
		sys_b  : in  std_logic_vector(bank_size-1 downto 0);
		sys_a  : in  std_logic_vector(addr_size-1 downto 0);
		sys_di_rdy : in  std_logic;
		sys_di_req : out std_logic;
--		sys_do_rdy : out std_logic_vector(word_size/byte_size-1 downto 0);
		sys_do_rdy : out std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
		sys_act : out std_logic;
		sys_cas : out std_logic;
		sys_pre : out std_logic;
		sys_dm  : in  std_logic_vector(line_size/byte_size-1 downto 0) := (others => '0');
		sys_di  : in  std_logic_vector(line_size-1 downto 0);
		sys_do  : out std_logic_vector(line_size-1 downto 0);
		sys_ref : out std_logic;

		xdr_rst : out std_logic;
		xdr_cke : out std_logic;
		xdr_cs  : out std_logic;
		xdr_ras : out std_logic;
		xdr_cas : out std_logic;
		xdr_we  : out std_logic;
		xdr_b   : out std_logic_vector(bank_size-1 downto 0);
		xdr_a   : out std_logic_vector(addr_size-1 downto 0);
		xdr_odt : out std_logic;
		xdr_dmi : in  std_logic_vector(line_size/byte_size-1 downto 0);
		xdr_dmt : out std_logic_vector(line_size/byte_size-1 downto 0);
		xdr_dmo : out std_logic_vector(line_size/byte_size-1 downto 0);

		xdr_dqi : in  std_logic_vector(line_size-1 downto 0);
		xdr_dqt : out std_logic_vector(line_size/byte_size-1 downto 0);
		xdr_dqo : out std_logic_vector(line_size-1 downto 0);
		xdr_sti : in  std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
		xdr_sto : out std_logic_vector(line_size/byte_size-1 downto 0);

		xdr_dqsi : in  std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
		xdr_dqso : out std_logic_vector(line_size/byte_size-1 downto 0);
		xdr_dqst : out std_logic_vector(line_size/byte_size-1 downto 0));

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of xdr is
	constant stdr : natural := xdr_stdr(mark);
	constant gear : natural := line_size/word_size;

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

	signal xdr_sch_odt : std_logic_vector(0 to gear-1);
	signal xdr_sch_dqsz : std_logic_vector(0 to gear-1);
	signal xdr_sch_dqs : std_logic_vector(xdr_sch_dqsz'range);
	signal xdr_sch_dqz : std_logic_vector(xdr_sch_dqsz'range);
	signal xdr_sch_st : std_logic_vector(xdr_sch_dqsz'range);
	signal xdr_sch_wwn : std_logic_vector(0 to gear-1); --data_phases-1);
	signal xdr_sch_rwn : std_logic_vector(xdr_sch_dqsz'range);
	signal xdr_wclks : std_logic_vector(0 to data_phases*word_size/byte_size-1);
	signal xdr_wenas : std_logic_vector(0 to data_phases*word_size/byte_size-1);

	signal xdr_win_dqs : std_logic_vector(xdr_dqsi'range);
	signal xdr_win_dq  : std_logic_vector(xdr_dqsi'range);
	signal xdr_wr_fifo_rst : std_logic;
	signal xdr_wr_fifo_req : std_logic;
	signal xdr_wr_fifo_ena : std_logic_vector(line_size/word_size-1 downto 0);
	signal xdr_wr_dm : std_logic_vector(sys_dm'range);
	signal xdr_wr_dq : std_logic_vector(sys_di'range);

	signal rot_val : std_logic_vector(unsigned_num_bits(line_size-1)-1 downto 0);
	signal rot_di : std_logic_vector(sys_di'range);

	signal xdr_cwl : std_logic_vector(sys_cwl'range);

	constant tlWR : natural := xdr_timing(mark, tWR)+xdr_latency(stdr, DQSXL);
	constant timers : natural_vector := ddr_timers(tCP, mark);

	signal xdr_mr_addr : std_logic_vector(3-1 downto 0);
	signal xdr_mr_data : std_logic_vector(13-1 downto 0);
	signal xdr_mpu_sel : std_logic;
	signal init_rdy : std_logic;

	constant lRCD : natural := to_xdrlatency(tCP, mark, tRCD);
	constant lRFC : natural := to_xdrlatency(tCP, mark, tRFC);
	constant lWR  : natural := to_xdrlatency(tCP, tlWR);
	constant lRP  : natural := to_xdrlatency(tCP, mark, tRP);
	constant bl_cod  : std_logic_vector := xdr_latcod(stdr, BL);
	constant bl_tab  : natural_vector := xdr_lattab(stdr, BL);
	constant cl_tab  : natural_vector := xdr_lattab(stdr, CL);
	constant cwl_tab : natural_vector := xdr_schtab(stdr, CWL);

	constant CL_COD    : std_logic_vector := xdr_latcod(stdr, CL);
	constant CWL_COD   : std_logic_vector := xdr_latcod(stdr, xdr_selcwl(stdr));
	constant STRL_TAB  : natural_vector := xdr_schtab(stdr, STRL);
	constant RWNL_TAB  : natural_vector := xdr_schtab(stdr, RWNL);
	constant DQSZL_TAB : natural_vector := xdr_schtab(stdr, DQSZL);
	constant DQSOL_TAB : natural_vector := xdr_schtab(stdr, DQSL);
	constant DQZL_TAB  : natural_vector := xdr_schtab(stdr, DQZL);
	constant WWNL_TAB  : natural_vector := xdr_schtab(stdr, WWNL);
	constant STRX_LAT  : natural := xdr_latency(stdr, STRXL);
	constant RWNX_LAT  : natural := xdr_latency(stdr, RWNXL);
	constant DQSZX_LAT : natural := xdr_latency(stdr, DQSZXL);
	constant DQSX_LAT  : natural := xdr_latency(stdr, DQSXL);
	constant DQZX_LAT  : natural := xdr_latency(stdr, DQZXL);
	constant WWNX_LAT  : natural := xdr_latency(stdr, WWNXL);
	constant WID_LAT   : natural := xdr_latency(stdr, WIDL);

begin


	xdr_cwl <= sys_cl when stdr=2 else sys_cwl;

	xdr_init_req <= sys_rst;

	xdr_init_e : entity hdl4fpga.xdr_init
	generic map (
		ddr_stdr => stdr,
		timers => timers,
		addr_size => addr_size,
		bank_size => bank_size)
	port map (
		xdr_init_bl  => sys_bl,
		xdr_init_cl  => sys_cl,
		xdr_init_cwl => xdr_cwl,
		xdr_init_bt  => "0",
		xdr_init_ods => "0",
		xdr_init_wr  => sys_wr,
		xdr_init_rtt  => sys_rtt,

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
		xdr_init_wlreq => sys_wlreq,
		xdr_init_wlrdy => sys_wlrdy,
		xdr_refi_req => xdr_refi_req,
		xdr_refi_rdy => xdr_refi_rdy);

	xdr_rst <= xdr_init_rst;
	xdr_cs  <= '0'         when xdr_mpu_sel='1' else xdr_init_cs;
	xdr_cke <= xdr_init_cke;
	xdr_odt <= xdr_sch_odt(0) when xdr_mpu_sel='1' else xdr_init_odt;
	xdr_ras <= xdr_mpu_ras when xdr_mpu_sel='1' else xdr_init_ras;
	xdr_ras <= xdr_mpu_ras when xdr_mpu_sel='1' else xdr_init_ras;
	xdr_cas <= xdr_mpu_cas when xdr_mpu_sel='1' else xdr_init_cas;
	xdr_we  <= xdr_mpu_we  when xdr_mpu_sel='1' else xdr_init_we;
	xdr_a   <= sys_a       when xdr_mpu_sel='1' else xdr_init_a;
	xdr_b   <= sys_b       when xdr_mpu_sel='1' else xdr_init_b;

	mpu_sel_slr_e : entity hdl4fpga.align
	generic map (
		srl16 => "false",
		n => 2,
		d => (0 to 1 => 1))
	port map (
		clk => sys_clks(0),
		di(0) => xdr_init_rdy,
		di(1) => init_rdy,
		do(0) => init_rdy,
		do(1) => xdr_mpu_sel);

	sys_ini <= init_rdy;
	xdr_mpu_rst <= not init_rdy;
	xdr_mpu_ref <= xdr_refi_req;

	xdr_pgm_e : entity hdl4fpga.xdr_pgm --(registered)
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
	sys_di_req  <= xdr_mpu_wwin;
				   
	xdr_mpu_e : entity hdl4fpga.xdr_mpu
	generic map (
		gear => gear,
		lRCD => lRCD,
		lRFC => lRFC,
		lWR  => lWR,
		lRP  => lRP,
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
		data_phases => data_phases,
		clk_phases => sclk_phases,
		clk_edges => sclk_edges,
		gear => gear,
		CL_COD    => CL_COD,
		CWL_COD   => CWL_COD,
                               
		STRL_TAB  => STRL_TAB,
		RWNL_TAB  => RWNL_TAB,
		DQSZL_TAB => DQSZL_TAB,
		DQSOL_TAB => DQSOL_TAB,
		DQZL_TAB  => DQZL_TAB,
		WWNL_TAB  => WWNL_TAB,
                               
		STRX_LAT  => STRX_LAT,
		RWNX_LAT  => RWNX_LAT,
		DQSZX_LAT => DQSZX_LAT,
		DQSX_LAT  => DQSX_LAT,
		DQZX_LAT  => DQZX_LAT,
		WWNX_LAT  => WWNX_LAT,
		WID_LAT   => WID_LAT)
	port map (
		sys_cl   => sys_cl,
		sys_cwl  => xdr_cwl,
		sys_clks => sys_clks,
		sys_rea  => xdr_mpu_rwin,
		sys_wri  => xdr_mpu_wwin,

		xdr_rwn => xdr_sch_rwn,
		xdr_st  => xdr_sch_st,

		xdr_dqsz => xdr_sch_dqsz,
		xdr_dqs  => xdr_sch_dqs,
		xdr_dqz  => xdr_sch_dqz,
		xdr_odt  => xdr_sch_odt,
		xdr_wwn  => xdr_sch_wwn);

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
			for j in 0 to gear-1 loop
				xdr_dqt(i*gear+j)  <= xdr_sch_dqz(j);
				xdr_dmt(i*gear+j)  <= reverse(xdr_sch_dqz)(j);
				xdr_dqso(i*gear+j) <= xdr_sch_dqs(j);
				xdr_dqst(i*gear+j) <= not xdr_sch_dqsz(j);
				xdr_sto(i*gear+j)  <= reverse(xdr_sch_st)(j);
				xdr_dmo(i*gear+j) <= xdr_wr_dm(i*gear+j);
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
--		data_delay => 2)
		data_delay => 4) --latticesemi
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
		sys_req => sys_di_rdy,
		sys_dmi => sys_dm,
		xdr_clks => xdr_wclks,
		xdr_dmo => xdr_wr_dm,
		xdr_enas => xdr_wenas, 
		xdr_dqo => xdr_dqo);

end;
