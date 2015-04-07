library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

entity xdr_pgm is
	generic (
		registered : boolean := false);
	port (
		xdr_pgm_rst : in  std_logic := '0';
		xdr_pgm_clk : in  std_logic := '0';
		xdr_pgm_ref : in  std_logic := '0';
		xdr_pgm_rrdy : out  std_logic := '0';
		sys_pgm_ref : out std_logic := '0';
		xdr_pgm_start : in  std_logic := '1';
		xdr_pgm_rdy : out std_logic;
		xdr_pgm_req : in  std_logic := '1';
		xdr_pgm_rw  : in  std_logic := '1';
		xdr_pgm_cmd : out std_logic_vector(0 to 2));

--	attribute fsm_encoding : string;
--	attribute fsm_encoding of xdr_pgm : entity is "compact";

	constant rrdy : natural := 5;
	constant ref  : natural := 4;
	constant rdy  : natural := 3;
	constant ras  : natural := 2;
	constant cas  : natural := 1;
	constant we   : natural := 0;

                        --> xdr_pgm_rdy <---------------------+
                        --> sys_pgm_ref <--------------------+|
                        --                                   ||
                        --                                   VV
	constant xdr_act  : std_logic_vector(5 downto 0)    := "000" & "011";
	constant xdr_actq : std_logic_vector(5 downto 0)    := "010" & "011";
	constant xdr_acty : std_logic_vector(5 downto 0)    := "100" & "011";
	constant xdr_rea  : std_logic_vector(xdr_act'range) := "000" & "101";
	constant xdr_reaq : std_logic_vector(xdr_act'range) := "010" & "101";
	constant xdr_wri  : std_logic_vector(xdr_act'range) := "000" & "100";
	constant xdr_wriq : std_logic_vector(xdr_act'range) := "010" & "100";
	constant xdr_pre  : std_logic_vector(xdr_act'range) := "001" & "010";
	constant xdr_preq : std_logic_vector(xdr_act'range) := "011" & "010";
	constant xdr_prey : std_logic_vector(xdr_act'range) := "101" & "010";
	constant xdr_aut  : std_logic_vector(xdr_act'range) := "000" & "001";
	constant xdr_autq : std_logic_vector(xdr_act'range) := "010" & "001";
	constant xdr_nop  : std_logic_vector(xdr_act'range) := "001" & "111";
	constant xdr_dnt  : std_logic_vector(xdr_act'range) := (others => '-');

	constant ddrs_act : std_logic_vector(0 to 2) := "011";
	constant ddrs_rea : std_logic_vector(0 to 2) := "101";
	constant ddrs_wri : std_logic_vector(0 to 2) := "100";
	constant ddrs_pre : std_logic_vector(0 to 2) := "010";
	constant ddrs_idl : std_logic_vector(0 to 2) := "110";
	constant ddrs_il1 : std_logic_vector(0 to 2) := "111";
	constant ddrs_il2 : std_logic_vector(0 to 2) := "000";
	constant ddrs_aut : std_logic_vector(0 to 2) := "001";
	constant ddrs_dnt : std_logic_vector(0 to 2) := (others => '-');

	type trans_row is record
		state   : std_logic_vector(0 to 2);
		input   : std_logic_vector(0 to 2);
		state_n : std_logic_vector(0 to 2);
		cmd_n   : std_logic_vector(xdr_act'range);
	end record;

	type trans_tab is array (natural range <>) of trans_row;

	signal xdr_input  : std_logic_vector(0 to 2);

	signal xdr_pgm_pc : std_logic_vector(ddrs_act'range);

	signal pc : std_logic_vector(xdr_pgm_pc'range);
	signal pgm_cmd : std_logic_vector(xdr_pgm_cmd'range);
	signal pgm_rdy : std_logic;
	signal pgm_rrdy : std_logic;
	signal sys_ref : std_logic;

-- pgm_ref   ------+
-- pgm_rw    -----+|
-- pgm_start ----+||
--               |||
--               vvv
--               000   001   010   011   100   101   110   111
--             +-----+-----+-----+-----+-----+-----+-----+-----+
--     act     | wri | wri | rea | rea | wri | wri | rea | rea |
--     rea     | pre | pre | pre | pre | '-' | rea | rea | rea |
--     wri     | pre | pre | pre | pre | wri | pre | '-' | pre |
--     pre     | pre | aut | pre | aut | act | act | act | act |
--     idl     | idl | aut | idl | aut | il1 | aut | il1 | aut |
--     il1     | act | act | act | act | act | act | act | act |
--     il2     | aut | aut | aut | aut | aut | aut | aut | aut |
--     aut     | idl | idl | idl | idl | act | act | act | act |
--             +-----+-----+-----+-----+-----+-----+-----+-----+

--                           --                 --
--                           -- OUTPUT COMMANDS --
--                           --                 --

--
--               000    001    010    011    100   101    110   111
--             +------+------+------+------+------+------+------+------+
--     act     | wri  | wri  | rea  | rea  | wri  | wri  | rea  | rea  |
--     rea     | pre  | preq | pre  | preq | '-'  | preq | rea  | reaq |
--     wri     | pre  | preq | pre  | preq | wri  | preq | '-'  | preq |
--     pre     | nop  | aut  | nop  | autq | act  | act  | act  | act  |
--     idl     | nop  | aut  | nop  | aut  | act  | aut  | act  | aut  |
--     il1     | wri  | wriq | rea  | reaq | wri  | wriq | rea  | reaq |
--     il2     | pre  | preq | pre  | pref | act  | act  | act  | act  |
--     aut     | prey | prey | prey | prey | acty | acty | acty | acty |
--             +------+------+------+------+------+------+------+------+

	constant pgm_tab : trans_tab := (
		(ddrs_act, "000", ddrs_wri, xdr_wri),	---------
		(ddrs_act, "001", ddrs_wri, xdr_wri),	-- ACT --
		(ddrs_act, "010", ddrs_rea, xdr_rea),	---------
		(ddrs_act, "011", ddrs_rea, xdr_rea),
		(ddrs_act, "100", ddrs_wri, xdr_wri),
		(ddrs_act, "101", ddrs_wri, xdr_wri),
		(ddrs_act, "110", ddrs_rea, xdr_rea),
		(ddrs_act, "111", ddrs_rea, xdr_rea),
		
		(ddrs_rea, "000", ddrs_pre, xdr_pre),	---------
		(ddrs_rea, "001", ddrs_pre, xdr_preq),	-- REA --
		(ddrs_rea, "010", ddrs_pre, xdr_pre),	---------
		(ddrs_rea, "011", ddrs_pre, xdr_preq),
		(ddrs_rea, "100", ddrs_dnt, xdr_wri),
		(ddrs_rea, "101", ddrs_pre, xdr_preq),
		(ddrs_rea, "110", ddrs_rea, xdr_rea),
		(ddrs_rea, "111", ddrs_rea, xdr_reaq),

		(ddrs_wri, "000", ddrs_pre, xdr_pre),	---------
		(ddrs_wri, "001", ddrs_pre, xdr_preq),	-- WRI --
		(ddrs_wri, "010", ddrs_pre, xdr_pre),	---------
		(ddrs_wri, "011", ddrs_pre, xdr_preq),
		(ddrs_wri, "100", ddrs_wri, xdr_wri),
		(ddrs_wri, "101", ddrs_pre, xdr_preq),
		(ddrs_wri, "110", ddrs_dnt, xdr_dnt),
		(ddrs_wri, "111", ddrs_pre, xdr_preq),

		(ddrs_pre, "000", ddrs_pre, xdr_nop),	---------
		(ddrs_pre, "001", ddrs_aut, xdr_autq),	-- PRE --
		(ddrs_pre, "010", ddrs_pre, xdr_nop),	---------
		(ddrs_pre, "011", ddrs_aut, xdr_autq),
		(ddrs_pre, "100", ddrs_act, xdr_act),
		(ddrs_pre, "101", ddrs_act, xdr_act),
		(ddrs_pre, "110", ddrs_act, xdr_act),
		(ddrs_pre, "111", ddrs_act, xdr_act),

		(ddrs_idl, "000", ddrs_idl, xdr_nop),	---------
		(ddrs_idl, "001", ddrs_aut, xdr_aut),	-- IDL --
		(ddrs_idl, "010", ddrs_idl, xdr_nop),	---------
		(ddrs_idl, "011", ddrs_aut, xdr_aut),
		(ddrs_idl, "100", ddrs_il1, xdr_act),
		(ddrs_idl, "101", ddrs_aut, xdr_aut),
		(ddrs_idl, "110", ddrs_il1, xdr_act),
		(ddrs_idl, "111", ddrs_aut, xdr_aut),

		(ddrs_il1, "000", ddrs_act, xdr_wri),	---------
		(ddrs_il1, "001", ddrs_act, xdr_wriq),	-- IL1 --
		(ddrs_il1, "010", ddrs_act, xdr_rea),	---------
		(ddrs_il1, "011", ddrs_act, xdr_reaq),
		(ddrs_il1, "100", ddrs_act, xdr_wri),
		(ddrs_il1, "101", ddrs_act, xdr_wriq),
		(ddrs_il1, "110", ddrs_act, xdr_rea),
		(ddrs_il1, "111", ddrs_act, xdr_reaq),

		(ddrs_il2, "000", ddrs_aut, xdr_pre),	---------
		(ddrs_il2, "001", ddrs_aut, xdr_preq),	-- IL2 --
		(ddrs_il2, "010", ddrs_aut, xdr_pre),	---------
		(ddrs_il2, "011", ddrs_aut, xdr_preq),
		(ddrs_il2, "100", ddrs_aut, xdr_act),
		(ddrs_il2, "101", ddrs_aut, xdr_act),
		(ddrs_il2, "110", ddrs_aut, xdr_act),
		(ddrs_il2, "111", ddrs_aut, xdr_act),

		(ddrs_aut, "000", ddrs_pre, xdr_prey),	---------
		(ddrs_aut, "001", ddrs_pre, xdr_prey),	-- AUT --
		(ddrs_aut, "010", ddrs_pre, xdr_prey),	---------
		(ddrs_aut, "011", ddrs_pre, xdr_prey),
		(ddrs_aut, "100", ddrs_act, xdr_acty),
		(ddrs_aut, "101", ddrs_act, xdr_acty),
		(ddrs_aut, "110", ddrs_act, xdr_acty),
		(ddrs_aut, "111", ddrs_act, xdr_acty));

end;

architecture non_registered of xdr_pgm is
begin

	xdr_input(2) <= xdr_pgm_ref;
	xdr_input(1) <= xdr_pgm_rw;
	xdr_input(0) <= xdr_pgm_start;

	process (xdr_pgm_clk)
	begin
		if rising_edge(xdr_pgm_clk) then
			if xdr_pgm_rst='0' then
				if xdr_pgm_req='1' then
					xdr_pgm_pc <= pc;
				end if;
			else
				xdr_pgm_pc  <= ddrs_pre;
			end if;
		end if;
	end process;

	xdr_pgm_cmd  <= pgm_cmd;
	xdr_pgm_rdy  <= pgm_rdy;
	sys_pgm_ref  <= sys_ref;
	xdr_pgm_rrdy <= pgm_rrdy;

	process (xdr_pgm_pc, xdr_input)
	begin
		pgm_rdy <= '-'; 
		pgm_rrdy <= '-'; 
		sys_ref <= '-';
		pgm_cmd <= (others => '-');
		pc  <= (others => '-');
		loop_pgm : for i in pgm_tab'range loop
			if xdr_pgm_pc=pgm_tab(i).state then
				if xdr_input=pgm_tab(i).input then
					pc <= pgm_tab(i).state_n; 
					pgm_cmd <= pgm_tab(i).cmd_n(ras downto we);
					pgm_rdy <= pgm_tab(i).cmd_n(rdy);
					sys_ref <= pgm_tab(i).cmd_n(ref);
					pgm_rrdy <= pgm_tab(i).cmd_n(rrdy);
					exit loop_pgm;
				end if;
			end if;
		end loop;
	end process;

end;

architecture registered of xdr_pgm is
begin

	xdr_input(2) <= xdr_pgm_ref;
	xdr_input(1) <= xdr_pgm_rw;
	xdr_input(0) <= xdr_pgm_start;

	process (xdr_pgm_clk)
		variable pgm_pc : std_logic_vector(pc'range);
	begin
		if rising_edge(xdr_pgm_clk) then
			if xdr_pgm_rst='0' then
				xdr_pgm_cmd  <= pgm_cmd;
				xdr_pgm_rdy  <= pgm_rdy;
				sys_pgm_ref  <= sys_ref;
				xdr_pgm_rrdy <= pgm_rrdy;
				if xdr_pgm_req='1' then
					xdr_pgm_pc <= pgm_pc;
				end if;
				pgm_pc := pc;
			else
				pgm_pc := ddrs_pre;
				xdr_pgm_pc <= pgm_pc;
--				xdr_pgm_cmd  <= pgm_cmd;
--				xdr_pgm_rdy  <= pgm_rdy;
--				sys_pgm_ref  <= sys_ref;
--				xdr_pgm_rrdy <= pgm_rrdy;
			end if;
		end if;
	end process;

	process (xdr_pgm_pc, xdr_input)
	begin
		pgm_rdy <= '-'; 
		pgm_rrdy <= '-'; 
		sys_ref <= '-';
		pgm_cmd <= (others => '-');
		pc  <= (others => '-');
		loop_pgm : for i in pgm_tab'range loop
			if xdr_pgm_pc=pgm_tab(i).state then
				if xdr_input=pgm_tab(i).input then
					pc <= pgm_tab(i).state_n; 
					pgm_cmd <= pgm_tab(i).cmd_n(ras downto we);
					pgm_rdy <= pgm_tab(i).cmd_n(rdy);
					sys_ref <= pgm_tab(i).cmd_n(ref);
					pgm_rrdy <= pgm_tab(i).cmd_n(rrdy);
					exit loop_pgm;
				end if;
			end if;
		end loop;
	end process;

end;

