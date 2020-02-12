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
		registered : boolean := true;
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

	constant ddr_nop   : std_logic_vector(0 to 2) := "111";
	constant ddr_act   : std_logic_vector(0 to 2) := "011";
	constant ddr_read  : std_logic_vector(0 to 2) := "101";
	constant ddr_write : std_logic_vector(0 to 2) := "100";
	constant ddr_pre   : std_logic_vector(0 to 2) := "010";
	constant ddr_aut   : std_logic_vector(0 to 2) := "001";
	constant ddr_dcare : std_logic_vector(0 to 2) := "000";

	constant cacc : natural := 6;
	constant refy : natural := 5;
	constant refq : natural := 4;
	constant rdy  : natural := 3;
	constant ras  : natural := 2;
	constant cas  : natural := 1;
	constant we   : natural := 0;

	                      --> ddr_pgm_trdy  <---------------------+
	                      --> ctlr_refreq   <--------------------+|
	                      --> pgm_refy      <-------------------+||
	                      --> pgm_cas       <------------------+|||
	                      --                                   ||||
	                      --                                   ||||
	                      --                                   ||||
	                      --                                   VVVV
	constant ddro_act  : std_logic_vector(6 downto 0)     := B"0000" & "011";
	constant ddro_acty : std_logic_vector(ddro_act'range) := B"0100" & "011";
	constant ddro_rea  : std_logic_vector(ddro_act'range) := B"1000" & "101";
	constant ddro_reaq : std_logic_vector(ddro_act'range) := B"1010" & "101";
	constant ddro_wri  : std_logic_vector(ddro_act'range) := B"1000" & "100";
	constant ddro_wriq : std_logic_vector(ddro_act'range) := B"1010" & "100";
	constant ddro_pre  : std_logic_vector(ddro_act'range) := B"0000" & "010";
	constant ddro_preq : std_logic_vector(ddro_act'range) := B"0010" & "010";
	constant ddro_autq : std_logic_vector(ddro_act'range) := B"0010" & "001";
	constant ddro_auty : std_logic_vector(ddro_act'range) := B"0111" & "001";
	constant ddro_nop  : std_logic_vector(ddro_act'range) := B"0001" & "111";
	constant ddro_nopy : std_logic_vector(ddro_act'range) := B"0101" & "111";

	type ddrs_states is (ddrs_act, ddrs_rea, ddrs_wri, ddrs_pre, ddrs_aut);

	type trans_row is record
		state   : ddrs_states;
		input   : std_logic_vector(0 to 2);
		state_n : ddrs_states;
		cmd_n   : std_logic_vector(ddro_act'range);
	end record;

	type trans_tab is array (natural range <>) of trans_row;

--           +------ pgm_irdy 
--           |+----- pgm_rw   
--           ||+---- pgm_ref
--           |||
--           vvv
--           000    001    010    011    100    101    110    111
--         +------+------+------+------+------+------+------+------+
--     act | wri  | wriq | rea  | reaq | wri  | wriq | rea  | reaq |
--     rea | pre  | pre  | pre  | pre  | wri  | wri  | rea  | rea  |
--     wri | pre  | pre  | pre  | pre  | wri  | wri  | rea  | rea  |
--     pre | pre  | aut  | pre  | aut  | act  | aut  | act  | aut  |
--     aut | idl  | idl  | idl  | idl  | act  | aut  | act  | aut  |
--         +------+------+------+------+------+------+------+------+

--                       --                 --
--                       -- OUTPUT COMMANDS --
--                       --                 --

--
--           000    001    010    011    100    101    110    111
--         +------+------+------+------+------+------+------+------+
--     act | wri  | wriq | rea  | reaq | wri  | wriq | rea  | reaq |
--     rea | pre  | preq | pre  | preq | wri  | wriq | rea  | reaq |
--     wri | pre  | preq | pre  | preq | wri  | wriq | rea  | reaq |
--     pre | nop  | autq | nop  | autq | act  | autq | act  | autq |
--     aut | nopy | auty | nopy | auty | acty | auty | acty | auty |
--         +------+------+------+------+------+------+------+------+

--	                +----- ddr_pgm_irdy
--	                |+---- ddr_pgm_rw   
--	                ||+--- ddr_pgm_ref  
--                  |||
--                  vvv
	constant pgm_tab : trans_tab := (
		(ddrs_act, "000", ddrs_wri, ddro_wri),	---------
		(ddrs_act, "001", ddrs_wri, ddro_wriq),	-- ACT --
		(ddrs_act, "010", ddrs_rea, ddro_rea),	---------
		(ddrs_act, "011", ddrs_rea, ddro_reaq),
		(ddrs_act, "100", ddrs_wri, ddro_wri),
		(ddrs_act, "101", ddrs_wri, ddro_wriq),
		(ddrs_act, "110", ddrs_rea, ddro_rea),
		(ddrs_act, "111", ddrs_rea, ddro_reaq),
		
		(ddrs_rea, "000", ddrs_pre, ddro_pre),	---------
		(ddrs_rea, "001", ddrs_pre, ddro_preq),	-- REA --
		(ddrs_rea, "010", ddrs_pre, ddro_pre),	---------
		(ddrs_rea, "011", ddrs_pre, ddro_preq),
		(ddrs_rea, "100", ddrs_wri, ddro_wri),
		(ddrs_rea, "101", ddrs_wri, ddro_wriq),
		(ddrs_rea, "110", ddrs_rea, ddro_rea),
		(ddrs_rea, "111", ddrs_rea, ddro_reaq),

		(ddrs_wri, "000", ddrs_pre, ddro_pre),	---------
		(ddrs_wri, "001", ddrs_pre, ddro_preq),	-- WRI --
		(ddrs_wri, "010", ddrs_pre, ddro_pre),	---------
		(ddrs_wri, "011", ddrs_pre, ddro_preq),
		(ddrs_wri, "100", ddrs_wri, ddro_wri),
		(ddrs_wri, "101", ddrs_wri, ddro_wriq),
		(ddrs_wri, "110", ddrs_rea, ddro_rea),
		(ddrs_wri, "111", ddrs_rea, ddro_reaq),

		(ddrs_pre, "000", ddrs_pre, ddro_nop),	---------
		(ddrs_pre, "001", ddrs_aut, ddro_autq),	-- PRE --
		(ddrs_pre, "010", ddrs_pre, ddro_nop),	---------
		(ddrs_pre, "011", ddrs_aut, ddro_autq),
		(ddrs_pre, "100", ddrs_act, ddro_act),
		(ddrs_pre, "101", ddrs_aut, ddro_autq),
		(ddrs_pre, "110", ddrs_act, ddro_act),
		(ddrs_pre, "111", ddrs_aut, ddro_autq),

		(ddrs_aut, "000", ddrs_pre, ddro_nopy),	---------
		(ddrs_aut, "001", ddrs_pre, ddro_auty),	-- AUT --
		(ddrs_aut, "010", ddrs_pre, ddro_nopy),	---------
		(ddrs_aut, "011", ddrs_pre, ddro_auty),
		(ddrs_aut, "100", ddrs_act, ddro_acty),
		(ddrs_aut, "101", ddrs_aut, ddro_auty),
		(ddrs_aut, "110", ddrs_act, ddro_acty),
		(ddrs_aut, "111", ddrs_aut, ddro_auty));

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture registered of ddr_pgm is

	signal ddr_input  : std_logic_vector(0 to 2);

	signal ddr_pgm_pc : ddrs_states;
	signal pgm_pc     : ddrs_states;
	signal pc         : ddrs_states;

	signal pgm_cmd  : std_logic_vector(ddr_pgm_cmd'range);
	signal pgm_rdy  : std_logic;
	signal pgm_refq : std_logic;
	signal pgm_refy : std_logic;
	signal pgm_cas  : std_logic;


	signal calibrating : std_logic;

--	attribute fsm_encoding : string;
--	attribute fsm_encoding of ddr_pgm_pc : signal is "compact";

begin

	ddr_input(2) <= ddr_pgm_ref;
	ddr_input(1) <= ddr_pgm_rw;
	ddr_input(0) <= ddr_pgm_irdy;

	pc <= pgm_pc when registered and ddr_mpu_trdy='1' else ddr_pgm_pc;
	process (ctlr_clk)
	begin
		if rising_edge(ctlr_clk) then
			if ctlr_rst='1' then
				ddr_pgm_pc <= ddrs_pre;
			else
				for i in pgm_tab'range loop
					if pc=pgm_tab(i).state then
						if ddr_input=pgm_tab(i).input then
							if ddr_mpu_trdy='1' then
								ddr_pgm_pc <= pgm_tab(i).state_n; 
							end if;
						end if;
					end if;
				end loop;
			end if;
			pgm_pc <= ddr_pgm_pc;
		end if;
	end process;

	ddr_pgm_cas  <= pgm_cas and ddr_mpu_trdy;
	process (ddr_input, pc)
	begin
		pgm_cmd  <= (others => '-');
		pgm_rdy  <= '-'; 
		pgm_cas  <= '-';
		pgm_refq <= '-';
		pgm_refy <= '-'; 
		for i in pgm_tab'range loop
			if pc=pgm_tab(i).state then
				if registered and ddr_mpu_trdy='1' then
					for j in pgm_tab'range loop
						if pgm_tab(i).state_n=pgm_tab(j).state then
							if ddr_input=pgm_tab(j).input then
								pgm_cmd  <= pgm_tab(j).cmd_n(ras downto we);
								pgm_rdy  <= pgm_tab(j).cmd_n(rdy);
								pgm_cas  <= pgm_tab(j).cmd_n(cacc);
								pgm_refq <= pgm_tab(j).cmd_n(refq);
								pgm_refy <= pgm_tab(j).cmd_n(refy);
							end if;
						end if;
					end loop;
				else
					if ddr_input=pgm_tab(i).input then
						pgm_cmd  <= pgm_tab(i).cmd_n(ras downto we);
						pgm_rdy  <= pgm_tab(i).cmd_n(rdy);
						pgm_cas  <= pgm_tab(i).cmd_n(cacc);
						pgm_refq <= pgm_tab(i).cmd_n(refq);
						pgm_refy <= pgm_tab(i).cmd_n(refy);
					end if;
				end if;
			end if;
		end loop;
	end process;

	process (ctlr_rst, pgm_cmd, ctlr_clk)
	begin
		if registered then
			if rising_edge(ctlr_clk) then
				ddr_pgm_cmd <= setif(ctlr_rst='0', pgm_cmd,  ddr_nop); 
			end if;
		else
			ddr_pgm_cmd <= setif(ctlr_rst='0', pgm_cmd,  ddr_nop); 
		end if;
	end process;

	ddr_pgm_trdy <= setif(ctlr_rst='0', pgm_rdy,  '1');
	ctlr_refreq  <= setif(ctlr_rst='0', pgm_refq, '0');
	ddr_pgm_rrdy <= setif(ctlr_rst='0', pgm_refy, '0');

end;
