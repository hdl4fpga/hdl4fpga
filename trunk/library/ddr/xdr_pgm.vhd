library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

entity xdr_pgm is
	port (
		xdr_pgm_rst : in  std_logic := '0';
		xdr_pgm_clk : in  std_logic := '0';
		xdr_pgm_ref : in  std_logic := '0';
		sys_pgm_ref : out std_logic := '0';
		xdr_pgm_start : in  std_logic := '1';
		xdr_pgm_rdy : out std_logic;
		xdr_pgm_req : in  std_logic := '1';
		xdr_pgm_rw  : in  std_logic := '1';
		xdr_pgm_cmd : out std_logic_vector(0 to 2));

--	attribute fsm_encoding : string;
--	attribute fsm_encoding of xdr_pgm : entity is "compact";

end;

architecture arch of xdr_pgm is
	constant rdy : natural := 4;
	constant ref : natural := 3;
	constant ras : natural := 2;
	constant cas : natural := 1;
	constant we  : natural := 0;

	constant xdr_pgm_size : natural := 4;
                        --> sys_pgm_ref <-------------------+
                        --> xdr_pgm_rdy <------------------+|
                        --                                 ||
                        --                                 VV
	constant xdr_act : std_logic_vector(4 downto 0)    := "00011";
	constant xdr_rea : std_logic_vector(xdr_act'range) := "00101";
	constant xdr_wri : std_logic_vector(xdr_act'range) := "00100";
	constant xdr_pre0 : std_logic_vector(xdr_act'range) := "00010";
	constant xdr_pre : std_logic_vector(xdr_act'range) := "10010";
	constant xdr_aut : std_logic_vector(xdr_act'range) := "01001";
	constant xdr_nop : std_logic_vector(xdr_act'range) := "10111";
	constant xdr_dnt : std_logic_vector(xdr_act'range) := (others => '-');

	constant ddrs_act : std_logic_vector(0 to 2) := "011";
	constant ddrs_rea : std_logic_vector(0 to 2) := "101";
	constant ddrs_wri : std_logic_vector(0 to 2) := "100";
	constant ddrs_pre : std_logic_vector(0 to 2) := "010";
	constant ddrs_aut : std_logic_vector(0 to 2) := "001";
	constant ddrs_dnt : std_logic_vector(0 to 2) := (others => '-');

	type trans_row is record
		state   : std_logic_vector(0 to 2);
		input   : std_logic_vector(0 to 2);
		state_n : std_logic_vector(0 to 2);
		cmd_n   : std_logic_vector(xdr_act'range);
	end record;

	type trans_tab is array (natural range <>) of trans_row;

-- pgm_ref   ------+
-- pgm_rw    -----+|
-- pgm_start ----+||
--               |||
--               vvv
--               000   001   010   011   100   101   110   111
--             +-----+-----+-----+-----+-----+-----+-----+-----+
--     act     | '-' | pre | '-' | pre | wri | pre | rea | pre |
--     rea     | pre | pre | pre | pre | '-' | pre | rea | pre |
--     wri     | pre | pre | pre | pre | wri | pre | '-' | pre |
--     pre     | pre | aut | pre | aut | act | aut | act | aut |
--     aut     | pre | pre | pre | pre | act | act | act | act |
--             +-----+-----+-----+-----+-----+-----+-----+-----+

--                           --                 --
--                           -- OUTPUT COMMANDS --
--                           --                 --

--
--               000    001    010    011    100   101    110   111
--             +------+------+------+------+-----+------+-----+------+
--     act     | '-'  | pre  | '-'  | pre  | wri | pre  | rea | pre  |
--     rea     | pre0 | pre0 | pre0 | pre0 | '-' | pre0 | rea | pre0 |
--     wri     | pre0 | pre0 | pre0 | pre0 | wri | pre0 | '-' | pre0 |
--     pre     | nop  | aut  | nop  | aut  | act | aut  | act | aut  |
--     aut     | pre  | pre  | pre  | pre  | act | act  | act | act  |
--             +------+------+------+------+-----+------+-----+------+


	constant pgm_tab : trans_tab := (
		(ddrs_act, "000", ddrs_dnt, xdr_dnt),	---------
		(ddrs_act, "001", ddrs_pre, xdr_pre),	-- ACT --
		(ddrs_act, "010", ddrs_dnt, xdr_dnt),	---------
		(ddrs_act, "011", ddrs_pre, xdr_pre),
		(ddrs_act, "100", ddrs_wri, xdr_wri),
		(ddrs_act, "101", ddrs_pre, xdr_pre),
		(ddrs_act, "110", ddrs_rea, xdr_rea),
		(ddrs_act, "111", ddrs_pre, xdr_pre),
		
		(ddrs_rea, "000", ddrs_pre, xdr_pre0),	---------
		(ddrs_rea, "001", ddrs_pre, xdr_pre0),	-- REA --
		(ddrs_rea, "010", ddrs_pre, xdr_pre0),	---------
		(ddrs_rea, "011", ddrs_pre, xdr_pre0),
		(ddrs_rea, "100", ddrs_dnt, xdr_wri),
		(ddrs_rea, "101", ddrs_pre, xdr_pre0),
		(ddrs_rea, "110", ddrs_rea, xdr_rea),
		(ddrs_rea, "111", ddrs_pre, xdr_pre0),

		(ddrs_wri, "000", ddrs_pre, xdr_pre0),	---------
		(ddrs_wri, "001", ddrs_pre, xdr_pre0),	-- WRI --
		(ddrs_wri, "010", ddrs_pre, xdr_pre0),	---------
		(ddrs_wri, "011", ddrs_pre, xdr_pre0),
		(ddrs_wri, "100", ddrs_wri, xdr_wri),
		(ddrs_wri, "101", ddrs_pre, xdr_pre0),
		(ddrs_wri, "110", ddrs_dnt, xdr_dnt),
		(ddrs_wri, "111", ddrs_pre, xdr_pre0),

		(ddrs_pre, "000", ddrs_pre, xdr_nop),	---------
		(ddrs_pre, "001", ddrs_aut, xdr_aut),	-- PRE --
		(ddrs_pre, "010", ddrs_pre, xdr_nop),	---------
		(ddrs_pre, "011", ddrs_aut, xdr_aut),
		(ddrs_pre, "100", ddrs_act, xdr_act),
		(ddrs_pre, "101", ddrs_aut, xdr_aut),
		(ddrs_pre, "110", ddrs_act, xdr_act),
		(ddrs_pre, "111", ddrs_aut, xdr_aut),

		(ddrs_aut, "000", ddrs_pre, xdr_pre),	---------
		(ddrs_aut, "001", ddrs_pre, xdr_pre),	-- AUT --
		(ddrs_aut, "010", ddrs_pre, xdr_pre),	---------
		(ddrs_aut, "011", ddrs_pre, xdr_pre),
		(ddrs_aut, "100", ddrs_act, xdr_act),
		(ddrs_aut, "101", ddrs_act, xdr_act),
		(ddrs_aut, "110", ddrs_act, xdr_act),
		(ddrs_aut, "111", ddrs_act, xdr_act));

	signal xdr_pgm_pc : std_logic_vector(ddrs_act'range);
	signal xdr_input  : std_logic_vector(0 to 2);

begin

	xdr_input(2) <= xdr_pgm_ref;
	xdr_input(1) <= xdr_pgm_rw;
	xdr_input(0) <= xdr_pgm_start;

	process (xdr_pgm_clk)
		variable pc : std_logic_vector(xdr_pgm_pc'range);
	begin
		if rising_edge(xdr_pgm_clk) then
			if xdr_pgm_rst='0' then
				pc  := (others => '-');
				xdr_pgm_rdy <= '-'; 
				sys_pgm_ref <= '-';
				loop_pgm : for i in pgm_tab'range loop
					if xdr_pgm_pc=pgm_tab(i).state then
						if xdr_input=pgm_tab(i).input then
							pc := pgm_tab(i).state_n; 
							xdr_pgm_cmd <= pgm_tab(i).cmd_n(ras downto we);
							xdr_pgm_rdy <= pgm_tab(i).cmd_n(rdy);
							sys_pgm_ref <= pgm_tab(i).cmd_n(ref);
							exit loop_pgm;
						end if;
					end if;
				end loop;
				if xdr_pgm_req='1' then
					xdr_pgm_pc <= pc;
				end if;
			else
				xdr_pgm_pc  <= ddrs_pre;
				xdr_pgm_cmd <= xdr_nop(ras downto we);
				xdr_pgm_rdy <= xdr_nop(rdy);
				sys_pgm_ref <= xdr_nop(ref);
			end if;
		end if;
	end process;
end;
