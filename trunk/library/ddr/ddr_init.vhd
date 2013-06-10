library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddr_init is
	generic (
		a    : natural := 13;
		trp  : natural := 10;
		tmrd : natural := 11;
	    trfc : natural := 13);
	port (
		ddr_init_bl  : in  std_logic_vector(0 to 2);
		ddr_init_cl  : in  std_logic_vector(0 to 2);
		ddr_init_clk : in  std_logic;
		ddr_init_req : in  std_logic;
		ddr_init_rdy : out std_logic := '1';
		ddr_init_dll : out std_logic := '1';
		ddr_init_ras : out std_logic := '1';
		ddr_init_cas : out std_logic := '1';
		ddr_init_we  : out std_logic := '1';
		ddr_init_a   : out std_logic_vector(a-1 downto 0) := (others => '1');
		ddr_init_b   : out std_logic_vector  (1 downto 0) := (others => '1'));
end;

architecture def of ddr_init is
	type ddr_init_states is (s_pall1, s_lmr1, s_lmr2, s_pall2, s_auto1, s_auto2, s_lmr3, s_end);

	constant ras : natural := 0;
	constant cas : natural := 1;
	constant rw  : natural := 2;

	constant cmd_nop  : std_logic_vector(0 to 2) := "111";
	constant cmd_auto : std_logic_vector(0 to 2) := "001";
	constant cmd_pre  : std_logic_vector(0 to 2) := "010";
	constant cmd_lmr  : std_logic_vector(0 to 2) := "000";

	constant lat_length : natural := 5;
	type ddr_state_row is record
		ddr_cmd    : std_logic_vector(0 to 2);
		ddr_lat    : signed(0 to lat_length-1);
		ddr_init_b : std_logic_vector(ddr_init_b'range);
	    next_state : ddr_init_states;
	end record;

	type ddr_state_tab is array (ddr_init_states) of ddr_state_row;
	constant ddr_init_tab : ddr_state_tab := (
		s_pall1 => (cmd_pre,  to_signed ( trp-2, lat_length), "00", s_lmr1),
		s_lmr1  => (cmd_lmr,  to_signed (tmrd-2, lat_length), "01", s_lmr2),
		s_lmr2  => (cmd_lmr,  to_signed (tmrd-2, lat_length), "00", s_pall2),
		s_pall2 => (cmd_pre,  to_signed ( trp-2, lat_length), "00", s_auto1),
		s_auto1 => (cmd_auto, to_signed (trfc-2, lat_length), "00", s_auto2),
		s_auto2 => (cmd_auto, to_signed (trfc-2, lat_length), "00", s_lmr3),
		s_lmr3  => (cmd_lmr,  to_signed (tmrd-2, lat_length), "00", s_end),
		s_end   => (cmd_nop, signed'(1 to lat_length => '1'), "11", s_end));

	signal lat_timer  : signed(0 to lat_length-1);
	signal ddr_init_s : ddr_init_states;
begin
	process (ddr_init_clk)
	begin
		if rising_edge(ddr_init_clk) then
			if ddr_init_req='1' then
				if lat_timer(0)='1' then
					lat_timer    <= ddr_init_tab(ddr_init_s).ddr_lat;
					ddr_init_ras <= ddr_init_tab(ddr_init_s).ddr_cmd(ras);
					ddr_init_cas <= ddr_init_tab(ddr_init_s).ddr_cmd(cas);
					ddr_init_we  <= ddr_init_tab(ddr_init_s).ddr_cmd(rw);
					ddr_init_b   <= ddr_init_tab(ddr_init_s).ddr_init_b;

					ddr_init_a <= (others => '0');
					case ddr_init_s is
					when s_lmr2 =>
						ddr_init_a(9-1 downto 0) <= "10" & ddr_init_cl & "0" & ddr_init_bl;
					when s_lmr3 =>
						ddr_init_a(9-1 downto 0) <= "00" & ddr_init_cl & "0" & ddr_init_bl;
					when s_pall1|s_pall2 =>
						ddr_init_a(10) <= '1';
					when s_end =>
						ddr_init_a <= (others => '1');
					when others =>
					end case;

					ddr_init_s <= ddr_init_tab(ddr_init_s).next_state;
					case ddr_init_s is
					when s_end =>
						ddr_init_rdy <= '1';
					when others =>
						ddr_init_rdy <= '0';
					end case;

					if ddr_init_states'pos(ddr_init_s) > ddr_init_states'pos(s_pall2) then
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
				ddr_init_s   <= s_pall1;
				lat_timer    <= (others => '1');
				ddr_init_ras <= '1';
				ddr_init_cas <= '1';
				ddr_init_we  <= '1';
				ddr_init_b   <= (others => '1');
				ddr_init_a   <= (others => '1');
				ddr_init_rdy <= '0';
			end if;
		end if;
	end process;
end;
