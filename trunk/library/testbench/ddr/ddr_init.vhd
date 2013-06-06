use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

architecture ddr_init of testbench is
	signal ddr_clk : std_logic := '0';
	signal ddr_wait_clk : std_logic := '0';
	signal ddr_rst : std_logic := '0';
	signal ddr_ras : std_logic := '1';
	signal ddr_cas : std_logic := '1';
	signal ddr_we  : std_logic := '1';
	signal ddr_init_rdy : std_logic;
	type str10_vector is array (natural range <>) of string(1 to 7);
	constant ddr_cname : str10_vector(0 to 7) := 
		("DDR_LRM", "DDR_AUT", "DDR_PRE", "DDR_CM3", "DDR_CM4", "DDR_CM5", "DDR_CM6", "DDR_NOP");
begin

--	ddr_rst <= '1', '0' after 23 ns;
	ddr_clk <= not ddr_clk after 5 ns;
	process
		variable msg : line;
		variable step : natural := 0;
	begin
		if rising_edge(ddr_clk) then
			ddr_rst <= '1';
			step := step + 1;

			if std_logic_vector'(ddr_ras&ddr_cas&ddr_we)/="111" and not is_x(std_logic_vector'(ddr_ras&ddr_cas&ddr_we)) then
				write (msg, step);
				write (msg, string'(" : ") & ddr_cname(to_integer(unsigned'(ddr_ras & ddr_cas & ddr_we))));
				write (msg, string'(" : "));
				write (msg, ddr_init_rdy);
				writeline (output, msg);
			end if;
		end if;

		wait on ddr_clk, ddr_rst, ddr_ras, ddr_cas, ddr_we;
	end process;

	du : entity work.ddr_init
	generic map (
		t_rp  => 8,
		t_mrd => 8,
		t_rfc => 8)
	port map (
		ddr_clk => ddr_clk,
		ddr_init_req => ddr_rst,
		ddr_init_rdy => ddr_init_rdy,
		ddr_init_ras => ddr_ras,
		ddr_init_cas => ddr_cas,
		ddr_init_we  => ddr_we);
end;
