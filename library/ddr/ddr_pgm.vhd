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
		cmmd_gear    : natural := 1);
	port (
		ctlr_clk     : in  std_logic := '0';
		ctlr_rst     : in  std_logic := '0';
		ctlr_refreq  : out std_logic := '0';
		ddr_pgm_cal  : in  std_logic := '0';
		ddr_pgm_seq  : out std_logic := '0';
		ddr_pgm_frm  : in  std_logic := '1';
		ddr_pgm_rw   : in  std_logic := '1';
		ddr_mpu_trdy : in  std_logic := '1';
		ddr_ref_req  : in  std_logic := '0';
		ddr_ref_rdy  : buffer std_logic := '0';
		ddr_pgm_cmd  : out std_logic_vector(0 to 2));

	constant refy : natural := 4;
	constant refq : natural := 3;
	constant ras  : natural := 2;
	constant cas  : natural := 1;
	constant we   : natural := 0;

	                      --> ctlr_refreq   <--------------------+
	                      --> pgm_refy      <-------------------+|
	                      --                                    ||
	                      --                                    ||
	                      --                                    ||
	                      --                                    VV
	constant ddro_act   : std_logic_vector(4 downto 0)     := B"00" & "011";
	constant ddro_area  : std_logic_vector(ddro_act'range) := B"00" & "101";
	constant ddro_areaq : std_logic_vector(ddro_act'range) := B"01" & "101";
	constant ddro_awri  : std_logic_vector(ddro_act'range) := B"00" & "100";
	constant ddro_awriq : std_logic_vector(ddro_act'range) := B"01" & "100";
	constant ddro_rea   : std_logic_vector(ddro_act'range) := B"00" & "101";
	constant ddro_reaq  : std_logic_vector(ddro_act'range) := B"01" & "101";
	constant ddro_wri   : std_logic_vector(ddro_act'range) := B"00" & "100";
	constant ddro_wriq  : std_logic_vector(ddro_act'range) := B"01" & "100";
	constant ddro_pre   : std_logic_vector(ddro_act'range) := B"00" & "010";
	constant ddro_preq  : std_logic_vector(ddro_act'range) := B"01" & "010";
	constant ddro_aut   : std_logic_vector(ddro_act'range) := B"11" & "001";
	constant ddro_nop   : std_logic_vector(ddro_act'range) := B"00" & "111";

	type ddrs_states is (ddrs_act, ddrs_rea, ddrs_wri, ddrs_pre);

	type trans_row is record
		state   : ddrs_states;
		input   : std_logic_vector(0 to 2);
		state_n : ddrs_states;
		cmd_n   : std_logic_vector(ddro_act'range);
	end record;

	type trans_tab is array (natural range <>) of trans_row;

--           +------ pgm_frm
--           |+----- pgm_rw
--           ||+---- pgm_ref
--           |||
--           vvv
--           000    001    010    011    100    101    110    111
--         +------+------+------+------+------+------+------+------+
--     act | wri  | wri  | rea  | rea  | wri  | wri  | rea  | rea  |
--     rea | pre  | pre  | pre  | pre  | wri  | wri  | rea  | rea  |
--     wri | pre  | pre  | pre  | pre  | wri  | wri  | rea  | rea  |
--     pre | pre  | pre  | pre  | aut  | act  | aut  | act  | aut  |
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
--     pre | nop  | aut  | nop  | aut  | act  | aut  | act  | aut  |
--         +------+------+------+------+------+------+------+------+

--	                +----- ddr_pgm_frm
--	                |+---- ddr_pgm_rw
--	                ||+--- ddr_pgm_ref
--                  |||
	constant pgm_tab : trans_tab := (
--                  vvv
		(ddrs_act, "000", ddrs_wri, ddro_awri),	 ---------
		(ddrs_act, "001", ddrs_wri, ddro_awriq), -- ACT --
		(ddrs_act, "010", ddrs_rea, ddro_area),  ---------
		(ddrs_act, "011", ddrs_rea, ddro_areaq),
		(ddrs_act, "100", ddrs_wri, ddro_awri),
		(ddrs_act, "101", ddrs_wri, ddro_awriq),
		(ddrs_act, "110", ddrs_rea, ddro_area),
		(ddrs_act, "111", ddrs_rea, ddro_areaq),

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
		(ddrs_pre, "001", ddrs_pre, ddro_aut),	-- PRE --
		(ddrs_pre, "010", ddrs_pre, ddro_nop),	---------
		(ddrs_pre, "011", ddrs_pre, ddro_aut),
		(ddrs_pre, "100", ddrs_act, ddro_act),
		(ddrs_pre, "101", ddrs_pre, ddro_aut),
		(ddrs_pre, "110", ddrs_act, ddro_act),
		(ddrs_pre, "111", ddrs_pre, ddro_aut));

end;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ddr_param.all;

architecture registered of ddr_pgm is

	signal ddr_input  : std_logic_vector(0 to 2);

	signal ddr_pgm_pc : ddrs_states;

	signal pgm_cmd  : std_logic_vector(ddr_pgm_cmd'range);
	signal pgm_end  : std_logic;
	signal pgm_refq : std_logic;
	signal pgm_refy : std_logic;

	signal calibrating : std_logic;

begin

	ddr_input(0) <= ddr_pgm_frm;
	ddr_input(1) <= ddr_pgm_rw;
	ddr_input(2) <= ddr_ref_req xor ddr_ref_rdy;

	calibrate_p : process (ctlr_clk, ddr_mpu_trdy, ddr_pgm_cal)
		variable t : signed(0 to unsigned_num_bits(cmmd_gear-1));
	begin
		if rising_edge(ctlr_clk) then
			if ctlr_rst='1' then
				t := to_signed(cmmd_gear-1, t'length);
			elsif ddr_pgm_cal='0' then
				t := to_signed(cmmd_gear-1, t'length);
			elsif ddr_mpu_trdy='1' then
				if ddr_pgm_cal='1' then
					if cmmd_gear > 1 then
						if t(0)='0' then
							t := t - 1;
						else
							t := to_signed(cmmd_gear-1, t'length);
						end if;
					else
						t := not t;
					end if;
				end if;
			end if;
		end if;
		ddr_pgm_seq <= t(0);
		calibrating <= ddr_pgm_cal and ddr_mpu_trdy and t(0);
	end process;

	process (ctlr_clk)
	begin
		if rising_edge(ctlr_clk) then
			if ctlr_rst='1' then
				ddr_pgm_pc <= ddrs_pre;
			elsif ddr_mpu_trdy='1' then
				for i in pgm_tab'range loop
					if ddr_pgm_pc=pgm_tab(i).state then
						if ddr_input=pgm_tab(i).input then
							ddr_pgm_pc <= pgm_tab(i).state_n;
						end if;
					end if;
				end loop;
			end if;
		end if;
	end process;

	process (ddr_input, ddr_pgm_pc)
	begin
		pgm_cmd  <= (others => '-');
		pgm_end  <= '-';
		pgm_refq <= '-';
		pgm_refy <= '-';
		for i in pgm_tab'range loop
			if ddr_pgm_pc=pgm_tab(i).state then
				if ddr_input=pgm_tab(i).input then
					pgm_cmd  <= pgm_tab(i).cmd_n(ras downto we);
					pgm_refq <= pgm_tab(i).cmd_n(refq);
					pgm_refy <= pgm_tab(i).cmd_n(refy);
				end if;
			end if;
		end loop;
	end process;

	process (ctlr_clk)
	begin
		if rising_edge(ctlr_clk) then
			if ctlr_rst='1' then
				ctlr_refreq <= '0';
				ddr_ref_rdy <= '0';
				ddr_pgm_cmd <= mpu_nop;
			elsif ddr_mpu_trdy='1' then
				ctlr_refreq <= pgm_refq;
				ddr_ref_rdy <= ddr_ref_rdy xor pgm_refy;
				ddr_pgm_cmd <= setif(calibrating='0', pgm_cmd, mpu_nop);
			end if;
		end if;
	end process;

	debug_b : block
		type dram_labels is (dram_nop, dram_act, dram_read, dram_write, dram_pre, dram_aut, dram_none);
		signal dram_label : dram_labels;
		subtype xxx is bit_vector(pgm_cmd'range);
	begin
		debug_s : with xxx'(to_bitvector(pgm_cmd)) select
		dram_label <=
			dram_nop   when "111",
			dram_act   when "011",
			dram_read  when "101",
			dram_write when "100",
			dram_pre   when "010",
			dram_aut   when "001",
			dram_none  when others;
		assert dram_label/=dram_none
		report "wrong command"
		severity warning;

	end block;

end;
