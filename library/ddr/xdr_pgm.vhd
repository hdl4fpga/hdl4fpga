library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
		xdr_pgm_cas : out std_logic;
		xdr_pgm_pre : out std_logic;
		xdr_pgm_cmd : out std_logic_vector(0 to 2));
--	attribute fsm_encoding : string;
--	attribute fsm_encoding of xdr_pgm : entity is "compact";
end;

architecture arch of xdr_pgm is
	constant ras : natural := 0;
	constant cas : natural := 1;
	constant we  : natural := 2;
	constant n   : natural := 2;

	constant xdr_pgm_size : natural := 4;

	constant xdr_nop   : std_logic_vector(0 to 2) := "111";
	constant xdr_act   : std_logic_vector(0 to 2) := "011";
	constant xdr_read  : std_logic_vector(0 to 2) := "101";
	constant xdr_write : std_logic_vector(0 to 2) := "100";
	constant xdr_pre   : std_logic_vector(0 to 2) := "010";
	constant xdr_aut   : std_logic_vector(0 to 2) := "001";

	type xdr_states is (
		ddrs_act, ddrs_read, ddrs_write, ddrs_pre,
		ddrs_aut, ddrs_nop);
	type xdr_states_row is array (xdr_states) of xdr_states;
	type xdr_table_row is record
		xdr_cmd : std_logic_vector(xdr_pgm_cmd'range);
	end record;

	type xdr_tran_tab is array (xdr_states) of xdr_table_row;

	constant xdr_pgm1 : xdr_tran_tab := (
		(xdr_cmd => xdr_act),
		(xdr_cmd => xdr_read),
		(xdr_cmd => xdr_write),
		(xdr_cmd => xdr_pre),
		(xdr_cmd => xdr_aut),
		(xdr_cmd => xdr_nop));

	signal xdr_mpu_pc  : xdr_states;
	signal xdr_pgm_pc  : xdr_states;
	signal xdr_pgm_npc : xdr_states;
	signal xdr_ref_req : std_logic;
	signal xdr_start   : std_logic;

	signal xdr_npc_act : xdr_states;
	signal xdr_npc_rea : xdr_states;
	signal xdr_npc_wri : xdr_states;
	signal xdr_npc_pre : xdr_states;
	signal xdr_npc_nop : xdr_states;
	signal xdr_npc_aut : xdr_states;

	signal xdr_npc_act_d : xdr_states;
	signal xdr_npc_rea_d : xdr_states;
	signal xdr_npc_wri_d : xdr_states;
	signal xdr_npc_pre_d : xdr_states;
	signal xdr_npc_nop_d : xdr_states;
	signal xdr_npc_aut_d : xdr_states;
begin
	xdr_npc_act_d <=
		ddrs_read  when xdr_pgm_rw='1' else
		ddrs_write;

	xdr_npc_rea_d <=
		xdr_mpu_pc when xdr_pgm_start='1' else
		ddrs_pre;

	xdr_npc_wri_d <=
		xdr_mpu_pc when xdr_pgm_start='1' else
		ddrs_pre;

	xdr_npc_pre_d <= 
		ddrs_aut when xdr_ref_req='1' else
		ddrs_act when xdr_start='1' or xdr_pgm_start='1' else
		ddrs_nop;

	xdr_npc_nop_d <= 
		ddrs_aut when xdr_ref_req='1' else
		ddrs_act when xdr_start='1' or xdr_pgm_start='1' else
		ddrs_nop;

	xdr_npc_aut_d <= 
		ddrs_aut when xdr_ref_req='1' else
		ddrs_act when xdr_start='1' else
		ddrs_nop;

	process (xdr_pgm_clk)
	begin
		if rising_edge(xdr_pgm_clk) then
			xdr_npc_act <= xdr_npc_act_d;
			xdr_npc_rea <= xdr_npc_rea_d;
			xdr_npc_wri <= xdr_npc_wri_d;
			xdr_npc_pre <= xdr_npc_pre_d;
			xdr_npc_nop <= xdr_npc_nop_d;
			xdr_npc_aut <= xdr_npc_aut_d;
		end if;
	end process;

	with xdr_mpu_pc select
	xdr_pgm_npc <=
   		xdr_npc_act when ddrs_act,
   		xdr_npc_pre when ddrs_pre,
		xdr_npc_rea when ddrs_read,
		xdr_npc_wri when ddrs_write,
   		xdr_npc_nop when ddrs_nop,
   		xdr_npc_aut when ddrs_aut;

	process (xdr_pgm_clk)
	begin
		if rising_edge(xdr_pgm_clk) then
			xdr_pgm_cmd <= xdr_pgm1(xdr_pgm_npc).xdr_cmd;
			if xdr_pgm_rst='0' then
				xdr_pgm_pc  <= xdr_pgm_npc;
				if xdr_pgm_req='1'then
					xdr_mpu_pc <= xdr_pgm_pc;
					case xdr_pgm_pc is
					when ddrs_act =>
						xdr_start   <= '0';
						xdr_pgm_rdy <= '0';
						xdr_ref_req <= xdr_pgm_ref or xdr_ref_req;
						sys_pgm_ref <= '0';
						xdr_pgm_cas <= '0';
						xdr_pgm_pre <= '0';
					when ddrs_read | ddrs_write =>
						xdr_start   <= '0';
						xdr_pgm_rdy <= '0';
						xdr_ref_req <= xdr_pgm_ref or xdr_ref_req;
						sys_pgm_ref <= '0';
						xdr_pgm_cas <= '1';
						xdr_pgm_pre <= '0';
					when ddrs_pre =>
						xdr_start   <= '0';
						xdr_pgm_rdy <= '0';
						xdr_ref_req <= xdr_pgm_ref or xdr_ref_req;
						sys_pgm_ref <= '0';
						xdr_pgm_cas <= '0';
						xdr_pgm_pre <= '1';
					when ddrs_nop =>
						xdr_start   <= xdr_pgm_start;
						xdr_pgm_rdy <= not xdr_ref_req and not xdr_pgm_start and not xdr_start;
						xdr_ref_req <= xdr_pgm_ref or xdr_ref_req;
						sys_pgm_ref <= '0';
						xdr_pgm_cas <= '0';
						xdr_pgm_pre <= '0';
					when ddrs_aut =>
						xdr_start   <= xdr_pgm_start;
						xdr_pgm_rdy <= not xdr_ref_req and not xdr_pgm_start;
						xdr_ref_req <= xdr_pgm_ref;
						sys_pgm_ref <= '1';
						xdr_pgm_cas <= '0';
						xdr_pgm_pre <= '0';
					end case;
				else
					case xdr_mpu_pc is
					when ddrs_act =>
						xdr_start   <= '0';
						xdr_pgm_rdy <= '0';
						xdr_ref_req <= xdr_pgm_ref or xdr_ref_req;
						sys_pgm_ref <= '0';
					when ddrs_read | ddrs_write =>
						xdr_start   <= '0';
						xdr_pgm_rdy <= '0';
						xdr_ref_req <= xdr_pgm_ref or xdr_ref_req;
						sys_pgm_ref <= '0';
					when ddrs_pre =>
						xdr_start   <= '0';
						xdr_pgm_rdy <= '0';
						xdr_ref_req <= xdr_pgm_ref or xdr_ref_req;
						sys_pgm_ref <= '0';
					when ddrs_nop =>
						report "Invalid state" severity failure;
						xdr_start   <= '-';
						xdr_pgm_rdy <= '-';
						xdr_ref_req <= '-';
						sys_pgm_ref <= '-';
					when ddrs_aut =>
						xdr_start   <= xdr_pgm_start;
						xdr_ref_req <= xdr_pgm_ref;
						sys_pgm_ref <= '0';
					end case;
					xdr_pgm_cas <= '0';
					xdr_pgm_pre <= '0';
				end if;
			else
				xdr_pgm_pc  <= ddrs_nop;
				xdr_mpu_pc  <= ddrs_nop;
				xdr_pgm_rdy <= '1';
				xdr_pgm_cas <= '0';
				xdr_pgm_pre <= '0';
				xdr_ref_req <= '0';
				xdr_start   <= '0';
				sys_pgm_ref <= '0';
			end if;
		end if;
	end process;
end;
