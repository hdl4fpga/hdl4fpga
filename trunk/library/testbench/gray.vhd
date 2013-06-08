use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;

architecture gray_cntr of testbench is
	constant n : natural := 8;
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal pl  : std_logic := '0';
	signal qo  : std_logic_vector(0 to n-1);
begin
	rst <= '1', '0' after 13 ns;
	pl  <= '0', '1' after 52 ns, '0' after 60 ns;
	clk <= not clk after 5 ns;

	du : entity hdl4fpga.gray_cntr
	generic map (
		n => n)
	port map (
		rst => rst,
		clk => clk,
		pl  => pl,
		di  => (others => '1'),
		qo  => qo);

	process (qo)
		variable msg : line;
		variable cnt : std_logic_vector(qo'range);
	begin
		write(msg, qo);
		cnt := qo;
		writeline(output, msg);
	end process;
end;
