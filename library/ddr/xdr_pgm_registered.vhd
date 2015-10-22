architecture registered of xdr_pgm is
	constant ddrs_pact : std_logic_vector(0 to 2) := "110";
	constant ddrs_paut : std_logic_vector(0 to 2) := "111";
	constant ddrs_idl  : std_logic_vector(0 to 2) := "000";

-- pgm_ref   ------+
-- pgm_rw    -----+|
-- pgm_start ----+||
--               |||
--               vvv
--               000    001    010    011    100    101    110    111
--             +------+------+------+------+------+------+------+------+
--     act     | wri  | wriq | rea  | reaq | wri  | wriq | rea  | reaq |
--     pact    | wri  | wriq | rea  | reaq | wri  | wriq | rea  | reaq |
--     rea     | pre  | pre  | pre  | pre  | wri  | wri  | rea  | rea  |
--     wri     | pre  | pre  | pre  | pre  | wri  | wri  | rea  | rea  |
--     pre     | pre  | paut | pre  | paut | pact | paut | pact | paut |
--     idl     | pre  | paut | pre  | paut | pact | paut | pact | paut |
--     paut    | idl  | idl  | idl  | idl  | act  | act  | act  | act  |
--     aut     | idl  | idl  | idl  | idl  | act  | act  | act  | act  |
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

	constant pgm_tab : trans_tab := (
		(ddrs_act, "000", ddrs_wri, xdr_wri),	---------
		(ddrs_act, "001", ddrs_wri, xdr_wriq),	-- ACT --
		(ddrs_act, "010", ddrs_rea, xdr_rea),	---------
		(ddrs_act, "011", ddrs_rea, xdr_reaq),
		(ddrs_act, "100", ddrs_wri, xdr_wri),
		(ddrs_act, "101", ddrs_wri, xdr_wriq),
		(ddrs_act, "110", ddrs_rea, xdr_rea),
		(ddrs_act, "111", ddrs_rea, xdr_reaq),
		
		(ddrs_pact, "000", ddrs_wri, xdr_wri),	---------
		(ddrs_pact, "001", ddrs_wri, xdr_wriq),	-- PACT --
		(ddrs_pact, "010", ddrs_rea, xdr_rea),	---------
		(ddrs_pact, "011", ddrs_rea, xdr_reaq),
		(ddrs_pact, "100", ddrs_wri, xdr_wri),
		(ddrs_pact, "101", ddrs_wri, xdr_wriq),
		(ddrs_pact, "110", ddrs_rea, xdr_rea),
		(ddrs_pact, "111", ddrs_rea, xdr_reaq),
		
		(ddrs_rea, "000", ddrs_pre, xdr_pre),	---------
		(ddrs_rea, "001", ddrs_pre, xdr_preq),	-- REA --
		(ddrs_rea, "010", ddrs_pre, xdr_pre),	---------
		(ddrs_rea, "011", ddrs_pre, xdr_preq),
		(ddrs_rea, "100", ddrs_wri, xdr_wri),
		(ddrs_rea, "101", ddrs_wri, xdr_wriq),
		(ddrs_rea, "110", ddrs_rea, xdr_rea),
		(ddrs_rea, "111", ddrs_rea, xdr_reaq),

		(ddrs_wri, "000", ddrs_pre, xdr_pre),	---------
		(ddrs_wri, "001", ddrs_pre, xdr_preq),	-- WRI --
		(ddrs_wri, "010", ddrs_pre, xdr_pre),	---------
		(ddrs_wri, "011", ddrs_pre, xdr_preq),
		(ddrs_wri, "100", ddrs_wri, xdr_wri),
		(ddrs_wri, "101", ddrs_wri, xdr_wriq),
		(ddrs_wri, "110", ddrs_rea, xdr_rea),
		(ddrs_wri, "111", ddrs_rea, xdr_reaq),

		(ddrs_pre, "000", ddrs_idl, xdr_nop),	---------
		(ddrs_pre, "001", ddrs_aut, xdr_autq),	-- PRE --
		(ddrs_pre, "010", ddrs_idl, xdr_nop),	---------
		(ddrs_pre, "011", ddrs_aut, xdr_autq),
		(ddrs_pre, "100", ddrs_act, xdr_act),
		(ddrs_pre, "101", ddrs_aut, xdr_autq),
		(ddrs_pre, "110", ddrs_act, xdr_act),
		(ddrs_pre, "111", ddrs_aut, xdr_autq),

		(ddrs_idl, "000", ddrs_idl,  xdr_nop),	---------
		(ddrs_idl, "001", ddrs_paut, xdr_autq),	-- IDL --
		(ddrs_idl, "010", ddrs_idl,  xdr_nop),	---------
		(ddrs_idl, "011", ddrs_paut, xdr_autq),
		(ddrs_idl, "100", ddrs_pact, xdr_act),
		(ddrs_idl, "101", ddrs_paut, xdr_autq),
		(ddrs_idl, "110", ddrs_pact, xdr_act),
		(ddrs_idl, "111", ddrs_paut, xdr_autq),

		(ddrs_paut, "000", ddrs_idl, xdr_nopy),	---------
		(ddrs_paut, "001", ddrs_idl, xdr_auty),	-- PAUT --
		(ddrs_paut, "010", ddrs_idl, xdr_nopy),	---------
		(ddrs_paut, "011", ddrs_idl, xdr_auty),
		(ddrs_paut, "100", ddrs_act, xdr_acty),
		(ddrs_paut, "101", ddrs_aut, xdr_auty),
		(ddrs_paut, "110", ddrs_act, xdr_acty),
		(ddrs_paut, "111", ddrs_aut, xdr_auty),

		(ddrs_aut, "000", ddrs_idl, xdr_nopy),	---------
		(ddrs_aut, "001", ddrs_idl, xdr_auty),	-- AUT --
		(ddrs_aut, "010", ddrs_idl, xdr_nopy),	---------
		(ddrs_aut, "011", ddrs_idl, xdr_auty),
		(ddrs_aut, "100", ddrs_act, xdr_acty),
		(ddrs_aut, "101", ddrs_aut, xdr_auty),
		(ddrs_aut, "110", ddrs_act, xdr_acty),
		(ddrs_aut, "111", ddrs_aut, xdr_auty)
	);
	signal ppp : std_logic;
begin

	xdr_input(2) <= xdr_pgm_ref;
	xdr_input(1) <= xdr_pgm_rw;
	xdr_input(0) <= xdr_pgm_start;

	process (xdr_pgm_clk)
	begin
		if rising_edge(xdr_pgm_clk) then
			if xdr_pgm_rst='0' then
				xdr_pgm_cmd  <= pgm_cmd;
				xdr_pgm_rdy  <= pgm_rdy;
				sys_pgm_ref  <= sys_ref;
				xdr_pgm_rrdy <= pgm_rrdy;
				if xdr_pgm_req='1' then
					xdr_pgm_pc  <= pc;
				end if;
				ppp <= pgm_cas;
			else
				ppp <= '0';
				xdr_pgm_pc <= ddrs_pre;
				xdr_pgm_cmd <= "111";
				xdr_pgm_rdy <= '1';
				sys_pgm_ref <= '0';
				xdr_pgm_rrdy <= '0';
			end if;
		end if;
	end process;

	xdr_pgm_cas  <= ppp and xdr_pgm_req;
	process (xdr_pgm_pc, xdr_input)
	begin
		pgm_rdy <= '-'; 
		pgm_rrdy <= '-'; 
		sys_ref <= '-';
		pgm_cmd <= (others => '-');
		pgm_cas <= '-';
		pc  <= (others => '-');
		loop_pgm : for i in pgm_tab'range loop
			if xdr_pgm_pc=pgm_tab(i).state then
				if xdr_input=pgm_tab(i).input then
					pc <= pgm_tab(i).state_n; 
					pgm_cmd <= pgm_tab(i).cmd_n(ras downto we);
					pgm_rdy <= pgm_tab(i).cmd_n(rdy);
					sys_ref <= pgm_tab(i).cmd_n(ref);
					pgm_rrdy <= pgm_tab(i).cmd_n(rrdy);
					pgm_cas <= pgm_tab(i).cmd_n(cacc);
					exit loop_pgm;
				end if;
			end if;
		end loop;
	end process;

end;

