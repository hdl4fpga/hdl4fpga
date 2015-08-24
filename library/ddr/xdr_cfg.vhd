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

entity xdr_cfg is
	generic (
		cRP  : natural := 10;
		cMRD : natural := 11;
	    cRFC : natural := 13;
	    cMOD : natural := 13;

		a  : natural := 13;
		ba : natural :=  2);
	port (
		xdr_cfg_ods : in  std_logic := '0';
		xdr_cfg_rtt : in  std_logic_vector(1 downto 0) := "01";
		xdr_cfg_bl  : in  std_logic_vector(0 to 2);
		xdr_cfg_cl  : in  std_logic_vector(0 to 2);
		xdr_cfg_wr  : in  std_logic_vector(0 to 2) := (others => '0');
		xdr_cfg_cwl : in  std_logic_vector(0 to 2) := (others => '0');
		xdr_cfg_pl  : in  std_logic_vector(0 to 2) := (others => '0');
		xdr_cfg_dqsn : in std_logic := '0';

		xdr_cfg_clk : in  std_logic;
		xdr_cfg_req : in  std_logic;
		xdr_cfg_rdy : out std_logic := '1';
		xdr_cfg_dll : out std_logic := '1';
		xdr_cfg_odt : out std_logic := '0';
		xdr_cfg_ras : out std_logic := '1';
		xdr_cfg_cas : out std_logic := '1';
		xdr_cfg_we  : out std_logic := '1';
		xdr_cfg_a   : out std_logic_vector(a-1 downto 0) := (others => '1');
		xdr_cfg_b   : out std_logic_vector(ba-1 downto 0) := (others => '1'));

	constant ras : natural := 0;
	constant cas : natural := 1;
	constant rw  : natural := 2;

	constant cmd_nop  : std_logic_vector(0 to 2) := "111";
	constant cmd_auto : std_logic_vector(0 to 2) := "001";
	constant cmd_pre  : std_logic_vector(0 to 2) := "010";
	constant cmd_lmr  : std_logic_vector(0 to 2) := "000";
	constant cmd_zqcl : std_logic_vector(0 to 2) := "110";
	attribute fsm_encoding : string;
	attribute fsm_encoding of xdr_cfg : entity is "compact";
end;

architecture ddr1 of xdr_cfg is
	constant lat_size : natural := 5;

	type xdr_code is record
		xdr_cmd : std_logic_vector(0 to 2);
		xdr_lat : signed(0 to lat_size-1);
	end record;

	type xdr_labels is (s_pall1, s_lmr1, s_lmr2, s_pall2, s_auto1, s_auto2, s_lmr3, s_end);
	type xdr_cfg_insr is record
		lbl  : xdr_labels;
		code : xdr_code;
	end record;

	type xdr_state_tab is array (xdr_labels) of xdr_cfg_insr;
	constant xdr_cfg_pgm : xdr_state_tab := (
		s_pall1 => (s_lmr1,  (cmd_pre,  to_signed ( cRP-2, lat_size))),
		s_lmr1  => (s_lmr2,  (cmd_lmr,  to_signed (cMRD-2, lat_size))),
		s_lmr2  => (s_pall2, (cmd_lmr,  to_signed (cMRD-2, lat_size))),
		s_pall2 => (s_auto1, (cmd_pre,  to_signed ( cRP-2, lat_size))),
		s_auto1 => (s_auto2, (cmd_auto, to_signed (cRFC-2, lat_size))),
		s_auto2 => (s_lmr3,  (cmd_auto, to_signed (cRFC-2, lat_size))),
		s_lmr3  => (s_end,   (cmd_lmr,  to_signed (cMRD-2, lat_size))),
		s_end   => (s_end,   (cmd_nop,  (1 to lat_size => '1'))));

	signal lat_timer  : signed(0 to lat_size-1);
	signal xdr_cfg_pc : xdr_labels;
begin

	process (xdr_cfg_clk)
	begin
		if rising_edge(xdr_cfg_clk) then
			if xdr_cfg_req='1' then
				if lat_timer(0)='1' then
					lat_timer   <= xdr_cfg_pgm(xdr_cfg_pc).code.xdr_lat;
					xdr_cfg_ras <= xdr_cfg_pgm(xdr_cfg_pc).code.xdr_cmd(ras);
					xdr_cfg_cas <= xdr_cfg_pgm(xdr_cfg_pc).code.xdr_cmd(cas);
					xdr_cfg_we  <= xdr_cfg_pgm(xdr_cfg_pc).code.xdr_cmd(rw);

					xdr_cfg_a <= (others => '0');
					case xdr_cfg_pc is
					when s_lmr1 =>
						xdr_cfg_a(1 downto 0) <= xdr_cfg_ods & '0';
					when s_lmr2 =>
						xdr_cfg_a(9-1 downto 0) <= "10" & xdr_cfg_cl & "0" & xdr_cfg_bl;
					when s_lmr3 =>
						xdr_cfg_a(9-1 downto 0) <= "00" & xdr_cfg_cl & "0" & xdr_cfg_bl;
					when s_pall1|s_pall2 =>
						xdr_cfg_a(10) <= '1';
					when s_end =>
						xdr_cfg_a <= (others => '1');
					when others =>
						xdr_cfg_a <= (others => '0');
					end case;

					case xdr_cfg_pc is
					when s_lmr1 =>
						xdr_cfg_b <= "01";
					when s_end =>
						xdr_cfg_b <= "11";
					when others =>
						xdr_cfg_b <= "00";
					end case;

					xdr_cfg_pc <= xdr_cfg_pgm(xdr_cfg_pc).lbl;
					case xdr_cfg_pc is
					when s_end =>
						xdr_cfg_rdy <= '1';
					when others =>
						xdr_cfg_rdy <= '0';
					end case;

					if xdr_labels'pos(xdr_cfg_pc) > xdr_labels'pos(s_pall2) then
						xdr_cfg_dll <= '1';
					else
						xdr_cfg_dll <= '0';
					end if;
				else
					lat_timer    <= lat_timer - 1;
					xdr_cfg_ras <= '1';
					xdr_cfg_cas <= '1';
					xdr_cfg_we  <= '1';
					xdr_cfg_b   <= (others => '1');
					xdr_cfg_a   <= (others => '1');
					xdr_cfg_rdy <= '0';
				end if;
			else
				xdr_cfg_pc  <= s_pall1;
				lat_timer    <= (others => '1');
				xdr_cfg_ras <= '1';
				xdr_cfg_cas <= '1';
				xdr_cfg_we  <= '1';
				xdr_cfg_b   <= (others => '1');
				xdr_cfg_a   <= (others => '1');
				xdr_cfg_rdy <= '0';
				xdr_cfg_dll <= '0';
			end if;
		end if;
	end process;
end;

architecture ddr2 of xdr_cfg is
	constant lat_size : natural := 9;

	type xdr_code is record
		xdr_cmd : std_logic_vector(0 to 2);
		xdr_lat : signed(0 to lat_size-1);
	end record;

	type xdr_labels is (
		lb_pall1, lb_lemr2, lb_lemr3,
		lb_edll,  lb_rdll,  lb_pall2,
		lb_auto1, lb_auto2, lb_lmr,
		lb_docd,  lb_xocd,  lb_end); 

	type xdr_cfg_insr is record
		lbl  : xdr_labels;
		code : xdr_code;
	end record;

	type xdr_state_code is array (xdr_labels) of xdr_cfg_insr;

	constant xdr_cfg_pgm : xdr_state_code := (
		(lb_lemr2, (cmd_pre,  to_signed ( cRP-2, lat_size))),
		(lb_lemr3, (cmd_lmr,  to_signed (cMRD-2, lat_size))),
		(lb_edll,  (cmd_lmr,  to_signed (cMRD-2, lat_size))),
		(lb_rdll,  (cmd_lmr,  to_signed (cMRD-2, lat_size))),
		(lb_pall2, (cmd_lmr,  to_signed (cMRD-2, lat_size))),
		(lb_auto1, (cmd_pre,  to_signed ( cRP-2, lat_size))),
		(lb_auto2, (cmd_auto, to_signed (cRFC-2, lat_size))),
		(lb_lmr,   (cmd_auto, to_signed (cRFC-2, lat_size))),
		(lb_docd,  (cmd_lmr,  to_signed (cMRD-2, lat_size))),
		(lb_xocd,  (cmd_lmr,  to_signed (cMRD-2, lat_size))),
		(lb_end,   (cmd_lmr,  to_signed (cMOD-2, lat_size))),
		(lb_end,   (cmd_nop,  (0 to lat_size-1 => '1'))));

	signal lat_timer : signed(0 to lat_size-1);
	signal xdr_cfg_pc : xdr_labels;

	-- DDR2 Mode Register --
	------------------------

	subtype  mr_bl is natural range 2 downto 0;
	constant mr_bt : natural := 3;
	subtype  mr_cl is natural range 6 downto 4;
	constant mr_tm : natural := 7;
	constant mr_dll : natural := 8;
	subtype  mr_wr is natural range 11 downto 9;
	constant mr_pd : natural := 12;

	-- DDR2 Extended Mode Register --
	---------------------------------

	constant emr_dll : natural := 0;
	constant emr_ods : natural := 1;
	constant emr_rt0 : natural := 2;
	subtype  emr_pl  is natural range 5 downto 3;
	constant emr_rt1 : natural := 6;
	subtype  emr_ocd is natural range 9 downto 7;
	constant emr_dqs : natural := 10;
	constant emr_rdqs : natural := 11;
	constant emr_out : natural := 12;

	-- DDR2 Extended Mode Register 2 --
	-----------------------------------

	constant emr2_srt : natural := 7;

begin
	process (xdr_cfg_clk)
	begin
		if rising_edge(xdr_cfg_clk) then
			if xdr_cfg_req='1' then
				if lat_timer(0)='1' then
					lat_timer    <= xdr_cfg_pgm(xdr_cfg_pc).code.xdr_lat;
					xdr_cfg_ras <= xdr_cfg_pgm(xdr_cfg_pc).code.xdr_cmd(ras);
					xdr_cfg_cas <= xdr_cfg_pgm(xdr_cfg_pc).code.xdr_cmd(cas);
					xdr_cfg_we  <= xdr_cfg_pgm(xdr_cfg_pc).code.xdr_cmd(rw);

					xdr_cfg_odt <= '0';
					xdr_cfg_a <= (others => '0');
					case xdr_cfg_pc is
					when lb_pall1 =>
						xdr_cfg_a(10) <= '1';
					when lb_lemr2|lb_lemr3 =>
						xdr_cfg_a <= (others => '0');
					when lb_edll =>
						xdr_cfg_a(emr_dll) <= '0';
					when lb_rdll =>
						xdr_cfg_a(mr_dll) <= '1'; 
					when lb_pall2 =>
						xdr_cfg_a(10) <= '1';
					when lb_auto1|lb_auto2 =>
						xdr_cfg_a(10) <= '1';
					when lb_lmr =>
						xdr_cfg_a(mr_bl) <= xdr_cfg_bl; 
						xdr_cfg_a(mr_bt) <= '0'; 
						xdr_cfg_a(mr_cl) <= xdr_cfg_cl;
						xdr_cfg_a(mr_tm) <= '0'; 
						xdr_cfg_a(mr_dll) <= '0'; 
						xdr_cfg_a(mr_wr) <= xdr_cfg_wr; 
						xdr_cfg_a(mr_pd) <= '0'; 
					when lb_docd =>
						xdr_cfg_a(emr_dll) <= '0';
						xdr_cfg_a(emr_ods) <= xdr_cfg_ods;
						xdr_cfg_a(emr_rt0) <= xdr_cfg_rtt(0);
						xdr_cfg_a(emr_rt1) <= xdr_cfg_rtt(1);
						xdr_cfg_a(emr_ocd) <= (others => '1');
						xdr_cfg_a(emr_pl)  <= xdr_cfg_pl;
						xdr_cfg_a(emr_dqs) <= xdr_cfg_dqsn;
						xdr_cfg_a(emr_rdqs) <= '0';
						xdr_cfg_a(emr_out) <= '0';
					when lb_xocd =>
						xdr_cfg_a(emr_dll) <= '0';
						xdr_cfg_a(emr_ods) <= xdr_cfg_ods;
						xdr_cfg_a(emr_rt0) <= xdr_cfg_rtt(0);
						xdr_cfg_a(emr_rt1) <= xdr_cfg_rtt(1);
						xdr_cfg_a(emr_ocd) <= (others => '0');
						xdr_cfg_a(emr_pl)  <= xdr_cfg_pl;
						xdr_cfg_a(emr_dqs) <= xdr_cfg_dqsn;
						xdr_cfg_a(emr_rdqs) <= '0';
						xdr_cfg_a(emr_out) <= '0';

					when lb_end =>
						xdr_cfg_a <= (others => '1');
						xdr_cfg_odt <= '1';
					when others =>
						xdr_cfg_a <= (others => '0');
						xdr_cfg_odt <= '0';
					end case;

					xdr_cfg_b <= (others => '0');
					case xdr_cfg_pc is
					when lb_lemr2 =>
						xdr_cfg_b <= "10";
					when lb_lemr3 =>
						xdr_cfg_b <= "11";
					when lb_edll =>
						xdr_cfg_b <= "01";
					when lb_rdll =>
						xdr_cfg_b <= "00";
					when lb_lmr =>
						xdr_cfg_b <= "00";
					when lb_docd|lb_xocd =>
						xdr_cfg_b <= "01";
					when lb_end =>
						xdr_cfg_b <= "11";
					when others =>
						xdr_cfg_b <= "00";
					end case;

					xdr_cfg_pc <= xdr_cfg_pgm(xdr_cfg_pc).lbl;
					if xdr_cfg_pc=lb_end then
						xdr_cfg_rdy <= '1';
					else
						xdr_cfg_rdy <= '0';
					end if;

					if xdr_labels'pos(xdr_cfg_pc) > xdr_labels'pos(lb_pall2) then
						xdr_cfg_dll <= '1';
					else
						xdr_cfg_dll <= '0';
					end if;
				else
					lat_timer    <= lat_timer - 1;
					xdr_cfg_ras <= '1';
					xdr_cfg_cas <= '1';
					xdr_cfg_we  <= '1';
					xdr_cfg_b   <= (others => '1');
					xdr_cfg_a   <= (others => '1');
					xdr_cfg_rdy <= '0';
				end if;
			else
				xdr_cfg_pc  <= lb_pall1;
				lat_timer    <= (others => '1');
				xdr_cfg_ras <= '1';
				xdr_cfg_cas <= '1';
				xdr_cfg_we  <= '1';
				xdr_cfg_odt <= '0';
				xdr_cfg_b   <= (others => '1');
				xdr_cfg_a   <= (others => '1');
				xdr_cfg_rdy <= '0';
				xdr_cfg_dll <= '0';
			end if;
		end if;
	end process;
end;

architecture ddr3 of xdr_cfg is
	constant lat_size : natural := 9;

	type xdr_code is record
		xdr_cmd : std_logic_vector(0 to 2);
		xdr_lat : signed(0 to lat_size-1);
	end record;

	type xdr_labels is (
		lb_lmr2, lb_lmr3, lb_lmr1, lb_lmr0,
		lb_zqcl, lb_end); 

	type xdr_cfg_insr is record
		lbl  : xdr_labels;
		code : xdr_code;
	end record;

	type xdr_state_code is array (xdr_labels) of xdr_cfg_insr;

	signal lat_timer : signed(0 to lat_size-1);
	signal xdr_cfg_pc : xdr_labels;

	-- DDR3 Mode Register 0 --
	--------------------------

	subtype  mr0_bl is natural range 2 downto 0;
	constant mr0_bt : natural := 3;
	subtype  mr0_cl is natural range 6 downto 4;
	constant mr0_tm : natural := 7;
	constant mr0_dll : natural := 8;
	subtype  mr0_wr is natural range 11 downto 9;
	constant mr0_pd : natural := 12;

	-- DDR3 Mode Register 1 --
	--------------------------

	constant mr1_dll : natural := 0;
	constant mr1_ods0 : natural := 1;
	constant mr1_ods1 : natural := 5;
	constant mr1_rt0 : natural := 2;
	constant mr1_rt1 : natural := 6;
	constant mr1_rt2 : natural := 9;
	subtype  mr1_al  is natural range 4 downto 3;
	constant mr1_wr  : natural := 7;
	constant mr1_dqs : natural := 10;
	constant mr1_tdqs : natural := 11;
	constant mr1_qoff : natural := 12;

	-- DDR3 Mode Register 2 --
	--------------------------

	subtype  mr2_cwl is natural range  5 downto 3;
	constant mr2_asr : natural := 6;
	constant mr2_srt : natural := 7;
	subtype  mr2_rtt is natural range 10 downto 9;

	-- DDR3 Mode Register 3 --
	--------------------------

	subtype  mr3_mpr_rf is natural range 1 downto 0;
	constant mr3_mpr : natural := 1;

	constant xdr_cfg_pgm : xdr_state_code := (
		(lb_lmr3, (cmd_lmr, to_signed (cMRD-2, lat_size))),
		(lb_lmr1, (cmd_lmr, to_signed (cMRD-2, lat_size))),
		(lb_lmr0, (cmd_lmr, to_signed (cMRD-2, lat_size))),
		(lb_zqcl, (cmd_lmr, to_signed (cMRD-2, lat_size))),
		(lb_end, (cmd_zqcl, to_signed (cMRD-2, lat_size))),
		(lb_end,  (cmd_nop, (1 to lat_size => '1'))));

begin
	process (xdr_cfg_clk)
	begin
		if rising_edge(xdr_cfg_clk) then
			if xdr_cfg_req='1' then
				if lat_timer(0)='1' then
					lat_timer   <= xdr_cfg_pgm(xdr_cfg_pc).code.xdr_lat;
					xdr_cfg_ras <= xdr_cfg_pgm(xdr_cfg_pc).code.xdr_cmd(ras);
					xdr_cfg_cas <= xdr_cfg_pgm(xdr_cfg_pc).code.xdr_cmd(cas);
					xdr_cfg_we  <= xdr_cfg_pgm(xdr_cfg_pc).code.xdr_cmd(rw);

					xdr_cfg_a <= (others => '0');
					case xdr_cfg_pc is
					when lb_lmr3 =>
						xdr_cfg_a <= (others => '0');
					when lb_lmr2 =>
						xdr_cfg_a(mr2_cwl) <= xdr_cfg_cwl;
					when lb_lmr1 =>
						xdr_cfg_a(mr1_dll) <= '0';
					when lb_lmr0 =>
						xdr_cfg_a(mr0_bl) <= xdr_cfg_bl; 
						xdr_cfg_a(mr0_bt) <= '0'; 
						xdr_cfg_a(mr0_cl) <= xdr_cfg_cl;
						xdr_cfg_a(mr0_tm) <= '0'; 
						xdr_cfg_a(mr0_dll) <= '1'; 
						xdr_cfg_a(mr0_wr) <= xdr_cfg_wr; 
						xdr_cfg_a(mr0_pd) <= '0'; 
					when lb_zqcl =>
						xdr_cfg_a(10) <= '1';
					when lb_end =>
						xdr_cfg_a <= (others => '1');
					when others =>
						xdr_cfg_a <= (others => '0');
					end case;

					xdr_cfg_b <= (others => '0');
					case xdr_cfg_pc is
					when lb_lmr2 =>
						xdr_cfg_b <= "010";
					when lb_lmr3 =>
						xdr_cfg_b <= "011";
					when lb_lmr1 =>
						xdr_cfg_b <= "001";
					when lb_lmr0 =>
						xdr_cfg_b <= "000";
					when lb_zqcl =>
						xdr_cfg_b <= "---";
					when lb_end =>
						xdr_cfg_b <= "111";
					end case;

					xdr_cfg_pc <= xdr_cfg_pgm(xdr_cfg_pc).lbl;
					if xdr_cfg_pc=lb_end then
						xdr_cfg_rdy <= '1';
					else
						xdr_cfg_rdy <= '0';
					end if;

					if xdr_labels'pos(xdr_cfg_pc) > xdr_labels'pos(lb_lmr0) then
						xdr_cfg_dll <= '1';
					else
						xdr_cfg_dll <= '0';
					end if;
				else
					lat_timer    <= lat_timer - 1;
					xdr_cfg_ras <= '1';
					xdr_cfg_cas <= '1';
					xdr_cfg_we  <= '1';
					xdr_cfg_b   <= (others => '1');
					xdr_cfg_a   <= (others => '1');
					xdr_cfg_rdy <= '0';
				end if;
			else
				xdr_cfg_pc  <= lb_lmr2;
				lat_timer    <= (others => '1');
				xdr_cfg_ras <= '1';
				xdr_cfg_cas <= '1';
				xdr_cfg_we  <= '1';
				xdr_cfg_b   <= (others => '1');
				xdr_cfg_a   <= (others => '1');
				xdr_cfg_rdy <= '0';
				xdr_cfg_dll <= '0';
			end if;
		end if;
	end process;
end;
