library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddr_pgm is
	port (
		ddr_pgm_rst : in  std_logic := '0';
		ddr_pgm_clk : in  std_logic := '0';
		ddr_pgm_ref : in  std_logic := '0';
		sys_pgm_ref : out std_logic := '0';
		ddr_pgm_start : in  std_logic := '1';
		ddr_pgm_rdy : out std_logic;
		ddr_pgm_req : in  std_logic := '1';
		ddr_pgm_rw  : in  std_logic := '1';
		ddr_pgm_cas : out std_logic;
		ddr_pgm_pre : out std_logic;
		ddr_pgm_cmd : out std_logic_vector(0 to 2));
end;

architecture arch of ddr_pgm is
	constant ras : natural := 0;
	constant cas : natural := 1;
	constant we  : natural := 2;
	constant n   : natural := 2;

	constant ddr_pgm_size : natural := 4;

	constant ddr_nop   : std_logic_vector(0 to 2) := "111";
	constant ddr_act   : std_logic_vector(0 to 2) := "011";
	constant ddr_read  : std_logic_vector(0 to 2) := "101";
	constant ddr_write : std_logic_vector(0 to 2) := "100";
	constant ddr_pre   : std_logic_vector(0 to 2) := "010";
	constant ddr_aut   : std_logic_vector(0 to 2) := "001";

	type ddr_states is (
		ddrs_act, ddrs_read, ddrs_write, ddrs_pre,
		ddrs_aut, ddrs_nop);
	type ddr_states_row is array (ddr_states) of ddr_states;
	type ddr_table_row is record
		ddr_cmd : std_logic_vector(ddr_pgm_cmd'range);
	end record;

	type ddr_tran_tab is array (ddr_states) of ddr_table_row;

	constant ddr_pgm1 : ddr_tran_tab := (
		(ddr_cmd => ddr_act),
		(ddr_cmd => ddr_read),
		(ddr_cmd => ddr_write),
		(ddr_cmd => ddr_pre),
		(ddr_cmd => ddr_aut),
		(ddr_cmd => ddr_nop));

	signal ddr_mpu_pc  : ddr_states;
	signal ddr_pgm_pc  : ddr_states;
	signal ddr_pgm_npc : ddr_states;
	signal ddr_ref_req : std_logic;
	signal ddr_start   : std_logic;

	signal ddr_npc_act : ddr_states;
	signal ddr_npc_rea : ddr_states;
	signal ddr_npc_wri : ddr_states;
	signal ddr_npc_pre : ddr_states;
	signal ddr_npc_nop : ddr_states;
	signal ddr_npc_aut : ddr_states;

	signal ddr_npc_act_d : ddr_states;
	signal ddr_npc_rea_d : ddr_states;
	signal ddr_npc_wri_d : ddr_states;
	signal ddr_npc_pre_d : ddr_states;
	signal ddr_npc_nop_d : ddr_states;
	signal ddr_npc_aut_d : ddr_states;
begin
	ddr_npc_act_d <=
		ddrs_read  when ddr_pgm_rw='1' else
		ddrs_write;

	ddr_npc_rea_d <=
		ddr_mpu_pc when ddr_pgm_start='1' else
		ddrs_pre;

	ddr_npc_wri_d <=
		ddr_mpu_pc when ddr_pgm_start='1' else
		ddrs_pre;

	ddr_npc_pre_d <= 
		ddrs_aut when ddr_ref_req='1' else
		ddrs_act when ddr_start='1' or ddr_pgm_start='1' else
		ddrs_nop;

	ddr_npc_nop_d <= 
		ddrs_aut when ddr_ref_req='1' else
		ddrs_act when ddr_start='1' or ddr_pgm_start='1' else
		ddrs_nop;

	ddr_npc_aut_d <= 
		ddrs_aut when ddr_ref_req='1' else
		ddrs_act when ddr_start='1' else
		ddrs_nop;

	process (ddr_pgm_clk)
	begin
		if rising_edge(ddr_pgm_clk) then
			ddr_npc_act <= ddr_npc_act_d;
			ddr_npc_rea <= ddr_npc_rea_d;
			ddr_npc_wri <= ddr_npc_wri_d;
			ddr_npc_pre <= ddr_npc_pre_d;
			ddr_npc_nop <= ddr_npc_nop_d;
			ddr_npc_aut <= ddr_npc_aut_d;
		end if;
	end process;

	with ddr_mpu_pc select
	ddr_pgm_npc <=
   		ddr_npc_act when ddrs_act,
   		ddr_npc_pre when ddrs_pre,
		ddr_npc_rea when ddrs_read,
		ddr_npc_wri when ddrs_write,
   		ddr_npc_nop when ddrs_nop,
   		ddr_npc_aut when ddrs_aut;

	process (ddr_pgm_clk)
	begin
		if rising_edge(ddr_pgm_clk) then
			ddr_pgm_cmd <= ddr_pgm1(ddr_pgm_npc).ddr_cmd;
			if ddr_pgm_rst='0' then
				ddr_pgm_pc  <= ddr_pgm_npc;
				if ddr_pgm_req='1'then
					ddr_mpu_pc <= ddr_pgm_pc;
					case ddr_pgm_pc is
					when ddrs_act =>
						ddr_start   <= '0';
						ddr_pgm_rdy <= '0';
						ddr_ref_req <= ddr_pgm_ref or ddr_ref_req;
						sys_pgm_ref <= '0';
						ddr_pgm_cas <= '0';
						ddr_pgm_pre <= '0';
					when ddrs_read | ddrs_write =>
						ddr_start   <= '0';
						ddr_pgm_rdy <= '0';
						ddr_ref_req <= ddr_pgm_ref or ddr_ref_req;
						sys_pgm_ref <= '0';
						ddr_pgm_cas <= '1';
						ddr_pgm_pre <= '0';
					when ddrs_pre =>
						ddr_start   <= '0';
						ddr_pgm_rdy <= '0';
						ddr_ref_req <= ddr_pgm_ref or ddr_ref_req;
						sys_pgm_ref <= '0';
						ddr_pgm_cas <= '0';
						ddr_pgm_pre <= '1';
					when ddrs_nop =>
						ddr_start   <= ddr_pgm_start;
						ddr_pgm_rdy <= not ddr_ref_req and not ddr_pgm_start and not ddr_start;
						ddr_ref_req <= ddr_pgm_ref or ddr_ref_req;
						sys_pgm_ref <= '0';
						ddr_pgm_cas <= '0';
						ddr_pgm_pre <= '0';
					when ddrs_aut =>
						ddr_start   <= ddr_pgm_start;
						ddr_pgm_rdy <= not ddr_ref_req and not ddr_pgm_start;
						ddr_ref_req <= ddr_pgm_ref;
						sys_pgm_ref <= '1';
						ddr_pgm_cas <= '0';
						ddr_pgm_pre <= '0';
					end case;
				else
					case ddr_mpu_pc is
					when ddrs_act =>
						ddr_start   <= '0';
						ddr_pgm_rdy <= '0';
						ddr_ref_req <= ddr_pgm_ref or ddr_ref_req;
						sys_pgm_ref <= '0';
					when ddrs_read | ddrs_write =>
						ddr_start   <= '0';
						ddr_pgm_rdy <= '0';
						ddr_ref_req <= ddr_pgm_ref or ddr_ref_req;
						sys_pgm_ref <= '0';
					when ddrs_pre =>
						ddr_start   <= '0';
						ddr_pgm_rdy <= '0';
						ddr_ref_req <= ddr_pgm_ref or ddr_ref_req;
						sys_pgm_ref <= '0';
					when ddrs_nop =>
						report "Invalid state" severity failure;
						ddr_start   <= '-';
						ddr_pgm_rdy <= '-';
						ddr_ref_req <= '-';
						sys_pgm_ref <= '-';
					when ddrs_aut =>
						ddr_start   <= ddr_pgm_start;
						ddr_ref_req <= ddr_pgm_ref;
						sys_pgm_ref <= '0';
					end case;
					ddr_pgm_cas <= '0';
					ddr_pgm_pre <= '0';
				end if;
			else
				ddr_pgm_pc  <= ddrs_nop;
				ddr_mpu_pc  <= ddrs_nop;
				ddr_pgm_rdy <= '1';
				ddr_pgm_cas <= '0';
				ddr_pgm_pre <= '0';
				ddr_ref_req <= '0';
				ddr_start   <= '0';
				sys_pgm_ref <= '0';
			end if;
		end if;
	end process;
end;
