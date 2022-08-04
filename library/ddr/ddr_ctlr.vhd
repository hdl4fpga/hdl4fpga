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
use hdl4fpga.profiles.all;
use hdl4fpga.ddr_db.all;
use hdl4fpga.ddr_param.all;

entity ddr_ctlr is
	generic (
		debug        : boolean := false;
		fpga         : fpga_devices;
		mark         : sdram_chips := m6t;
		tcp          : real := 0.0;

		cmmd_gear    : natural :=  1;
		bank_size    : natural :=  2;
		addr_size    : natural := 13;
		sclk_phases  : natural :=  4;
		sclk_edges   : natural :=  2;
		data_phases  : natural :=  2;
		data_edges   : natural :=  2;
		data_gear    : natural :=  2;
		word_size    : natural := 16;
		byte_size    : natural :=  8);
	port (
		ctlr_alat    : out std_logic_vector(2 downto 0);
		ctlr_blat    : out std_logic_vector(2 downto 0);
		ctlr_bl      : in std_logic_vector(2 downto 0);
		ctlr_cl      : in std_logic_vector(2 downto 0);
		ctlr_cwl     : in std_logic_vector(2 downto 0);
		ctlr_wrl     : in std_logic_vector(2 downto 0);
		ctlr_rtt     : in std_logic_vector;

		ctlr_rst     : in std_logic;
		ctlr_clks    : in std_logic_vector(0 to sclk_phases/sclk_edges-1);
		ctlr_cfgrdy  : out std_logic;
		ctlr_inirdy  : out std_logic;

		ctlr_frm     : in  std_logic;
		ctlr_trdy    : out std_logic;
		ctlr_fch     : out std_logic;
		ctlr_cmd     : out std_logic_vector(0 to 2);
		ctlr_rw      : in  std_logic;
		ctlr_b       : in  std_logic_vector(bank_size-1 downto 0);
		ctlr_a       : in  std_logic_vector(addr_size-1 downto 0);
		ctlr_di_dv   : in  std_logic;
		ctlr_di_req  : out std_logic;
		ctlr_do_dv   : out std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
		ctlr_do_req  : out std_logic;
		ctlr_dio_req : out std_logic;
		ctlr_act     : out std_logic;
		ctlr_ras     : out std_logic;
		ctlr_cas     : out std_logic;
		ctlr_dm      : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0) := (others => '0');
		ctlr_di      : in  std_logic_vector(data_gear*word_size-1 downto 0);
		ctlr_do      : out std_logic_vector(data_gear*word_size-1 downto 0);
		ctlr_refreq  : out std_logic;
		phy_frm      : in  std_logic := '0';
		phy_trdy     : out std_logic;
		phy_rw       : in  std_logic := '-';
		phy_inirdy   : in  std_logic := '1';
		phy_wlrdy    : in  std_logic := '-';
		phy_wlreq    : out std_logic;
		phy_rlreq    : out std_logic;
		phy_rlrdy    : in  std_logic := '1';
		phy_rst      : out std_logic;
		phy_cke      : out std_logic;
		phy_cs       : out std_logic;
		phy_ras      : out std_logic;
		phy_cas      : out std_logic;
		phy_we       : out std_logic;
		phy_b        : out std_logic_vector(bank_size-1 downto 0);
		phy_a        : out std_logic_vector(addr_size-1 downto 0);
		phy_odt      : out std_logic;
		phy_dmi      : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_dmt      : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_dmo      : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);

		phy_dqi      : in  std_logic_vector(data_gear*word_size-1 downto 0);
		phy_dqt      : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_dqo      : out std_logic_vector(data_gear*word_size-1 downto 0);
		phy_sti      : in  std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
		phy_sto      : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);

		phy_dqsi     : in  std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
		phy_dqso     : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_dqst     : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0));

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of ddr_ctlr is
	constant stdr         : sdrams := ddr_stdr(mark);

	constant strx_lat     : natural          := ddr_latency(fpga, strxl);
	constant rwnx_lat     : natural          := ddr_latency(fpga, rwnxl);
	constant dqszx_lat    : natural          := ddr_latency(fpga, dqszxl);
	constant dqsx_lat     : natural          := ddr_latency(fpga, dqsxl);
	constant dqzx_lat     : natural          := ddr_latency(fpga, dqzxl);
	constant rdfifo_lat   : natural          := ddr_latency(fpga, hdl4fpga.ddr_db.rdfifo_lat);
	constant lwr          : natural          := to_ddrlatency(tcp, ddr_timing(mark, twr)+tcp*real(ddr_latency(fpga, dqsxl)));
	constant lrcd         : natural          := to_ddrlatency(tcp, mark, trcd);
	constant lrfc         : natural          := to_ddrlatency(tcp, mark, trfc);
	constant lrp          : natural          := to_ddrlatency(tcp, mark, trp);
	constant wwnx_lat     : natural          := ddr_latency(fpga, wwnxl);
	constant wid_lat      : natural          := ddr_latency(fpga, widl);
--	constant wwnx_lat     : natural          := ddr_latency(stdr, wwnxl);
--	constant wid_lat      : natural          := ddr_latency(stdr, widl);
	constant bl_cod       : std_logic_vector := ddr_latcod(stdr, bl);
	constant cl_cod       : std_logic_vector := ddr_latcod(stdr, cl);
	constant cwl_cod      : std_logic_vector := ddr_latcod(stdr, ddr_selcwl(stdr));
	constant bl_tab       : natural_vector   := ddr_lattab(stdr, bl);
	constant cl_tab       : natural_vector   := ddr_lattab(stdr, cl);
	constant cwl_tab      : natural_vector   := ddr_lattab(stdr, cwl);
	constant strl_tab     : natural_vector   := ddr_schtab(stdr, fpga, strl);
	constant rwnl_tab     : natural_vector   := ddr_schtab(stdr, fpga, rwnl);
	constant dqszl_tab    : natural_vector   := ddr_schtab(stdr, fpga, dqszl);
	constant dqsol_tab    : natural_vector   := ddr_schtab(stdr, fpga, dqsl);
	constant dqzl_tab     : natural_vector   := ddr_schtab(stdr, fpga, dqzl);
	constant timers       : natural_vector   := ddr_timers(tcp, mark, debug => debug);
	constant wwnl_tab     : natural_vector   := ddr_schtab(stdr, fpga, wwnl);

	subtype byte is std_logic_vector(0 to byte_size-1);
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
	signal ddr_init_a     : std_logic_vector(addr_size-1 downto 0);
	signal ddr_init_b     : std_logic_vector(bank_size-1 downto 0);

	signal ddr_pgm_frm    : std_logic;
	signal ddr_pgm_rw     : std_logic;
	signal ddr_pgm_cmd    : std_logic_vector(0 to 2);

	signal ddr_mpu_rst    : std_logic;
	signal ddr_mpu_trdy   : std_logic;
	signal ddr_mpu_ras    : std_logic;
	signal ddr_mpu_cas    : std_logic;
	signal ddr_mpu_we     : std_logic;
	signal ddr_mpu_wri    : std_logic;
	signal ddr_mpu_rea    : std_logic;
	signal ddr_mpu_rwin   : std_logic;
	signal ddr_mpu_wwin   : std_logic;
	signal ddr_mpu_rwwin  : std_logic;

	signal ddr_sch_odt    : std_logic_vector(0 to cmmd_gear-1);
	signal ddr_sch_dqsz   : std_logic_vector(0 to data_gear-1);
	signal ddr_sch_dqs    : std_logic_vector(ddr_sch_dqsz'range);
	signal ddr_sch_dqz    : std_logic_vector(ddr_sch_dqsz'range);
	signal ddr_sch_st     : std_logic_vector(ddr_sch_dqsz'range);
	signal ddr_sch_wwn    : std_logic_vector(0 to data_gear-1);
	signal ddr_sch_rwn    : std_logic_vector(ddr_sch_dqsz'range);
	signal ddr_wclks      : std_logic_vector(0 to data_phases*word_size/byte_size-1);
	signal ddr_wenas      : std_logic_vector(0 to data_phases*word_size/byte_size-1);

	signal ddr_win_dqs    : std_logic_vector(phy_dqsi'range);
	signal ddr_win_dq     : std_logic_vector(phy_dqsi'range);
	signal ddr_wr_dm      : std_logic_vector(ctlr_dm'range);

	signal rot_val        : std_logic_vector(unsigned_num_bits(data_gear*word_size-1)-1 downto 0);
	signal rot_di         : std_logic_vector(ctlr_di'range);

	signal ddr_cwl        : std_logic_vector(ctlr_cwl'range);

	signal ddr_mr_addr    : std_logic_vector(3-1 downto 0);
	signal ddr_mr_data    : std_logic_vector(13-1 downto 0);
	signal ddr_mpu_sel    : std_logic;
	signal init_rdy       : std_logic;


	signal refreq : std_logic;
	signal fifo_bypass : std_logic;
begin

	ctlr_alat    <= std_logic_vector(to_unsigned(lrcd, ctlr_alat'length));

	ctlr_trdy    <= ddr_mpu_trdy when phy_inirdy='1' else '0';
	phy_trdy     <= ddr_mpu_trdy when phy_inirdy='0' else '0';
	ddr_pgm_frm  <= ctlr_frm     when phy_inirdy='1' else phy_frm;
	ddr_pgm_rw   <= ctlr_rw      when phy_inirdy='1' else phy_rw;
	ddr_cwl      <= ctlr_cl      when stdr=ddr2      else ctlr_cwl;
	ddr_init_req <= ctlr_rst;
	ddr_init_e : entity hdl4fpga.ddr_init
	generic map (
		ddr_stdr       => stdr,
		timers         => timers,
		addr_size      => addr_size,
		bank_size      => bank_size)
	port map (
		ddr_init_bl    => ctlr_bl,
		ddr_init_cl    => ctlr_cl,
		ddr_init_cwl   => ddr_cwl,
		ddr_init_bt    => "0",
		ddr_init_ods   => "0",
		ddr_init_wr    => ctlr_wrl,
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
		ddr_init_wlreq => phy_wlreq,
		ddr_init_wlrdy => phy_wlrdy,
		ddr_refi_req   => ddr_refi_req,
		ddr_refi_rdy   => ddr_refi_rdy);

	init_rdy    <= ddr_init_rdy;
	phy_rst     <= ddr_init_rst;
	phy_cke     <= ddr_init_cke;
	phy_cs      <= '0'          when ddr_mpu_sel='1' else ddr_init_cs;
	phy_ras     <= ddr_mpu_ras  when ddr_mpu_sel='1' else ddr_init_ras;
	phy_cas     <= ddr_mpu_cas  when ddr_mpu_sel='1' else ddr_init_cas;
	phy_we      <= ddr_mpu_we   when ddr_mpu_sel='1' else ddr_init_we;
	phy_a       <= ctlr_a       when ddr_mpu_sel='1' else ddr_init_a;
	phy_b       <= ctlr_b       when ddr_mpu_sel='1' else ddr_init_b;
	phy_odt     <= ddr_init_odt when ddr_mpu_sel='0' else ddr_sch_odt(0) when stdr=ddr3 else '1';
	phy_rlreq   <= init_rdy;
	ctlr_cfgrdy <= init_rdy;
	ctlr_inirdy <= init_rdy when phy_inirdy='1' else '0';

	ddr_pgm_e : entity hdl4fpga.ddr_pgm
	generic map (
		cmmd_gear     => cmmd_gear)
	port map (
		ctlr_clk      => ctlr_clks(0),
		ctlr_rst      => ddr_mpu_rst,
		ctlr_refreq   => ctlr_refreq,
		ddr_pgm_frm   => ddr_pgm_frm ,
		ddr_mpu_trdy  => ddr_mpu_trdy,
		ddr_pgm_cmd   => ddr_pgm_cmd,
		ddr_pgm_rw    => ddr_pgm_rw,
		ddr_ref_req   => ddr_refi_req,
		ddr_ref_rdy   => ddr_refi_rdy);

	ddr_mpu_rst <= not init_rdy;
	ddr_mpu_sel <= init_rdy;
	ddr_mpu_e : entity hdl4fpga.ddr_mpu
	generic map (
		gear        => data_gear,
		lrcd        => lrcd,
		lrfc        => lrfc,
		lwr         => lwr,
		lrp         => lrp,
		bl_cod      => bl_cod,
		cl_cod      => cl_cod,
		cwl_cod     => cwl_cod,
		bl_tab      => bl_tab,
		cl_tab      => cl_tab,
		cwl_tab     => cwl_tab)
	port map (
		ddr_mpu_bl    => ctlr_bl,
		ddr_mpu_cl    => ctlr_cl,
		ddr_mpu_cwl   => ddr_cwl,

		ddr_mpu_rst   => ddr_mpu_rst,
		ddr_mpu_clk   => ctlr_clks(0),
		ddr_mpu_cmd   => ddr_pgm_cmd,
		ddr_mpu_trdy  => ddr_mpu_trdy,
		ddr_mpu_fch   => ctlr_fch,
		ddr_mpu_act   => ctlr_act,
		ddr_mpu_cas   => ddr_mpu_cas,
		ddr_mpu_ras   => ddr_mpu_ras,
		ddr_mpu_blat  => ctlr_blat,
		ddr_mpu_we    => ddr_mpu_we,
		ddr_mpu_rea   => ddr_mpu_rea,
		ddr_mpu_wri   => ddr_mpu_wri,
		ddr_mpu_rwin  => ddr_mpu_rwin,
		ddr_mpu_wwin  => ddr_mpu_wwin,
		ddr_mpu_rwwin => ddr_mpu_rwwin);

	ctlr_cmd     <= ddr_pgm_cmd;
	ctlr_di_req  <= ddr_mpu_wwin;
	ctlr_do_req  <= ddr_mpu_rwin;
	ctlr_dio_req <= ddr_mpu_rwwin;

	ddr_sch_e : entity hdl4fpga.ddr_sch
	generic map (
		profile     => fpga,
		cmmd_gear   => cmmd_gear,
		data_phases => data_phases,
		clk_phases  => sclk_phases,
		clk_edges   => sclk_edges,
		data_gear   => data_gear,
		cl_cod      => cl_cod,
		cwl_cod     => cwl_cod,

		strl_tab    => strl_tab,
		rwnl_tab    => rwnl_tab,
		dqszl_tab   => dqszl_tab,
		dqsol_tab   => dqsol_tab,
		dqzl_tab    => dqzl_tab,
		wwnl_tab    => wwnl_tab,

		strx_lat    => strx_lat,
		rwnx_lat    => rwnx_lat,
		dqszx_lat   => dqszx_lat,
		dqsx_lat    => dqsx_lat,
		dqzx_lat    => dqzx_lat,
		wwnx_lat    => wwnx_lat,
		wid_lat     => wid_lat)
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
		ddr_sch_st,
		ddr_sch_dqz,
		ddr_sch_dqs,
		ddr_sch_dqsz,
		ddr_sch_rwn,
		ddr_sch_wwn)
	begin
		for i in 0 to word_size/byte_size-1 loop
			for j in 0 to data_gear-1 loop
				phy_dqt(i*data_gear+j)  <= ddr_sch_dqz(j);
				phy_dmt(i*data_gear+j)  <= reverse(ddr_sch_dqz)(j);
				phy_dqso(i*data_gear+j) <= ddr_sch_dqs(j);
				phy_dqst(i*data_gear+j) <= not ddr_sch_dqsz(j);
				phy_sto(i*data_gear+j)  <= reverse(ddr_sch_st)(j);
				phy_dmo(i*data_gear+j)  <= ddr_wr_dm(i*data_gear+j);
			end loop;
			for j in 0 to data_phases-1 loop
				ddr_wenas(i*data_phases+j) <= ddr_sch_wwn(j);
			end loop;
		end loop;
	end process;

	rdfifo_i : entity hdl4fpga.ddr_rdfifo
	generic map (
		data_phases => data_phases,
		data_gear   => data_gear,
		word_size   => word_size,
		byte_size   => byte_size,
		data_delay  => rdfifo_lat)
	port map (
		sys_clk     => ctlr_clks(0),
		sys_rdy     => ctlr_do_dv,
		sys_rea     => ddr_mpu_rea,
		sys_do      => ctlr_do,
		ddr_win_dq  => ddr_win_dq,
		ddr_win_dqs => ddr_win_dqs,
		ddr_dqsi    => phy_dqsi,
		ddr_dqi     => phy_dqi);

	rot_val <= ddr_rotval (
		line_size => data_gear*word_size,
		word_size => word_size,
		lat_val => ctlr_cwl,
		lat_cod => cwl_cod,
		lat_tab => wwnl_tab);

	rotate_i : entity hdl4fpga.barrel
	port map (
		shf => rot_val,
		di  => ctlr_di,
		do  => rot_di);

	process (ctlr_clks(ctlr_clks'high))
	begin
		for k in 0 to word_size/byte_size-1 loop
			for i in 0 to data_phases-1 loop
				ddr_wclks(k*data_phases+i) <= ctlr_clks(ctlr_clks'high);
				if data_edges > 1 then
					ddr_wclks(k*data_phases+1) <= not ctlr_clks(ctlr_clks'high);
				end if;
			end loop;
		end loop;
	end process;

	wrfifo_b : block
		signal bypass : std_logic;
		signal dqo    : std_logic_vector(phy_dqo'range);
		signal dmo    : std_logic_vector(ddr_wr_dm'range);
	begin
		bypass <= '1' when stdr=sdr else '0';

		wrfifo_i : entity hdl4fpga.ddr_wrfifo
		generic map (
			data_phases => data_phases,
			data_gear   => data_gear,
			word_size   => word_size,
			byte_size   => byte_size)
		port map (
			ctlr_clk    => ctlr_clks(0),
			ctlr_dqi    => rot_di,
			ctlr_ena    => ctlr_di_dv,
			ctlr_req    => ddr_mpu_wri,
			ctlr_dmi    => ctlr_dm,
			ddr_clks    => ddr_wclks,
			ddr_dmo     => dmo,
			ddr_enas    => ddr_wenas,
			ddr_dqo     => dqo);

		phy_dqo   <= rot_di  when bypass='1' else dqo;
		ddr_wr_dm <= ctlr_dm when bypass='1' else dmo;
	end block;

end;
