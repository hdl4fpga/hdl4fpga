library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddr_init is
	generic (
		lat_length : natural := 5;
		a    : natural := 13;
		trp  : natural := 10;
		tmrd : natural := 11;
	    trfc : natural := 13;
	    tmod : natural := 13;
		ba   : natural := 2);
	port (
		ddr_init_ods : in  std_logic := '1';
		ddr_init_rtt : in  std_logic_vector(1 downto 0) := "01";
		ddr_init_bl  : in  std_logic_vector(0 to 2);
		ddr_init_cl  : in  std_logic_vector(0 to 2);
		ddr_init_wr  : in  std_logic_vector(0 to 2) := (others => '0');
		ddr_init_cwl : in  std_logic_vector(0 to 2) := (others => '0');
		ddr_init_pl  : in  std_logic_vector(0 to 2) := (others => '0');
		ddr_init_dqsn : in std_logic := '0';

		ddr_init_clk : in  std_logic;
		ddr_init_req : in  std_logic;
		ddr_init_rdy : out std_logic := '1';
		ddr_init_dll : out std_logic := '1';
		ddr_init_ras : out std_logic := '1';
		ddr_init_cas : out std_logic := '1';
		ddr_init_we  : out std_logic := '1';
		ddr_init_a   : out std_logic_vector(a-1 downto 0) := (others => '1');
		ddr_init_b   : out std_logic_vector(ba-1 downto 0) := (others => '1'));

	constant ras : natural := 0;
	constant cas : natural := 1;
	constant rw  : natural := 2;

	constant cmd_nop  : std_logic_vector(0 to 2) := "111";
	constant cmd_auto : std_logic_vector(0 to 2) := "001";
	constant cmd_pre  : std_logic_vector(0 to 2) := "010";
	constant cmd_lmr  : std_logic_vector(0 to 2) := "000";
	constant cmd_zqcl : std_logic_vector(0 to 2) := "110";

	type ddr_code is record
		ddr_cmd : std_logic_vector(0 to 2);
		ddr_lat : signed(0 to lat_length-1);
	end record;
	attribute fsm_encoding : string;
	attribute fsm_encoding of ddr_init : entity is "compact";
end;

architecture ddr1 of ddr_init is
	type ddr_labels is (s_pall1, s_lmr1, s_lmr2, s_pall2, s_auto1, s_auto2, s_lmr3, s_end);

	type ddr_init_insr is record
		lbl  : ddr_labels;
		code : ddr_code;
	end record;

	type ddr_state_tab is array (ddr_labels) of ddr_init_insr;
	constant ddr_init_pgm : ddr_state_tab := (
		s_pall1 => (s_lmr1,  (cmd_pre,  to_signed ( trp-2, lat_length))),
		s_lmr1  => (s_lmr2,  (cmd_lmr,  to_signed (tmrd-2, lat_length))),
		s_lmr2  => (s_pall2, (cmd_lmr,  to_signed (tmrd-2, lat_length))),
		s_pall2 => (s_auto1, (cmd_pre,  to_signed ( trp-2, lat_length))),
		s_auto1 => (s_auto2, (cmd_auto, to_signed (trfc-2, lat_length))),
		s_auto2 => (s_lmr3,  (cmd_auto, to_signed (trfc-2, lat_length))),
		s_lmr3  => (s_end,   (cmd_lmr,  to_signed (tmrd-2, lat_length))),
		s_end   => (s_end,   (cmd_nop,  (1 to lat_length => '1'))));

	signal lat_timer  : signed(0 to lat_length-1);
	signal ddr_init_pc : ddr_labels;
begin

	process (ddr_init_clk)
	begin
		if rising_edge(ddr_init_clk) then
			if ddr_init_req='1' then
				if lat_timer(0)='1' then
					lat_timer    <= ddr_init_pgm(ddr_init_pc).code.ddr_lat;
					ddr_init_ras <= ddr_init_pgm(ddr_init_pc).code.ddr_cmd(ras);
					ddr_init_cas <= ddr_init_pgm(ddr_init_pc).code.ddr_cmd(cas);
					ddr_init_we  <= ddr_init_pgm(ddr_init_pc).code.ddr_cmd(rw);

					ddr_init_a <= (others => '0');
					case ddr_init_pc is
					when s_lmr1 =>
						ddr_init_a(1 downto 0) <= ddr_init_ods & '0';
					when s_lmr2 =>
						ddr_init_a(9-1 downto 0) <= "10" & ddr_init_cl & "0" & ddr_init_bl;
					when s_lmr3 =>
						ddr_init_a(9-1 downto 0) <= "00" & ddr_init_cl & "0" & ddr_init_bl;
					when s_pall1|s_pall2 =>
						ddr_init_a(10) <= '1';
					when s_end =>
						ddr_init_a <= (others => '1');
					when others =>
						ddr_init_a <= (others => '0');
					end case;

					case ddr_init_pc is
					when s_lmr1 =>
						ddr_init_b <= "01";
					when s_end =>
						ddr_init_b <= "11";
					when others =>
						ddr_init_b <= "00";
					end case;

					ddr_init_pc <= ddr_init_pgm(ddr_init_pc).lbl;
					case ddr_init_pc is
					when s_end =>
						ddr_init_rdy <= '1';
					when others =>
						ddr_init_rdy <= '0';
					end case;

					if ddr_labels'pos(ddr_init_pc) > ddr_labels'pos(s_pall2) then
						ddr_init_dll <= '1';
					else
						ddr_init_dll <= '0';
					end if;
				else
					lat_timer    <= lat_timer - 1;
					ddr_init_ras <= '1';
					ddr_init_cas <= '1';
					ddr_init_we  <= '1';
					ddr_init_b   <= (others => '1');
					ddr_init_a   <= (others => '1');
					ddr_init_rdy <= '0';
				end if;
			else
				ddr_init_pc  <= s_pall1;
				lat_timer    <= (others => '1');
				ddr_init_ras <= '1';
				ddr_init_cas <= '1';
				ddr_init_we  <= '1';
				ddr_init_b   <= (others => '1');
				ddr_init_a   <= (others => '1');
				ddr_init_rdy <= '0';
				ddr_init_dll <= '0';
			end if;
		end if;
	end process;
end;

architecture ddr2 of ddr_init is

	type ddr_labels is (
		lb_pall1, lb_lemr2, lb_lemr3,
		lb_edll,  lb_rdll,  lb_pall2,
		lb_auto1, lb_auto2, lb_lmr,
		lb_docd,  lb_xocd,  lb_end); 

	type ddr_init_insr is record
		lbl  : ddr_labels;
		code : ddr_code;
	end record;

	type ddr_state_code is array (ddr_labels) of ddr_init_insr;

	constant ddr_init_pgm : ddr_state_code := (
		(lb_lemr2, (cmd_pre,  to_signed ( trp-2, lat_length))),
		(lb_lemr3, (cmd_lmr,  to_signed (tmrd-2, lat_length))),
		(lb_edll,  (cmd_lmr,  to_signed (tmrd-2, lat_length))),
		(lb_rdll,  (cmd_lmr,  to_signed (tmrd-2, lat_length))),
		(lb_pall2, (cmd_lmr,  to_signed (tmrd-2, lat_length))),
		(lb_auto1, (cmd_pre,  to_signed ( trp-2, lat_length))),
		(lb_auto2, (cmd_auto, to_signed (trfc-2, lat_length))),
		(lb_lmr,   (cmd_auto, to_signed (trfc-2, lat_length))),
		(lb_docd,  (cmd_lmr,  to_signed (tmrd-2, lat_length))),
		(lb_xocd,  (cmd_lmr,  to_signed (tmrd-2, lat_length))),
		(lb_end,   (cmd_lmr,  to_signed (tmrd-2, lat_length))),
		(lb_end,   (cmd_nop,  (0 to lat_length-1 => '1'))));

	signal lat_timer : signed(0 to lat_length-1);
	signal ddr_init_pc : ddr_labels;

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
	process (ddr_init_clk)
	begin
		if rising_edge(ddr_init_clk) then
			if ddr_init_req='1' then
				if lat_timer(0)='1' then
					lat_timer    <= ddr_init_pgm(ddr_init_pc).code.ddr_lat;
					ddr_init_ras <= ddr_init_pgm(ddr_init_pc).code.ddr_cmd(ras);
					ddr_init_cas <= ddr_init_pgm(ddr_init_pc).code.ddr_cmd(cas);
					ddr_init_we  <= ddr_init_pgm(ddr_init_pc).code.ddr_cmd(rw);

					ddr_init_a <= (others => '0');
					case ddr_init_pc is
					when lb_pall1 =>
						ddr_init_a(10) <= '1';
					when lb_lemr2|lb_lemr3 =>
						ddr_init_a <= (others => '0');
					when lb_edll =>
						ddr_init_a(emr_dll) <= '0';
					when lb_rdll =>
						ddr_init_a(mr_dll) <= '1'; 
					when lb_pall2 =>
						ddr_init_a(10) <= '1';
					when lb_auto1|lb_auto2 =>
						ddr_init_a(10) <= '1';
					when lb_lmr =>
						ddr_init_a(mr_bl) <= ddr_init_bl; 
						ddr_init_a(mr_bt) <= '0'; 
						ddr_init_a(mr_cl) <= ddr_init_cl;
						ddr_init_a(mr_tm) <= '0'; 
						ddr_init_a(mr_dll) <= '0'; 
						ddr_init_a(mr_wr) <= ddr_init_wr; 
						ddr_init_a(mr_pd) <= '0'; 
					when lb_docd =>
						ddr_init_a(emr_dll) <= '0';
						ddr_init_a(emr_ods) <= ddr_init_ods;
						ddr_init_a(emr_rt0) <= ddr_init_rtt(0);
						ddr_init_a(emr_rt1) <= ddr_init_rtt(1);
						ddr_init_a(emr_ocd) <= (others => '1');
						ddr_init_a(emr_pl)  <= ddr_init_pl;
						ddr_init_a(emr_dqs) <= ddr_init_dqsn;
						ddr_init_a(emr_rdqs) <= '0';
						ddr_init_a(emr_out) <= '0';
					when lb_xocd =>
						ddr_init_a(emr_dll) <= '0';
						ddr_init_a(emr_ods) <= ddr_init_ods;
						ddr_init_a(emr_rt0) <= ddr_init_rtt(0);
						ddr_init_a(emr_rt1) <= ddr_init_rtt(1);
						ddr_init_a(emr_ocd) <= (others => '0');
						ddr_init_a(emr_pl)  <= ddr_init_pl;
						ddr_init_a(emr_dqs) <= ddr_init_dqsn;
						ddr_init_a(emr_rdqs) <= '0';
						ddr_init_a(emr_out) <= '0';

					when lb_end =>
						ddr_init_a <= (others => '1');
					when others =>
						ddr_init_a <= (others => '0');
					end case;

					ddr_init_b <= (others => '0');
					case ddr_init_pc is
					when lb_lemr2 =>
						ddr_init_b <= "10";
					when lb_lemr3 =>
						ddr_init_b <= "11";
					when lb_edll =>
						ddr_init_b <= "01";
					when lb_rdll =>
						ddr_init_b <= "00";
					when lb_lmr =>
						ddr_init_b <= "00";
					when lb_docd|lb_xocd =>
						ddr_init_b <= "01";
					when lb_end =>
						ddr_init_b <= "11";
					when others =>
						ddr_init_b <= "00";
					end case;

					ddr_init_pc <= ddr_init_pgm(ddr_init_pc).lbl;
					if ddr_init_pc=lb_end then
						ddr_init_rdy <= '1';
					else
						ddr_init_rdy <= '0';
					end if;

					if ddr_labels'pos(ddr_init_pc) > ddr_labels'pos(lb_pall2) then
						ddr_init_dll <= '1';
					else
						ddr_init_dll <= '0';
					end if;
				else
					lat_timer    <= lat_timer - 1;
					ddr_init_ras <= '1';
					ddr_init_cas <= '1';
					ddr_init_we  <= '1';
					ddr_init_b   <= (others => '1');
					ddr_init_a   <= (others => '1');
					ddr_init_rdy <= '0';
				end if;
			else
				ddr_init_pc  <= lb_pall1;
				lat_timer    <= (others => '1');
				ddr_init_ras <= '1';
				ddr_init_cas <= '1';
				ddr_init_we  <= '1';
				ddr_init_b   <= (others => '1');
				ddr_init_a   <= (others => '1');
				ddr_init_rdy <= '0';
				ddr_init_dll <= '0';
			end if;
		end if;
	end process;
end;

architecture ddr3 of ddr_init is

	type ddr_labels is (
		lb_lmr2, lb_lmr3, lb_lmr1, lb_lmr0,
		lb_zqcl, lb_end); 

	type ddr_init_insr is record
		lbl  : ddr_labels;
		code : ddr_code;
	end record;

	type ddr_state_code is array (ddr_labels) of ddr_init_insr;

	signal lat_timer : signed(0 to lat_length-1);
	signal ddr_init_pc : ddr_labels;

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

	constant ddr_init_pgm : ddr_state_code := (
		(lb_lmr3, (cmd_lmr, to_signed (tmrd-2, lat_length))),
		(lb_lmr1, (cmd_lmr, to_signed (tmrd-2, lat_length))),
		(lb_lmr0, (cmd_lmr, to_signed (tmrd-2, lat_length))),
		(lb_zqcl, (cmd_lmr, to_signed (tmod-2, lat_length))),
		(lb_end, (cmd_zqcl, to_signed (tmrd-2, lat_length))),
		(lb_end,  (cmd_nop, (1 to lat_length => '1'))));

begin
	process (ddr_init_clk)
	begin
		if rising_edge(ddr_init_clk) then
			if ddr_init_req='1' then
				if lat_timer(0)='1' then
					lat_timer    <= ddr_init_pgm(ddr_init_pc).code.ddr_lat;
					ddr_init_ras <= ddr_init_pgm(ddr_init_pc).code.ddr_cmd(ras);
					ddr_init_cas <= ddr_init_pgm(ddr_init_pc).code.ddr_cmd(cas);
					ddr_init_we  <= ddr_init_pgm(ddr_init_pc).code.ddr_cmd(rw);

					ddr_init_a <= (others => '0');
					case ddr_init_pc is
					when lb_lmr3 =>
						ddr_init_a <= (others => '0');
					when lb_lmr2 =>
						ddr_init_a(mr2_cwl) <= ddr_init_cwl;
					when lb_lmr1 =>
						ddr_init_a(mr1_dll) <= '0';
					when lb_lmr0 =>
						ddr_init_a(mr0_bl) <= ddr_init_bl; 
						ddr_init_a(mr0_bt) <= '0'; 
						ddr_init_a(mr0_cl) <= ddr_init_cl;
						ddr_init_a(mr0_tm) <= '0'; 
						ddr_init_a(mr0_dll) <= '1'; 
						ddr_init_a(mr0_wr) <= ddr_init_wr; 
						ddr_init_a(mr0_pd) <= '0'; 
					when lb_zqcl =>
						ddr_init_a(10) <= '1';
					when lb_end =>
						ddr_init_a <= (others => '1');
					when others =>
						ddr_init_a <= (others => '0');
					end case;

					ddr_init_b <= (others => '0');
					case ddr_init_pc is
					when lb_lmr2 =>
						ddr_init_b <= "010";
					when lb_lmr3 =>
						ddr_init_b <= "011";
					when lb_lmr1 =>
						ddr_init_b <= "001";
					when lb_lmr0 =>
						ddr_init_b <= "000";
					when lb_zqcl =>
						ddr_init_b <= "---";
					when lb_end =>
						ddr_init_b <= "111";
					end case;

					ddr_init_pc <= ddr_init_pgm(ddr_init_pc).lbl;
					if ddr_init_pc=lb_end then
						ddr_init_rdy <= '1';
					else
						ddr_init_rdy <= '0';
					end if;

					if ddr_labels'pos(ddr_init_pc) > ddr_labels'pos(lb_lmr0) then
						ddr_init_dll <= '1';
					else
						ddr_init_dll <= '0';
					end if;
				else
					lat_timer    <= lat_timer - 1;
					ddr_init_ras <= '1';
					ddr_init_cas <= '1';
					ddr_init_we  <= '1';
					ddr_init_b   <= (others => '1');
					ddr_init_a   <= (others => '1');
					ddr_init_rdy <= '0';
				end if;
			else
				ddr_init_pc  <= lb_lmr2;
				lat_timer    <= (others => '1');
				ddr_init_ras <= '1';
				ddr_init_cas <= '1';
				ddr_init_we  <= '1';
				ddr_init_b   <= (others => '1');
				ddr_init_a   <= (others => '1');
				ddr_init_rdy <= '0';
				ddr_init_dll <= '0';
			end if;
		end if;
	end process;
end;