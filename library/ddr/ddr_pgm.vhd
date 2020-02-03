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

entity ddr_pgm is
	generic (
		CMMD_GEAR : natural := 1);
	port (
		ctlr_clk      : in  std_logic := '0';
		ctlr_rst      : in  std_logic := '0';
		ctlr_refreq   : out std_logic := '0';
		ddr_pgm_ref   : in  std_logic := '0';
		ddr_pgm_cal   : in  std_logic := '0';
		ddr_pgm_rrdy  : out std_logic := '0';
		ddr_pgm_irdy  : in  std_logic := '1';
		ddr_pgm_trdy  : out std_logic;
		ddr_mpu_trdy  : in  std_logic := '1';
		ddr_pgm_rw    : in  std_logic := '1';
		ddr_pgm_cas   : out std_logic := '0';
		ddr_pgm_seq   : out std_logic := '0';
		ddr_pgm_cmd   : out std_logic_vector(0 to 2));

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture registered of ddr_pgm is

	constant cacc : natural := 6;
	constant rrdy : natural := 5;
	constant ref  : natural := 4;
	constant rdy  : natural := 3;
	constant ras  : natural := 2;
	constant cas  : natural := 1;
	constant we   : natural := 0;

                        --> ddr_pgm_trdy  <---------------------+
                        --> ctlr_refreq   <--------------------+|
                        --                                     ||
                        --                                     VV
	constant ddr_act  : std_logic_vector(6 downto 0)    := B"0000" & "011";
	constant ddr_acty : std_logic_vector(ddr_act'range) := B"0100" & "011";
	constant ddr_rea  : std_logic_vector(ddr_act'range) := B"1000" & "101";
	constant ddr_reaq : std_logic_vector(ddr_act'range) := B"1010" & "101";
	constant ddr_wri  : std_logic_vector(ddr_act'range) := B"1000" & "100";
	constant ddr_wriq : std_logic_vector(ddr_act'range) := B"1010" & "100";
	constant ddr_pre  : std_logic_vector(ddr_act'range) := B"0000" & "010";
	constant ddr_preq : std_logic_vector(ddr_act'range) := B"0010" & "010";
	constant ddr_aut  : std_logic_vector(ddr_act'range) := B"0000" & "001";
	constant ddr_autq : std_logic_vector(ddr_act'range) := B"0010" & "001";
	constant ddr_auty : std_logic_vector(ddr_act'range) := B"0111" & "001";
	constant ddr_nop  : std_logic_vector(ddr_act'range) := B"0001" & "111";
	constant ddr_nopy : std_logic_vector(ddr_act'range) := B"0101" & "111";
	constant ddr_dnt  : std_logic_vector(ddr_act'range) := (others => '-');

	constant ddrs_act  : std_logic_vector(0 to 2) := "011";
	constant ddrs_rea  : std_logic_vector(0 to 2) := "101";
	constant ddrs_wri  : std_logic_vector(0 to 2) := "100";
	constant ddrs_pre  : std_logic_vector(0 to 2) := "010";
	constant ddrs_aut  : std_logic_vector(0 to 2) := "001";
	constant ddrs_pact : std_logic_vector(0 to 2) := "110";
	constant ddrs_paut : std_logic_vector(0 to 2) := "111";
	constant ddrs_idl  : std_logic_vector(0 to 2) := "000";
	constant ddrs_dnt  : std_logic_vector(0 to 2) := (others => '-');

	type state_names is (s_act, s_rea, s_wri, s_pre, s_aut, s_pact, s_paut, s_idl, s_dnt, s_none);
	signal mpu_name : state_names;
	signal mpu_pc : state_names;

	type trans_row is record
		state   : std_logic_vector(0 to 2);
		input   : std_logic_vector(0 to 2);
		state_n : std_logic_vector(0 to 2);
		cmd_n   : std_logic_vector(ddr_act'range);
	end record;

	type trans_tab is array (natural range <>) of trans_row;

	signal ddr_input  : std_logic_vector(0 to 2);

	signal ddr_pgm_pc : std_logic_vector(ddrs_act'range);

	signal pgm_cmd  : std_logic_vector(ddr_pgm_cmd'range);
	signal pgm_rdy  : std_logic;
	signal pgm_rrdy : std_logic;
	signal pgm_cas  : std_logic;
	signal sys_ref  : std_logic;


-- pgm_ref   ------+
-- pgm_rw    -----+|
-- pgm_irdy  ----+||
--               |||
--               vvv
--               000    001    010    011    100    101    110    111
--             +------+------+------+------+------+------+------+------+
--     act     | wri  | wriq | rea  | reaq | wri  | wriq | rea  | reaq |
--     pact    | wri  | wriq | rea  | reaq | wri  | wriq | rea  | reaq |
--     rea     | pre  | pre  | pre  | pre  | wri  | wri  | rea  | rea  |
--     wri     | pre  | pre  | pre  | pre  | wri  | wri  | rea  | rea  |
--     pre     | pre  | aut  | pre  | aut  | pact | aut  | pact | aut  |
--     idl     | idl  | paut | idl  | paut | pact | paut | pact | paut |
--     paut    | idl  | idl  | idl  | idl  | act  | aut  | act  | aut  |
--     aut     | idl  | idl  | idl  | idl  | act  | aut  | act  | aut  |
--             +------+------+------+------+------+------+------+------+

--                           --                 --
--                           -- OUTPUT COMMANDS --
--                           --                 --

--
--               000    001    010    011    100    101    110    111
--             +------+------+------+------+------+------+------+------+
--     act     | wri  | wriq | rea  | reaq | wri  | wriq | rea  | reaq |
--     pact    | nop  | autq | nop  | autq | act  | autq | act  | autq |
--     rea     | pre  | preq | pre  | preq | wri  | wriq | rea  | reaq |
--     wri     | pre  | preq | pre  | preq | wri  | wriq | rea  | reaq |
--     pre     | nop  | autq | nop  | autq | act  | autq | act  | autq |
--     idl     | nop  | autq | nop  | autq | act  | autq | act  | autq |
--     paut    | nopy | auty | nopy | auty | acty | auty | acty | auty |
--     aut     | nopy | auty | nopy | auty | acty | auty | acty | auty |
--             +------+------+------+------+------+------+------+------+

--	ddr_pgm_ref  -----+
--	ddr_pgm_rw   ----+|
--	ddr_pgm_irdy ---+||
--                  |||
--                  vvv
	constant pgm_tab : trans_tab(0 to 64-1) := (
		(ddrs_act, "000", ddrs_wri, ddr_wri),	---------
		(ddrs_act, "001", ddrs_wri, ddr_wriq),	-- ACT --
		(ddrs_act, "010", ddrs_rea, ddr_rea),	---------
		(ddrs_act, "011", ddrs_rea, ddr_reaq),
		(ddrs_act, "100", ddrs_wri, ddr_wri),
		(ddrs_act, "101", ddrs_wri, ddr_wriq),
		(ddrs_act, "110", ddrs_rea, ddr_rea),
		(ddrs_act, "111", ddrs_rea, ddr_reaq),
		
		(ddrs_pact, "000", ddrs_wri, ddr_wri),	---------
		(ddrs_pact, "001", ddrs_wri, ddr_wriq),	-- PACT --
		(ddrs_pact, "010", ddrs_rea, ddr_rea),	---------
		(ddrs_pact, "011", ddrs_rea, ddr_reaq),
		(ddrs_pact, "100", ddrs_wri, ddr_wri),
		(ddrs_pact, "101", ddrs_wri, ddr_wriq),
		(ddrs_pact, "110", ddrs_rea, ddr_rea),
		(ddrs_pact, "111", ddrs_rea, ddr_reaq),
		
		(ddrs_rea, "000", ddrs_pre, ddr_pre),	---------
		(ddrs_rea, "001", ddrs_pre, ddr_preq),	-- REA --
		(ddrs_rea, "010", ddrs_pre, ddr_pre),	---------
		(ddrs_rea, "011", ddrs_pre, ddr_preq),
		(ddrs_rea, "100", ddrs_wri, ddr_wri),
		(ddrs_rea, "101", ddrs_wri, ddr_wriq),
		(ddrs_rea, "110", ddrs_rea, ddr_rea),
		(ddrs_rea, "111", ddrs_rea, ddr_reaq),

		(ddrs_wri, "000", ddrs_pre, ddr_pre),	---------
		(ddrs_wri, "001", ddrs_pre, ddr_preq),	-- WRI --
		(ddrs_wri, "010", ddrs_pre, ddr_pre),	---------
		(ddrs_wri, "011", ddrs_pre, ddr_preq),
		(ddrs_wri, "100", ddrs_wri, ddr_wri),
		(ddrs_wri, "101", ddrs_wri, ddr_wriq),
		(ddrs_wri, "110", ddrs_rea, ddr_rea),
		(ddrs_wri, "111", ddrs_rea, ddr_reaq),

		(ddrs_pre, "000", ddrs_idl, ddr_nop),	---------
		(ddrs_pre, "001", ddrs_aut, ddr_autq),	-- PRE --
		(ddrs_pre, "010", ddrs_idl, ddr_nop),	---------
		(ddrs_pre, "011", ddrs_aut, ddr_autq),
		(ddrs_pre, "100", ddrs_act, ddr_act),
		(ddrs_pre, "101", ddrs_aut, ddr_autq),
		(ddrs_pre, "110", ddrs_act, ddr_act),
		(ddrs_pre, "111", ddrs_aut, ddr_autq),

		(ddrs_idl, "000", ddrs_idl,  ddr_nop),	---------
		(ddrs_idl, "001", ddrs_paut, ddr_autq),	-- IDL --
		(ddrs_idl, "010", ddrs_idl,  ddr_nop),	---------
		(ddrs_idl, "011", ddrs_paut, ddr_autq),
		(ddrs_idl, "100", ddrs_pact, ddr_act),
		(ddrs_idl, "101", ddrs_paut, ddr_autq),
		(ddrs_idl, "110", ddrs_pact, ddr_act),
		(ddrs_idl, "111", ddrs_paut, ddr_autq),

		(ddrs_paut, "000", ddrs_idl, ddr_nopy),	---------
		(ddrs_paut, "001", ddrs_idl, ddr_auty),	-- PAUT --
		(ddrs_paut, "010", ddrs_idl, ddr_nopy),	---------
		(ddrs_paut, "011", ddrs_idl, ddr_auty),
		(ddrs_paut, "100", ddrs_act, ddr_acty),
		(ddrs_paut, "101", ddrs_aut, ddr_auty),
		(ddrs_paut, "110", ddrs_act, ddr_acty),
		(ddrs_paut, "111", ddrs_aut, ddr_auty),

		(ddrs_aut, "000", ddrs_idl, ddr_nopy),	---------
		(ddrs_aut, "001", ddrs_idl, ddr_auty),	-- AUT --
		(ddrs_aut, "010", ddrs_idl, ddr_nopy),	---------
		(ddrs_aut, "011", ddrs_idl, ddr_auty),
		(ddrs_aut, "100", ddrs_act, ddr_acty),
		(ddrs_aut, "101", ddrs_aut, ddr_auty),
		(ddrs_aut, "110", ddrs_act, ddr_acty),
		(ddrs_aut, "111", ddrs_aut, ddr_auty));

	signal ppp : std_logic;
	attribute fsm_encoding : string;
	attribute fsm_encoding of ddr_pgm_pc : signal is "compact";

	signal calibrating : std_logic;

	signal debug_pc : std_logic_vector(ddr_pgm_pc'range);
begin

	ddr_input(2) <= ddr_pgm_ref;
	ddr_input(1) <= ddr_pgm_rw;
	ddr_input(0) <= ddr_pgm_irdy;

	process (ctlr_clk)
		variable pc : std_logic_vector(ddr_pgm_pc'range);
		variable t  : signed(0 to unsigned_num_bits(CMMD_GEAR)-1);
	begin
		if rising_edge(ctlr_clk) then
			ddr_pgm_seq <= t(0);
			if ctlr_rst='0' then
				if ddr_mpu_trdy='1' then
					if calibrating='1' then
						if t(0)='0' then
							ddr_pgm_cmd <= pgm_cmd;
							t := t - 1;
						else
							ddr_pgm_cmd <= "111";
							t := to_signed(CMMD_GEAR-1, t'length);
						end if;
					end if;
					calibrating <= ddr_pgm_cal;
				end if;

				if calibrating='0' then
					ddr_pgm_cmd <= pgm_cmd;
				end if;

				if ddr_mpu_trdy='1' then
					ddr_pgm_pc <= pc; 
				end if;

				ddr_pgm_trdy <= pgm_rdy;
				ctlr_refreq  <= sys_ref;
				ddr_pgm_rrdy <= pgm_rrdy;
				for i in pgm_tab'range loop
					if ddr_pgm_pc=pgm_tab(i).state then
						if ddr_input=pgm_tab(i).input then
							pc := pgm_tab(i).state_n; 
						end if;
					end if;
				end loop;
				ppp <= pgm_cas;
			else
				ppp <= '0';
				ddr_pgm_pc <= ddrs_pre; 
				pc := ddrs_pre;
				ddr_pgm_cmd <= "111";
				ddr_pgm_trdy <= '1';
				ctlr_refreq <= '0';
				ddr_pgm_rrdy <= '0';
				t   := to_signed(CMMD_GEAR-1, t'length);
				cal <= '0';
			end if;
			debug_pc <= pc;
		end if;
	end process;

	ddr_pgm_cas  <= ppp and ddr_mpu_trdy;
	process (ddr_input, ddr_pgm_pc)
	begin
		pgm_rdy  <= '-'; 
		pgm_rrdy <= '-'; 
		sys_ref  <= '-';
		pgm_cmd  <= (others => '-');
		pgm_cas  <= '-';
		for i in pgm_tab'range loop
			if ddr_pgm_pc=pgm_tab(i).state then
				if ddr_input=pgm_tab(i).input then
					pgm_cmd  <= pgm_tab(i).cmd_n(ras downto we);
					pgm_rdy  <= pgm_tab(i).cmd_n(rdy);
					sys_ref  <= pgm_tab(i).cmd_n(ref);
					pgm_rrdy <= pgm_tab(i).cmd_n(rrdy);
					pgm_cas  <= pgm_tab(i).cmd_n(cacc);
				end if;
			end if;
		end loop;
	end process;

	debug1 : with debug_pc select
	mpu_pc <=
		s_act  when ddrs_act,
		s_rea  when ddrs_rea,
		s_wri  when ddrs_wri,
		s_pre  when ddrs_pre,
		s_aut  when ddrs_aut,
		s_dnt  when ddrs_dnt,
		s_pact when ddrs_pact,
		s_paut when ddrs_paut,
		s_idl  when ddrs_idl,
		s_none when others;

	debug : with ddr_pgm_pc select
	mpu_name <=
		s_act  when ddrs_act,
		s_rea  when ddrs_rea,
		s_wri  when ddrs_wri,
		s_pre  when ddrs_pre,
		s_aut  when ddrs_aut,
		s_dnt  when ddrs_dnt,
		s_pact when ddrs_pact,
		s_paut when ddrs_paut,
		s_idl  when ddrs_idl,
		s_none when others;

end;

